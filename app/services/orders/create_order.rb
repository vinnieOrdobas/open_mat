# frozen_string_literal: true

module Orders
  class CreateOrder
    def initialize(user:, cart_items:)
      @user = user
      @cart_items = cart_items
      @passes = []
    end

    def perform
      return { success: false, errors: [ "Cart is empty" ] } if @cart_items.blank?
      return find_and_validate_passes if find_and_validate_passes

      create_order_in_transaction

    rescue ActiveRecord::RecordInvalid => e
      { success: false, errors: [ e.message ] }
    end

    private

    def find_and_validate_passes
      @cart_items.each do |item|
        pass = Pass.find_by(id: item[:pass_id])
        return { success: false, errors: [ "Pass with id #{item[:pass_id]} not found" ] } if pass.nil?
        @passes << pass
      end
      nil # Success
    end

    def create_order_in_transaction
      order = nil
      ActiveRecord::Base.transaction do
        order = @user.orders.build(
          status: "awaiting_approvals",
          currency: @passes.first.currency
        )
        order.save!

        build_line_items!(order)
        update_total!(order)
      end

      { success: true, order: order }
    end

    def build_line_items!(order)
      @cart_items.each_with_index do |item, index|
        pass = @passes[index]
        order.order_line_items.create!(
          pass: pass,
          quantity: item[:quantity].to_i,
          price_at_purchase_cents: pass.price_cents
        )
      end
    end

    def update_total!(order)
      total = order.order_line_items.sum("quantity * price_at_purchase_cents")
      order.update!(total_price_cents: total)
    end
  end
end
