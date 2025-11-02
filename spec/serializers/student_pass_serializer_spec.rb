# frozen_string_literal: true

RSpec.describe StudentPassSerializer, type: :serializer do
  let!(:pass_template) { build_stubbed(:pass, name: '10-Class Card', pass_type: 'punch_card') }
  let!(:student_pass) do
    build_stubbed(
      :student_pass,
      id: 1,
      pass: pass_template,
      status: 'active',
      expires_at: nil,
      credits_remaining: 8
    )
  end

  let(:json) { described_class.new(student_pass).as_json.deep_symbolize_keys }
  let(:expected_keys) do
    [ :id, :academy_id, :status, :expires_at, :credits_remaining, :pass ]
  end

  it 'includes all the expected, public attributes' do
    expect(json.keys).to contain_exactly(*expected_keys)
  end

  it 'returns the correct values' do
    expect(json[:id]).to eq(student_pass.id)
    expect(json[:status]).to eq('active')
    expect(json[:expires_at]).to be_nil
    expect(json[:credits_remaining]).to eq(8)
  end

  it 'includes the nested pass template data' do
    expect(json[:pass]).to be_a(Hash)
    expect(json[:pass][:name]).to eq('10-Class Card')
    expect(json[:pass][:pass_type]).to eq('punch_card')
  end

  it 'does NOT include internal IDs like user_id or order_line_item_id' do
    expect(json.keys).not_to include(:user_id)
    expect(json.keys).not_to include(:order_line_item_id)
  end
end
