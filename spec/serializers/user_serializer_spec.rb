# frozen_string_literal: true

RSpec.describe UserSerializer, type: :serializer do
  let!(:user) do
    create(:user,
           firstname: 'Test',
           lastname: 'User',
           email: 'test@example.com',
           username: 'testuser',
           role: 'student',
           belt_rank: 'white',
           created_at: Time.current,
           updated_at: Time.current)
  end

  let!(:headshot) { create(:attachment, :headshot, attachable: user) }
  let!(:order) { create(:order, user: user) }
  let(:json) { described_class.new(user.reload).as_json.deep_symbolize_keys }

  let(:expected_keys) do
    [
      :id,
      :username,
      :email,
      :firstname,
      :lastname,
      :role,
      :belt_rank,
      :created_at,
      :updated_at,
      :headshot,
      :orders
    ]
  end

  it 'includes all the expected attributes and associations' do
    expect(json.keys).to contain_exactly(*expected_keys)
  end

  it 'returns the correct top-level values' do
    expect(json[:id]).to eq(user.id)
    expect(json[:username]).to eq('testuser')
    expect(json[:role]).to eq('student')
    expect(json[:belt_rank]).to eq('white')
  end

  it 'formats timestamps correctly' do
    expect(json[:created_at]).to eq(user.created_at.iso8601)
  end

  it 'includes the nested headshot' do
    expect(json[:headshot]).to be_a(Hash)
    expect(json[:headshot][:id]).to eq(headshot.id)
    expect(json[:headshot][:kind]).to eq('headshot')
  end

  it 'includes the nested orders' do
    expect(json[:orders]).to be_an(Array)
    expect(json[:orders].count).to eq(1)
    expect(json[:orders].first[:id]).to eq(order.id)
  end
end
