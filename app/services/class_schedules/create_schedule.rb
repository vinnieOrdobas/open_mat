# frozen_string_literal: true

module ClassSchedules
  class CreateSchedule
    def initialize(academy:, params:)
      @academy = academy
      @params = params
    end

    def perform
      schedule = @academy.class_schedules.build(@params)

      return { success: false, errors: schedule.errors.full_messages } unless schedule.save

      { success: true, schedule: schedule }
    end
  end
end
