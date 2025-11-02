# frozen_string_literal: true

class StudentPass < ApplicationRecord
  belongs_to :user
  belongs_to :pass
  belongs_to :order_line_item
  belongs_to :academy

  enum status: {
    active: "active",
    expired: "expired",
    depleted: "depleted"
  }

  validates :status, presence: true
  validate :time_or_credit_based

  private

  def time_or_credit_based
    if expires_at.present? && credits_remaining.present?
      errors.add(:base, "Pass cannot be both time-based and credit-based")
    end

    # if expires_at.blank? && credits_remaining.blank?
    #   # This allows for a simple "unlimited" pass, but our logic
    #   # currently creates either time or credit. We'll allow it for now.
    #   # A 'single' or 'day_pass' should have *one* of these set by the ActivatePasses service.
    # end
  end
end
