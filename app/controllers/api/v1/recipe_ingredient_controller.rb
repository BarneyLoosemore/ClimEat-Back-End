class Api::V1::RecipeIngredientController < ApplicationController

    def show
        @recipe_ingredient = RecipeIngredient.find(params[:id])
        render json: @recipe_ingredient
    end

    def index
        @recipe_ingredients = RecipeIngredient.all
        render json: @recipe_ingredients
    end

end
