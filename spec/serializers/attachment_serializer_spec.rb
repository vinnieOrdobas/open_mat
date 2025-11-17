# frozen_string_literal: true

RSpec.describe AttachmentSerializer, type: :serializer do
  let!(:attachment) do
    build_stubbed(
      :attachment,
      id: 1,
      kind: 'logo',
      url: 'http://example.com/logo.png'
    )
  end

  let(:json) { described_class.new(attachment).as_json.deep_symbolize_keys }
  let(:expected_keys) { [:id, :kind, :url] }

  it 'includes all expected keys' do
    expect(json.keys).to contain_exactly(*expected_keys)
  end

  it 'returns the correct values' do
    expect(json[:id]).to eq(1)
    expect(json[:kind]).to eq('logo')
    expect(json[:url]).to eq('http://example.com/logo.png')
  end
end