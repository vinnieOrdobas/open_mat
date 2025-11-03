# frozen_string_literal: true

class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :class_schedule
  belongs_to :student_pass

  validates :user_id, uniqueness: {
    scope: :class_schedule_id,
    message: "has already booked this class"
  }
end
