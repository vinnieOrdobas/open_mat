# frozen_string_literal: true

FactoryBot.define do
  factory :booking do
    association :user
    association :class_schedule
    association :student_pass
  end
end
