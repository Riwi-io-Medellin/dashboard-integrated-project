class AddNeedsOpenaiApiToTeams < ActiveRecord::Migration[8.0]
  def change
    add_column :teams, :needs_openai_api, :boolean, default: false, null: false
  end
end
