# frozen_string_literal: true

class Api::V1::ProfileController < Api::V1::ApplicationController
  before_action :authenticate_request!

  def show
    render json: @current_user, serializer: UserSerializer, status: :ok
  end
end
