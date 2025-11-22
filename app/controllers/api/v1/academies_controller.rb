# frozen_string_literal: true

class Api::V1::AcademiesController < Api::V1::ApplicationController
  before_action :authenticate_request!, except: %i[index show]
  before_action :set_academy, only: %i[show update]
  before_action :authorize_owner!, only: %i[create]
  before_action :authorize_academy_owner!, only: %i[update]

  def index
    @academies = search_query

    render json: @academies, each_serializer: AcademySerializer, status: :ok
  end

  def show
    render json: serialize_academy(@academy), status: :ok
  end

  def create
    return render json: { error: "Not Authorized" }, status: :unauthorized unless owner?

    result = create_academy(academy_params)

    return render json: { errors: result[:errors] }, status: :unprocessable_entity unless result[:success]

    render json: serialize_academy(result[:academy]), status: :created
  end

  def update
    result = update_academy(@academy, academy_params)

    return render json: { errors: result[:errors] }, status: :unprocessable_entity unless result[:success]

    render json: serialize_academy(result[:academy]), status: :ok
  end

  private

  def search_query
    query = Academies::SearchQuery.new

    query = query.by_term(params[:term]) if params[:term].present?
    query = query.with_amenity_ids(Array(params[:amenity_ids]).map(&:to_i)) if params[:amenity_ids].present?
    query = query.by_pass_types(params[:pass_types]) if params[:pass_types].present?
    query = query.by_class_days(Array(params[:class_days]).map(&:to_i)) if params[:class_days].present?
    query = query.by_countries(params[:countries]) if params[:countries].present?

    query.results
  end

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
    @academy = Academy.includes(:amenities, :passes, :reviews, :class_schedules, :attachments).find_by(id: params[:id])
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
