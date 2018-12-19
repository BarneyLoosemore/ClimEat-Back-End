class CreateIngredients < ActiveRecord::Migration[5.2]
  def change
    create_table :ingredients do |t|
      t.string :name
      t.float :kg_CO2_per_kg_produce

      t.timestamps
    end
  end
end
