
local LOCAL_UNLOCKS = {
    ["randovania-red-01"] = "steel-processing",
}

local function add_freebie(force, name)
    local stack = {
        name = name,
        count = game.item_prototypes[name].stack_size,
    }

    for _, player in pairs(force.players) do
        if player.valid and player.character and player.character.valid then
            local character = player.character
            if character.can_insert(stack) then
                local sent = character.insert(stack)
                player.print(string.format("Received %dx [item=%s]", sent, name))
            else
                player.print("Unable to provide freebies, inventory is full.")
            end
        end
    end
end

local function unlock_with_freebies(force, name)
    local research = force.technologies[name]

    research.researched = true
    for _, effect in ipairs(research.effects or {}) do
        if effect.type == "unlock-recipe" then
            local recipe_proto = game.recipe_prototypes[effect.recipe]
            for _, product in ipairs(recipe_proto.products) do
                local amount = (product.amount or product.amount_max or 0) - (product.catalyst_amount or 0)
                if product.type == "item" and amount > 0 then
                    add_freebie(force, product.name)
                end
            end
        end
    end
end

---@param event EventData.on_research_finished Event data
local function on_research_finished(event)
    local research = event.research
    research.force.print(string.format("Researched %s", research.name))

    if LOCAL_UNLOCKS[research.name] then
        unlock_with_freebies(research.force, LOCAL_UNLOCKS[research.name])
    end
end

script.on_event(defines.events.on_research_finished, on_research_finished)

local function data_sync()
    local unlocked_research = {}
    for name, tech in pairs(game.forces["player"].technologies) do
        if tech.researched then
            if name:match("randovania-") then
                table.insert(unlocked_research, name)
            end
        end
    end

    rcon.print(game.table_to_json({
        api_version = 1,
        unlocked_research = unlocked_research,
    }))
end

commands.add_command("randovania-sync", "Exports all the data needed by Randovania", data_sync)
