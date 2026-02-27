class AddGithubRepoUrlToTeams < ActiveRecord::Migration[8.0]
  def change
    add_column :teams, :github_repo_url, :string
  end
end
