class AddJornadaAndCapacityToGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :groups, :jornada, :string
    add_column :groups, :capacity, :integer, default: 30
  end
end
