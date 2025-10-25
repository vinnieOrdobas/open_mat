# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: 'pending'
      t.integer :total_price_cents, null: false, default: 0
      t.string :currency, null: false, default: 'EUR'

      t.timestamps
    end
  end
end
