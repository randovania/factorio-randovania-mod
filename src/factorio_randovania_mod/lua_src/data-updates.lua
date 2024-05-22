local existing_tree = require("generated.existing-tree-repurpose")

for name, tech in pairs(data.raw["technology"]) do
    if existing_tree[name] then
        tech.hidden = false
        tech.enabled = false
        tech.visible_when_disabled = true
        tech.prerequisites = existing_tree[name].prerequisites or {}
        tech.unit = {
            count = 1,
            time = 60,
            ingredients = {{existing_tree[name].science_pack or "impossible-science-pack", 1}}
        }
    else
        tech.hidden = true
    end
end

function add_randovania_tech(param)
    local prototype = {
        type = "technology",
        name = param.name,
        icon_size = param.icon_size or 256,
        icon_mipmaps = 4,
        icon = param.icon,
        effects = {},
        unit = param.costs,
        order = param.order or param.name,
        prerequisites = param.prerequisites,
    }
    if param.take_effects_from then
        local original = data.raw["technology"][param.take_effects_from]
        prototype.icon = original.icon
        prototype.icons = original.icons
        prototype.icon_size = original.icon_size
        prototype.icon_mipmaps = original.icon_mipmaps
        prototype.effects = original.effects
    end
    data:extend { prototype }
end

local tech_tree = require("generated.tech-tree")
for _, tech in ipairs(tech_tree) do
    add_randovania_tech(tech)
end

for _, custom_recipe in pairs(require("generated.custom-recipes")) do
    local recipe = data.raw["recipe"][custom_recipe.recipe_name]
    recipe.category = custom_recipe.category
    recipe.result_count = custom_recipe.result_amount
    recipe.ingredients = custom_recipe.ingredients
end

-- Make productivity modules work everywhere
for _, name in pairs {"productivity-module", "productivity-module-2", "productivity-module-3"} do
    data.raw["module"][name].limitation = nil
end