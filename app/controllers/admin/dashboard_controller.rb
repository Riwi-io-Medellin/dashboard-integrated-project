# frozen_string_literal: true

# Admin dashboard displaying statistics and overview
module Admin
  class DashboardController < BaseController
    def index
      @total_coders = Coder.count
      @total_teams = Team.count
      @total_groups = Group.count
      @groups_with_stats = Group.left_joins(:coders, :teams)
                                .select("groups.*, COUNT(DISTINCT coders.id) as coders_count, COUNT(DISTINCT teams.id) as teams_count")
                                .group("groups.id")
                                .order(:name)
      @recent_teams = Team.includes(:group, :coders).order(created_at: :desc).limit(5)
      @unassigned_coders = Coder.left_joins(:team_member).where(team_members: { id: nil }).count
    end
  end
end
