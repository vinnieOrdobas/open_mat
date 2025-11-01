# frozen_string_literal: true

class OrderLineItem < ApplicationRecord
  belongs_to :order
  belongs_to :pass

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price_at_purchase_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validates :pass_id, uniqueness: { scope: :order_id }

  enum status: {
    pending_approval: "pending_approval",
    approved: "approved",
    rejected: "rejected"
  }
end
