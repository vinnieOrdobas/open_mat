# frozen_string_literal: true

class Academy < ApplicationRecord
  belongs_to :user

  has_many :passes, dependent: :destroy
  has_many :order_line_items, through: :passes

  has_many :academy_amenities, dependent: :destroy
  has_many :amenities, through: :academy_amenities
  has_many :class_schedules, dependent: :destroy
  has_many :reviews, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :street_address, presence: true
  validates :city, presence: true
  validates :country, presence: true
end
