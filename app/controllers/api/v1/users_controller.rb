# frozen_string_literal: true

class Api::V1::UsersController < Api::V1::ApplicationController
  def create
    # Update this line to call the new method name
    result = Users::RegisterUser.new(user_params).register

    return render json: { errors: result[:errors] }, status: :unprocessable_entity unless result[:success]

    render json: serialize_user(user: result[:user]), status: :created
  end

  private

  def user_params
    params.require(:user).permit(
      :firstname,
      :lastname,
      :email,
      :username,
      :password,
      :password_confirmation
    )
  end

  def serialize_user(user:)
    UserSerializer.new(user).as_json
  end
end
