# frozen_string_literal: true

class Api::V1::ProfileController < Api::V1::ApplicationController
  before_action :authenticate_request!

  def show
    render json: serialize_profile(current_user), status: :ok
  end

  def update
    return render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity unless update_profile

    render json: serialize_profile(current_user), status: :ok
  end

  private

  def profile_params
    params.require(:user).permit(:firstname, :lastname, :belt_rank)
  end

  def update_profile
    current_user.update(profile_params)
  end

  def serialize_profile(user)
    UserSerializer.new(user).as_json
  end
end
