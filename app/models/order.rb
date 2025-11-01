# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :user

  has_many :order_line_items, dependent: :destroy
  has_many :passes, through: :order_line_items

  has_one :payment, dependent: :destroy

  # --- Validations ---
  validates :status, presence: true
  validates :total_price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # --- Enums ---
  enum status: {
    awaiting_approvals: "awaiting_approvals",
    ready_for_payment: "ready_for_payment",
    completed: "completed",
    rejected: "rejected"
  }
end
