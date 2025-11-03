# frozen_string_literal: true

class CreateClassSchedules < ActiveRecord::Migration[7.2]
  def change
    create_table :class_schedules do |t|
      t.references :academy, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :day_of_week, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false

      t.timestamps
    end
  end
end
