# frozen_string_literal: true

RSpec.describe OrderSerializer, type: :serializer do
  let!(:user) { create(:user) }
  let!(:order) do
    # Use build_stubbed for speed, but manually associate line items
    build_stubbed(
      :order,
      id: 1,
      user: user,
      status: 'awaiting_approvals',
      total_price_cents: 5000,
      currency: 'USD',
      created_at: Time.current,
      updated_at: Time.current
    )
  end
  let!(:line_item1) { build_stubbed(:order_line_item, order: order, quantity: 1, price_at_purchase_cents: 2000) }
  let!(:line_item2) { build_stubbed(:order_line_item, order: order, quantity: 1, price_at_purchase_cents: 3000) }

  before do
    allow(order).to receive(:order_line_items).and_return([ line_item1, line_item2 ])
  end

  let(:json) { described_class.new(order).as_json.deep_symbolize_keys }
  let(:expected_keys) do
    [ :id, :user_id, :status, :total_price_cents, :currency,
     :created_at, :updated_at, :order_line_items ]
  end

  it 'includes all expected keys' do
    expect(json.keys).to contain_exactly(*expected_keys)
  end

  it 'returns correct values for order attributes' do
    expect(json[:id]).to eq(order.id)
    expect(json[:user_id]).to eq(user.id)
    expect(json[:status]).to eq('awaiting_approvals')
    expect(json[:total_price_cents]).to eq(5000)
  end

  it 'includes associated order_line_items' do
    expect(json[:order_line_items]).to be_an(Array)
    expect(json[:order_line_items].count).to eq(2)
    expect(json[:order_line_items].first).to include(:id, :order_id, :pass_id, :quantity, :price_at_purchase_cents)
  end
end
