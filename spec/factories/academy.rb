# frozen_string_literal: true

FactoryBot.define do
  factory :academy do
    association :user

    sequence(:name) { |n| "Test Academy #{n}" }
    sequence(:email) { |n| "academy#{n}@example.com" }
    street_address { '123 Main St' }
    city { 'Anytown' }
    country { 'USA' }
    payout_info { 'my-secret-paypal-email' }
  end
end
