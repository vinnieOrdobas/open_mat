# frozen_string_literal: true

RSpec.describe Api::V1::OrdersController, type: :controller do
  describe 'POST #create' do
    subject(:do_action) { post :create, params: request_params }

    let!(:user) { create(:user) }
    let(:user_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: user.id)}" } }

    let!(:pass1) { create(:pass, price_cents: 2000) }
    let!(:pass2) { create(:pass, price_cents: 8000) }

    let(:valid_cart_items) { [ { pass_id: pass1.id, quantity: 1 }, { pass_id: pass2.id, quantity: 2 } ] }
    let(:request_params) { { order: { cart_items: valid_cart_items } } }
    let(:valid_cart_items_as_strings) do
      valid_cart_items.map { |item| { pass_id: item[:pass_id].to_s, quantity: item[:quantity].to_s } }
    end
    let(:permitted_params) do
      ActionController::Parameters.new(cart_items: valid_cart_items_as_strings).permit(cart_items: [ :pass_id, :quantity ])
    end

    let(:mock_create_service) { instance_double(Orders::CreateOrder) }
    let(:mock_order) { build_stubbed(:order, user: user) }
    let(:mock_serializer) { instance_double(OrderSerializer) }

    context 'when authenticated' do
      before do
        request.headers.merge!(user_headers)

        allow(Orders::CreateOrder).to receive(:new).with(user: user, cart_items: permitted_params[:cart_items]).and_return(mock_create_service)
        allow(OrderSerializer).to receive(:new).with(mock_order).and_return(mock_serializer)
      end

      context 'and the CreateOrder service succeeds' do
        let(:expected_hash) { { id: mock_order.id, status: 'pending_approval' } }

        before do
          allow(mock_create_service).to receive(:perform).and_return({ success: true, order: mock_order })
          allow(mock_serializer).to receive(:as_json).and_return(expected_hash.to_json)
        end

        it 'calls the CreateOrder service' do
          do_action
          expect(Orders::CreateOrder).to have_received(:new).with(user: user, cart_items: permitted_params[:cart_items])
          expect(mock_create_service).to have_received(:perform)
        end

        it 'calls the OrderSerializer' do
          do_action
          expect(OrderSerializer).to have_received(:new).with(mock_order)
        end

        it 'returns a :created (201) status and the new order JSON' do
          do_action
          expect(response).to have_http_status(:created)
          expect(response.body).to eq(expected_hash.to_json)
        end
      end

      context 'and the CreateOrder service fails' do
        let(:errors) { [ "Pass not found", "Validation failed: Quantity invalid" ] }

        before do
          allow(mock_create_service).to receive(:perform).and_return({ success: false, errors: errors })
        end

        it 'calls the CreateOrder service' do
          do_action
          expect(mock_create_service).to have_received(:perform)
        end

        it 'does NOT call the OrderSerializer' do
          do_action
          expect(OrderSerializer).not_to have_received(:new)
        end

        it 'returns a :bad_request (400) status and the errors' do
          do_action
          expect(response).to have_http_status(:bad_request)
          json_response = JSON.parse(response.body).deep_symbolize_keys
          expect(json_response[:errors]).to match(errors)
        end
      end
    end

    context 'when not authenticated' do
      before do
        allow(Orders::CreateOrder).to receive(:new)
      end

      it 'does NOT call the CreateOrder service' do
        do_action
        expect(Orders::CreateOrder).not_to have_received(:new)
      end

      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body).deep_symbolize_keys
        expect(json_response[:error]).to eq('Not Authorized')
      end
    end
  end

  # We will add describe 'GET #index' later
end
