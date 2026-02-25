# frozen_string_literal: true

# Public controller for team registration via QR token
# No authentication required — accessed by anyone scanning QR
# Supports both existing coders (autocomplete) and new people (manual entry)
class TeamRegistrationsController < ApplicationController
  skip_before_action :authenticate_user!
  layout "registration"

  def new
    @team = Team.find_by!(token: params[:token])

    if @team.registered_at.present?
      render :already_registered
      nil
    end
  end

  def create
    @team = Team.find_by!(token: params[:token])

    if @team.registered_at.present?
      render :already_registered
      return
    end

    # Parse members from JSON
    members_json = params[:members_data]
    begin
      members = JSON.parse(members_json)
    rescue JSON::ParserError, TypeError
      flash.now[:alert] = "Error al procesar los miembros del equipo."
      render :new, status: :unprocessable_entity
      return
    end

    # Validate member count
    if members.size < 3
      flash.now[:alert] = "El equipo debe tener al menos 3 miembros."
      render :new, status: :unprocessable_entity
      return
    end

    if members.size > 6
      flash.now[:alert] = "El equipo no puede tener más de 6 miembros."
      render :new, status: :unprocessable_entity
      return
    end

    # Validate leader exists
    has_leader = members.any? { |m| m["is_leader"] == true }
    unless has_leader
      flash.now[:alert] = "Debes seleccionar un líder del equipo."
      render :new, status: :unprocessable_entity
      return
    end

    # Validate team name and category
    team_name = params[:team_name].to_s.strip
    project_category = params[:project_category].to_s.strip
    description = params[:description].to_s.strip.presence

    if team_name.blank?
      flash.now[:alert] = "El nombre del equipo es obligatorio."
      render :new, status: :unprocessable_entity
      return
    end

    unless Team::CATEGORIES.include?(project_category)
      flash.now[:alert] = "Selecciona una categoría de proyecto válida."
      render :new, status: :unprocessable_entity
      return
    end

    ActiveRecord::Base.transaction do
      members.each do |member_data|
        coder = resolve_or_create_coder(member_data)
        role = member_data["is_leader"] ? "leader" : "member"
        @team.team_members.create!(coder: coder, role: role)
      end

      @team.update!(
        name: team_name,
        description: description,
        project_category: project_category,
        registered_at: Time.current
      )
    end

    redirect_to team_registration_path(token: @team.token), notice: "¡Equipo registrado exitosamente!"
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = "Error al registrar: #{e.message}"
    render :new, status: :unprocessable_entity
  end

  private

  # Resolves an existing coder by ID or creates a new one from provided data
  def resolve_or_create_coder(member_data)
    if member_data["type"] == "existing" && member_data["coder_id"].present?
      Coder.find(member_data["coder_id"])
    else
      # Create a new coder record
      Coder.create!(
        first_name: member_data["first_name"].to_s.strip,
        last_name: member_data["last_name"].to_s.strip,
        email: member_data["email"].to_s.strip.presence,
        group: @team.group
      )
    end
  end
end
