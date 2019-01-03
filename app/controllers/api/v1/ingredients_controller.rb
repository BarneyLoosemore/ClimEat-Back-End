class Api::V1::IngredientsController < ApplicationController

    def show
        @ingredient = Ingredient.find(params[:id])
        render json: @ingredient
    end

    def index
        @ingredients = Ingredient.all
        render json: @ingredients
    end

end
