# frozen_string_literal: true

module Bookings
  class CreateBooking
    def initialize(user:, class_schedule:)
      @user = user
      @class_schedule = class_schedule
      @academy = @class_schedule.academy
      @active_pass = nil
    end

    def perform
      return validation_errors if validation_errors

      create_booking_and_redeem_pass

    rescue ActiveRecord::RecordInvalid => e
      { success: false, errors: [ e.message ] }
    end

    private

    def validation_errors
      check_booking_exists? || check_active_pass_exists? || check_pass_is_usable?
    end

    def check_booking_exists?
      { success: false, errors: [ "You have already booked this class" ] } if booking_exists?

      nil
    end

    def check_active_pass_exists?
      @active_pass = StudentPass.find_by(
        user: @user,
        academy: @academy,
        status: "active"
      )

      return { success: false, errors: [ "No active pass found for this academy" ] } unless @active_pass

      nil
    end

    def check_pass_is_usable?
      check_time_based_pass || check_credit_based_pass
    end

    def check_time_based_pass
      return unless @active_pass.expires_at.present?

      if pass_expired?
        @active_pass.update(status: "expired")
        return { success: false, errors: [ "Your pass for this academy is expired" ] }
      end

      nil
    end

    def check_credit_based_pass
      return unless credit_based?

      unless credits_remaining?
        @active_pass.update(status: "depleted")
        return { success: false, errors: [ "Your pass for this academy is out of credits" ] }
      end

      nil
    end


    def create_booking_and_redeem_pass
      booking = nil
      ActiveRecord::Base.transaction do
        booking = @user.bookings.create!(
          class_schedule: @class_schedule,
          student_pass: @active_pass
        )

        redeem_pass!
      end

      { success: true, booking: booking }
    end

    def redeem_pass!
      return unless credits_remaining?

      @active_pass.decrement!(:credits_remaining)

      @active_pass.update!(status: "depleted") unless credits_remaining?
    end

    def booking_exists?
      Booking.exists?(user: @user, class_schedule: @class_schedule)
    end

    def pass_expired?
      @active_pass.expires_at < Time.current
    end

    def credits_remaining?
      credit_based? && @active_pass.credits_remaining > 0
    end

    def credit_based?
      @active_pass.credits_remaining.present?
    end
  end
end
