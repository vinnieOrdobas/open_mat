# frozen_string_literal: true

RSpec.describe OrderLineItemSerializer, type: :serializer do
  let!(:order) { create(:order) }
  let!(:pass) { create(:pass) }
  let!(:line_item) do
    build_stubbed(
      :order_line_item,
      id: 1,
      order: order,
      pass: pass,
      quantity: 2,
      price_at_purchase_cents: pass.price_cents,
      status: 'pending_approval' # Add status to the object
    )
  end

  let(:json) { described_class.new(line_item).as_json.deep_symbolize_keys }
  let(:expected_keys) { [ :id, :order_id, :pass_id, :quantity, :price_at_purchase_cents, :status ] }

  it 'includes all expected keys' do
    expect(json.keys).to contain_exactly(*expected_keys)
  end

  it 'returns correct values' do
    expect(json[:id]).to eq(line_item.id)
    expect(json[:order_id]).to eq(order.id)
    expect(json[:pass_id]).to eq(pass.id)
    expect(json[:quantity]).to eq(2)
    expect(json[:price_at_purchase_cents]).to eq(pass.price_cents)
    expect(json[:status]).to eq('pending_approval') # <-- ADD THIS ASSERTION
  end
end
