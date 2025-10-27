# frozen_string_literal: true

FactoryBot.define do
  factory :academy_amenity do
    association :academy
    association :amenity
  end
end
