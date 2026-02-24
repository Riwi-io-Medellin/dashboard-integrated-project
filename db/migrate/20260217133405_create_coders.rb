# frozen_string_literal: true

class CreateCoders < ActiveRecord::Migration[8.0]
  def change
    create_table :coders do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.integer :student_id
      t.string :national_id
      t.string :email
      t.string :phone
      t.string :gender
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end

    add_index :coders, :student_id, unique: true
    add_index :coders, :email
  end
end
