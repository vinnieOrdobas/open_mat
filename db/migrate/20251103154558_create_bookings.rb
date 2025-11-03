# frozen_string_literal: true

class CreateBookings < ActiveRecord::Migration[7.1]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :class_schedule, null: false, foreign_key: true
      t.references :student_pass, null: false, foreign_key: true

      t.timestamps
    end

    add_index :bookings, %i[user_id class_schedule_id], unique: true
  end
end
