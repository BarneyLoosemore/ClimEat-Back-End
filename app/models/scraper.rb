class Scraper 

    def initialize (ingredients)
        @ingredients = ingredients
        @browser = Watir::Browser.new :chrome
        @browser.goto("https://www.bbcgoodfood.com/recipes")
    end

    def scrape_ingredients_recipes 
        @ingredients.each{ |ingredient| load_recipes(ingredient) }
    end

    def load_recipes (ingredient)
        input = @browser.text_field(class: ["metadrift-suggestions__search__input", "ui-autocomplete-input"])
        button = @browser.div(class: "metadrift-suggestions__search__submit")
        input.set ingredient
            sleep 2
        button.click
            sleep 2
        parse_recipes()
    end

    def parse_recipes 
        recipe_links = @browser.links(class: "metadrift-teaser-item__title__link").map{ |recipe| recipe.href }

        recipe_links.each{ |link|

            @browser.goto(link)
            sleep 3

            recipe = {
                name: @browser.h1(class: "recipe-header__title").innertext,
                ingredients: @browser.ul(class: "ingredients-list__group").map{ |i| i.innertext },
                instructions: @browser.ol(class: "method__list").map{ |i| i.innertext },
                servings: @browser.section(class: ["recipe-details__item", "recipe-details__item--servings"]).span(class: "recipe-details__text").innertext.scan(/\d/).join('')
            }

            created_recipe = Recipe.create(name: recipe[:name], servings: recipe[:servings], website: "BBC")

            # recipe[:ingredients].each{|ingredient| puts ingredient }
            recipe[:ingredients].each{|ingredient| self.create_recipe_ingredient(ingredient, created_recipe.id)}

            recipe[:instructions].each{ |instruction| 
                Instruction.create(
                    recipe_id: created_recipe.id, 
                    index: recipe[:instructions].index(instruction) + 1, 
                    content: instruction)
            }

        }
    end

    
    def create_recipe_ingredient (ingredient_content, recipe_id)

        ingredient = self.find_ingredient(ingredient_content)

        amount = self.find_amount(ingredient_content)

        metric_obj = self.find_metric(ingredient_content)
        kg = metric_obj[:kg]
        multiplier = metric_obj[:multiplier]

        ingredient_kgs = amount*kg*multiplier

        RecipeIngredient.create( recipe_id: recipe_id, ingredient_id: ingredient[0].id, ingredient_kgs: ingredient_kgs, content: ingredient_content )
    end


    def find_ingredient (ingredient_content)
        found_ingredient = Ingredient.all.select{|i| ingredient_content.downcase.include?(i.name.downcase)}
        if found_ingredient.length == 0
            found_ingredient = Ingredient.find(118)
        end
        return found_ingredient
    end

    def find_amount (ingredient_content)
        ingr_word_nums = ingredient_content.split(' ').join('-').split('-').map{|i| i.to_i}.sort
        highest_amount = ingr_word_nums.last
        new_ingredient_string = ingr_word_nums.map{|num| num == 0}
        puts highest_amount
        return highest_amount
    end

    def find_metric (ingredient_content)

        ingredient_content = ingredient_content.tr("0-9", "")

        standard_metrics = [{name: "gram", kg: 0.001}, {name: "kg", kg: 1}, {name: "kilo", kg: 1}, {name: "kilogram", kg: 1}]
        niche_metrics = [{name: "breast", kg: 0.2}, {name: "thigh", kg: 0.15}, {name: "drumstick", kg: 0.10}, {name: "leg", kg: 2.00}, {name: "steak", kg: 0.20}, {name: "chop", kg: 0.15}, {name: "wing", kg: 0.09}]
        size_metric = [{name: "small", multiplier: 0.7}, {name: "medium", multiplier: 1}, {name: "large", multiplier: 1.3}]

        grams = ingredient_content.split(' ').join('-').split('-').select{|w| w == 'g'}

        if grams.length > 0
            return {kg: 0.001, multiplier: 1}
        end

        metric = standard_metrics.select{|metric| ingredient_content.downcase.include?(metric[:name])}.sort_by{|metric| metric[:name].length}.last 
        if metric == nil 
            niche_metric = niche_metrics.select{|metric| ingredient_content.downcase.include?(metric[:name])}.sort_by{|metric| metric[:name].length}.last 
            size_metric = size_metric.select{|metric| ingredient_content.downcase.include?(metric[:name])}.sort_by{|metric| metric[:name].length}.last 
            if niche_metric && size_metric 
                puts niche_metric 
                puts size_metric
                return {kg: niche_metric[:kg], multiplier: size_metric[:multiplier]}
            elsif niche_metric 
                puts niche_metric
                return {kg: niche_metric[:kg], multiplier: 1} 
            elsif size_metric 
                puts size_metric
                # kg to be changed based on average weight of 1 ingredient
                return {kg: 0.2, multiplier: size_metric[:multiplier]}
            else
                # kg to be changed based on average weight of 1 ingredient
                return {kg: 0.2, multiplier: 1}
            end
        else 
            return {kg: metric[:kg], multiplier: 1}
        end
    end
 

end
