data.raw.lab.lab.fast_replaceable_group = "lab"

local burner_lab = table.deepcopy(data.raw.lab.lab)
burner_lab.name = "burner-lab"
burner_lab.minable.result = "burner-lab"
burner_lab.next_upgrade = "lab"
burner_lab.module_slots = nil
burner_lab.energy_source = {
    type = "burner",
    fuel_categories = {"chemical"},
    effectivity = 1,
    fuel_inventory_size = 1,
    emissions_per_minute = { pollution = 2 },
    light_flicker = {
        minimum_light_size = 1,
        light_intensity_to_size_coefficient = 0.25,
        color = {1, 0.5, 0},
        minimum_intensity = 0.1,
        maximum_intensity = 0.3
    },
    smoke = {
        {
            name = "smoke",
            deviation = {0.1, 0.1},
            position = {0.0, -1.0},
            frequency = 4
        }
    }
}
local function set_lab(layers, is_on)
    layers[1].filename = "__randovania-assets__/graphics/entity/burner-lab/burner-lab.png"

    if is_on then
        layers[3].filename = "__randovania-assets__/graphics/entity/burner-lab/burner-lab-light.png"
    end
end

burner_lab.icon = "__randovania-assets__/graphics/icons/burner-lab.png"
set_lab(burner_lab.on_animation.layers, true)
set_lab(burner_lab.off_animation.layers, false)


local lab_item = table.deepcopy(data.raw.item.lab)
lab_item.name = "burner-lab"
lab_item.icon = "__randovania-assets__/graphics/icons/burner-lab.png"
lab_item.place_result = "burner-lab"

local lab_recipe = {
    type = "recipe",
    name = "burner-lab",
    category = "crafting",
    enabled = true,
    energy_required = 5,
    ingredients = {
        {type = "item", name = "iron-gear-wheel", amount = 15},
        {type = "item", name = "copper-cable", amount = 30},
        {type = "item", name = "burner-inserter", amount = 5}
    },
    results = {{type = "item", name = "burner-lab", amount = 1}}
}

local machine = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-1"])
machine.name = "burner-assembling-machine"
machine.minable.result = "burner-assembling-machine"
machine.next_upgrade = "assembling-machine-1"
machine.energy_source = {
    type = "burner",
    fuel_categories = {"chemical"},
    effectivity = 1,
    fuel_inventory_size = 1,
    emissions_per_minute = { pollution = 4 },
    light_flicker = {
        minimum_light_size = 1,
        light_intensity_to_size_coefficient = 0.2,
        color = {1, 0.5, 0},
        minimum_intensity = 0.05,
        maximum_intensity = 0.3
    },
    smoke = {
        {
            name = "smoke",
            deviation = {0.1, 0.1},
            position = {0.5, -1.4},
            frequency = 3
        }
    }
}
machine.icon = "__randovania-assets__/graphics/icons/burner-assembling-machine.png"
machine.graphics_set.animation.layers[1].filename = "__randovania-assets__/graphics/entity/burner-assembling-machine/burner-assembling-machine.png"


local machine_item = table.deepcopy(data.raw.item["assembling-machine-1"])
machine_item.name = "burner-assembling-machine"
machine_item.icon = "__randovania-assets__/graphics/icons/burner-assembling-machine.png"
machine_item.place_result = "burner-assembling-machine"

local machine_recipe = {
    type = "recipe",
    name = "burner-assembling-machine",
    category = "crafting",
    order = "assembling-machine-0",
    enabled = true,
    energy_required = 5,
    ingredients = {
        {type = "item", name = "iron-gear-wheel", amount = 10},
        {type = "item", name = "copper-cable", amount = 10},
        {type = "item", name = "burner-inserter", amount = 3}
    },
    results = {{type = "item", name = "burner-assembling-machine", amount = 1}}
}

data.raw.recipe["assembling-machine-1"].order = "assembling-machine-1"
data.raw.recipe["assembling-machine-2"].order = "assembling-machine-2"
data.raw.recipe["assembling-machine-3"].order = "assembling-machine-3"

data:extend(
    {
        burner_lab,
        lab_item,
        lab_recipe,
        machine,
        machine_item,
        machine_recipe
    }
)
