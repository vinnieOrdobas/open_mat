# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  attributes :id,
             :username,
             :email,
             :firstname,
             :lastname,
             :role,
             :belt_rank,
             :created_at,
             :updated_at

  has_one :headshot, serializer: AttachmentSerializer
  has_many :orders

  # has_many :academies
  has_many :bookings, serializer: BookingSerializer
end
