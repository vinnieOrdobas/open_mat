# frozen_string_literal: true

class Api::V1::OrdersController < Api::V1::ApplicationController
  before_action :authenticate_request!

  def index
    @orders = current_user.orders.order(created_at: :desc)

    render json: serialize_orders(@orders), status: :ok
  end

  def create
    result = Orders::CreateOrder.new(user: current_user, cart_items: order_params[:cart_items]).perform

    return render json: { errors: result[:errors] }, status: :bad_request unless result[:success]

    render json: serialize_orders(result[:order]), status: :created
  end

  private

  def order_params
    params.require(:order).permit(cart_items: [ :pass_id, :quantity ])
  end

  def serialize_orders(orders)
    return OrderSerializer.new(orders).as_json if orders.is_a?(Order)

    orders.map { |o| OrderSerializer.new(o).as_json }
  end
end
