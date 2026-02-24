# frozen_string_literal: true

# Application controller with Devise authentication
class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :current_user_admin?, :current_user_team_leader?

  layout :set_layout

  private

  def set_layout
    devise_controller? ? "devise" : "application"
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :document_number ])
  end

  private

  def current_user_admin?
    current_user&.admin?
  end

  def current_user_team_leader?
    current_user&.team_leader?
  end

  def require_admin!
    unless current_user_admin? || current_user_team_leader?
      redirect_to root_path, alert: "No tienes permisos para acceder a esta sección."
    end
  end

  # Devise: redirect after sign in based on role
  def after_sign_in_path_for(resource)
    if resource.admin? || resource.team_leader?
      admin_dashboard_path
    else
      portal_dashboard_path
    end
  end
end
