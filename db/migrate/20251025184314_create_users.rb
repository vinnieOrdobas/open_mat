# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :firstname, null: false
      t.string :lastname, null: false
      t.string :email, null: false
      t.string :username, null: false
      t.string :password_digest, null: false
      t.string :nationality
      t.string :phone_number
      t.date :date_of_birth
      t.string :belt_rank
      t.string :role, null: false, default: 'student'

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
  end
end
