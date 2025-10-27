# frozen_string_literal: true

class Api::V1::AmenitiesController < Api::V1::ApplicationController
  def index
    @amenities = Amenity.all

    # Render them using the serializer we just created
    render json: @amenities, each_serializer: AmenitySerializer, status: :ok
  end
end
