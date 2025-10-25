# frozen_string_literal: true

class Payment < ApplicationRecord
  # --- Associations ---
  belongs_to :order

  # --- Validations ---
  validates :status, presence: true
  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :processor, presence: true
  validates :processor_id, presence: true # The Stripe/PayPal charge ID

  # --- Enums ---
  enum status: {
    pending: "pending",
    succeeded: "succeeded",
    failed: "failed"
  }
end
