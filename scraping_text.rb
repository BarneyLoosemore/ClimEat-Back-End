browser = Watir::Browser.new :chrome
browser.goto("https://www.bbcgoodfood.com/recipes")

# 1
input = browser.text_field(class: ["metadrift-suggestions__search__input", "ui-autocomplete-input"])

# 2
button = browser.div(class: "metadrift-suggestions__search__submit")

# 3
input.set [INSERT INGREDIENT NAME]

# 4
button.click

#### WAIT FOR RECIPES TO LOAD - SLEEP ####

# 5
browser.links(class: "metadrift-teaser-item__title__link")
    .each{ |recipe|  
    # for each recipe do as below

    browser.goto(recipe.href)

    #### WAIT FOR RECIPE PAGE TO LOAD - SLEEP ####
    # 1
    ingredients_text_array = browser.ul(class: "ingredients-list__group").map{ |i| i.innertext }

    # 2
    # method_list = browser.ol(class: "method__list")
    method_text_array = browser.ol(class: "method__list").map{ |i| i.innertext }

    # 3
    servings_text = browser.section(class: ["recipe-details__item", "recipe-details__item--servings"]).span(class: "recipe-details__text").innertext
    serving_number = servings_text.scan(/\d/).join(‘’)

    # 4
    recipe_name = browser.h1(class: "recipe-header__title").innertext

}




# method #

# first

browser = Watir::Browser.new :chrome
browser.goto("https://www.bbcgoodfood.com/recipes")
sleep 3
input = browser.text_field(class: ["metadrift-suggestions__search__input", "ui-autocomplete-input"])
button = browser.div(class: "metadrift-suggestions__search__submit")
sleep 1
input.set "beef"
sleep 1
button.click
sleep 1

# then
recipe_links = browser.links(class: "metadrift-teaser-item__title__link").map{ |recipe| recipe.href }

recipes = recipe_links.map{ |link|

    browser.goto(link)
    sleep 3
    {
        name: browser.h1(class: "recipe-header__title").innertext,
        ingredients: browser.ul(class: "ingredients-list__group").map{ |i| i.innertext },
        method: browser.ol(class: "method__list").map{ |i| i.innertext },
        servings: browser.section(class: ["recipe-details__item", "recipe-details__item--servings"]).span(class: "recipe-details__text").innertext.scan(/\d/).join('')
    }
}


# for storing JSON file into database 
ingredients = "JSON array"
ingredients.each{|ingredient|
    Ingredient.create(name: ingredient[:food_name], kg_CO2_per_kg_produce: ingredient[:kg_CO2_per_kg_produce])
}


