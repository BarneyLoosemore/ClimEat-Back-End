class Scraper 

    def initialize (ingredients)
        @ingredients = ingredients
        @browser = Watir::Browser.new :chrome
        #  headless: true
        @browser.window.resize_to(1200, 1000)
        @browser.goto("https://www.bbcgoodfood.com/recipes")
    end

    def scrape_ingredients_recipes 
        @ingredients.each{ |ingredient| load_recipes(ingredient) }
    end

    def load_recipes (ingredient)
        @browser.goto("https://www.bbcgoodfood.com/recipes")
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
            run(link)
        }
    end


    def run (link) 
        begin
            result = Timeout::timeout(30) do
                parse_recipe(link)
            end
        rescue Timeout::Error
            parse_recipe(link)
        end
    end


    def parse_recipe (link) 

        @browser.goto(link)
        sleep 3

        recipe = {
            name: @browser.h1(class: "recipe-header__title").innertext,
            ingredients: self.find_recipe_ingredients(),
            instructions: @browser.ol(class: "method__list").map{ |i| i.innertext },
            servings: @browser.section(class: ["recipe-details__item", "recipe-details__item--servings"]).span(class: "recipe-details__text").text.split(' ').join('-').split('-').map{|i| i.to_i}.sort.last        }

        created_recipe = Recipe.create(name: recipe[:name], servings: recipe[:servings], website: "BBC", image_url: @browser.img(itemprop: "image").src)

        # recipe[:ingredients].each{|ingredient| puts ingredient }
        recipe[:ingredients].each{|ingredient| self.create_recipe_ingredient(ingredient, created_recipe.id)}

        recipe[:instructions].each{ |instruction| 
            Instruction.create(
                recipe_id: created_recipe.id, 
                index: recipe[:instructions].index(instruction) + 1, 
                content: instruction)
        }

    end

    
    def create_recipe_ingredient (ingredient_content, recipe_id)

        ingredient = self.find_ingredient(ingredient_content)

        amount = self.find_amount(ingredient_content)

        metric_obj = self.find_metric(ingredient_content)
        kg = metric_obj[:kg]

        # if metric is kg, set the amount to the lowest found number - 
        # this accounts for if the ingredient content includes higher amounts..
        # ..that refer to things other than the kg total (e.g. "around 1kg/2lb or 4oz")
        if kg == 1
            amount = self.find_lowest_amount(ingredient_content)
        end

        multiplier = metric_obj[:multiplier]

        ingredient_kgs = amount*kg*multiplier

        RecipeIngredient.create( recipe_id: recipe_id, ingredient_id: ingredient[0].id, ingredient_kgs: ingredient_kgs, content: ingredient_content )
    end

    def find_recipe_ingredients 
        @browser.ul(class: "ingredients-list__group").map{ |i| i.innertext }
    end


    def find_ingredient (ingredient_content)

        void_ingredients = ["butter bean", "butternut", "peel", "sea salt", "stock"]

        void = void_ingredients.select{|i| ingredient_content.downcase.include?(i)}

        if void.length > 0
            return [Ingredient.all.last]
        end

        found_ingredient = Ingredient.all.select{|i| ingredient_content.downcase.include?(i.name.downcase)}
        if found_ingredient.length == 0
            found_ingredient = [Ingredient.all.last]
        end

        if found_ingredient.length > 1
            found_ingredient = found_ingredient.sort{|ingr| ingr.name.length }
        end
        return found_ingredient
    end

    def find_amount (ingredient_content)
        ingr_word_nums = ingredient_content.split(' ').join('-').split('-').map{|i| i.to_i}.sort
        highest_amount = ingr_word_nums.last
        puts highest_amount
        return highest_amount
    end

    def find_lowest_amount (ingredient_content)
        ingr_word_nums = ingredient_content.split(' ').join('-').split('-').map{|i| i.to_i}.sort
        lowest_amount = ingr_word_nums.select{|n| n > 0 }.first
        return lowest_amount
    end 

    def find_metric (ingredient_content)

        ingredient_content = ingredient_content.tr("0-9", "")
        ingredient_content = ingredient_content.tr(")", "")

        standard_metrics = [{name: "gram", kg: 0.001}, {name: "ml", kg: 0.001}, {name: "millilitre", kg: 0.001}, {name: "milliliter", kg: 0.001}, {name: "liter", kg: 0.001}, {name: "kg", kg: 1}, {name: "kilo", kg: 1}, {name: "kilogram", kg: 1}]
        niche_metrics = [{name: "breast", kg: 0.2}, {name: "thigh", kg: 0.15}, {name: "drumstick", kg: 0.10}, {name: "leg", kg: 2.00}, {name: "steak", kg: 0.20}, {name: "chop", kg: 0.15}, {name: "wing", kg: 0.09}, {name: "sausage", kg: 0.08}]
        size_metric = [{name: "small", multiplier: 0.7}, {name: "medium", multiplier: 1}, {name: "large", multiplier: 1.3}]

        grams = ingredient_content.split(' ').join('/').split('/').join('-').split('-').select{|w| w == 'g'}
        # standardise using regex?

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


def recipe_CO2(recipe_id)
    ingredient_CO2 = Recipe.find(recipe_id).recipe_ingredients.map{|r_i| r_i.ingredient_kgs*Ingredient.find(r_i.ingredient_id).kg_CO2_per_kg_produce}  
    co2 = ingredient_CO2.sum/Recipe.find(recipe_id).servings
    return co2.round(2)
end 

def recipe_CO2(recipe_id)
    ingredient_CO2 = Recipe.find(recipe_id).recipe_ingredients.map{|r_i| r_i.ingredient_kgs*Ingredient.find(r_i.ingredient_id).kg_CO2_per_kg_produce}  
    co2 = ingredient_CO2.sum
    return co2.round(2)
end 

