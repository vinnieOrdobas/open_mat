# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    association :order
    status { 'succeeded' }
    amount_cents { order&.total_price_cents || 1000 }
    currency { order&.currency || 'USD' }
    processor { 'mock' }
    sequence(:processor_id) { |n| "mock_ch_#{n}" }
  end
end
