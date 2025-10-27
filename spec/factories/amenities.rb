# frozen_string_literal: true

FactoryBot.define do
  factory :amenity do
    sequence(:name) { |n| "Amenity #{n}" }
    category { 'facilities' }
    icon_name { 'default-icon' }
  end
end
