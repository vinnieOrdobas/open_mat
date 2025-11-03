# frozen_string_literal: true

class ClassScheduleSerializer < ApplicationSerializer
  attributes :id,
             :academy_id,
             :title,
             :day_of_week,
             :start_time,
             :end_time,
             :created_at,
             :updated_at

def start_time
  object.start_time.strftime("%H:%M")
end

def end_time
  object.end_time.strftime("%H:%M")
end
end
