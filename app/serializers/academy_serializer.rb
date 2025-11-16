# frozen_string_literal: true

class AcademySerializer < ApplicationSerializer
  attributes :id,
             :user_id,
             :name,
             :email,
             :phone_number,
             :website,
             :description,
             :street_address,
             :city,
             :state_province,
             :postal_code,
             :country,
             :latitude,
             :longitude,
             :created_at,
             :updated_at,
             :average_rating

  has_many :amenities
  has_many :passes
  has_many :reviews
  has_many :class_schedules
end
