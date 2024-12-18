local layout = require("layout")

local LOCAL_UNLOCKS = {}

local has_layout, layout_data = pcall(layout.get_data)
local starting_tech = {}

if has_layout and layout_data then
    starting_tech = layout_data.starting_tech
    for _, progressive in pairs(layout_data.progressive_data) do
        for _, location in pairs(progressive.locations) do
            LOCAL_UNLOCKS[location] = progressive.unlocked
        end
    end
end

local playersAlreadyWarned = {}
local _bannedCategoriesForFreebies = {
    ["rocket-building"] = true,
    ["hand-crafting"] = true,
}

---@param player_index int
local function give_pending_freebies(player_index)
    local freebies = storage.player_pending_freebies[player_index]
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

    for _, effect in ipairs(research.prototype.effects) do
        if effect.type == "unlock-recipe" then
            local recipe_proto = prototypes.recipe[effect.recipe]
            if not _bannedCategoriesForFreebies[recipe_proto.category] then
                local ingredient_count = {}
                for _, ingredient in pairs(recipe_proto.ingredients) do
                    if ingredient.type == "item" then
                        ingredient_count[ingredient.name] = ingredient_count.amount
                    end
                end

                for _, product in ipairs(recipe_proto.products) do
                    if product.type == "item" and (product.amount or product.amount_max) - (ingredient_count[product.name] or 0) > 0 then
                        table.insert(result, {
                            name = product.name,
                            count = prototypes.item[product.name].stack_size,
                        })
                    end
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
        table.insert(storage.total_freebies, freebie)
    end

    for _, player in pairs(research.force.players) do
        for _, freebie in pairs(freebies) do
            table.insert(storage.player_pending_freebies[player.index], freebie)
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
    -- if not storage.player_pending_freebies then
    --     storage.player_pending_freebies = {}
    --     storage.total_freebies = {}
    -- end

    if not storage.player_pending_freebies[event.player_index] then
        -- New joiner!
        local freebies = {}
        for _, freebie in pairs(storage.total_freebies) do
            table.insert(freebies, freebie)
        end
        storage.player_pending_freebies[event.player_index] = freebies
    end
    give_pending_freebies(event.player_index)
end


script.on_event(defines.events.on_player_joined_game, on_player_joined_game)

script.on_init(function()
    storage.player_pending_freebies = {}
    storage.total_freebies = {
        {
            name = "stone-furnace",
            count = prototypes.item["stone-furnace"].stack_size,
        },
        {
            name = "burner-mining-drill",
            count = prototypes.item["burner-mining-drill"].stack_size,
        }
    }

    local player_tech = game.forces.player.technologies
    for _, tech in ipairs(starting_tech) do
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