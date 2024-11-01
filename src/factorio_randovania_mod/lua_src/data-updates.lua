local existing_tree = require("generated.existing-tree-repurpose")

for name, tech in pairs(data.raw["technology"]) do
    local dummy_pack = "impossible-science-pack"
    if existing_tree[name] then
        tech.hidden = false
        tech.visible_when_disabled = true
        tech.prerequisites = existing_tree[name].prerequisites or {}
        dummy_pack = existing_tree[name].science_pack
    else
        tech.hidden = true
        tech.hidden_in_factoriopedia = true
    end
    tech.research_trigger = nil
    tech.enabled = false
    tech.unit = {
        count = 1,
        time = 60,
        ingredients = {{dummy_pack, 1}}
    }
end

local original_effects = {}

function add_randovania_tech(param)
    ---@type data.TechnologyPrototype
    local prototype = {
        type = "technology",
        name = param.name,
        icon_size = param.icon_size or 256,
        icon = param.icon,
        effects = {},
        unit = param.costs,
        research_trigger = param.research_trigger,
        order = param.order or param.name,
        prerequisites = param.prerequisites,
    }
    if param.take_effects_from then
        local original = data.raw["technology"][param.take_effects_from]
        prototype.icon = original.icon
        prototype.icons = original.icons
        prototype.icon_size = original.icon_size
        prototype.effects = original_effects[param.take_effects_from] or original.effects
        prototype.localised_description = {"technology-description." .. param.take_effects_from:gsub("-%d+", "")}
        prototype.essential = original.essential

        -- Remove the effects, so Factoriopedia won't link the hidden tech
        original.effects = nil
        original_effects[param.take_effects_from] = prototype.effects
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
    recipe.ingredients = custom_recipe.ingredients
end

-- Make productivity modules work everywhere
for _, recipe in pairs(data.raw["recipe"]) do
    recipe.allow_productivity = true
end