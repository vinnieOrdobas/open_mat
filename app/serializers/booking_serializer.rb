# frozen_string_literal: true

class BookingSerializer < ApplicationSerializer
  attributes :id,
             :user_id,
             :created_at,
             :class_schedule,
             :student_pass

  def class_schedule
    ClassScheduleSerializer.new(object.class_schedule).as_json
  end

  def student_pass
    StudentPassSerializer.new(object.student_pass).as_json
  end
end
