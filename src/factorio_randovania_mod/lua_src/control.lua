local layout = require("layout")

local LOCAL_UNLOCKS = {}

local has_layout, layout_data = pcall(layout.get_data)
local starting_tech = {}

local freebie_full_stack = true
local strict_multiplayer_freebie = false

if has_layout and layout_data then
    starting_tech = layout_data.starting_tech
    for _, progressive in pairs(layout_data.progressive_data) do
        for _, location in pairs(progressive.locations) do
            LOCAL_UNLOCKS[location] = progressive.unlocked
        end
    end

    freebie_full_stack = not layout_data.optional_modifications.single_item_freebie
    strict_multiplayer_freebie = layout_data.optional_modifications.strict_multiplayer_freebie
end

local freebie_rounding = strict_multiplayer_freebie and math.floor or math.ceil

---comment
---@param player_index integer
---@return {[string]:integer}
local function get_pending_freebies_for(player_index)
    return storage.player_pending_freebies[player_index]
end

local players_already_warned = {}
local k_item_types_with_freebies = {
    ["armor"] = true,
    ["gun"] = true,
}

---@param item_prototype LuaItemPrototype
---@return integer
local function should_give_freebie_for(item_prototype)
    if item_prototype.place_result or item_prototype.place_as_equipment_result or item_prototype.module_effects or k_item_types_with_freebies[item_prototype.type] then
        if freebie_full_stack then
            return item_prototype.stack_size
        else
            return 1
        end
    end
    return 0
end

---Attempt to deliver any pending freebies for the given player.
---@param player_index int
local function give_pending_freebies(player_index)
    local pending_freebies = get_pending_freebies_for(player_index)
    local player = game.get_player(player_index)
    if not player or not pending_freebies then
        return
    end

    local character = player.character
    if player.valid and character and character.valid then
        while next(pending_freebies) do
            local item_name = next(pending_freebies)
            assert(item_name)

            local stack = {name = item_name, count = pending_freebies[item_name]} --[[@as ItemStackDefinition]]
            if character.can_insert(stack) then
                local sent = character.insert(stack)
                player.print(string.format("Received %dx [item=%s]", sent, stack.name))
                players_already_warned[player_index] = nil
                pending_freebies[item_name] = nil
            else
                if not players_already_warned[player_index] then
                    player.print("Unable to provide freebies, inventory is full.")
                    players_already_warned[player_index] = true
                end
                return
            end
        end
    else
        -- game.print(string.format("give_pending_freebies: player %s does not have valid character", player.name))
    end
end

---@param name string
local function unlock_tech(name)
    local force = game.forces.player
    local research = force.technologies[name]
    research.researched = true
end

---@param progressive table
local function progressive_unlock(progressive)
    local force = game.forces.player
    for _, name in ipairs(progressive) do
        if not force.technologies[name].researched then
            return unlock_tech(name)
        end
    end
end

---Gets what freebies should be distributed with the given research.
---@param research LuaTechnology
---@return {[string]: integer}
local function freebies_for_tech(research)
    local result = {}

    for _, effect in ipairs(research.prototype.effects) do
        if effect.type == "unlock-recipe" then
            for _, product in ipairs(prototypes.recipe[effect.recipe].products) do
                if product.type == "item" then
                    local freebie_count = should_give_freebie_for(prototypes.item[product.name])
                    if freebie_count > 0 and not result[product.name] then
                        result[product.name] = freebie_count
                    end
                end
            end
        end
    end

    return result
end

---Increments how much pending 
---@param player_index integer
---@param item_name string
---@param amount integer
local function distribute_freebie_to_player(player_index, item_name, amount)
    if amount > 0 then
        local player_storage = get_pending_freebies_for(player_index)
        player_storage[item_name] = (player_storage[item_name] or 0) + amount
    end
end

---For every item in storage.items_with_freebies, distribute it to connected players.
local function distribute_freebies()
    local force = game.forces.player
    local total_players = #force.connected_players
    if total_players == 0 then
        -- game.print("distribute_freebies: no connected players")
        return
    end

    for freebie, amount in pairs(storage.items_with_freebies) do
        if amount > 0 then
            local per_player = freebie_rounding(amount / total_players)
            -- game.print(string.format("distribute_freebies: for %s, giving %d per player", freebie, per_player))

            local first_player = nil

            for _, player in pairs(force.players) do
                local to_give = strict_multiplayer_freebie and 0 or 1
                if player.connected then
                    first_player = first_player or player
                    storage.items_with_freebies[freebie] = math.max(storage.items_with_freebies[freebie] - per_player, 0)
                    to_give = per_player
                end
                distribute_freebie_to_player(player.index, freebie, to_give)
            end

            if storage.items_with_freebies[freebie] > 0 and first_player then
                distribute_freebie_to_player(first_player.index, freebie, storage.items_with_freebies[freebie])
                storage.items_with_freebies[freebie] = 0
            end
        end
    end
end

---@param freebies {[string]: integer}
local function give_freebies(freebies)
    for freebie, amount in pairs(freebies) do
        if not storage.items_with_freebies[freebie] then
            storage.items_with_freebies[freebie] = amount
        end
    end

    distribute_freebies()
    for _, player in pairs(game.forces.player.players) do
        give_pending_freebies(player.index)
    end
end

---@param event EventData.on_research_finished Event data
local function on_research_finished(event)
    local research = event.research
    if research.force ~= game.forces.player then return end

    -- game.print(string.format("Researched %s", research.name))
    give_freebies(freebies_for_tech(research))

    if LOCAL_UNLOCKS[research.name] then
        progressive_unlock(LOCAL_UNLOCKS[research.name])
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
    if not storage.player_pending_freebies[event.player_index] then
        -- New joiner!
        local freebies = {}

        if not strict_multiplayer_freebie then
            for freebie, amount in pairs(storage.items_with_freebies) do
                if amount == 0 then
                    freebies[freebie] = 1
                end
            end
        end
        storage.player_pending_freebies[event.player_index] = freebies
    end
    distribute_freebies()
    give_pending_freebies(event.player_index)
end

script.on_event(defines.events.on_player_joined_game, on_player_joined_game)


---@param event EventData.on_player_toggled_map_editor
local function on_player_toggled_map_editor(event)
    distribute_freebies()
    give_pending_freebies(event.player_index)
end

script.on_event(defines.events.on_player_toggled_map_editor, on_player_toggled_map_editor)

---@param items string[]
---@returns {[string]: integer}
local function starting_item_freebies(items)
    local result = {}
    for _, name in pairs(items) do
        result[name] = prototypes.item[name].stack_size
    end
    return result
end

script.on_init(function()
    storage.player_pending_freebies = {}
    storage.items_with_freebies = {}

    give_freebies(starting_item_freebies {
        "stone-furnace",
        "burner-mining-drill",
    })

    local player_tech = game.forces.player.technologies
    for _, tech in ipairs(starting_tech) do
        player_tech[tech].researched = true
        -- give_freebies(freebies_for_tech(player_tech[tech]), force)
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

    rcon.print(helpers.table_to_json({
        api_version = 1,
        unlocked_research = unlocked_research,
    }))
end

commands.add_command("randovania-sync", "Exports all the data needed by Randovania", data_sync)

script.on_event(defines.events.on_player_created, function(event)
    local player = game.get_player(event.player_index)
    if not player then return end

    local error_message

    if has_layout and not layout_data then
        -- Layout string not set
        error_message = {"randovania.invalid_layout_missing"}
    elseif not has_layout then
        -- Invalid layout string
        error_message = {"randovania.invalid_layout_bad", layout_data}
    else
        give_pending_freebies(event.player_index)
        return
    end

    local screen_element = player.gui.screen
    local main_frame = screen_element.add{
        type="frame",
        name="rdv_main_frame",
        caption={"randovania.invalid_layout_title"},
        direction="vertical",
    }
    -- main_frame.style.size = {385, 165}
    main_frame.auto_center = true
    
    main_frame.add{type="label", name="intro", caption={"randovania.invalid_layout_intro"}}
    main_frame.add{type="label", name="message", caption=error_message}
    main_frame.add{type="line", name="footer_line"}
    main_frame.add{type="label", name="footer", caption={"randovania.invalid_layout_footer"}}.style.single_line = false
end)