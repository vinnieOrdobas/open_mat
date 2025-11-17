# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :academies, dependent: :restrict_with_error
  has_many :orders, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :student_passes, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  has_one :headshot, -> { where(kind: "headshot") }, class_name: "Attachment", as: :attachable, dependent: :destroy

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: true
  validates :role, presence: true

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
