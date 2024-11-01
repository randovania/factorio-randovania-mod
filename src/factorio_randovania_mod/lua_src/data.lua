local function remove_if(t, pred)
    for i = #t, 1, -1 do
        if pred(t[i]) then
            table.remove(t, i)
        end
    end
end

local kRecipesWithNewTech = {
    "transport-belt",
    "light-armor",
}

local kInitialRecipes = {
    -- basic resources
    "stone-furnace",
    "copper-plate",
    "iron-plate",
    "stone-brick",
    -- military
    "pistol",
    "firearm-magazine",
    -- iron processing
    "iron-gear-wheel",
    "iron-stick",
    "iron-chest",
    -- copper processing
    "copper-cable",
    -- qol
    "wooden-chest",
    "small-electric-pole",
    -- basic fluids
    "pipe",
    "pipe-to-ground",
    -- burner tooling
    "burner-inserter",
    "burner-mining-drill",
    -- science
    "lab"
}

require("prototypes.handcraft")
require("prototypes.burners")
require("prototypes.tech")
require("prototypes.extra-tiers")
require("prototypes.modules")

---- Lock all initial recipes

for _, name in ipairs(kRecipesWithNewTech) do
    data.raw["recipe"][name].enabled = false
end

for _, name in ipairs(kInitialRecipes) do
    data.raw["recipe"][name].enabled = true
    data.raw["recipe"][name].hidden = nil
end

---- Change requirement to crafting a burner lab, so electronics isn't required to be super early
data.raw["technology"]["automation-science-pack"].research_trigger.item = "burner-lab"

---- Remove iron-stick from the many recipes that unlock it
for _, name in pairs { "railway", "electric-energy-distribution-1", "concrete", "circuit-network" } do
    remove_if(data.raw["technology"][name]["effects"], function(it) return it.recipe == "iron-stick" end)
end

---- Unlock belts in logistic 1
table.insert(
    data.raw["technology"]["logistics"]["effects"],
    1,
    {
        recipe = "transport-belt",
        type = "unlock-recipe"
    }
)

---- Move Long Handed Inserter for it's own tech
remove_if(
    data.raw["technology"]["automation"]["effects"],
    function(it)
        return it.recipe == "long-handed-inserter"
    end
)

-- Adjust the starting techs from unlocking too much
remove_if(
    data.raw["technology"]["steam-power"]["effects"],
    function(it)
        return it.recipe == "pipe" or it.recipe == "pipe-to-ground"
    end
)
data.raw["technology"]["electronics"]["effects"] = {
    {
        type = "unlock-recipe",
        recipe = "electronic-circuit"
    },
}

---- Merge automated rail into Railway
for _, recipe_name in ipairs { "train-stop", "rail-signal", "rail-chain-signal" } do
    table.insert(
        data.raw["technology"]["railway"]["effects"],
        {
            recipe = recipe_name,
            type = "unlock-recipe"
        }
    )
end

---- Merge nuclear-fuel-reprocessing into nuclear-power
table.insert(
    data.raw["technology"]["nuclear-power"]["effects"],
    {
        recipe = "nuclear-fuel-reprocessing",
        type = "unlock-recipe"
    }
)

---- Adjust Coal Liquefaction to be alternative oil source

-- Unlock refinery
table.insert(
    data.raw["technology"]["coal-liquefaction"]["effects"],
    {
        recipe = "oil-refinery",
        type = "unlock-recipe"
    }
)
-- Remove heavy oil cost
remove_if(
    data.raw["recipe"]["coal-liquefaction"]["ingredients"],
    function(it)
        return it.name == "heavy-oil"
    end
)

---- Remove oil cracking recipes from usual spot
remove_if(
    data.raw["technology"]["advanced-oil-processing"]["effects"],
    function(it)
        return it.recipe == "heavy-oil-cracking" or it.recipe == "light-oil-cracking" or it.recipe == "chemical-plant"
    end
)

---- Remove solid fuel recipe from usual recipes
remove_if(
    data.raw["technology"]["advanced-oil-processing"]["effects"],
    function(it)
        return it.recipe == "solid-fuel-from-heavy-oil" or it.recipe == "solid-fuel-from-light-oil"
    end
)
remove_if(
    data.raw["technology"]["oil-processing"]["effects"],
    function(it)
        return it.recipe == "solid-fuel-from-petroleum-gas"
    end
)

---- Remove big-electric-pole from electric-energy-distribution-1
remove_if(
    data.raw["technology"]["electric-energy-distribution-1"]["effects"],
    function(it)
        return it.recipe == "big-electric-pole"
    end
)

---- Remove regular inserter capacity bonus from inserter-capacity-bonus-7
remove_if(
    data.raw["technology"]["inserter-capacity-bonus-7"]["effects"],
    function(it)
        return it.type == "inserter-stack-size-bonus"
    end
)

---- Make Solar and Accumulators better

data.raw["solar-panel"]["solar-panel"].production = "240kW"
data.raw["accumulator"]["accumulator"].energy_source = {
    type = "electric",
    buffer_capacity = "20MJ",
    usage_priority = "tertiary",
    input_flow_limit = "1200kW",
    output_flow_limit = "1200kW"
}

---- Tweak Nuclear Reactor freebies

data.raw["item"]["steam-turbine"].stack_size = 50
data.raw["item"]["nuclear-reactor"].stack_size = 5

---- Buff Mining Productivity

data.raw["technology"]["mining-productivity-4"].effects[1].modifier = 0.25

---- Fluid/Barrel Handling

table.insert(data.raw["technology"]["fluid-wagon"]["effects"], {
    type = "unlock-recipe",
    recipe = "pump"
})
remove_if(
    data.raw["technology"]["fluid-handling"]["effects"],
    function(it)
        return it.recipe == "storage-tank" or it.recipe == "pump"
    end
)
data.raw["technology"]["fluid-handling"].icon = "__base__/graphics/icons/fluid/barreling/empty-barrel.png"
data.raw["technology"]["fluid-handling"].icon_size = 64
data.raw["recipe"]["fluid-wagon"].ingredients = {
    { type = "item", name = "iron-gear-wheel", amount = 10 },
    { type = "item", name = "iron-plate",      amount = 20 },
    { type = "item", name = "steel-plate",     amount = 21 },
    { type = "item", name = "pipe",            amount = 8 }
}
