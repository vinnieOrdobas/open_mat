# frozen_string_literal: true

RSpec.describe AcademySerializer, type: :serializer do
  let(:user) { create(:user, :owner, firstname: 'Gym', lastname: 'Owner', email: 'email@email.com', username: 'gym_owner') }
  let!(:academy) { create(:academy, name: 'Test Academy', payout_info: 'my-secret-paypal-email', user: user) }

  let(:json) { described_class.new(academy).as_json.deep_symbolize_keys }

  let(:expected_keys) do
    [
      :id, :user_id, :name, :email, :phone_number, :website, :description,
      :street_address, :city, :state_province, :postal_code, :country,
      :latitude, :longitude, :created_at, :updated_at
    ]
  end

  it 'includes all the expected, public attributes' do
    expect(json.keys).to contain_exactly(*expected_keys)
  end

  it 'returns the correct values for the attributes' do
    expect(json[:id]).to eq(academy.id)
    expect(json[:name]).to eq('Test Academy')
    expect(json[:user_id]).to eq(user.id)
  end

  it 'formats the timestamps using ApplicationSerializer' do
    expect(json[:created_at]).to eq(academy.created_at.iso8601)
  end

  it 'does NOT include the sensitive payout_info' do
    expect(json.keys).not_to include(:payout_info)
  end
end
