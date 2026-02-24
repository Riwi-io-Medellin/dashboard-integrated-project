# frozen_string_literal: true

class CreateTeamMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :team_members do |t|
      t.references :team, null: false, foreign_key: true
      t.references :coder, null: false, foreign_key: true
      t.string :role, null: false, default: "member"

      t.timestamps
    end

    add_index :team_members, [ :team_id, :coder_id ], unique: true
    add_index :team_members, :coder_id, unique: true, name: "index_team_members_on_coder_unique"
  end
end
