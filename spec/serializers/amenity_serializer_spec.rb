# frozen_string_literal: true

RSpec.describe AmenitySerializer, type: :serializer do
  let(:amenity) do
    build_stubbed(
      :amenity,
      id: 1,
      name: 'Showers',
      category: 'facilities',
      icon_name: 'shower-icon',
      created_at: Time.current,
      updated_at: Time.current
    )
  end

  let(:json) { described_class.new(amenity).as_json.deep_symbolize_keys }
  let(:expected_keys) do
    [ :id, :name, :category, :icon_name, :created_at, :updated_at ]
  end

  it 'includes all the expected attributes' do
    expect(json.keys).to contain_exactly(*expected_keys)
  end

  it 'returns the correct values' do
    expect(json[:id]).to eq(amenity.id)
    expect(json[:name]).to eq('Showers')
    expect(json[:category]).to eq('facilities')
  end

  it 'formats timestamps correctly' do
    expect(json[:created_at]).to eq(amenity.created_at.iso8601)
  end
end
