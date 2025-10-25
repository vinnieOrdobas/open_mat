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

  # We could also add associations here later, like:
  # has_many :academies
  # has_many :orders
end
