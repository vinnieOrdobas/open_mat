# frozen_string_literal: true

class Api::V1::AcademyOrderLineItemsController < Api::V1::ApplicationController
  before_action :authenticate_request!
  before_action :set_academy
  before_action :authorize_academy_owner!

  def index
    @line_items = filter_order_line_items(scope: @academy.order_line_items)

    render json: @line_items.order(created_at: :desc), each_serializer: OrderLineItemSerializer, status: :ok
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

  def filter_order_line_items(scope:)
    return scope unless params[:status].present?

    scope.where(status: params[:status])
  end
end
