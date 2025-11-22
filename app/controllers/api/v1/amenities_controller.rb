# frozen_string_literal: true

class Api::V1::AmenitiesController < Api::V1::ApplicationController
  def index
    render json: Amenity.all, each_serializer: AmenitySerializer, status: :ok
  end
end
