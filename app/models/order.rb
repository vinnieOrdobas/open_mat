# frozen_string_literal: true

class Order < ApplicationRecord
  # --- Associations ---
  belongs_to :user

  has_many :order_line_items, dependent: :destroy
  has_many :passes, through: :order_line_items

  has_one :payment, dependent: :destroy

  # --- Validations ---
  validates :status, presence: true
  validates :total_price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # --- Enums ---
  enum status: {
    pending_approval: "pending_approval",
    approved: "approved",
    rejected: "rejected",
    completed: "completed",
    payment_failed: "payment_failed"
  }
end
