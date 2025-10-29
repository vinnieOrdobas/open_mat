# frozen_string_literal: true

FactoryBot.define do
  factory :order_line_item do
    association :order
    association :pass
    quantity { 1 }
    price_at_purchase_cents { pass&.price_cents || 1000 }
  end
end
