# frozen_string_literal: true

# CRUD controller for managing Groups
module Admin
  class GroupsController < BaseController
    before_action :set_group, only: [ :show, :edit, :update, :destroy ]

    def index
      @groups = Group.left_joins(:coders, :teams)
                     .select("groups.*, COUNT(DISTINCT coders.id) as coders_count, COUNT(DISTINCT teams.id) as teams_count")
                     .group("groups.id")
                     .order(:name)
    end

    def show
      @coders = @group.coders.left_joins(:team_member).order(:last_name, :first_name)
      @teams = @group.teams.includes(:coders)
    end

    def new
      @group = Group.new
    end

    def create
      @group = Group.new(group_params)
      if @group.save
        redirect_to admin_groups_path, notice: "Grupo creado exitosamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @group.update(group_params)
        redirect_to admin_groups_path, notice: "Grupo actualizado exitosamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @group.destroy
      redirect_to admin_groups_path, notice: "Grupo eliminado exitosamente."
    end

    private

    def set_group
      @group = Group.find(params[:id])
    end

    def group_params
      params.require(:group).permit(:name, :jornada, :capacity)
    end
  end
end
