# frozen_string_literal: true

class ApplicationSerializer < ActiveModel::Serializer
  def created_at
    # object is the model instance being serialized
    object.created_at.iso8601
  end

  def updated_at
    object.updated_at.iso8601
  end
end
