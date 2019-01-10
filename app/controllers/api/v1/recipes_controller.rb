class Api::V1::RecipesController < ApplicationController

    def show
        @recipe = Recipe.find(params[:id])
        render json: @recipe
    end

    def index
        @recipes = Recipe.all
        render json: @recipes
    end

end

