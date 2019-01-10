class CreateRecipes < ActiveRecord::Migration[5.2]
  def change
    create_table :recipes do |t|
      t.string :name
      t.integer :servings
      t.string :website
      t.string :image_url

      t.timestamps
    end
  end
end
