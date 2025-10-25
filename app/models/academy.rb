# frozen_string_literal: true

class Academy < ApplicationRecord
  # --- Associations ---
  belongs_to :user # The owner

  has_many :passes, dependent: :destroy

  has_many :academy_amenities, dependent: :destroy
  has_many :amenities, through: :academy_amenities

  # --- Validations ---
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :street_address, presence: true
  validates :city, presence: true
  validates :country, presence: true
end
