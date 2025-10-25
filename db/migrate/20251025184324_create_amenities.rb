# frozen_string_literal: true

class CreateAmenities < ActiveRecord::Migration[7.2]
  def change
    create_table :amenities do |t|
      t.string :name, null: false
      t.string :category, null: false
      t.string :icon_name

      t.timestamps
    end
    add_index :amenities, :name, unique: true
  end
end
