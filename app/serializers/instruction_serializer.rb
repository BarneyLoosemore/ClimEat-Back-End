class InstructionSerializer < ActiveModel::Serializer
  attributes :id, :recipe_id, :index, :content
  # belongs_to :recipe
end