# frozen_string_literal: true

class Api::V1::AcademiesController < Api::V1::ApplicationController
  before_action :authenticate_request!
  before_action :set_academy, only: [ :show, :update ]
  before_action :authorize_owner!, only: [ :create ]
  before_action :authorize_academy_owner!, only: [ :show, :update ]

  def create
    return render json: { error: "Not Authorized" }, status: :unauthorized unless owner?

    result = create_academy(academy_params)

    return render json: { errors: result[:errors] }, status: :unprocessable_entity unless result[:success]

    render json: serialize_academy(result[:academy]), status: :created
  end

  def show
    render json: serialize_academy(@academy), status: :ok
  end

  def update
    result = update_academy(@academy, academy_params)

    return render json: { errors: result[:errors] }, status: :unprocessable_entity unless result[:success]

    render json: serialize_academy(result[:academy]), status: :ok
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

  def update_academy(academy, params)
    Academies::UpdateAcademy.new(academy, params).perform
  end

  def serialize_academy(academy)
    AcademySerializer.new(academy).as_json
  end

  def set_academy
    @academy = Academy.find_by(id: params[:id])
    render json: { error: "Academy not found" }, status: :not_found unless @academy
  end

  def authorize_owner!
    return if current_user.owner?

    render json: { error: "Not Authorized" }, status: :unauthorized
  end

  def authorize_academy_owner!
    return if @academy.user_id == current_user.id

    render json: { error: "Not Authorized" }, status: :unauthorized
  end
end
