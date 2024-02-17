local function remove_if(t, pred)
    for i = #t, 1 do
        if pred(t[i]) then
            table.remove(t, i)
        end
    end
end

local function set_recipe_field(recipe, field, value)
    if recipe.normal then
        recipe.normal[field] = value
    else
        recipe[field] = value
    end
    if recipe.expensive then
        recipe.expensive[field] = value
    end
end

local kRecipesWithNewTech = {
    "transport-belt",
    "electronic-circuit",
    "light-armor",
}

local kInitialRecipes = {
    "copper-plate",
    "iron-plate",
    "stone-brick",
    "radar",
    "pistol",
    "small-electric-pole",
    "copper-cable",
    "offshore-pump",
    "pipe",
    "burner-inserter",
    "inserter",
    "burner-mining-drill",
    "electric-mining-drill",
    "iron-gear-wheel",
    "steam-engine",
    "boiler",
    "stone-furnace",
    "iron-stick",
    "wooden-chest",
    "iron-chest",
    "pipe-to-ground",
    "repair-pack",
    "lab",
    "automation-science-pack",
    "firearm-magazine",
}

---- Lock all initial recipes

-- for _, name in ipairs(kInitialRecipes) do
--     set_recipe_field(data.raw["recipe"][name], "enabled", false)
-- end

---- Unlock belts in logistic 1

---- Move Long Handed Inserter for it's own tech
data.raw["technology"]["long-handed-inserter"] = {
    effects = {
        {
            recipe = "long-handed-inserter",
            type = "unlock-recipe"
        }
    },
    icon = "__base__/graphics/technology/fast-inserter.png",
    icon_mipmaps = 4,
    icon_size = 256,
    order = "d-b",
    unit = {
        count = 75,
        ingredients = {{"automation-science-pack", 1}},
        time = 30
    }
}
remove_if(
    data.raw["technology"]["automation"]["effects"],
    function(it)
        return it.recipe == "long-handed-inserter"
    end
)

---- Merge automated rail into Railway
for _, recipe_name in ipairs {"train-stop", "rail-signal", "rail-chain-signal"} do
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

---- Create oil cracking recipe
data.raw["technology"]["oil-cracking"] = {
    effects = {
        {
            recipe = "chemical-plant",
            type = "unlock-recipe"
        },
        {
            recipe = "heavy-oil-cracking",
            type = "unlock-recipe"
        },
        {
            recipe = "light-oil-cracking",
            type = "unlock-recipe"
        }
    },
    icon = "__base__/graphics/technology/oil-processing.png",
    icon_mipmaps = 4,
    icon_size = 256,
    order = "d-b",
    unit = {
        count = 75,
        ingredients = {{"automation-science-pack", 1}},
        time = 30
    }
}
remove_if(
    data.raw["technology"]["advanced-oil-processing"]["effects"],
    function(it)
        return it.recipe == "heavy-oil-cracking" or it.recipe == "light-oil-cracking"
    end
)

---- Create solid fuel recipe
data.raw["technology"]["solid-fuel"] = {
    effects = {
        {
            recipe = "solid-fuel-from-heavy-oil",
            type = "unlock-recipe"
        },
        {
            recipe = "solid-fuel-from-light-oil",
            type = "unlock-recipe"
        },
        {
            recipe = "solid-fuel-from-petroleum-gas",
            type = "unlock-recipe"
        }
    },
    icon = "__base__/graphics/technology/oil-processing.png",
    icon_mipmaps = 4,
    icon_size = 256,
    order = "d-b",
    unit = {
        count = 75,
        ingredients = {{"automation-science-pack", 1}},
        time = 30
    }
}
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

---- Create light armor
data.raw["technology"]["light-armor"] = {
    effects = {
        {
            recipe = "light-armor",
            type = "unlock-recipe"
        }
    },
    icon = "__base__/graphics/technology/heavy-armor.png",
    icon_mipmaps = 4,
    icon_size = 256,
    order = "g-a-b",
    unit = {
        count = 75,
        ingredients = {{"automation-science-pack", 1}},
        time = 30
    }
}
