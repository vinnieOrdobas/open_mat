# frozen_string_literal: true

class Api::V1::AcademiesController < Api::V1::ApplicationController
  before_action :authenticate_request!

  def create
    return render json: { error: "Not Authorized" }, status: :unauthorized unless owner?

    result = create_academy(academy_params)

    return render json: { errors: result[:errors] }, status: :unprocessable_entity unless result[:success]

    render json: serialize_academy(result[:academy]), status: :created
  end

  private

  # Strong params for creating an academy
  def academy_params
    params.require(:academy).permit(
      :name,
      :email,
      :phone_number,
      :website,
      :description,
      :street_address,
      :city,
      :state_province,
      :postal_code,
      :country,
      :latitude,
      :longitude
    )
  end

  def owner?
    current_user.owner?
  end

  def create_academy(academy_params)
    Academies::CreateAcademy.new(current_user, academy_params).perform
  end

  def serialize_academy(academy)
    AcademySerializer.new(academy).as_json
  end
end
