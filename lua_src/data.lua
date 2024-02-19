local function remove_if(t, pred)
    for i = #t, 1, -1 do
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

local function make_tech(param)
    param.type = "technology"
    param.order = param.order or "d-b"
    param.unit = {
        count = 10,
        ingredients = {{"automation-science-pack", 1}},
        time = 15
    }
    return param
end

local kRecipesWithNewTech = {
    "transport-belt",
    "electronic-circuit",
    "light-armor",
    "inserter",
    "automation-science-pack",
    -- steam power
    "offshore-pump",
    "boiler",
    "steam-engine"
}

local kInitialRecipes = {
    -- basic resources
    "stone-furnace",
    "copper-plate",
    "iron-plate",
    "stone-brick",
    -- military
    "radar",
    "pistol",
    "firearm-magazine",
    "repair-pack",
    -- iron processing
    "iron-stick",
    "iron-gear-wheel",
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
    "electric-mining-drill",
    -- science
    "lab"
}

-- Create custom tech

data:extend {
    make_tech {
        name = "long-handed-inserter",
        effects = {
            {
                recipe = "long-handed-inserter",
                type = "unlock-recipe"
            }
        },
        icon = "__base__/graphics/technology/fast-inserter.png",
        icon_mipmaps = 4,
        icon_size = 256
    },
    make_tech {
        name = "oil-cracking",
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
        icon_size = 256
    },
    make_tech {
        name = "solid-fuel",
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
        icon_size = 256
    },
    make_tech {
        name = "light-armor",
        effects = {
            {
                recipe = "light-armor",
                type = "unlock-recipe"
            }
        },
        icon = "__base__/graphics/technology/heavy-armor.png",
        icon_mipmaps = 4,
        icon_size = 256
    },
    make_tech {
        name = "big-electric-pole",
        effects = {
            {
                recipe = "big-electric-pole",
                type = "unlock-recipe"
            }
        },
        icon = "__base__/graphics/technology/electric-energy-distribution-1.png",
        icon_mipmaps = 4,
        icon_size = 256
    },
    make_tech {
        name = "inserter",
        effects = {
            {
                recipe = "inserter",
                type = "unlock-recipe"
            }
        },
        icon = "__base__/graphics/technology/fast-inserter.png",
        icon_mipmaps = 4,
        icon_size = 256
    },
    make_tech {
        name = "steam-power",
        effects = {
            {
                type = "unlock-recipe",
                recipe = "offshore-pump"
            },
            {
                type = "unlock-recipe",
                recipe = "boiler"
            },
            {
                type = "unlock-recipe",
                recipe = "steam-engine"
            }
        },
        icon = "__base__/graphics/technology/electric-energy-acumulators.png",
        icon_mipmaps = 4,
        icon_size = 256
    },
    make_tech {
        name = "automation-science-pack",
        effects = {
            {
                type = "unlock-recipe",
                recipe = "automation-science-pack"
            }
        },
        icon = "__base__/graphics/technology/automation-science-pack.png",
        icon_mipmaps = 4,
        icon_size = 256
    },
    make_tech {
        name = "regular-inserter-capacity-bonus",
        effects = {
            {
              type = "inserter-stack-size-bonus",
              modifier = 1
            },
        },
        icon = "__base__/graphics/technology/inserter-capacity.png",
        icon_mipmaps = 4,
        icon_size = 256,
        upgrade = true
    }
}

---- Lock all initial recipes

for _, name in ipairs(kRecipesWithNewTech) do
    set_recipe_field(data.raw["recipe"][name], "enabled", false)
end

-- for _, name in ipairs(kInitialRecipes) do
--     set_recipe_field(data.raw["recipe"][name], "enabled", false)
-- end

---- Unlock belts in logistic 1
table.insert(
    data.raw["technology"]["logistics"]["effects"],
    {
        recipe = "transport-belt",
        type = "unlock-recipe"
    }
)

---- Repurpose electronics for electronic-circuit
data.raw["technology"]["electronics"].effects = {
    {
        recipe = "electronic-circuit",
        type = "unlock-recipe"
    }
}

---- Move Long Handed Inserter for it's own tech
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