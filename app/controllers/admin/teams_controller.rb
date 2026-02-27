# frozen_string_literal: true

# Controller for viewing teams and their QR codes
module Admin
  class TeamsController < BaseController
    def index
      @teams = Team.includes(:group, :coders).order(created_at: :desc)
      @teams = @teams.where(group_id: params[:group_id]) if params[:group_id].present?
      @groups = Group.order(:name)
    end

    def show
      @team = Team.includes(:group, team_members: :coder).find(params[:id])
    end

    def new
      @team = Team.new
      @groups = Group.order(:name)
    end

    def create
      @team = Team.new(team_params)
      if @team.save
        redirect_to admin_team_path(@team), notice: "Equipo creado exitosamente. Comparte el código QR para el registro."
      else
        @groups = Group.order(:name)
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      @team = Team.find(params[:id])
      @team.destroy
      redirect_to admin_teams_path, notice: "Equipo eliminado exitosamente."
    end

    def qr
      @team = Team.find(params[:id])
      registration_url = team_registration_url(token: @team.token)
      @qr_svg = QrGeneratorService.new(registration_url).to_svg
    end

    def create_github_repo
      @team = Team.find(params[:id])
      result = GithubTeamRepoService.new(@team).create_repo!

      if result[:success]
        redirect_to admin_team_path(@team), notice: "Repositorio de GitHub creado exitosamente. Los colaboradores han sido invitados."
      else
        redirect_to admin_team_path(@team), alert: result[:error]
      end
    end

    def create_multiple_github_repos
      team_ids = params[:team_ids]

      if team_ids.blank?
        redirect_to admin_teams_path, alert: "Por favor, selecciona al menos un equipo."
        return
      end

      teams = Team.where(id: team_ids)
      created_count = 0
      failed_count = 0

      teams.each do |team|
        result = GithubTeamRepoService.new(team).create_repo!
        if result[:success]
          created_count += 1
        else
          failed_count += 1
          Rails.logger.error "Error creando repo masivo para Team #{team.id}: #{result[:error]}"
        end
      end

      message = "Se crearon #{created_count} repositorios exitosamente."
      message += " Fallaron #{failed_count}." if failed_count > 0

      if created_count > 0
        redirect_to admin_teams_path, notice: message
      else
        redirect_to admin_teams_path, alert: message
      end
    end

    private

    def team_params
      params.require(:team).permit(:name, :description, :project_category, :group_id, team_ids: [])
    end
  end
end
