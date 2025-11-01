# frozen_string_literal: true

RSpec.describe Api::V1::OrdersController, type: :controller do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let(:user_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: user.id)}" } }

  describe 'GET #index' do
    subject(:do_action) { get :index }

    context 'when authenticated' do
      before { request.headers.merge!(user_headers) }

      let!(:order1) { create(:order, user: user, created_at: 1.day.ago) }
      let!(:order2) { create(:order, user: user, created_at: 2.days.ago) }
      let!(:other_order) { create(:order, user: other_user) }

      it 'returns an :ok (200) status' do
        do_action
        expect(response).to have_http_status(:ok)
      end

      it "returns only the current user's orders" do
        do_action

        json_response = JSON.parse(response.body)
        expect(json_response).to be_an(Array)
        expect(json_response.count).to eq(2)
        order_ids = json_response.map { |o| o['id'] }
        expect(order_ids).to contain_exactly(order1.id, order2.id)
      end

      it 'returns orders sorted by created_at descending (most recent first)' do
        do_action

        json_response = JSON.parse(response.body)
        expect(json_response.first['id']).to eq(order1.id)
        expect(json_response.last['id']).to eq(order2.id)
      end

      it 'uses the OrderSerializer (checks for nested line items)' do
        create(:order_line_item, order: order1)
        do_action
        json_response = JSON.parse(response.body)
        expect(json_response.first).to have_key('order_line_items')
      end
    end

    context 'when not authenticated' do
      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST #create' do
    subject(:do_action) { post :create, params: request_params }

    let!(:pass1) { create(:pass) }
    let!(:pass2) { create(:pass) }
    let(:valid_cart_items) { [ { pass_id: pass1.id, quantity: 1 }, { pass_id: pass2.id, quantity: 2 } ] }
    let(:request_params) { { order: { cart_items: valid_cart_items } } }
    let(:cart_items_as_strings) { valid_cart_items.map { |item| item.transform_keys(&:to_s).transform_values(&:to_s) } }
    let(:permitted_cart_items) do
      ActionController::Parameters.new(cart_items: cart_items_as_strings).permit(cart_items: [ :pass_id, :quantity ])[:cart_items]
    end

    let(:mock_create_service) { instance_double(Orders::CreateOrder) }
    let(:real_order) { build_stubbed(:order, user: user) }

    context 'when authenticated' do
      before do
        request.headers.merge!(user_headers)
        allow(Orders::CreateOrder).to receive(:new).with(user: user, cart_items: permitted_cart_items).and_return(mock_create_service)
      end

      context 'and the CreateOrder service succeeds' do
        let(:expected_json) { OrderSerializer.new(real_order).as_json.to_json }

        before do
          allow(mock_create_service).to receive(:perform).and_return({ success: true, order: real_order })
        end

        it 'calls the CreateOrder service' do
          do_action
          expect(mock_create_service).to have_received(:perform)
        end

        it 'returns a :created (201) status and the new order JSON' do
          do_action
          expect(response).to have_http_status(:created)
          expect(response.body).to eq(expected_json)
        end
      end

      context 'and the CreateOrder service fails' do
        let(:errors) { [ "Pass not found" ] }
        before do
          allow(mock_create_service).to receive(:perform).and_return({ success: false, errors: errors })
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
      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
