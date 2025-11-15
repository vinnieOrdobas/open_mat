# frozen_string_literal: true

RSpec.describe Academy, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:passes).dependent(:destroy) }
    it { should have_many(:order_line_items).through(:passes) }
    it { should have_many(:academy_amenities).dependent(:destroy) }
    it { should have_many(:amenities).through(:academy_amenities) }
  end

  describe 'validations' do
    # We need a subject for the uniqueness validation
    let(:user) { User.create!(firstname: 'Owner', lastname: 'One', email: 'owner@example.com', username: 'owner1', password: 'password', role: 'owner') }
    subject { Academy.new(user: user, name: 'Test Academy', email: 'academy@example.com', street_address: '123 Main St', city: 'Anytown', country: 'USA') }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:street_address) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:country) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should allow_value('test@example.com').for(:email) }
  end

  describe '#average_rating' do
    let(:owner) { create(:user, :owner) }
    let!(:academy) { create(:academy, user: owner) }

    context 'when there are reviews' do
      before do
        create(:review, academy: academy, rating: 5)
        create(:review, academy: academy, rating: 3)
      end

      it 'returns the correct average' do
        expect(academy.average_rating).to eq(4.0)
      end
    end

    context 'when there are no reviews' do
      it 'returns nil' do
        expect(academy.average_rating).to be_nil
      end
    end

    context 'when reviews require rounding' do
      before do
        create(:review, academy: academy, rating: 5)
        create(:review, academy: academy, rating: 4)
        create(:review, academy: academy, rating: 4)
      end

      it 'rounds to one decimal place' do
        expect(academy.average_rating).to eq(4.3)
      end
    end
  end
end
