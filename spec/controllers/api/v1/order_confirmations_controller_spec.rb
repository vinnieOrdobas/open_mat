# frozen_string_literal: true

RSpec.describe Api::V1::OrderConfirmationsController, type: :controller do
  describe 'POST #create' do
    subject(:do_action) { post :create, params: { order_id: order.id } }

    let!(:student) { create(:user, role: 'student') } # The order owner
    let!(:other_user) { create(:user, role: 'student') }

    let!(:order) { create(:order, user: student, status: 'awaiting_approvals') }

    let(:student_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: student.id)}" } }
    let(:other_user_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: other_user.id)}" } }

    let(:mock_payment_service) { instance_double(Payments::ProcessMockPayment) }
    let(:real_payment) { build_stubbed(:payment, order: order, status: 'succeeded') }

    context 'when authenticated as the order owner' do
      before do
        request.headers.merge!(student_headers)
        allow(Payments::ProcessMockPayment).to receive(:new).with(order: order).and_return(mock_payment_service)
      end

      context 'and the payment service succeeds' do
        let(:expected_json) { PaymentSerializer.new(real_payment).as_json.to_json }

        before do
          allow(mock_payment_service).to receive(:perform).and_return({ success: true, payment: real_payment })
        end

        it 'calls the ProcessMockPayment service' do
          do_action
          expect(Payments::ProcessMockPayment).to have_received(:new).with(order: order)
          expect(mock_payment_service).to have_received(:perform)
        end

        it 'returns a :created (201) status and the payment JSON' do
          do_action

          expect(response).to have_http_status(:created)
          expect(response.body).to eq(expected_json)
        end
      end

      context 'and the payment service fails (e.g., items not approved)' do
        let(:errors) { [ "Not all line items have been approved" ] }

        before do
          allow(mock_payment_service).to receive(:perform).and_return({ success: false, errors: errors })
        end

        it 'calls the ProcessMockPayment service' do
          do_action

          expect(mock_payment_service).to have_received(:perform)
        end

        it 'returns an :unprocessable_entity (422) status and the errors' do
          do_action

          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body).deep_symbolize_keys
          expect(json_response[:errors]).to match(errors)
        end
      end
    end

    context 'when authenticated as a different user' do
      before do
        request.headers.merge!(other_user_headers)
        allow(Payments::ProcessMockPayment).to receive(:new)
      end

      it 'does NOT call the ProcessMockPayment service' do
        do_action
        expect(Payments::ProcessMockPayment).not_to have_received(:new)
      end

      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Not Authorized')
      end
    end

    context 'when not authenticated (missing token)' do
      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Not Authorized')
      end
    end

    context 'when the order does not exist' do
      before do
        request.headers.merge!(student_headers) # Still need to be logged in
      end

      it 'returns a :not_found (404) status' do
        post :create, params: { order_id: 'invalid-id' }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Order not found')
      end
    end
  end
end
