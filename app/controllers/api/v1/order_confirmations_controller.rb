# frozen_string_literal: true

class Api::V1::OrderConfirmationsController < Api::V1::ApplicationController
  before_action :authenticate_request!
  before_action :set_order
  before_action :authorize_order_owner!

  def create
    result = Payments::ProcessMockPayment.new(order: @order).perform

    return render json: { errors: result[:errors] }, status: :unprocessable_entity unless result[:success]

    render json: serialize_payment(result[:payment]), status: :created
  end

  private

  def set_order
    @order = Order.find_by(id: params[:order_id])

    render json: { error: "Order not found" }, status: :not_found unless @order
  end

  def authorize_order_owner!
    return if @order.user_id == current_user.id

    render json: { error: "Not Authorized" }, status: :unauthorized
  end

  def serialize_payment(payment)
    PaymentSerializer.new(payment).as_json
  end
end
