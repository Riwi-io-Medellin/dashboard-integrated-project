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

    def qr
      @team = Team.find(params[:id])
      registration_url = team_registration_url(token: @team.token)
      @qr_svg = QrGeneratorService.new(registration_url).to_svg
    end

    private

    def team_params
      params.require(:team).permit(:name, :description, :project_category, :group_id)
    end
  end
end
