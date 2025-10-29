# frozen_string_literal: true

class Api::V1::OrdersController < Api::V1::ApplicationController
  before_action :authenticate_request!

  # POST /api/v1/orders
  def create
    result = Orders::CreateOrder.new(user: current_user, cart_items: order_params[:cart_items]).perform

    return render json: { errors: result[:errors] }, status: :bad_request unless result[:success]

    render json: serialize_order(result[:order]), status: :created
  end

  # We will add the 'index' action here later for Story 3

  private

  def order_params
    params.require(:order).permit(cart_items: [ :pass_id, :quantity ])
  end

  def serialize_order(order)
    OrderSerializer.new(order).as_json
  end
end
