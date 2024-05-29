local function make_tech(param)
    param.type = "technology"
    param.order = param.order or "d-b"
    if param.cost_reference then
        param.unit = table.deepcopy(data.raw["technology"][param.cost_reference].unit)
        param.prerequisites = { param.cost_reference }
        param.cost_reference = nil
    end
    return param
end

data:extend {
    {
        type = "tool",
        name = "impossible-science-pack",
        icon = "__core__/graphics/icons/technology/effect/effect-deconstruction.png",
        icon_size = 64, icon_mipmaps = 1,
        subgroup = "science-pack",
        order = "z[automation-science-pack]",
        stack_size = 20,
        durability = 1,
        durability_description_key = "description.science-pack-remaining-amount-key",
        durability_description_value = "description.science-pack-remaining-amount-value"
    },

    make_tech {
        cost_reference = "automation",
        name = "long-handed-inserter",
        effects = {
            {
                recipe = "long-handed-inserter",
                type = "unlock-recipe"
            }
        },
        icon = "__randovania-layout__/graphics/technology/long-handed-inserter.png",
        icon_mipmaps = 4,
        icon_size = 256
    },
    make_tech {
        cost_reference = "automation",
        name = "longer-handed-inserter",
        effects = {
            {
                recipe = "longer-handed-inserter",
                type = "unlock-recipe"
            }
        },
        icon = "__randovania-layout__/graphics/technology/longer-handed-inserter.png",
        icon_mipmaps = 4,
        icon_size = 256
    },
    make_tech {
        cost_reference = "advanced-oil-processing",
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
        cost_reference = "oil-processing",
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
        cost_reference = "heavy-armor",
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
        cost_reference = "electric-energy-distribution-1",
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
        unit = {
            count = 20,
            ingredients = { },
            time = 20
        },
        effects = {
            {
                recipe = "inserter",
                type = "unlock-recipe"
            }
        },
        icon = "__base__/graphics/technology/fast-inserter.png",
        icon_mipmaps = 4,
        icon_size = 256,

    },
    make_tech {
        name = "steam-power",
        unit = {
            count = 50,
            ingredients = { },
            time = 20
        },
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
        icon = "__base__/graphics/icons/steam-engine.png",
        icon_mipmaps = 4,
        icon_size = 64
    },
    make_tech {
        name = "automation-science-pack",
        unit = {
            count = 10,
            ingredients = { },
            time = 10
        },
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
        cost_reference = "inserter-capacity-bonus-2",
        name = "regular-inserter-capacity-bonus",
        effects = {
            {
                type = "inserter-stack-size-bonus",
                modifier = 1
            }
        },
        icon = "__base__/graphics/technology/inserter-capacity.png",
        icon_mipmaps = 4,
        icon_size = 256,
        max_level = "infinite",
        upgrade = true
    },
    make_tech {
        cost_reference = "inserter-capacity-bonus-1",
        name = "stack-inserter-capacity-bonus",
        effects = {
            {
                type = "stack-inserter-capacity-bonus",
                modifier = 2
            }
        },
        icon = "__base__/graphics/technology/inserter-capacity.png",
        icon_mipmaps = 4,
        icon_size = 256,
        max_level = "infinite",
        upgrade = true
    },
    make_tech {
        cost_reference = "research-speed-1",
        name = "research-productivity",
        effects = {
            {
                type = "laboratory-productivity",
                modifier = 0.1
            }
        },
        icons = util.technology_icon_constant_productivity("__base__/graphics/technology/research-speed.png"),
        icon_mipmaps = 4,
        icon_size = 256,
        max_level = "infinite",
        upgrade = true
    },
    make_tech {
        cost_reference = "fluid-handling",
        name = "fluid-storage",
        effects = {
            {
                type = "unlock-recipe",
                recipe = "storage-tank"
            },
            {
                type = "unlock-recipe",
                recipe = "pump"
            }
        },
        icon = "__base__/graphics/technology/fluid-handling.png",
        icon_mipmaps = 4,
        icon_size = 256
    }
}
