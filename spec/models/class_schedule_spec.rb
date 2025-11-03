# frozen_string_literal: true

RSpec.describe ClassSchedule, type: :model do
  subject { build(:class_schedule) }

  describe 'associations' do
    it { should belong_to(:academy) }
  end

  describe 'validations' do
    it { should be_valid }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:day_of_week) }
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_time) }

    it { should validate_inclusion_of(:day_of_week).in_range(0..6).with_message("must be a valid day (0-6)") }

    it 'is invalid with a day_of_week outside the range' do
      subject.day_of_week = 7
      expect(subject).not_to be_valid
      expect(subject.errors[:day_of_week]).to include("must be a valid day (0-6)")
    end

    context 'when end_time is not after start_time' do
      it 'is invalid if end_time is before start_time' do
        subject.start_time = '19:00'
        subject.end_time = '18:00'
        expect(subject).not_to be_valid
        expect(subject.errors[:end_time]).to include("must be after start time")
      end

      it 'is invalid if end_time is the same as start_time' do
        subject.start_time = '19:00'
        subject.end_time = '19:00'
        expect(subject).not_to be_valid
        expect(subject.errors[:end_time]).to include("must be after start time")
      end
    end

    context 'when end_time is after start_time' do
      it 'is valid' do
        subject.start_time = '19:00'
        subject.end_time = '20:00'
        expect(subject).to be_valid
      end
    end
  end
end
