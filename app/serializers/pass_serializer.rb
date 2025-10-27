# frozen_string_literal: true

class PassSerializer < ApplicationSerializer
  attributes :id,
             :academy_id,
             :name,
             :description,
             :price_cents,
             :currency,
             :pass_type,
             :class_credits, # Will be null unless pass_type is 'punch_card'
             :is_active,
             :created_at,
             :updated_at
end
