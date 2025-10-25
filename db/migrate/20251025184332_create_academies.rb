# frozen_string_literal: true

class CreateAcademies < ActiveRecord::Migration[7.2]
  def change
    create_table :academies do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone_number
      t.string :website
      t.text :description
      t.string :street_address, null: false
      t.string :city, null: false
      t.string :state_province
      t.string :postal_code
      t.string :country, null: false
      t.decimal :latitude
      t.decimal :longitude
      t.string :payout_info

      t.timestamps
    end
    add_index :academies, :email, unique: true
  end
end
