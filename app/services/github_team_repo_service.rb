# frozen_string_literal: true

require "octokit"

class GithubTeamRepoService
  ORGANIZATION_NAME = "Riwi-io-Medellin"

  def initialize(team)
    @team = team
    @client = Octokit::Client.new(access_token: ENV.fetch("GITHUB_ADMIN_TOKEN", nil))
  end

  # Crea el repositorio publico en la organizacion y agrega a los miembros
  def create_repo!
    return { success: false, error: "Falta GITHUB_ADMIN_TOKEN" } unless ENV["GITHUB_ADMIN_TOKEN"].present?
    return { success: false, error: "El equipo ya tiene un repositorio." } if @team.github_repo_url.present?

    # Nombre sugerido, ej: team_name-integrative-project-Grupo
    # Se usa parameterize para eliminar espacios y caracteres invalidos
    repo_name = "#{@team.name.parameterize}-integrative-project-#{@team.group.name.parameterize}"

    begin
      # 1. Crear el repositorio en la organización
      repo = @client.create_repository(
        repo_name,
        organization: ORGANIZATION_NAME,
        description: "Repositorio para el equipo #{@team.name} (#{@team.category_label}) - RIWI",
        private: false,
        has_issues: true,
        has_projects: true,
        auto_init: true # Inicializa con un README
      )

      # 2. Guardar la URL en la DB
      @team.update!(github_repo_url: repo.html_url)

      # 3. Agregar los colaboradores
      add_collaborators(repo.full_name)

      { success: true, url: repo.html_url }
    rescue Octokit::Error => e
      Rails.logger.error "Error creando repositorio de GitHub para Team #{@team.id}: #{e.message}"
      { success: false, error: "Error interactuando con GitHub: #{e.message}" }
    end
  end

  private

  def add_collaborators(full_repo_name)
    @team.coders.each do |coder|
      next if coder.github_user.blank?

      begin
        # Se envia la invitacion de colaborador con permisos de push (default)
        @client.add_collaborator(full_repo_name, coder.github_user)
      rescue Octokit::Error => e
        Rails.logger.error "Error agregando a #{coder.github_user} al repo #{full_repo_name}: #{e.message}"
      end
    end
  end
end
