class AddDocumentNumberToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :document_number, :string
  end
end
