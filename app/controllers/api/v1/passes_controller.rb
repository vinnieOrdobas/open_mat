# frozen_string_literal: true

class Api::V1::PassesController < Api::V1::ApplicationController
  before_action :authenticate_request!
  before_action :set_academy
  before_action :authorize_academy_owner!
  before_action :set_pass, only: [ :update, :destroy ]

  def create
    result = create_pass(pass_params)

    return render json: { errors: result[:errors] }, status: :unprocessable_entity unless result[:success]

    render json: serialize_pass(result[:pass]), status: :created
  end

  def update
    result = update_pass(@pass, pass_params)

    return render json: { errors: result[:errors] }, status: :unprocessable_entity unless result[:success]

    render json: serialize_pass(result[:pass]), status: :ok
  end

  def destroy
    return render json: { errors: @pass.errors.full_messages }, status: :unprocessable_entity unless @pass.destroy

    head :no_content
  end

  private

  def create_pass(params)
    Passes::CreatePass.new(@academy, params).perform
  end

  def update_pass(pass, params)
    Passes::UpdatePass.new(pass, params).perform
  end

  def serialize_pass(pass)
    PassSerializer.new(pass).as_json
  end

  def set_academy
    @academy = Academy.find_by(id: params[:academy_id])

    render json: { error: "Academy not found" }, status: :not_found unless @academy
  end

  def set_pass
    @pass = @academy.passes.find_by(id: params[:id])

    render json: { error: "Pass not found for this academy" }, status: :not_found unless @pass
  end

  def authorize_academy_owner!
    return if @academy.user_id == current_user.id

    render json: { error: "Not Authorized" }, status: :unauthorized
  end

  def pass_params
    params.require(:pass).permit(
      :name,
      :description,
      :price_cents,
      :pass_type,
      :currency,
      :class_credits,
      :is_active
    )
  end
end
