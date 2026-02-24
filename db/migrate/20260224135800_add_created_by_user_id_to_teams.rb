class AddCreatedByUserIdToTeams < ActiveRecord::Migration[8.0]
  def change
    add_reference :teams, :created_by_user, foreign_key: { to_table: :users }, null: true
  end
end
