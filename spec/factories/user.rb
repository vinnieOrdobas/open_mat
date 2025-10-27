# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    firstname { 'Test' }
    lastname { 'User' }

    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }

    password { 'password123' }
    password_confirmation { 'password123' }
    role { 'student' }

    trait :owner do
      role { 'owner' }
    end
  end
end
