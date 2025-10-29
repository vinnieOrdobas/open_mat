# frozen_string_literal: true

module Payments
  class ProcessMockPayment
    def initialize(order:)
      @order = order
    end

    def perform
      return { success: false, errors: [ "Order is not pending approval (current status: #{@order.status})" ], payment: nil } unless @order.pending_approval?

      payment = nil

      ActiveRecord::Base.transaction do
        @order.update!(status: "approved")

        # In a real app, this is where we'd call Stripe API
        payment = @order.create_payment!(
          status: "succeeded", # Simulate success
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
  end
end
