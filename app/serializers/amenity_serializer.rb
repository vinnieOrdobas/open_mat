# frozen_string_literal: true

class AmenitySerializer < ApplicationSerializer
  attributes :id,
             :name,
             :category,
             :icon_name,
             :created_at,
             :updated_at
end
