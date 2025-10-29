# frozen_string_literal: true

RSpec.describe PaymentSerializer, type: :serializer do
  let!(:order) { create(:order) }
  let!(:payment) do
    build_stubbed(
      :payment,
      id: 1,
      order: order,
      status: 'succeeded',
      amount_cents: order.total_price_cents,
      currency: order.currency,
      processor: 'mock',
      processor_id: 'mock_12345',
      created_at: Time.current,
      updated_at: Time.current
    )
  end

  let(:json) { described_class.new(payment).as_json.deep_symbolize_keys }
  let(:expected_keys) do
    [ :id, :order_id, :status, :amount_cents, :currency,
     :processor, :processor_id, :created_at, :updated_at ]
  end

  it 'includes all expected keys' do
    expect(json.keys).to contain_exactly(*expected_keys)
  end

  it 'returns correct values' do
    expect(json[:id]).to eq(payment.id)
    expect(json[:order_id]).to eq(order.id)
    expect(json[:status]).to eq('succeeded')
    expect(json[:processor]).to eq('mock')
    expect(json[:processor_id]).to eq('mock_12345')
  end
end
