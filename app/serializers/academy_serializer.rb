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
             :updated_at

  # As we discussed, we can add associations here later
  # when we need them, e.g.:
  #
  # has_many :amenities
  # has_many :passes
end
