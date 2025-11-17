class Attachment < ApplicationRecord
  belongs_to :attachable, polymorphic: true

  validates :kind, presence: true
end
