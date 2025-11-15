# frozen_string_literal: true

class ReviewSerializer < ApplicationSerializer
  attributes :id,
             :academy_id,
             :rating,
             :comment,
             :created_at

  attribute :user_id do
    object.user_id
  end

  attribute :username do
    object.user.username
  end
end