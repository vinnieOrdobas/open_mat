# frozen_string_literal: true

class Amenity < ApplicationRecord
  # --- Associations ---
  has_many :academy_amenities, dependent: :destroy
  has_many :academies, through: :academy_amenities

  # --- Validations ---
  validates :name, presence: true, uniqueness: true
  validates :category, presence: true

  # --- Enums ---
  enum category: {
    facilities: "facilities",     # e.g., Showers, Changing Rooms
    equipment: "equipment",       # e.g., Weight Room, Gi Rentals
    convenience: "convenience"    # e.g., Free Wi-Fi, Parking
  }
end
