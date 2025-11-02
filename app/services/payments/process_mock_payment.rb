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

        active_order_passes(@order)
      end

      { success: true, payment: payment }

    rescue StandardError => e
      { success: false, errors: [ e.message ], payment: nil }
    end

    private

    def check_order_ready
      return { success: false, errors: [ "Order is not awaiting approvals (status: #{@order.status})" ] } unless @order.awaiting_approvals?

      return { success: false, errors: [ "Not all line items have been approved" ] } unless @order.order_line_items.all?(&:approved?)

      nil
    end

    def active_order_passes(order)
      order.order_line_items.each { |line_item| activate_pass(line_item) }
    end

    def activate_pass(line_item)
      result = Passes::ActivatePasses.new(line_item: line_item).perform

      raise "Failed to activate pass for line item #{line_item.id}" unless result[:success]
    end
  end
end
