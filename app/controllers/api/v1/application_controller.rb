# frozen_string_literal: true

class Api::V1::ApplicationController < ActionController::API
  def current_user
    @current_user ||= find_user_from_token
  end

  def authenticate_request!
    render json: { error: "Not Authorized" }, status: :unauthorized unless current_user
  end

  private

  def find_user_from_token
    return unless token

    payload = JsonWebToken.decode(token)
    return unless payload

    User.find_by(id: payload[:user_id])
  end

  def token
    return unless request.headers["Authorization"]

    @token ||= request.headers["Authorization"].split(" ").last
  end
end
