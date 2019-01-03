class IngredientSerializer < ActiveModel::Serializer
  attributes :id, :name, :kg_CO2_per_kg_produce
end