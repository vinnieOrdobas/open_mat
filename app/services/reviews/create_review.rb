# frozen_string_literal: true

module Reviews
  class CreateReview
    def initialize(user:, academy:, params:)
      @user = user
      @academy = academy
      @params = params
    end

    def perform
      return validation_error unless user_has_attended?

      review = @academy.reviews.build(@params)
      review.user = @user

      return { success: false, errors: review.errors.full_messages } unless review.save

      { success: true, review: review }
    end

    private

    def user_has_attended?
      @user.bookings.joins(:class_schedule)
           .where(class_schedules: { academy_id: @academy.id })
           .exists?
    end

    def validation_error
      { success: false, errors: ['You can only review academies you have booked a class with'] }
    end
  end
end
