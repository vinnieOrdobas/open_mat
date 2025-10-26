# frozen_string_literal: true

RSpec.describe Api::V1::AcademiesController, type: :controller do
  describe 'POST #create' do
    subject(:do_action) { post :create, params: request_params }

    let(:valid_academy_params) do
      {
        name: 'Gracie Barra Anytown',
        email: 'info@gbanytown.com',
        street_address: '123 Mat St',
        city: 'Anytown',
        country: 'USA'
      }
    end
    let(:request_params) { { academy: valid_academy_params } }

    let(:permitted_params) do
      ActionController::Parameters.new(valid_academy_params).permit(
        :name, :email, :phone_number, :website, :description, :street_address,
        :city, :state_province, :postal_code, :country, :latitude, :longitude
      )
    end

    let(:mock_create_service) { instance_double(Academies::CreateAcademy) }
    let(:mock_academy) { instance_double(Academy, id: 1) }
    let(:mock_serializer) { instance_double(AcademySerializer) }

    let!(:owner_user) { create(:user, :owner) }
    let!(:student_user) { create(:user, role: 'student') }
    let(:owner_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: owner_user.id)}" } }
    let(:student_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: student_user.id)}" } }

    context 'with an authenticated owner user' do
      let(:expected_hash) { { id: 1, name: 'Gracie Barra Anytown' } }

      before do
        request.headers.merge!(owner_headers)
        allow(Academies::CreateAcademy).to receive(:new).with(owner_user, permitted_params).and_return(mock_create_service)
        allow(mock_create_service).to receive(:perform).and_return({ success: true, academy: mock_academy })
        allow(AcademySerializer).to receive(:new).with(mock_academy).and_return(mock_serializer)
        allow(mock_serializer).to receive(:as_json).and_return(expected_hash.to_json)
      end

      it 'calls the CreateAcademy service' do
        do_action
        expect(Academies::CreateAcademy).to have_received(:new).with(owner_user, permitted_params)
        expect(mock_create_service).to have_received(:perform)
      end

      it 'calls the AcademySerializer' do
        do_action
        expect(AcademySerializer).to have_received(:new).with(mock_academy)
      end

      it 'returns a :created (201) status and the new academy' do
        do_action
        expect(response).to have_http_status(:created)
        expect(response.body).to eq(expected_hash.to_json)
      end

      context 'when the service fails (e.g., validation error)' do
        let(:errors) { [ "Name can't be blank" ] }

        before do
          allow(mock_create_service).to receive(:perform).and_return({ success: false, errors: errors })
        end

        it 'does not call the serializer' do
          do_action
          expect(AcademySerializer).not_to have_received(:new)
        end

        it 'returns an :unprocessable_entity (422) status and the errors' do
          do_action
          json_response = JSON.parse(response.body).deep_symbolize_keys
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response[:errors]).to match(errors)
        end
      end
    end

    context 'with an authenticated user who is NOT an owner' do
      before do
        request.headers.merge!(student_headers)
        allow(Academies::CreateAcademy).to receive(:new)
      end

      it 'does NOT call the CreateAcademy service' do
        do_action
        expect(Academies::CreateAcademy).not_to have_received(:new)
      end

      it 'returns an :unauthorized (401) status' do
        do_action
        json_response = JSON.parse(response.body).deep_symbolize_keys
        expect(response).to have_http_status(:unauthorized)
        expect(json_response[:error]).to eq('Not Authorized')
      end
    end

    context 'with no authenticated user (missing token)' do
      before { allow(Academies::CreateAcademy).to receive(:new) }

      it 'does NOT call the CreateAcademy service' do
        do_action
        expect(Academies::CreateAcademy).not_to have_received(:new)
      end

      it 'returns an :unauthorized (401) status' do
        do_action
        json_response = JSON.parse(response.body).deep_symbolize_keys
        expect(response).to have_http_status(:unauthorized)
        expect(json_response[:error]).to eq('Not Authorized')
      end
    end
  end
end
