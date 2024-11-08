do
    ---A progressive tech group.
    ---@class TechTreeVisualData
    ---Icon name
    ---@field icon string
    ---Icon size
    ---@field icon_size integer
    ---The localised_description of the new prototype
    ---@field localised_description string
    local tech_tree_visual_data = {
    }

    ---A progressive tech group.
    ---@class TechTreeEntry
    ---The name of the new prototype
    ---@field name string
    ---The localised_name of the new prototype
    ---@field localised_name string
    ---The prerequisites of the new tech
    ---@field prerequisites string[]
    ---Take the visual data from the given tech 
    ---@field take_effects_from? string
    ---Visual data 
    ---@field visual_data? TechTreeVisualData
    ---Take the tech cost of the given tech
    ---@field cost_reference string
    local tech_tree_entry = {
    }

    ---A progressive tech group.
    ---@class ProgressiveEntry
    ---The technologies that unlock things when researched.
    ---@field locations string[]
    ---The technologies that are unlocked by researching anything in locations.
    ---@field unlocked string[]
    local progressive_entry = {
    }

    ---Tweaking some existing recipe
    ---@class RecipeTweakEntry
    ---The name of the recipe to change
    ---@field recipe_name string
    ---The new category
    ---@field category string
    ---The new ingredients
    ---@field ingredients (data.FluidIngredientPrototype|data.ItemIngredientPrototype)[]
    local recipe_tweak_entry = {
    }

    ---Data for configuring the randomizer.
    ---@class LayoutData
    ---Custom tech tree entries
    ---@field tech_tree TechTreeEntry[]
    ---Progressive pickups and the tech that unlocks them
    ---@field progressive_data ProgressiveEntry[]
    ---List of tweaks for existing recipes
    ---@field custom_recipes RecipeTweakEntry[]
    ---List of technologies to grant automatically on start
    ---@field starting_tech string[]
    local layout_data = {
    }
end

local layout = {}

---Returns the data for configuring the randomizer.
---@return LayoutData
function layout.get_data()
    if not layout._cache then
        layout._cache = require("generated.json-data") --[[@as LayoutData]]
    end
    return layout._cache
end

return layout
