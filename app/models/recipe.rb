class Recipe < ApplicationRecord
    has_many :recipe_ingredients
    has_many :ingredients, through: :recipe_ingredients
    has_many :instructions


    def self.load_recipes 
        browser = Watir::Browser.new :chrome
        browser.goto("https://www.bbcgoodfood.com/recipes")
            sleep 3
        input = browser.text_field(class: ["metadrift-suggestions__search__input", "ui-autocomplete-input"])
        button = browser.div(class: "metadrift-suggestions__search__submit")
        input.set "beef"
            sleep 1
        button.click
            sleep 2
        parse_recipes(browser)
    end

    def self.parse_recipes(browser)
        recipe_links = browser.links(class: "metadrift-teaser-item__title__link").map{ |recipe| recipe.href }

        recipe_links.each{ |link|

            browser.goto(link)
            sleep 3

            recipe = {
                name: browser.h1(class: "recipe-header__title").innertext,
                ingredients: browser.ul(class: "ingredients-list__group").map{ |i| i.innertext },
                instructions: browser.ol(class: "method__list").map{ |i| i.innertext },
                servings: browser.section(class: ["recipe-details__item", "recipe-details__item--servings"]).span(class: "recipe-details__text").innertext.scan(/\d/).join('')
            }

            created_recipe = Recipe.create(name: recipe[:name], servings: recipe[:servings], website: "BBC")

            binding.pry

            recipe[:instructions].each{ |instruction| 
                Instruction.create(
                    recipe_id: created_recipe.id, 
                    index: recipe[:instructions].index(instruction) + 1, 
                    content: instruction)
            }

        }
    end
end
