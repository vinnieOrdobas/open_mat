# frozen_string_literal: true

class User < ApplicationRecord
  # --- Secure Password ---
  has_secure_password

  # --- Associations ---
  # An 'owner' user can have many academies
  # We CANNOT delete a user if they still own an academy.
  has_many :academies, dependent: :restrict_with_error

  # A user can have many orders
  has_many :orders, dependent: :destroy

  # --- Validations ---
  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: true
  validates :role, presence: true

  # --- Enums (for clean, readable roles and ranks) ---
  enum role: {
    student: "student",
    owner: "owner",
    admin: "admin"
  }

  enum belt_rank: {
    white: "white",
    blue: "blue",
    purple: "purple",
    brown: "brown",
    black: "black"
  }
end
