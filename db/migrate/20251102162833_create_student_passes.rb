# frozen_string_literal: true

class CreateStudentPasses < ActiveRecord::Migration[7.2]
  def change
    create_table :student_passes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :pass, null: false, foreign_key: true
      t.references :order_line_item, null: false, foreign_key: true
      t.references :academy, null: false, foreign_key: true
      t.string :status, null: false, default: "active"

      t.datetime :expires_at
      t.integer :credits_remaining

      t.timestamps
    end
  end
end
