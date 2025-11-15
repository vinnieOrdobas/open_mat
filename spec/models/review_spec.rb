# frozen_string_literal: true

RSpec.describe Review, type: :model do
  subject { build(:review) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:academy) }
  end

  describe 'validations' do
    it { should be_valid }

    it { should validate_presence_of(:rating) }

    it { should validate_inclusion_of(:rating).in_range(1..5).with_message("must be between 1 and 5") }

    it 'is invalid with a rating of 0' do
      subject.rating = 0
      expect(subject).not_to be_valid
    end

    it 'is invalid with a rating of 6' do
      subject.rating = 6
      expect(subject).not_to be_valid
    end

    context 'when a review for this academy by this user already exists' do
      let!(:existing_review) { create(:review) }

      subject {
        build(:review,
              user: existing_review.user,
              academy: existing_review.academy
        )
      }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors[:user_id]).to include("has already reviewed this academy")
      end

      it { should validate_uniqueness_of(:user_id).scoped_to(:academy_id).with_message("has already reviewed this academy") }
    end

    it 'is valid if a different user reviews the same academy' do
      create(:review)
      subject.academy = Review.first.academy
      expect(subject).to be_valid
    end

    it 'is valid if the same user reviews a different academy' do
      create(:review)
      subject.user = Review.first.user
      expect(subject).to be_valid
    end
  end
end
