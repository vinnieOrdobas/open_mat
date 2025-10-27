# frozen_string_literal: true

RSpec.describe Api::V1::PassesController, type: :controller do
  let!(:owner) { create(:user, :owner) }
  let!(:other_owner) { create(:user, :owner) }
  let!(:student) { create(:user) }

  let!(:academy) { create(:academy, user: owner) }
  let!(:other_academy) { create(:academy, user: other_owner) }

  let!(:pass) { create(:pass, academy: academy, name: 'Old Name') }

  let(:owner_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: owner.id)}" } }
  let(:other_owner_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: other_owner.id)}" } }
  let(:student_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: student.id)}" } }

  describe 'POST #create' do
    subject(:do_action) { post :create, params: request_params }

    let(:valid_pass_params) { { name: 'New Day Pass', price_cents: '3000', pass_type: 'day_pass' } }
    let(:request_params) { { academy_id: academy.id, pass: valid_pass_params } }
    let(:permitted_params) do
      ActionController::Parameters.new(valid_pass_params).permit(
        :name, :description, :price_cents, :pass_type, :currency, :class_credits, :is_active
      )
    end

    let(:mock_create_service) { instance_double(Passes::CreatePass) }
    let(:mock_pass) { instance_double(Pass, id: 2) }
    let(:mock_serializer) { instance_double(PassSerializer) }

    context 'when authenticated as the academy owner' do
      let(:expected_hash) { { id: 2, name: 'New Day Pass' } }

      before do
        request.headers.merge!(owner_headers)
        allow(Passes::CreatePass).to receive(:new).with(academy, permitted_params).and_return(mock_create_service)
        allow(mock_create_service).to receive(:perform).and_return({ success: true, pass: mock_pass })
        allow(PassSerializer).to receive(:new).with(mock_pass).and_return(mock_serializer)
        allow(mock_serializer).to receive(:as_json).and_return(expected_hash.to_json)
      end

      it 'calls the CreatePass service' do
        do_action
        expect(Passes::CreatePass).to have_received(:new).with(academy, permitted_params)
        expect(mock_create_service).to have_received(:perform)
      end

      it 'returns a :created (201) status' do
        do_action
        expect(response).to have_http_status(:created)
      end
    end

    context 'when authenticated as a different owner' do
      before { request.headers.merge!(other_owner_headers) }
      it 'returns :unauthorized (401)' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with no authentication' do
      it 'returns :unauthorized (401)' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH #update' do
    subject(:do_action) { patch :update, params: request_params }

    let(:update_params) { { name: 'Updated Pass Name' } }
    let(:request_params) { { academy_id: academy.id, id: pass.id, pass: update_params } }
    let(:permitted_params) { ActionController::Parameters.new(update_params).permit! }

    let(:mock_update_service) { instance_double(Passes::UpdatePass) }
    let(:mock_serializer) { instance_double(PassSerializer) }

    context 'when authenticated as the academy owner' do
      let(:expected_hash) { { id: pass.id, name: 'Updated Pass Name' } }

      before do
        request.headers.merge!(owner_headers)
        allow(Passes::UpdatePass).to receive(:new).with(pass, permitted_params).and_return(mock_update_service)
        allow(mock_update_service).to receive(:perform).and_return({ success: true, pass: pass.tap { |p| p.name = 'Updated Pass Name' } })
        allow(PassSerializer).to receive(:new).with(an_instance_of(Pass)).and_return(mock_serializer)
        allow(mock_serializer).to receive(:as_json).and_return(expected_hash.to_json)
      end

      it 'calls the UpdatePass service' do
        do_action
        expect(Passes::UpdatePass).to have_received(:new).with(pass, permitted_params)
        expect(mock_update_service).to have_received(:perform)
      end

      it 'returns an :ok (200) status and the updated pass' do
        do_action
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq(expected_hash.to_json)
      end

      context 'when the pass ID belongs to a different academy' do
        let!(:other_pass) { create(:pass, academy: other_academy) }
        let(:request_params) { { academy_id: academy.id, id: other_pass.id, pass: update_params } }

        it 'returns a :not_found (404) status' do
          do_action
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when authenticated as a different owner' do
      before { request.headers.merge!(other_owner_headers) }

      it 'returns :unauthorized (401)' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE #destroy' do
    subject(:do_action) { delete :destroy, params: request_params }

    let!(:pass_to_delete) { create(:pass, academy: academy) }
    let(:request_params) { { academy_id: academy.id, id: pass_to_delete.id } }

    context 'when authenticated as the academy owner' do
      before { request.headers.merge!(owner_headers) }

      it 'destroys the pass' do
        expect { do_action }.to change(Pass, :count).by(-1)
      end

      it 'returns a :no_content (204) status' do
        do_action
        expect(response).to have_http_status(:no_content)
      end

      context 'when the pass ID does not exist for this academy' do
        let(:request_params) { { academy_id: academy.id, id: 'invalid' } }

        it 'returns a :not_found (404) status' do
          do_action
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when authenticated as a different owner' do
      before { request.headers.merge!(other_owner_headers) }

      it 'does not destroy the pass' do
        expect { do_action }.not_to change(Pass, :count)
      end

      it 'returns :unauthorized (401)' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
