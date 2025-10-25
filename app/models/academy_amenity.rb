# frozen_string_literal: true

class AcademyAmenity < ApplicationRecord
  # --- Associations ---
  belongs_to :academy
  belongs_to :amenity

  # --- Validations ---
  validates :amenity_id, uniqueness: { scope: :academy_id }
end
