# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    association :user
    status { 'pending_approval' }
    total_price_cents { 1000 }
    currency { 'USD' }
  end
end
