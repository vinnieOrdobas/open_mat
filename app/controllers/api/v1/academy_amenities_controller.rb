# frozen_string_literal: true

class Api::V1::AcademyAmenitiesController < Api::V1::ApplicationController
  before_action :authenticate_request!
  before_action :set_academy
  before_action :authorize_academy_owner!

  def create
    amenity = Amenity.find_by(id: academy_amenity_params[:amenity_id])

    return render json: { error: "Amenity not found" }, status: :not_found unless amenity

    academy_amenity = @academy.academy_amenities.build(amenity: amenity)

    return render json: { errors: academy_amenity.errors.full_messages }, status: :unprocessable_entity unless academy_amenity.save

    render json: { id: academy_amenity.id }, status: :created
  end


  def destroy
    academy_amenity = @academy.academy_amenities.find_by(id: params[:id])

    return render json: { error: "Academy amenity link not found" }, status: :not_found unless academy_amenity

    academy_amenity.destroy
    head :no_content
  end

  private

  def set_academy
    @academy = Academy.find_by(id: params[:academy_id])
    render json: { error: "Academy not found" }, status: :not_found unless @academy
  end


  def authorize_academy_owner!
    return if @academy.user_id == current_user.id
    render json: { error: "Not Authorized" }, status: :unauthorized
  end

  def academy_amenity_params
    params.require(:academy_amenity).permit(:amenity_id)
  end
end
