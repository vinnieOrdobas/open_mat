# frozen_string_literal: true

RSpec.describe Api::V1::AcademyOrderLineItemsController, type: :controller do
  describe 'GET #index' do
    subject(:do_action) { get :index, params: request_params }

    let!(:owner) { create(:user, :owner) }
    let!(:other_owner) { create(:user, :owner) }

    let!(:academy) { create(:academy, user: owner) }
    let!(:pass) { create(:pass, academy: academy) }

    let!(:item_pending) { create(:order_line_item, pass: pass, status: 'pending_approval') }
    let!(:item_approved) { create(:order_line_item, pass: pass, status: 'approved') }

    let!(:other_academy) { create(:academy, user: other_owner) }
    let!(:other_pass) { create(:pass, academy: other_academy) }
    let!(:other_item) { create(:order_line_item, pass: other_pass, status: 'pending_approval') }

    let(:owner_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: owner.id)}" } }
    let(:other_owner_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: other_owner.id)}" } }
    let(:request_params) { { academy_id: academy.id } }

    context 'when authenticated as the academy owner' do
      before { request.headers.merge!(owner_headers) }

      it 'returns an :ok (200) status' do
        do_action
        expect(response).to have_http_status(:ok)
      end

      it "returns only line items for that academy" do
        do_action

        json_response = JSON.parse(response.body)
        expect(json_response).to be_an(Array)
        expect(json_response.count).to eq(2)
        item_ids = json_response.map { |item| item['id'] }
        expect(item_ids).to contain_exactly(item_pending.id, item_approved.id)
      end

      it 'uses the OrderLineItemSerializer' do
        do_action

        json_response = JSON.parse(response.body)
        expect(json_response.first).to include('id', 'order_id', 'pass_id', 'quantity', 'price_at_purchase_cents')
      end

      context 'when filtering by status' do
        let(:request_params) { { academy_id: academy.id, status: 'pending_approval' } }

        it 'returns only line items with the matching status' do
          do_action

          json_response = JSON.parse(response.body)
          expect(json_response).to be_an(Array)
          expect(json_response.count).to eq(1)
          expect(json_response.first['id']).to eq(item_pending.id)
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

    context 'when not authenticated' do
      it 'returns :unauthorized (401)' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the academy does not exist' do
      let(:request_params) { { academy_id: 'invalid' } }
      before { request.headers.merge!(owner_headers) } # Still need auth

      it 'returns a :not_found (404) status' do
        do_action
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
