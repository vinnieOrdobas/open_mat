# frozen_string_literal: true

RSpec.describe 'Api::V1::Ordering Workflow', type: :request do
  let!(:student) { create(:user, role: 'student') }
  let!(:owner) { create(:user, :owner) }
  let!(:other_owner) { create(:user, :owner) }

  let!(:academy) { create(:academy, user: owner) }
  let!(:pass1) { create(:pass, academy: academy, price_cents: 2000) }
  let!(:pass2) { create(:pass, academy: academy, price_cents: 5000) }

  let(:student_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: student.id)}", 'Content-Type' => 'application/json' } }
  let(:owner_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: owner.id)}", 'Content-Type' => 'application/json' } }
  let(:other_owner_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: other_owner.id)}", 'Content-Type' => 'application/json' } }

  let(:json_response) { JSON.parse(response.body).deep_symbolize_keys rescue {} }

  # === Flow Step 1: Student Creates Order ===
  describe 'POST /api/v1/orders' do
    let(:cart_params) do
      { order: { cart_items: [ { pass_id: pass1.id, quantity: 2 } ] } }
    end

    context 'when authenticated as a student' do
      it 'creates an order with status awaiting_approvals' do
        post '/api/v1/orders', headers: student_headers, params: cart_params.to_json

        expect(response).to have_http_status(:created)
        expect(json_response[:status]).to eq('awaiting_approvals')
        expect(json_response[:order_line_items].count).to eq(1)
        expect(json_response[:order_line_items].first[:status]).to eq('pending_approval')
        expect(Order.last.user).to eq(student)
      end
    end

    context 'when unauthenticated' do
      it 'returns unauthorized' do
        post '/api/v1/orders', headers: {}, params: cart_params.to_json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # === Flow Step 2: Owner Approves Line Items ===
  describe 'PATCH /api/v1/order_line_items/:id' do
    let!(:order) { create(:order, user: student) }
    let!(:line_item) { create(:order_line_item, order: order, pass: pass1, status: 'pending_approval') }
    let(:approval_params) { { order_line_item: { status: 'approved' } }.to_json }

    context 'when authenticated as the correct owner' do
      it 'approves the line item' do
        patch "/api/v1/order_line_items/#{line_item.id}", headers: owner_headers, params: approval_params
        expect(response).to have_http_status(:ok)
        expect(json_response[:status]).to eq('approved')
        expect(line_item.reload.status).to eq('approved')
      end
    end

    context 'when authenticated as the student (not owner)' do
      it 'returns unauthorized' do
        patch "/api/v1/order_line_items/#{line_item.id}", headers: student_headers, params: approval_params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated as a different owner' do
      it 'returns unauthorized' do
        patch "/api/v1/order_line_items/#{line_item.id}", headers: other_owner_headers, params: approval_params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # === Flow Step 3: Student Confirms/Pays ===
  describe 'POST /api/v1/orders/:order_id/confirmation' do
    let!(:order) { create(:order, user: student, status: 'awaiting_approvals', total_price_cents: 2000) }

    context 'when authenticated as the student and all items are approved' do
      let!(:line_item) { create(:order_line_item, order: order, pass: pass1, status: 'approved') } # Item is approved

      it 'processes the payment and marks the order completed' do
        post "/api/v1/orders/#{order.id}/confirmation", headers: student_headers

        expect(response).to have_http_status(:created)
        expect(json_response[:status]).to eq('succeeded')
        expect(json_response[:amount_cents]).to eq(2000)
        expect(order.reload.status).to eq('completed')
      end
    end

    context 'when authenticated as the student but items are still pending' do
      let!(:line_item) { create(:order_line_item, order: order, pass: pass1, status: 'pending_approval') } # Item is NOT approved

      it 'returns an error' do
        post "/api/v1/orders/#{order.id}/confirmation", headers: student_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include('Not all line items have been approved')
        expect(order.reload.status).to eq('awaiting_approvals') # Status unchanged
      end
    end

    context 'when authenticated as a different user' do
      let!(:line_item) { create(:order_line_item, order: order, pass: pass1, status: 'approved') } # Setup for success

      it 'returns unauthorized' do
        post "/api/v1/orders/#{order.id}/confirmation", headers: { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: other_owner.id)}" }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # === Flow Step 4: Student Views History ===
  describe 'GET /api/v1/orders' do
    let!(:order1) { create(:order, user: student, status: 'completed') }
    let!(:order2) { create(:order, user: student, status: 'awaiting_approvals') }
    let!(:other_user_order) { create(:order, user: other_owner) } # Should not be visible

    context 'when authenticated as the student' do
      it "returns only the student's orders" do
        get '/api/v1/orders', headers: student_headers

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body).map { |o| o.deep_symbolize_keys }
        expect(json_response).to be_an(Array)
        expect(json_response.count).to eq(2)

        order_ids = json_response.map { |o| o[:id] }
        expect(order_ids).to contain_exactly(order1.id, order2.id)
        expect(order_ids).not_to include(other_user_order.id)
      end
    end

    context 'when unauthenticated' do
      it 'returns unauthorized' do
        get '/api/v1/orders'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
