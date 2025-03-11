local layout = require("layout")

local has_layout, layout_data = pcall(layout.get_data)
if not has_layout or not layout_data then
    print("Unable to load layout data:", layout_data)
    return
end


if not layout_data.optional_modifications.can_send_fish_to_space then
    -- Deny launching fish to space
    data.raw.capsule["raw-fish"].send_to_orbit_mode = nil
end


if layout_data.optional_modifications.stronger_solar then
    ---- Make Solar and Accumulators 4 times better
    data.raw["solar-panel"]["solar-panel"].production = "240kW"
    data.raw["accumulator"]["accumulator"].energy_source = {
        type = "electric",
        buffer_capacity = "20MJ",
        usage_priority = "tertiary",
        input_flow_limit = "1200kW",
        output_flow_limit = "1200kW"
    }
end


local existing_tree = {}

for _, progressive in pairs(layout_data.progressive_data) do
    for i, unlocked in pairs(progressive.unlocked) do
        existing_tree[unlocked] = {
            prerequisites =  i == 1 and progressive.locations or {progressive.unlocked[i - 1]},
            science_pack = "impossible-science-pack",
        }
    end
end

local original_effects = {}

---comment
---@param param TechTreeEntry
---@return data.TechnologyPrototype
function add_randovania_tech(param)
    local reference_cost = data.raw["technology"][param.cost_reference]

    ---@type data.TechnologyPrototype
    local prototype = {
        type = "technology",
        name = param.name,
        localised_name = param.localised_name,
        effects = {},
        unit = reference_cost.unit,
        research_trigger = reference_cost.research_trigger,
        order = reference_cost.order,
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
    elseif param.visual_data then
        prototype.icon = param.visual_data.icon
        prototype.icon_size = param.visual_data.icon_size
        prototype.localised_description = param.visual_data.localised_description

    else
        error("Missing take_effects_from or visual_data for " .. param.name)
    end
    return prototype
end

local new_tech = {}

for _, tech in ipairs(layout_data.tech_tree) do
    table.insert(new_tech, add_randovania_tech(tech))
end

-- Make all existing tech unresearchable and invisible, except for the ones we keep around because of progressive
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

data:extend(new_tech)

for _, custom_recipe in pairs(layout_data.custom_recipes) do
    local recipe = data.raw["recipe"][custom_recipe.recipe_name]
    recipe.category = custom_recipe.category
    recipe.ingredients = {}
    for i, ingredient in pairs(custom_recipe.ingredients) do
        recipe.ingredients[i] = {
            type = ingredient.is_fluid and "fluid" or "item",
            name = ingredient.name,
            amount = ingredient.amount,
        }
    end
end

if layout_data.optional_modifications.productivity_everywhere then
    -- Make productivity modules work everywhere
    for _, recipe in pairs(data.raw["recipe"]) do
        recipe.allow_productivity = true
    end
end