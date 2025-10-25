# frozen_string_literal: true

class CreateOrderLineItems < ActiveRecord::Migration[7.2]
  def change
    create_table :order_line_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :pass, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.integer :price_at_purchase_cents, null: false, default: 0

      t.timestamps
    end
  end
end
