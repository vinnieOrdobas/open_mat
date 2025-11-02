# frozen_string_literal: true

class StudentPassSerializer < ApplicationSerializer
  attributes :id,
             :academy_id,
             :status,
             :expires_at,
             :credits_remaining

  belongs_to :pass, serializer: PassSerializer
end
