# frozen_string_literal: true

# Service to import coders from an Excel (.xlsx) file
# Maps Spanish column headers to Coder model attributes
class ExcelImportService
  COLUMN_MAPPING = {
    "Apellido(s)" => :last_name,
    "Nombre" => :first_name,
    "Grupos" => :group_name,
    "ID de estudiante" => :student_id,
    "Número de ID" => :national_id,
    "Dirección de correo" => :email,
    "Teléfono" => :phone,
    "Género" => :gender
  }.freeze

  def initialize(file)
    @file = file
    @imported = 0
    @errors = []
  end

  def call
    spreadsheet = Roo::Excelx.new(@file.path)
    headers = spreadsheet.row(1).map(&:strip)

    (2..spreadsheet.last_row).each do |i|
      row = Hash[headers.zip(spreadsheet.row(i))]
      process_row(row, i)
    end

    { imported: @imported, errors: @errors }
  rescue StandardError => e
    @errors << "Error al procesar el archivo: #{e.message}"
    { imported: @imported, errors: @errors }
  end

  private

  def process_row(row, row_number)
    group_name = row["Grupos"]&.strip
    return if group_name.blank?

    group = Group.find_or_create_by!(name: group_name)

    coder_attrs = {
      last_name: row["Apellido(s)"]&.strip,
      first_name: row["Nombre"]&.strip,
      student_id: row["ID de estudiante"]&.to_i,
      national_id: row["Número de ID"]&.to_s&.strip,
      email: row["Dirección de correo"]&.strip,
      phone: row["Teléfono"]&.to_s&.strip,
      gender: row["Género"]&.strip,
      group: group
    }

    # Update existing coder by student_id or create new
    if coder_attrs[:student_id].present? && coder_attrs[:student_id] > 0
      coder = Coder.find_or_initialize_by(student_id: coder_attrs[:student_id])
      coder.assign_attributes(coder_attrs)
    else
      coder = Coder.new(coder_attrs)
    end

    if coder.save
      @imported += 1
    else
      @errors << "Fila #{row_number}: #{coder.errors.full_messages.join(', ')}"
    end
  rescue StandardError => e
    @errors << "Fila #{row_number}: #{e.message}"
  end
end
