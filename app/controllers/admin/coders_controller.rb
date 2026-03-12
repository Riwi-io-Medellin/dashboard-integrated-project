# frozen_string_literal: true

require "csv"

# Controller for listing coders and importing from Excel
module Admin
  class CodersController < BaseController
    def index
      @coders = Coder.includes(:group, :team_member)
                     .order(:last_name, :first_name)

      @coders = @coders.where(group_id: params[:group_id]) if params[:group_id].present?

      if params[:search].present?
        search = "%#{params[:search]}%"
        @coders = @coders.where(
          "first_name ILIKE :s OR last_name ILIKE :s OR email ILIKE :s OR CAST(student_id AS TEXT) ILIKE :s",
          s: search
        )
      end

      @groups = Group.order(:name)
    end

    def export
      @coders = Coder.includes(:group, team_member: :team).order(:last_name, :first_name)

      csv_data = CSV.generate(headers: true, col_sep: ",") do |csv|
        csv << [
          "Nombre", "Apellido", "Email", "Teléfono", "Documento",
          "ID Estudiante", "Género", "Grupo", "GitHub", "Discord",
          "Equipo", "Rol en Equipo", "Categoría del Proyecto", "Descripción del Proyecto"
        ]

        @coders.each do |coder|
          csv << [
            coder.first_name,
            coder.last_name,
            coder.email,
            coder.phone,
            coder.national_id,
            coder.student_id,
            coder.gender,
            coder.group&.name,
            coder.github_user,
            coder.discord_user,
            coder.team&.name,
            coder.team_member&.role,
            coder.team&.category_label,
            coder.team&.description
          ]
        end
      end

      send_data csv_data,
                filename: "coders-riwi-#{Date.today}.csv",
                type: "text/csv; charset=utf-8",
                disposition: "attachment"
    end

    def destroy
      @coder = Coder.find(params[:id])
      @coder.destroy
      redirect_back fallback_location: admin_coders_path, notice: "Coder eliminado exitosamente."
    end

    def import
      if params[:file].blank?
        redirect_to admin_coders_path, alert: "Por favor selecciona un archivo Excel (.xlsx)."
        return
      end

      result = ExcelImportService.new(params[:file]).call
      if result[:errors].any?
        flash[:alert] = "Importación completada con errores: #{result[:imported]} importados, #{result[:errors].size} errores."
        flash[:import_errors] = result[:errors].first(10)
      else
        flash[:notice] = "Se importaron #{result[:imported]} coders exitosamente."
      end

      redirect_to admin_coders_path
    end
  end
end
