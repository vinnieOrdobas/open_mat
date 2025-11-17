# frozen_string_literal: true

RSpec.describe Academy, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:passes).dependent(:destroy) }
    it { should have_many(:order_line_items).through(:passes) }
    it { should have_many(:academy_amenities).dependent(:destroy) }
    it { should have_many(:amenities).through(:academy_amenities) }
    it { should have_many(:attachments).dependent(:destroy) }
  end

  describe 'validations' do
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

  describe 'attachments' do
    let(:owner) { create(:user, :owner) }
    let!(:academy) { create(:academy, user: owner) }
    let!(:logo) { create(:attachment, :logo, attachable: academy) }
    let!(:photo1) { create(:attachment, :photo, attachable: academy) }
    let!(:photo2) { create(:attachment, :photo, attachable: academy) }

    before do
      logo
      photo1
      photo2
    end

    it 'returns the correct logo via the #logo helper' do
      expect(academy.logo).to eq(logo)
    end

    it 'returns the correct photos via the #photos helper' do
      expect(academy.photos).to include(photo1, photo2)
      expect(academy.photos.count).to eq(2)
    end

    it 'does not mix up logos and photos' do
      expect(academy.photos).not_to include(logo)
      expect(academy.logo).not_to eq(photo1)
    end
  end
end
