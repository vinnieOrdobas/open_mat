# frozen_string_literal: true

class Pass < ApplicationRecord
  # --- Associations ---
  belongs_to :academy

  has_many :order_line_items
  has_many :orders, through: :order_line_items

  # --- Validations ---
  validates :name, presence: true
  validates :pass_type, presence: true
  validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # A punch_card must have a number of credits
  validates :class_credits, presence: true, numericality: { only_integer: true, greater_than: 0 }, if: :punch_card?

  # --- Enums (for logic) ---
  enum pass_type: {
    single: "single",         # A single class pass
    day_pass: "day_pass",     # Unlimited classes for 1 day
    week_pass: "week_pass",   # Unlimited classes for 7 days
    month_pass: "month_pass", # Unlimited classes for 30 days
    punch_card: "punch_card"  # A card with X number of classes
  }

  # --- Helper Methods ---
  def punch_card?
    pass_type == "punch_card"
  end
end
