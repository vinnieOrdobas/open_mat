# frozen_string_literal: true

RSpec.describe Api::V1::OrderConfirmationsController, type: :controller do
  describe 'POST #create' do
    subject(:do_action) { post :create, params: { order_id: order.id } }

    let!(:student) { create(:user, role: 'student') }
    let!(:other_user) { create(:user, role: 'student') }

    let!(:order) { create(:order, user: student, status: 'awaiting_approvals') }

    let(:student_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: student.id)}" } }
    let(:other_user_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: other_user.id)}" } }

    let(:mock_payment_service) { instance_double(Payments::ProcessMockPayment) }
    let(:mock_payment) { build_stubbed(:payment, order: order) }
    let(:mock_serializer) { instance_double(PaymentSerializer) }

    context 'when authenticated as the order owner' do
      before do
        request.headers.merge!(student_headers)

        allow(Payments::ProcessMockPayment).to receive(:new).with(order: order).and_return(mock_payment_service)
        allow(PaymentSerializer).to receive(:new).with(mock_payment).and_return(mock_serializer)
      end

      context 'and the payment service succeeds' do
        let(:expected_hash) { { id: mock_payment.id, status: 'succeeded' } }

        before do
          allow(mock_payment_service).to receive(:perform).and_return({ success: true, payment: mock_payment })
          allow(mock_serializer).to receive(:as_json).and_return(expected_hash.to_json)
        end

        it 'calls the ProcessMockPayment service' do
          do_action
          expect(Payments::ProcessMockPayment).to have_received(:new).with(order: order)
          expect(mock_payment_service).to have_received(:perform)
        end

        it 'calls the PaymentSerializer' do
          do_action
          expect(PaymentSerializer).to have_received(:new).with(mock_payment)
        end

        it 'returns a :created (201) status and the payment JSON' do
          do_action
          expect(response).to have_http_status(:created)
          expect(response.body).to eq(expected_hash.to_json)
        end
      end

      context 'and the payment service fails' do
        let(:errors) { [ "Not all line items have been approved" ] }

        before do
          allow(mock_payment_service).to receive(:perform).and_return({ success: false, errors: errors })
        end

        it 'calls the ProcessMockPayment service' do
          do_action
          expect(mock_payment_service).to have_received(:perform)
        end

        it 'does NOT call the PaymentSerializer' do
          do_action
          expect(PaymentSerializer).not_to have_received(:new)
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
      end
    end

    context 'when not authenticated (missing token)' do
      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the order does not exist' do
      before do
        request.headers.merge!(student_headers)
      end

      it 'returns a :not_found (404) status' do
        post :create, params: { order_id: 'invalid-id' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
