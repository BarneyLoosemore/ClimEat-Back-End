class CreateInstructions < ActiveRecord::Migration[5.2]
  def change
    create_table :instructions do |t|
      t.integer :recipe_id
      t.integer :index
      t.text :content

      t.timestamps
    end
  end
end
