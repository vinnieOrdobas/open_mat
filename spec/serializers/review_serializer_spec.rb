# frozen_string_literal: true

RSpec.describe ReviewSerializer, type: :serializer do
  let!(:user) { create(:user, username: 'reviewer_jane') }
  let!(:review) do
    build_stubbed(
      :review,
      id: 1,
      user: user,
      rating: 4,
      comment: 'Great mats!',
      created_at: Time.current
    )
  end

  let(:json) { described_class.new(review).as_json.deep_symbolize_keys }

  let(:expected_keys) { %i[id academy_id rating comment created_at user_id username] }

  it 'includes all the expected attributes' do
    expect(json.keys).to contain_exactly(*expected_keys)
  end

  it 'returns the correct top-level values' do
    expect(json[:id]).to eq(review.id)
    expect(json[:rating]).to eq(4)
    expect(json[:comment]).to eq('Great mats!')
  end

  it 'includes the nested user information' do
    expect(json[:user_id]).to eq(user.id)
    expect(json[:username]).to eq('reviewer_jane')
  end
end
