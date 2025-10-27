# frozen_string_literal: true

FactoryBot.define do
  factory :pass do
    association :academy

    sequence(:name) { |n| "Pass #{n}" }
    description { 'A standard pass description.' }
    price_cents { 2000 }
    currency { 'USD' }
    pass_type { 'single' }
    is_active { true }

    trait :day_pass do
      pass_type { 'day_pass' }
      price_cents { 3000 }
    end

    trait :punch_card do
      pass_type { 'punch_card' }
      class_credits { 10 }
      price_cents { 25000 }
    end
  end
end
