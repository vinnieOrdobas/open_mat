# frozen_string_literal: true

RSpec.describe Api::V1::OrderLineItemsController, type: :controller do
  describe 'PATCH #update' do
    subject(:do_action) { patch :update, params: request_params }

    let!(:owner) { create(:user, :owner) }
    let!(:other_owner) { create(:user, :owner) }
    let!(:student) { create(:user, id: 999) } # The buyer (for authorization test)

    let!(:academy) { create(:academy, user: owner) }
    let!(:pass) { create(:pass, academy: academy) }
    let!(:order) { create(:order, user: student) }
    let!(:line_item) { create(:order_line_item, order: order, pass: pass, status: 'pending_approval') }

    let(:owner_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: owner.id)}" } }
    let(:other_owner_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: other_owner.id)}" } }
    let(:student_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: student.id)}" } }

    let(:update_params) { { status: 'approved' } }
    let(:request_params) { { id: line_item.id, order_line_item: update_params } }
    let(:permitted_params) { ActionController::Parameters.new(update_params).permit! } # Simplified stub

    let(:mock_update_service) { instance_double(OrderLineItems::UpdateStatus) }
    let(:mock_serializer) { instance_double(OrderLineItemSerializer) }

    context 'when authenticated as the correct academy owner' do
      let(:expected_hash) { { id: line_item.id, status: 'approved' } }

      before do
        request.headers.merge!(owner_headers)
        allow(OrderLineItems::UpdateStatus).to receive(:new).with(line_item: line_item, new_status: 'approved').and_return(mock_update_service)
        allow(mock_update_service).to receive(:perform).and_return({ success: true, line_item: line_item.tap { |li| li.status = 'approved' } })

        allow(OrderLineItemSerializer).to receive(:new).with(an_instance_of(OrderLineItem)).and_return(mock_serializer)
        allow(mock_serializer).to receive(:as_json).and_return(expected_hash.to_json)
      end

      it 'calls the UpdateStatus service with the correct params' do
        do_action
        expect(OrderLineItems::UpdateStatus).to have_received(:new).with(line_item: line_item, new_status: 'approved')
        expect(mock_update_service).to have_received(:perform)
      end

      it 'returns an :ok (200) status and the updated line item' do
        do_action
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq(expected_hash.to_json)
      end

      context 'when the service fails (e.g., invalid transition)' do
        before do
          allow(mock_update_service).to receive(:perform).and_return({ success: false, errors: errors })
        end

        let(:errors) { [ "Cannot transition from 'pending_approval' to 'shipped'" ] }

        it 'returns an :unprocessable_entity (422) status and the errors' do
          do_action

          json_response = JSON.parse(response.body).deep_symbolize_keys
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response[:errors]).to match(errors)
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

    context 'when authenticated as the student who placed the order' do
      before { request.headers.merge!(student_headers) }
      it 'returns :unauthorized (401)' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the line item does not exist' do
      let(:request_params) { { id: 'invalid', order_line_item: update_params } }
      before { request.headers.merge!(owner_headers) } # Still need auth

      it 'returns a :not_found (44) status' do
        do_action
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
