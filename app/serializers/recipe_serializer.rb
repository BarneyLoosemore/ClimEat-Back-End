class RecipeSerializer < ActiveModel::Serializer
  attributes :id, :name, :servings, :image_url, :recipe_ingredients, :instructions
  # has_many :recipe_ingredients
  # has_many :ingredients, through: :recipe_ingredients
  # has_many :instructions
end