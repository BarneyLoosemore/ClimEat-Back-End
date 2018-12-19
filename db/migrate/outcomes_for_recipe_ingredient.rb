

def classify
    if ingredient_number && ingredient_metric && ingredient_name found? 
        do
            # quantify ingredient_number + ingredient_metric in kgs
            RecipeIngredient.create(
                recipe_id: recipe.id, 
                ingredient_id: ingredient.id,
                ingredient_kgs: ingredient.kgs,
                content: ingredient.content
            )
        end
    elsif ingredient_number && ingredient_metric ** !ingredient_name found?
        do
            # quantify ingredient_number + ingredient_metric in kgs
            RecipeIngredient.create(
                recipe_id: recipe.id, 
                ingredient_id: 118 (unknown ingredient id),
                ingredient_kgs: ingredient.kgs,
                content: ingredient.content
            )
        end
    elsif either or both ingredient number && ingredient_metric not found && ingredient_name found
        do
            RecipeIngredient.create(
                recipe_id: recipe.id, 
                ingredient_id: ingredient.id,
                ingredient_kgs: 0,
                content: ingredient.content
            )
        end
    elsif nothing found
        do
            RecipeIngredient.create(
                recipe_id: recipe.id, 
                ingredient_id: 118 (unkown ingredient id),
                ingredient_kgs: 0,
                content: ingredient.content
            )
        end
    end
end