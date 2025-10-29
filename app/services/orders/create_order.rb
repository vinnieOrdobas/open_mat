# frozen_string_literal: true

module Orders
  class CreateOrder
    def initialize(user:, cart_items:)
      @user = user
      @cart_items = cart_items
      @order = @user.orders.build(status: "pending_approval")
    end

    def perform
      ActiveRecord::Base.transaction do
        @order.save!

        build_line_items!

        update_total!
      end

      { success: true, order: @order }

    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
      { success: false, errors: [ e.message ], order: nil }
    end

    private

    def build_line_items!
      @cart_items.each do |item|
        pass = Pass.find(item[:pass_id])

        @order.order_line_items.create!(
          pass: pass,
          quantity: item[:quantity].to_i,
          price_at_purchase_cents: pass.price_cents
        )
      end
    end

    def update_total!
      total = @order.order_line_items.sum("quantity * price_at_purchase_cents")

      @order.update!(total_price_cents: total, currency: @order.order_line_items.first.pass.currency)
    end
  end
end
