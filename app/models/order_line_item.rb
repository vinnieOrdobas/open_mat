# frozen_string_literal: true

class OrderLineItem < ApplicationRecord
  # --- Associations ---
  belongs_to :order
  belongs_to :pass

  # --- Validations ---
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price_at_purchase_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Optional: Prevents adding the same pass twice (e.g., just update quantity)
  validates :pass_id, uniqueness: { scope: :order_id }
end
