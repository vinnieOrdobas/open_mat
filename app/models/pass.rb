# frozen_string_literal: true

class Pass < ApplicationRecord
  belongs_to :academy

  has_many :order_line_items
  has_many :orders, through: :order_line_items

  validates :name, presence: true
  validates :pass_type, presence: true
  validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :class_credits, presence: true, numericality: { only_integer: true, greater_than: 0 }, if: :punch_card?

  enum pass_type: {
    single: "single",
    day_pass: "day_pass",
    week_pass: "week_pass",
    month_pass: "month_pass",
    punch_card: "punch_card"
  }

  def punch_card?
    pass_type == "punch_card"
  end
end
