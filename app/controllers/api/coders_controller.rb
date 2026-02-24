# frozen_string_literal: true

# JSON API endpoint for coder autocomplete search
# Provides both full search (for admin/registration) and safe search (for portal)
module Api
  class CodersController < ApplicationController
    skip_before_action :authenticate_user!

    # Full search - used by admin and public registration
    def search
      query = params[:q].to_s.strip

      if query.length < 2
        render json: []
        return
      end

      coders = Coder.left_joins(:team_member)
                    .where(team_members: { id: nil })
                    .where(
                      "first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q OR CAST(student_id AS TEXT) ILIKE :q",
                      q: "%#{query}%"
                    )
                    .limit(10)
                    .select(:id, :first_name, :last_name, :email, :student_id)

      render json: coders.map { |c|
        { id: c.id, name: c.full_name, email: c.email, student_id: c.student_id }
      }
    end

    # Safe search - used by coder portal (only returns name + group, no email/ID)
    def search_safe
      query = params[:q].to_s.strip

      if query.length < 2
        render json: []
        return
      end

      coders = Coder.left_joins(:team_member, :group)
                    .where(team_members: { id: nil })
                    .where(
                      "first_name ILIKE :q OR last_name ILIKE :q",
                      q: "%#{query}%"
                    )
                    .includes(:group)
                    .limit(10)

      render json: coders.map { |c|
        { id: c.id, name: c.full_name, group: c.group&.name || "Sin clan" }
      }
    end

    # Check if a coder is already part of a team (by email or national_id)
    def check_team
      email = params[:email].to_s.strip.downcase.presence
      national_id = params[:national_id].to_s.strip.presence

      coder = nil
      coder = Coder.find_by(national_id: national_id) if national_id
      coder ||= Coder.where("LOWER(email) = ?", email).first if email

      if coder&.assigned_to_team?
        render json: { in_team: true, coder_name: coder.full_name }
      else
        render json: { in_team: false }
      end
    end
  end
end
