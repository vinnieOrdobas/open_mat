# frozen_string_literal: true

RSpec.describe 'Api::V1::Ordering Workflow', type: :request do
  let!(:student) { create(:user, role: 'student') }
  let!(:owner) { create(:user, :owner) }
  let!(:other_owner) { create(:user, :owner) }

  let!(:academy) { create(:academy, user: owner) }
  let!(:pass1) { create(:pass, :day_pass, academy: academy, price_cents: 2000) }
  let!(:pass2) { create(:pass, :punch_card, academy: academy, price_cents: 5000, class_credits: 5) }

  let(:student_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: student.id)}", 'Content-Type' => 'application/json' } }
  let(:owner_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: owner.id)}", 'Content-Type' => 'application/json' } }

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
        expect(json_response[:order_line_items].first[:status]).to eq('pending_approval') # Test status
        expect(Order.last.user).to eq(student)
      end
    end
  end

  # === Flow Step 2 (Owner): Lists Pending Items ===
  describe 'GET /api/v1/academies/:academy_id/order_line_items' do
    let!(:order) { create(:order, user: student) }
    let!(:line_item) { create(:order_line_item, order: order, pass: pass1, status: 'pending_approval') }
    let!(:line_item2) { create(:order_line_item, order: order, pass: pass2, status: 'approved') }

    context 'when authenticated as the academy owner' do
      it 'lists all line items for their academy' do
        get "/api/v1/academies/#{academy.id}/order_line_items", headers: owner_headers

        parsed_response = JSON.parse(response.body).map { |o| o.deep_symbolize_keys }

        expect(response).to have_http_status(:ok)
        expect(parsed_response.count).to eq(2)
        expect(parsed_response.map { |li| li[:id] }).to contain_exactly(line_item.id, line_item2.id)
      end

      it 'filters by status' do
        get "/api/v1/academies/#{academy.id}/order_line_items?status=pending_approval", headers: owner_headers

        parsed_response = JSON.parse(response.body).map { |o| o.deep_symbolize_keys }

        expect(response).to have_http_status(:ok)
        expect(parsed_response.count).to eq(1)
        expect(parsed_response.first[:id]).to eq(line_item.id)
      end
    end
  end

  # === Flow Step 3 (Owner): Approves Line Items ===
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
  end

  # === Flow Step 4 (Student): Confirms & Pays ===
  describe 'POST /api/v1/orders/:order_id/confirmation' do
    let!(:order) { create(:order, user: student, status: 'awaiting_approvals', total_price_cents: (pass1.price_cents + pass2.price_cents)) }
    let!(:line_item1) { create(:order_line_item, order: order, pass: pass1, quantity: 1, status: 'approved') }
    let!(:line_item2) { create(:order_line_item, order: order, pass: pass2, quantity: 1, status: 'approved') }

    context 'when authenticated as the student and all items are approved' do
      it 'processes payment, creates StudentPasses, and marks order completed' do
        expect {
          post "/api/v1/orders/#{order.id}/confirmation", headers: student_headers
        }.to change(StudentPass, :count).by(2)

        expect(response).to have_http_status(:created)
        expect(json_response[:status]).to eq('succeeded')
        expect(order.reload.status).to eq('completed')

        pass_a_wallet_item = StudentPass.find_by(order_line_item_id: line_item1.id)
        pass_b_wallet_item = StudentPass.find_by(order_line_item_id: line_item2.id)

        expect(pass_a_wallet_item.expires_at).to be_within(1.second).of(Time.current + 1.day)
        expect(pass_b_wallet_item.credits_remaining).to eq(5)
      end
    end
  end

  # === Flow Step 5 (Student): Views History ===
  describe 'GET /api/v1/orders' do
    let!(:order1) { create(:order, user: student, status: 'completed') }
    let!(:order2) { create(:order, user: student, status: 'awaiting_approvals') }
    let!(:other_user_order) { create(:order, user: other_owner) }

    context 'when authenticated as the student' do
      it "returns only the student's orders" do
        get '/api/v1/orders', headers: student_headers

        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body).map { |o| o.deep_symbolize_keys }

        expect(parsed_response).to be_an(Array)
        expect(parsed_response.count).to eq(2)

        order_ids = parsed_response.map { |o| o[:id] }
        expect(order_ids).to contain_exactly(order1.id, order2.id)
      end
    end
  end
end
