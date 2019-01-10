class RecipeIngredientSerializer < ActiveModel::Serializer
  attributes :id, :recipe_id, :ingredient_id, :ingredient_kgs
  # belongs_to :recipe
  # belongs_to :ingredient
end