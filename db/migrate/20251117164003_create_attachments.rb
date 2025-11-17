# frozen_string_literal: true

class CreateAttachments < ActiveRecord::Migration[7.1]
  def change
    create_table :attachments do |t|
      t.string :attachable_type, null: false
      t.integer :attachable_id, null: false

      t.string :kind, null: false
      t.string :url

      t.timestamps
    end

    add_index :attachments, %i[attachable_type attachable_id]
    add_index :attachments, :kind
  end
end
