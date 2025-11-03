# frozen_string_literal: true

class ClassSchedule < ApplicationRecord
  belongs_to :academy

  validates :title, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true

  validates :day_of_week, presence: true, inclusion: {
    in: 0..6,
    message: "must be a valid day (0-6)"
  }

  validate :end_time_after_start_time

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?

    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end
end
