# frozen_string_literal: true

RSpec.describe Reviews::CreateReview do
  let!(:student) { create(:user, role: 'student') }
  let!(:academy) { create(:academy) }
  let(:review_params) { { rating: 5, comment: 'Great place!' } }
  let(:service) { described_class.new(user: student, academy: academy, params: review_params) }

  context "when the user HAS attended (has a used pass)" do
    let!(:used_pass) { create(:student_pass, user: student, academy: academy, status: 'depleted') }

    it 'creates a new review' do
      expect { service.perform }.to change(Review, :count).by(1)
    end

    it 'returns a success result with the new review' do
      result = service.perform

      expect(result[:success]).to be(true)
      expect(result[:review]).to be_a(Review)
      expect(result[:review].rating).to eq(5)
      expect(result[:review].user).to eq(student)
      expect(result[:review].academy).to eq(academy)
    end

    context 'and tries to review a second time' do
      let!(:first_review) { create(:review, user: student, academy: academy) }

      it 'returns a model validation error' do
        result = service.perform
        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("User has already reviewed this academy")
      end
    end
  end

  context "when the user has NOT attended (no used pass)" do
    it 'does not create a new review' do
      expect { service.perform }.not_to change(Review, :count)
    end

    it 'returns a failure result with a validation error' do
      result = service.perform
      expect(result[:success]).to be(false)
      expect(result[:errors]).to include("You can only review academies you have attended")
    end
  end

  context "when the user has an 'active' but unused pass" do
    let!(:active_pass) { create(:student_pass, user: student, academy: academy, status: 'active') }

    it 'does not create a new review' do
      expect { service.perform }.not_to change(Review, :count)
    end

    it 'returns a failure result with a validation error' do
      result = service.perform
      expect(result[:success]).to be(false)
      expect(result[:errors]).to include("You can only review academies you have attended")
    end
  end
end
