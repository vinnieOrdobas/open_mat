# frozen_string_literal: true

RSpec.describe Booking, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:class_schedule) }
    it { should belong_to(:student_pass) }
  end

  describe 'validations' do
    let!(:existing_booking) { create(:booking) }

    subject { build(:booking, user: existing_booking.user, class_schedule: existing_booking.class_schedule) }

    it 'is invalid if the user has already booked this class' do
      expect(subject).not_to be_valid
      expect(subject.errors[:user_id]).to include("has already booked this class")
    end

    it { should validate_uniqueness_of(:user_id).scoped_to(:class_schedule_id).with_message("has already booked this class") }

    it 'is valid if the user books a different class' do
      different_schedule = create(:class_schedule)
      subject.class_schedule = different_schedule
      expect(subject).to be_valid
    end

    it 'is valid if a different user books the same class' do
      different_user = create(:user)
      subject.user = different_user
      expect(subject).to be_valid
    end
  end
end
