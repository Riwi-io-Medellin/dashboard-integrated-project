# frozen_string_literal: true

# Portal teams controller — coders can create teams and add members
module Portal
  class TeamsController < BaseController
    def new
      existing_team = current_user.coder&.team || Team.find_by(created_by_user_id: current_user.id)
      if existing_team
        redirect_to portal_team_path(existing_team), notice: "Ya perteneces a un equipo."
        return
      end
      @team = Team.new
      @groups = Group.order(:name)
    end

    def create
      existing_team = current_user.coder&.team || Team.find_by(created_by_user_id: current_user.id)
      if existing_team
        redirect_to portal_team_path(existing_team), alert: "Ya perteneces a un equipo."
        return
      end

      members_json = params[:members_data]
      begin
        members = JSON.parse(members_json)
      rescue JSON::ParserError, TypeError
        flash.now[:alert] = "Error al procesar los miembros del equipo."
        @team = Team.new
        @groups = Group.order(:name)
        render :new, status: :unprocessable_entity
        return
      end

      # Validations
      if members.size < 3
        flash.now[:alert] = "El equipo debe tener al menos 3 miembros."
        @team = Team.new
        @groups = Group.order(:name)
        render :new, status: :unprocessable_entity
        return
      end

      if members.size > 6
        flash.now[:alert] = "El equipo no puede tener más de 6 miembros."
        @team = Team.new
        @groups = Group.order(:name)
        render :new, status: :unprocessable_entity
        return
      end

      unless members.any? { |m| m["is_leader"] == true }
        flash.now[:alert] = "Debes seleccionar un líder del equipo."
        @team = Team.new
        @groups = Group.order(:name)
        render :new, status: :unprocessable_entity
        return
      end

      team_name = params[:team_name].to_s.strip
      project_category = params[:project_category].to_s.strip
      group_id = params[:group_id].to_s.strip

      if team_name.blank?
        flash.now[:alert] = "El nombre del equipo es obligatorio."
        @team = Team.new
        @groups = Group.order(:name)
        render :new, status: :unprocessable_entity
        return
      end

      unless Team::CATEGORIES.include?(project_category)
        flash.now[:alert] = "Selecciona una categoría de proyecto válida."
        @team = Team.new
        @groups = Group.order(:name)
        render :new, status: :unprocessable_entity
        return
      end

      group = Group.find_by(id: group_id)
      unless group
        flash.now[:alert] = "Selecciona un clan válido."
        @team = Team.new
        @groups = Group.order(:name)
        render :new, status: :unprocessable_entity
        return
      end

      ActiveRecord::Base.transaction do
        @team = Team.create!(
          name: team_name,
          project_category: project_category,
          group: group,
          needs_openai_api: params[:needs_openai_api] == "1",
          created_by_user: current_user,
          registered_at: Time.current
        )

        members.each do |member_data|
          coder = resolve_or_create_coder(member_data, group)
          role = member_data["is_leader"] ? "leader" : "member"
          @team.team_members.create!(coder: coder, role: role)
        end

        # Link current user to a coder if not already linked
        ensure_user_linked_to_team(members, group)
      end

      redirect_to portal_team_path(@team), notice: "¡Equipo creado exitosamente!"
    rescue ActiveRecord::RecordInvalid => e
      # Extract most meaningful message
      msg = e.record.errors.full_messages.first.presence || e.message
      flash.now[:alert] = "No se pudo guardar el equipo: #{msg}. Por favor revisa los datos de los miembros."
      @team = Team.new
      @groups = Group.order(:name)
      @submitted_members = params[:members_data]
      @submitted_team_name = params[:team_name]
      @submitted_category = params[:project_category]
      @submitted_group_id = params[:group_id]
      @submitted_openai = params[:needs_openai_api]
      render :new, status: :unprocessable_entity
    rescue StandardError => e
      flash.now[:alert] = "Ocurrió un error inesperado: #{e.message}"
      @team = Team.new
      @groups = Group.order(:name)
      @submitted_members = params[:members_data]
      @submitted_team_name = params[:team_name]
      @submitted_category = params[:project_category]
      @submitted_group_id = params[:group_id]
      @submitted_openai = params[:needs_openai_api]
      render :new, status: :unprocessable_entity
    end

    def show
      @team = Team.includes(team_members: { coder: :group }).find(params[:id])
      @members = @team.team_members.includes(coder: :group)
    end

    def edit
      @team = find_own_team
      redirect_to portal_dashboard_path, alert: "No tienes permiso para editar ese equipo." and return unless @team
      @groups = Group.order(:name)
      @members = @team.team_members.includes(coder: :group)
    end

    def update
      @team = find_own_team
      redirect_to portal_dashboard_path, alert: "No tienes permiso para editar ese equipo." and return unless @team

      members_json = params[:members_data]
      begin
        members = JSON.parse(members_json.presence || "[]")
      rescue JSON::ParserError, TypeError
        members = []
      end

      if members.size < 3
        flash.now[:alert] = "El equipo debe tener al menos 3 miembros."
        @submitted_members = params[:members_data]
        setup_edit_ivars
        render :edit, status: :unprocessable_entity and return
      end

      if members.size > 6
        flash.now[:alert] = "El equipo no puede tener más de 6 miembros."
        @submitted_members = params[:members_data]
        setup_edit_ivars
        render :edit, status: :unprocessable_entity and return
      end

      unless members.any? { |m| m["is_leader"] == true }
        flash.now[:alert] = "Debes seleccionar un líder del equipo."
        @submitted_members = params[:members_data]
        setup_edit_ivars
        render :edit, status: :unprocessable_entity and return
      end

      group = Group.find_by(id: params[:group_id])
      unless group
        flash.now[:alert] = "Selecciona un clan válido."
        @submitted_members = params[:members_data]
        setup_edit_ivars
        render :edit, status: :unprocessable_entity and return
      end

      ActiveRecord::Base.transaction do
        @team.update!(
          name: params[:team_name].to_s.strip,
          project_category: params[:project_category].to_s.strip,
          group: group,
          needs_openai_api: params[:needs_openai_api] == "1"
        )

        # Rebuild members: remove all and re-create
        @team.team_members.destroy_all
        members.each do |member_data|
          coder = resolve_or_create_coder(member_data, group)
          role = member_data["is_leader"] ? "leader" : "member"
          @team.team_members.create!(coder: coder, role: role)
        end
      end

      redirect_to portal_team_path(@team), notice: "¡Equipo actualizado exitosamente!"
    rescue ActiveRecord::RecordInvalid => e
      msg = e.record.errors.full_messages.first.presence || e.message
      flash.now[:alert] = "No se pudo actualizar el equipo: #{msg}"
      @submitted_members = params[:members_data]
      setup_edit_ivars
      render :edit, status: :unprocessable_entity
    rescue StandardError => e
      flash.now[:alert] = "Error inesperado: #{e.message}"
      @submitted_members = params[:members_data]
      setup_edit_ivars
      render :edit, status: :unprocessable_entity
    end


    private

    def resolve_or_create_coder(member_data, group)
      if member_data["type"] == "existing" && member_data["coder_id"].present?
        Coder.find(member_data["coder_id"])
      else
        email = member_data["email"].to_s.strip.downcase.presence
        national_id = member_data["national_id"].to_s.strip.presence

        # Try to find existing coder by national_id or email to avoid duplicates
        existing = nil
        existing = Coder.find_by(national_id: national_id) if national_id
        existing ||= Coder.where("LOWER(email) = ?", email).first if email

        if existing
          # Optionally update missing document number if they didn't have one
          existing.update(national_id: national_id) if national_id && existing.national_id.blank?
          existing
        else
          Coder.create!(
            first_name: member_data["first_name"].to_s.strip,
            last_name: member_data["last_name"].to_s.strip,
            email: email,
            national_id: national_id,
            github_user: member_data["github_user"].to_s.strip,
            discord_user: member_data["discord_user"].to_s.strip,
            group: group
          )
        end
      end
    end

    def ensure_user_linked_to_team(members, group)
      return if current_user.coder_id.present?

      matching = members.find { |m| m["email"].to_s.strip.downcase == current_user.email.downcase }
      if matching
        coder = if matching["type"] == "existing"
                  Coder.find_by(id: matching["coder_id"])
        else
          national_id = matching["national_id"].to_s.strip.presence
          found = Coder.find_by(national_id: national_id) if national_id
          found ||= Coder.where("LOWER(email) = ?", current_user.email.downcase).first
          found
        end
        current_user.update!(coder: coder) if coder
      end
    end

    # Returns the team if the current user owns or created it
    def find_own_team
      team = Team.find_by(id: params[:id])
      return nil unless team
      return team if team.created_by_user_id == current_user.id
      return team if current_user.coder&.team_id == team.id
      nil
    end

    def setup_edit_ivars
      @groups = Group.order(:name)
      @members = @team.team_members.includes(coder: :group)
    end
  end
end
