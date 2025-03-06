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
    ---@class RecipeIngredientEntry
    ---If the ingredient is a fluid ingredient
    ---@field is_fluid boolean
    ---The name of the ingredient. 
    ---@field name string
    ---The new amount
    ---@field amount integer
    local recipe_ingredient_entry = {
    }

    ---Tweaking some existing recipe
    ---@class RecipeTweakEntry
    ---The name of the recipe to change
    ---@field recipe_name string
    ---The new category
    ---@field category string
    ---The new ingredients
    ---@field ingredients RecipeIngredientEntry[]
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

local base64 = require("external_libs.base64")
local Blob = require("external_libs.Blob")
local LibDeflate = require("external_libs.LibDeflate")

local layout = {}

---comment
---@param blob Blob
---@return integer
local function decode_length(blob)
    return blob:unpack("I2")
end

---comment
---@param blob Blob
---@return string
local function decode_string(blob)
    return blob:prefixstring(2)
end

---comment
---@param blob Blob
---@return string[]
local function decode_string_array(blob)
    return blob:array(decode_length(blob), decode_string)
end

---comment
---@param blob Blob
---@return TechTreeEntry
local function decode_tech_tree_entry(blob)
    local name = decode_string(blob)
    local localised_name = decode_string(blob)
    local prerequisites = decode_string_array(blob)
    local take_effects_from = decode_string(blob) --[[@as string?]]
    local visual_data = nil
    if take_effects_from == "" then
        take_effects_from = nil
        visual_data = {
            icon = decode_string(blob),
            icon_size = blob:unpack("I2"),
            localised_description = decode_string(blob),
        }
    end
    local cost_reference = decode_string(blob)
    return {
        name = name,
        localised_name = localised_name,
        prerequisites = prerequisites,
        take_effects_from = take_effects_from,
        visual_data = visual_data,
        cost_reference = cost_reference,
    }
end

---comment
---@param blob Blob
---@return ProgressiveEntry
local function decode_progressive_entry(blob)
    return {
        locations = decode_string_array(blob),
        unlocked = decode_string_array(blob),
    }
end

---comment
---@param blob Blob
---@return RecipeIngredientEntry
local function decode_ingredient(blob)
    local is_fluid = blob:byte() == string.char(1)
    return {
        is_fluid = is_fluid,
        name = decode_string(blob),
        amount = decode_length(blob),
    }
end

---comment
---@param blob Blob
---@return RecipeTweakEntry
local function decode_recipe_tweak_entry(blob)
    return {
        recipe_name = decode_string(blob),
        category = decode_string(blob),
        ingredients = blob:array(decode_length(blob), decode_ingredient),
    }
end

---comment
---@param data string
---@return LayoutData
local function decode_data(data)
    local blob_header = Blob.new(data)
    local version = blob_header:unpack("I2")
    assert(version == 1, "Randovania game for a different version of the mod")
    
    local expected_version = decode_string(blob_header)
    if settings.startup["randovania-enforce-version"].value then
        local active_mods = mods or script.active_mods
        assert(expected_version == active_mods["randovania"], "Randovania game for a different version of the mod")
    end
    local compressed_size = blob_header:unpack("I4")
    
    local decompressed = LibDeflate:DecompressZlib(blob_header:bytes(compressed_size))
    local blob = Blob.new(decompressed)

    local layout_data = {
        tech_tree = {},
        progressive_data = {},
        custom_recipes = {},
        starting_tech = {},
    } --[[@as LayoutData]]

    for i = 1, decode_length(blob) do
        table.insert(layout_data.tech_tree, decode_tech_tree_entry(blob))
    end
    for i = 1, decode_length(blob) do
        table.insert(layout_data.progressive_data, decode_progressive_entry(blob))
    end
    for i = 1, decode_length(blob) do
        table.insert(layout_data.custom_recipes, decode_recipe_tweak_entry(blob))
    end
    layout_data.starting_tech = decode_string_array(blob)

    return layout_data
end

---Returns the data for configuring the randomizer.
---@return LayoutData|false
function layout.get_data()
    if layout._cache == nil then
        local layout_string = settings.startup["randovania-layout-string"].value --[[@as string]]
        if layout_string == "" then
            return false
        end
        local raw = base64.decode(layout_string)
        layout._cache = decode_data(raw)
    end
    return layout._cache
end

return layout
