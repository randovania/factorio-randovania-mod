local LOCAL_UNLOCKS = require("generated.local-unlocks")
local STARTING_TECH = require("generated.starting-tech")

local playersAlreadyWarned = {}

---@param player_index int
local function give_pending_freebies(player_index)
    local freebies = global.player_pending_freebies[player_index]
    local player = game.get_player(player_index)
    if not player or not freebies then
        return
    end

    local character = player.character
    if player.valid and character and character.valid then
        while freebies[1] do
            local stack = freebies[1]
            if character.can_insert(stack) then
                local sent = character.insert(stack)
                player.print(string.format("Received %dx [item=%s]", sent, stack.name))
                playersAlreadyWarned[player_index] = nil
                table.remove(freebies, 1)
            else
                if not playersAlreadyWarned[player_index] then
                    player.print("Unable to provide freebies, inventory is full.")
                    playersAlreadyWarned[player_index] = true
                end
                return
            end
        end
    end
end

---@param force LuaForce
---@param name string
local function unlock_tech(force, name)
    local research = force.technologies[name]
    -- research.force.print(string.format("Unlocking %s", name))
    research.researched = true
end

---@param force LuaForce
---@param progressive table
local function progressive_unlock(force, progressive)
    for _, name in ipairs(progressive) do
        if not force.technologies[name].researched then
            return unlock_tech(force, name)
        end
    end
end

---@param research LuaTechnology
local function freebies_for_tech(research)
    local result = {}

    for _, effect in ipairs(research.effects or {}) do
        if effect.type == "unlock-recipe" then
            local recipe_proto = game.recipe_prototypes[effect.recipe]
            for _, product in ipairs(recipe_proto.products) do
                local amount = (product.amount or product.amount_max or 0) - (product.catalyst_amount or 0)
                if product.type == "item" and amount > 0 then
                    table.insert(result, {
                        name = product.name,
                        count = game.item_prototypes[product.name].stack_size,
                    })
                end
            end
        end
    end

    return result
end

---@param research LuaTechnology
local function give_freebies(research)
    -- force.print(string.format("Giving freebies %s", research.name))

    local freebies = freebies_for_tech(research)

    for _, freebie in pairs(freebies) do
        table.insert(global.total_freebies, freebie)
    end

    for _, player in pairs(research.force.players) do
        for _, freebie in pairs(freebies) do
            table.insert(global.player_pending_freebies[player.index], freebie)
        end
        give_pending_freebies(player.index)
    end
end

---@param event EventData.on_research_finished Event data
local function on_research_finished(event)
    local research = event.research
    -- research.force.print(string.format("Researched %s", research.name))

    give_freebies(research)

    if LOCAL_UNLOCKS[research.name] then
        progressive_unlock(research.force, LOCAL_UNLOCKS[research.name])
    end
end

script.on_event(defines.events.on_research_finished, on_research_finished)

---@param event EventData.on_player_main_inventory_changed
local function on_player_main_inventory_changed(event)
    give_pending_freebies(event.player_index)
end

script.on_event(defines.events.on_player_main_inventory_changed, on_player_main_inventory_changed)

---@param event EventData.on_player_joined_game
local function on_player_joined_game(event)
    -- We shouldn't need this.
    -- if not global.player_pending_freebies then
    --     global.player_pending_freebies = {}
    --     global.total_freebies = {}
    -- end

    if not global.player_pending_freebies[event.player_index] then
        -- New joiner!
        local freebies = {}
        for _, freebie in pairs(global.total_freebies) do
            table.insert(freebies, freebie)
        end
        global.player_pending_freebies[event.player_index] = freebies
    end
    give_pending_freebies(event.player_index)
end

script.on_event(defines.events.on_player_joined_game, on_player_joined_game)

script.on_init(function()
    global.player_pending_freebies = {}
    global.total_freebies = {}

    local player_tech = game.forces.player.technologies
    for _, tech in ipairs(STARTING_TECH) do
        player_tech[tech].researched = true
        give_freebies(player_tech[tech])
    end
end)

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
