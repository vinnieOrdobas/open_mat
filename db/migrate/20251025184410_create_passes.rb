# frozen_string_literal: true

class CreatePasses < ActiveRecord::Migration[7.2]
  def change
    create_table :passes do |t|
      t.references :academy, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :price_cents, null: false, default: 0
      t.string :currency, null: false, default: 'EUR'
      t.string :pass_type, null: false
      t.integer :class_credits
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end
  end
end
