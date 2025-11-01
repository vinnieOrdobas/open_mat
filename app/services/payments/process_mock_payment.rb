# frozen_string_literal: true

module Payments
  class ProcessMockPayment
    def initialize(order:)
      @order = order
    end

    def perform
      return check_order_ready if check_order_ready

      payment = nil

      ActiveRecord::Base.transaction do
        payment = @order.create_payment!(
          status: "succeeded",
          amount_cents: @order.total_price_cents,
          currency: @order.currency,
          processor: "mock",
          processor_id: "mock_ch_#{SecureRandom.hex(8)}"
        )

        @order.update!(status: "completed")
      end

      { success: true, payment: payment }

    rescue ActiveRecord::RecordInvalid => e
      { success: false, errors: e.record.errors.full_messages, payment: nil }
    end

    private

    def check_order_ready
      return { success: false, errors: [ "Order is not awaiting approvals (status: #{@order.status})" ] } unless @order.awaiting_approvals?

      return { success: false, errors: [ "Not all line items have been approved" ] } unless @order.order_line_items.all?(&:approved?)

      nil
    end
  end
end
