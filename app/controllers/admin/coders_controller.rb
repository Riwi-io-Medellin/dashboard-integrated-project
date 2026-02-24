# frozen_string_literal: true

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
