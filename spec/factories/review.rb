# frozen_string_literal: true

FactoryBot.define do
  factory :review do
    association :user
    association :academy
    rating { 5 }
    comment { "This place is great! Highly recommend." }
  end
end
