# frozen_string_literal: true

class OrderLineItemSerializer < ApplicationSerializer
  attributes :id,
             :order_id,
             :pass_id,
             :quantity,
             :price_at_purchase_cents

  # Optional: Include details about the pass purchased
  # belongs_to :pass, serializer: PassSerializer
end
