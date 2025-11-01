# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    association :user

    status { 'awaiting_approvals' }
    total_price_cents { 1000 }
    currency { 'USD' }
  end
end
