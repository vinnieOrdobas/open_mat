# frozen_string_literal: true

RSpec.describe PassSerializer, type: :serializer do
  let!(:owner) { create(:user, :owner) }
  let!(:academy) { create(:academy, user: owner) }

  let(:pass) do
    build_stubbed(
      :pass,
      id: 1,
      academy: academy,
      name: 'Single Day Pass',
      description: 'Access for one day.',
      price_cents: 2500,
      currency: 'USD',
      pass_type: 'day_pass',
      class_credits: nil,
      is_active: true,
      created_at: Time.current,
      updated_at: Time.current
    )
  end

  let(:json) { described_class.new(pass).as_json.deep_symbolize_keys }
  let(:expected_keys) do
    [
      :id, :academy_id, :name, :description, :price_cents, :currency,
      :pass_type, :class_credits, :is_active, :created_at, :updated_at
    ]
  end

  it 'includes all the expected attributes' do
    expect(json.keys).to contain_exactly(*expected_keys)
  end

  it 'returns the correct values' do
    expect(json[:id]).to eq(pass.id)
    expect(json[:name]).to eq('Single Day Pass')
    expect(json[:academy_id]).to eq(academy.id)
    expect(json[:price_cents]).to eq(2500)
    expect(json[:pass_type]).to eq('day_pass')
    expect(json[:class_credits]).to be_nil
  end

  it 'formats timestamps correctly' do
    expect(json[:created_at]).to eq(pass.created_at.iso8601)
  end
end
