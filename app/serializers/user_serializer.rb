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

  # We can add this later for an owner-specific view
  # has_many :academies
end