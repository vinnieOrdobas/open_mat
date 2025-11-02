# frozen_string_literal: true

FactoryBot.define do
  factory :student_pass do
    association :user
    association :academy
    association :pass
    association :order_line_item

    status { 'active' }
    expires_at { nil }
    credits_remaining { nil }

    trait :time_based do
      expires_at { Time.current + 7.days }
    end

    trait :credit_based do
      credits_remaining { 10 }
    end
  end
end
