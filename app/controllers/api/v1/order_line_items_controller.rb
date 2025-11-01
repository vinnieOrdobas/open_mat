# frozen_string_literal: true

class Api::V1::OrderLineItemsController < Api::V1::ApplicationController
  before_action :authenticate_request!
  before_action :set_order_line_item
  before_action :authorize_line_item_owner!

  def update
    result = OrderLineItems::UpdateStatus.new(
      line_item: @order_line_item,
      new_status: update_params[:status]
    ).perform

    return render json: { errors: result[:errors] }, status: :unprocessable_entity unless result[:success]

    render json: serialize_line_item(result[:line_item]), status: :ok
  end

  private

  def set_order_line_item
    @order_line_item = OrderLineItem.find_by(id: params[:id])
    render json: { error: "Order line item not found" }, status: :not_found unless @order_line_item
  end

  def authorize_line_item_owner!
    academy = @order_line_item.pass.academy

    return if academy.user_id == current_user.id

    render json: { error: "Not Authorized" }, status: :unauthorized
  end

  def update_params
    params.require(:order_line_item).permit(:status)
  end

  def serialize_line_item(line_item)
    OrderLineItemSerializer.new(line_item).as_json
  end
end
