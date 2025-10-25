# frozen_string_literal: true

class CreateAcademyAmenities < ActiveRecord::Migration[7.2]
  def change
    create_table :academy_amenities do |t|
      t.references :academy, null: false, foreign_key: true
      t.references :amenity, null: false, foreign_key: true

      t.timestamps
    end
  end
end
