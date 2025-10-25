# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :status, null: false, default: 'pending'
      t.integer :amount_cents, null: false
      t.string :currency, null: false
      t.string :processor, null: false
      t.string :processor_id, null: false

      t.timestamps
    end
  end
end
