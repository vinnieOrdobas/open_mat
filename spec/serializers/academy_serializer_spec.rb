# frozen_string_literal: true

RSpec.describe AcademySerializer, type: :serializer do
  let(:user) { create(:user, :owner, firstname: 'Gym', lastname: 'Owner', email: 'email@email.com', username: 'gym_owner') }
  let!(:academy) { create(:academy, name: 'Test Academy', payout_info: 'my-secret-paypal-email', user: user) }
  let!(:amenity1) { create(:amenity, name: 'Showers') }
  let!(:pass1) { create(:pass, :day_pass, academy: academy, name: 'Day Pass') }
  let!(:pass2) { create(:pass, :punch_card, academy: academy, name: '10 Class Card') }
  let!(:student_1) { create(:user, :student) }
  let!(:student_2) { create(:user, :student) }
  let!(:review1) { create(:review, academy: academy, rating: 5, comment: 'Great place!', user: student_1) }
  let!(:review2) { create(:review, academy: academy, rating: 4, comment: 'Good experience.', user: student_2) }

  before do
    academy.amenities << amenity1
    review1
    review2
  end

  let(:json) { described_class.new(academy).as_json.deep_symbolize_keys }

  let(:expected_keys) do
    [
      :id, :user_id, :name, :email, :phone_number, :website, :description,
      :street_address, :city, :state_province, :postal_code, :country,
      :latitude, :longitude, :created_at, :updated_at, :amenities, :passes,
      :reviews, :average_rating, :class_schedules
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

  it 'includes associated amenities' do
    expect(json[:amenities]).to be_an(Array)
    expect(json[:amenities].count).to eq(1)
    expect(json[:amenities].first[:id]).to eq(amenity1.id)
    expect(json[:amenities].first[:name]).to eq('Showers')
  end

  it 'includes associated passes' do
    expect(json[:passes]).to be_an(Array)
    expect(json[:passes].count).to eq(2)
    pass_names = json[:passes].map { |p| p[:name] }
    expect(pass_names).to contain_exactly('Day Pass', '10 Class Card')
    expect(json[:passes].first[:id]).to eq(pass1.id)
  end

  it 'includes the calculated average_rating' do
    expect(json[:average_rating]).to eq(4.5)
  end

  it 'includes the nested reviews' do
    expect(json[:reviews]).to be_an(Array)
    expect(json[:reviews].count).to eq(2)
    expect(json[:reviews].first[:rating]).to eq(5)
    expect(json[:reviews].last[:rating]).to eq(4)
  end
end
