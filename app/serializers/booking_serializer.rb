# frozen_string_literal: true

class BookingSerializer < ApplicationSerializer
  attributes :id,
             :user_id,
             :created_at

  belongs_to :class_schedule, serializer: ClassScheduleSerializer
  belongs_to :student_pass, serializer: StudentPassSerializer
end
