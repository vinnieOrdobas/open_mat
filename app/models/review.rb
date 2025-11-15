# frozen_string_literal: true

class Review < ApplicationRecord
  belongs_to :user
  belongs_to :academy

  validates :rating, presence: true, inclusion: {
    in: 1..5,
    message: "must be between 1 and 5"
  }

  validates :user_id, uniqueness: {
    scope: :academy_id,
    message: "has already reviewed this academy"
  }
end
