class AddSocialsToCoders < ActiveRecord::Migration[8.0]
  def change
    add_column :coders, :github_user, :string
    add_column :coders, :discord_user, :string
  end
end
