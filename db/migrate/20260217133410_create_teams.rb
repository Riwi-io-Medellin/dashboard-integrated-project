# frozen_string_literal: true

class CreateTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.string :project_category, null: false
      t.references :group, null: false, foreign_key: true
      t.string :token, null: false
      t.datetime :registered_at

      t.timestamps
    end

    add_index :teams, :token, unique: true
  end
end
