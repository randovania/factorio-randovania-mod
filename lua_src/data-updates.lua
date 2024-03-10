for name, tech in pairs(data.raw["technology"]) do
    tech.hidden = true
end

function add_randovania_tech(param)
    local prototype = {
        type = "technology",
        name = param.name,
        icon_size = 256,
        icon_mipmaps = 4,
        icon = param.icon,
        effects = {},
        unit = param.costs,
        order = param.order or param.name,
        prerequisites = param.prerequisites,
    }
    if param.replicate then
        local replicated = data.raw["technology"][param.replicate]
        prototype.effects = replicated.effects
        prototype.localised_name = replicated.localised_name or {"technology-name." .. param.replicate}
        prototype.localised_description = replicated.localised_description or {"technology-description." .. param.replicate}
        replicated.effects = {}
        replicated.enabled = false
    end
    data:extend { prototype }
end

local tech_tree = require("generated.tech-tree")

for _, tech in ipairs(tech_tree) do
    add_randovania_tech(tech)
end
