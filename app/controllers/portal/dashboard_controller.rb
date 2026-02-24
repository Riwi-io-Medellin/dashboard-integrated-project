# frozen_string_literal: true

# Portal dashboard for coders — shows welcome and team status
module Portal
  class DashboardController < BaseController
    def index
      @coder = current_user.coder
      @team = @coder&.team

      # Fallback: show team if current user created it (even if not linked as coder)
      if @team.nil?
        @team = Team.find_by(created_by_user_id: current_user.id)
      end

      @team_members = @team&.team_members&.includes(:coder) || []
    end
  end
end
