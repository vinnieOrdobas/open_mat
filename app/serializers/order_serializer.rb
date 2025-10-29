# frozen_string_literal: true

class OrderSerializer < ApplicationSerializer
  attributes :id,
             :user_id,
             :status,
             :total_price_cents,
             :currency,
             :created_at,
             :updated_at

  # Include the line items belonging to this order
  has_many :order_line_items, serializer: OrderLineItemSerializer
end
