# frozen_string_literal: true

class AddStatusToOrderLineItems < ActiveRecord::Migration[7.2]
  def change
    add_column :order_line_items, :status, :string, null: false, default: "pending_approval"
  end
end
