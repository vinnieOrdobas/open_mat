# frozen_string_literal: true

FactoryBot.define do
  factory :class_schedule do
    association :academy
    title { "All Levels Gi" }
    day_of_week { 1 }
    start_time { "19:00:00" }
    end_time { "20:30:00" }

    trait :tuesday_class do
      title { "No-Gi Fundamentals" }
      day_of_week { 2 }
      start_time { "18:00:00" }
      end_time { "19:00:00" }
    end
  end
end
