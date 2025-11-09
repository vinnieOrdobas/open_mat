# frozen_string_literal: true

RSpec.describe Bookings::CreateBooking do
  let!(:student) { create(:user, role: 'student') }
  let!(:academy) { create(:academy) }
  let!(:class_schedule) { create(:class_schedule, academy: academy) }
  let(:service) { described_class.new(user: student, class_schedule: class_schedule) }

  context 'with a valid, time-based pass' do
    let!(:student_pass) do
      create(:student_pass, :time_based, user: student, academy: academy, expires_at: 1.week.from_now)
    end

    it 'creates a new Booking' do
      expect { service.perform }.to change(Booking, :count).by(1)
    end

    it 'returns a success result with the new booking' do
      result = service.perform
      expect(result[:success]).to be(true)
      expect(result[:booking]).to be_a(Booking)
      expect(result[:booking].student_pass).to eq(student_pass)
    end

    it 'does NOT change the credits or expiration of the pass' do
      service.perform
      expect(student_pass.reload.credits_remaining).to be_nil
      expect(student_pass.reload.expires_at).to be_within(1.second).of(1.week.from_now)
      expect(student_pass.reload.status).to eq('active')
    end
  end

  context 'with a valid, credit-based pass' do
    let!(:student_pass) do
      create(:student_pass, :credit_based, user: student, academy: academy, credits_remaining: 5)
    end

    it 'creates a new Booking' do
      expect { service.perform }.to change(Booking, :count).by(1)
    end

    it 'decrements the pass credits by 1' do
      service.perform
      expect(student_pass.reload.credits_remaining).to eq(4)
      expect(student_pass.status).to eq('active')
    end
  end

  context 'with a valid, single-credit pass (last credit)' do
    let!(:student_pass) do
      create(:student_pass, :credit_based, user: student, academy: academy, credits_remaining: 1)
    end

    it 'creates a new Booking' do
      expect { service.perform }.to change(Booking, :count).by(1)
    end

    it 'decrements credits to 0 and marks pass as depleted' do
      service.perform
      expect(student_pass.reload.credits_remaining).to eq(0)
      expect(student_pass.status).to eq('depleted')
    end
  end

  context 'when the user is already booked' do
    let!(:student_pass) { create(:student_pass, :time_based, user: student, academy: academy) }
    let!(:existing_booking) { create(:booking, user: student, class_schedule: class_schedule, student_pass: student_pass) }

    it 'does not create a new Booking' do
      expect { service.perform }.not_to change(Booking, :count)
    end

    it 'returns a failure result with an error' do
      result = service.perform
      expect(result[:success]).to be(false)
      expect(result[:errors]).to match_array("Validation failed: User has already booked this class")
    end
  end

  context 'when the user has no active pass' do
    it 'does not create a new Booking' do
      expect { service.perform }.not_to change(Booking, :count)
    end

    it 'returns a failure result with an error' do
      result = service.perform
      expect(result[:success]).to be(false)
      expect(result[:errors]).to include('No active pass found for this academy')
    end
  end

  context 'when the user has an expired pass' do
    let(:student_pass) do
      create(:student_pass, :time_based, user: student, academy: academy, expires_at: 1.day.ago)
    end

    it 'does not create a new Booking' do
      student_pass
      expect { service.perform }.not_to change(Booking, :count)
    end

    it 'updates the pass status to expired' do
      student_pass
      service.perform
      expect(student_pass.reload.status).to eq('expired')
    end
  end

  context 'when the user has a depleted pass (0 credits)' do
    let(:student_pass) do
      create(:student_pass, :credit_based, user: student, academy: academy, credits_remaining: 0)
    end

    it 'does not create a new Booking' do
      student_pass
      expect { service.perform }.not_to change(Booking, :count)
    end

    it 'updates the pass status to depleted' do
      student_pass
      service.perform
      expect(student_pass.reload.status).to eq('depleted')
    end
  end
end
