# frozen_string_literal: true

class Api::V1::SessionsController < Api::V1::ApplicationController
  def create
    user = Sessions::AuthenticateUser.new(
      session_params[:email],
      session_params[:password]
    ).authenticate

    return render json: { error: "Invalid email or password" }, status: :unauthorized unless user

    token = JsonWebToken.encode(user_id: user.id)

    render json: { token: token, exp: 24.hours.from_now.to_i }, status: :ok
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
