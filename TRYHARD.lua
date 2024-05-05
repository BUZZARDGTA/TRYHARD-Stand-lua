-- TRYHARD lua for STAND by IB_U_Z_Z_A_R_Dl
-- GitHub repo: https://github.com/Illegal-Services/TRYHARD-lua

-- CREDITS:
-- Well this is my very first Lua script, and I'm so thanksfull to everyone who helped me get into this new world.
--
-- JerryScript lua by @Jerry123#4508: Original "Hotkey Weapon Thermal Vision" code before I tweaked it.
-- Heist Control lua by @icedoomfist: Original "Auto Refill Snacks & Armours" code before I tweaked it.
-- Crosshair lua by @CocoW: Original "Better Crosshair" code before I tweaked it.
--
-- People that helped me in Stand's Discord server in #Programming:
-- @hexarobi, @someoneidfk, @asuka666, @prisuhm and everyone else that I forgot.

util.require_natives("1660775568-uno")

local CURRENT_SCRIPT_VERSION = 0.6
local TITLE = "TRYHARD " .. "v" .. CURRENT_SCRIPT_VERSION .. " by IBU_Z_Z_A_R_Dl"

local my_root = menu.my_root()
local joaat = util.joaat

function STAT_SET_INT(stat, value)
    STATS.STAT_SET_INT(joaat(ADD_MP_INDEX(stat)), value, true)
end

function ADD_MP_INDEX(stat)
    local Exceptions = {
        "MP_CHAR_STAT_RALLY_ANIM",
        "MP_CHAR_ARMOUR_1_COUNT",
        "MP_CHAR_ARMOUR_2_COUNT",
        "MP_CHAR_ARMOUR_3_COUNT",
        "MP_CHAR_ARMOUR_4_COUNT",
        "MP_CHAR_ARMOUR_5_COUNT",
    }

    for _, exception in pairs(Exceptions) do
        if stat == exception then
            return "MP" .. util.get_char_slot() .. "_" .. stat
        end
    end

    if
        not string.startswith(stat, "MP_")
        and not string.startswith(stat, "MPPLY_")
    then
        return "MP" .. util.get_char_slot() .. "_" .. stat
    end

    return stat
end

function enable_thermal_vision(thermal_command)
    menu.trigger_command(thermal_command, "on")
    GRAPHICS._SEETHROUGH_SET_MAX_THICKNESS(50.0)
end

function disable_thermal_vision(thermal_command)
    menu.trigger_command(thermal_command, "off")
    GRAPHICS._SEETHROUGH_SET_MAX_THICKNESS(1.0)
end

print(string.rep("-", 50))

my_root:divider("<-  " ..  TITLE .. "  ->")

local show_crosshair = my_root:list("Better Crosshair")
local hide_crosshair_in_vehicles = true
local hide_crosshair_in_stand_menu = true
local display_warning_message = true
local crosshair_tex = directx.create_texture(filesystem.scripts_dir() .. "cr1.png")
local crosshair_size = 0.025
local crosshair_idle_colour = {r=1.0,g=1.0,b=1.0,a=1.0}
local crosshair_hostile_ped_colour = {r=1.0,g=0.0,b=0.0,a=1.0}
local crosshair_friendly_ped_colour = {r=0.0,g=0.0,b=1.0,a=1.0}
local crosshair_default_ped_colour = {r=1.0,g=1.0,b=1.0,a=0.5}
local crosshair_colour = crosshair_idle_colour
local sniper_rifle_hash = joaat("weapon_sniperrifle")
local heavy_sniper_hash = joaat("weapon_heavysniper")
local heavy_sniper_mk2_hash = joaat("weapon_heavysniper_mk2")
local marksman_rifle_hash = joaat("weapon_marksmanrifle")
local marksman_rifle_mk2_hash = joaat("weapon_marksmanrifle_mk2")
local precision_rifle_hash = joaat("weapon_precisionrifle")
local musket_hash = joaat("weapon_musket")

show_crosshair:toggle_loop("Render Alternative Crosshair (beta)", {}, "Replace the original game's crosshair with an enhanced and customizable one.", function()
    if display_warning_message then
        display_warning_message = false
        util.toast(
            "[Lua Script]: " .. TITLE .. "\n"
            .. "\nI'm aware that aiming at vehicles with a ped inside is glitched."
            .. "\nI couldn't fin a solution for it yet."
        )
    end

    if
        menu.is_open()
        and hide_crosshair_in_stand_menu
    then
        return
    end

    local user = PLAYER.PLAYER_ID()
    if
        not PLAYER.IS_PLAYER_PLAYING(user)
        or not NETWORK.NETWORK_IS_PLAYER_CONNECTED(user)
        or not NETWORK.NETWORK_IS_PLAYER_ACTIVE(user)
        or PLAYER.IS_PLAYER_DEAD(user)
        or NETWORK.IS_PLAYER_IN_CUTSCENE(user)
        or NETWORK.NETWORK_IS_PLAYER_FADING(user)
        or HUD.IS_PAUSE_MENU_ACTIVE()
        or util.is_session_transition_active()
    then
        return
    end

    local user_ped = PLAYER.PLAYER_PED_ID()
    if
        PED.IS_PED_IN_ANY_VEHICLE(user_ped, false)
        and hide_crosshair_in_vehicles
    then
        return
    end

    if PLAYER.IS_PLAYER_FREE_AIMING(user) then
        HUD.HIDE_HUD_COMPONENT_THIS_FRAME(14)

        local ped_info = {
            is_a_ped = nil,
            is_a_player = nil,
            is_a_vehicle = nil,
            is_dead = nil,
            is_hostile = nil,
            is_friendly = nil,
            is_in_vehicle = nil,
        }

        local pEntity <const> = memory.alloc_int()
        if PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(user, pEntity) then
            local aimed_entity = memory.read_int(pEntity)
            if ENTITY.IS_ENTITY_A_PED(aimed_entity) then
                ped_info.is_a_ped = true -- PLACEHOLDER \/ FOR COMMENTED CODE BELLOW \/
                --if PED.IS_PED_IN_ANY_VEHICLE(aimed_entity, true) then
                --    ped_info.is_in_vehicle = true
                --    local vehicle = PED.GET_VEHICLE_PED_IS_IN(aimed_entity, false)
                --    if vehicle then
                --        if PLAYER.IS_PLAYER_FREE_AIMING_AT_ENTITY(vehicle) then
                --            print(true)
                --            ped_info.is_a_vehicle = true
                --            ped_info.is_a_ped = false
                --        else
                --            print(false)
                --            ped_info.is_a_vehicle = false
                --            ped_info.is_a_ped = true
                --        end
                --    end
                --else
                --    ped_info.is_in_vehicle = false
                --    ped_info.is_a_vehicle = false
                --    ped_info.is_a_ped = true
                --end

                ped_info.is_a_player = PED.IS_PED_A_PLAYER(aimed_entity)

                if ped_info.is_hostile == nil then
                    ped_info.is_hostile = PED.IS_PED_IN_COMBAT(aimed_entity, user_ped)
                end

                local blip = HUD.GET_BLIP_FROM_ENTITY(aimed_entity)
                if
                    blip
                    and HUD.DOES_BLIP_EXIST(blip)
                then
                    local blipColour = HUD.GET_BLIP_COLOUR(blip)
                    print("DEBUG: blip:" .. blip .. " | blipColour:" .. blipColour)
                    if ped_info.is_hostile == nil then
                        ped_info.is_hostile = (
                            blipColour == 1
                            or blipColour == 59
                        ) and true or false
                    end
                    ped_info.is_friendly = HUD.GET_BLIP_COLOUR(blip) == 57
                end

                if ped_info.is_a_ped then
                    ped_info.is_dead = ENTITY.IS_ENTITY_DEAD(aimed_entity) and true or false
                end
            end
        end

        -- WEAPON.GET_CURRENT_PED_WEAPON
        local selected_weapon = WEAPON.GET_SELECTED_PED_WEAPON(user_ped)
        if
            selected_weapon == sniper_rifle_hash
            or selected_weapon == heavy_sniper_hash
            or selected_weapon == heavy_sniper_mk2_hash
            or selected_weapon == marksman_rifle_hash
            or selected_weapon == marksman_rifle_mk2_hash
        then
            HUD.DISPLAY_SNIPER_SCOPE_THIS_FRAME()
            return
        else
            if ped_info.is_a_ped then
                if ped_info.is_dead then
                    crosshair_colour = crosshair_default_ped_colour
                elseif ped_info.is_hostile then
                    crosshair_colour = crosshair_hostile_ped_colour
                elseif ped_info.is_friendly then
                    crosshair_colour = crosshair_friendly_ped_colour
                elseif ped_info.is_a_player then
                    crosshair_colour = crosshair_hostile_ped_colour
                else
                    crosshair_colour = crosshair_default_ped_colour
                end
            else
                crosshair_colour = crosshair_idle_colour
            end
        end

    else
        crosshair_colour = crosshair_idle_colour
    end

    directx.draw_texture(
        crosshair_tex,      -- id
        crosshair_size,     -- sizeX
        crosshair_size,     -- sizeY
        0.5,                -- centerX
        0.5,                -- centerY
        0.5,                -- posX
        0.5,                -- posY
        0.0,                -- rotation
        crosshair_colour    -- colour
    )

end, function()
    display_warning_message = true
end)
show_crosshair:divider("---------------------------------------")
show_crosshair:divider("Options:")
show_crosshair:divider("---------------------------------------")
show_crosshair:toggle("Hide Crosshair in Vehicles", {}, "Stops the crosshair rendering when in vehicles.", function(toggle)
    hide_crosshair_in_vehicles = toggle
end, true)
show_crosshair:toggle("Hide Crosshair if Stand Opened", {}, "Stops the crosshair rendering when Stand is opened.", function(toggle)
    hide_crosshair_in_stand_menu = toggle
end, true)
show_crosshair:slider_float("Crosshair Size", {}, "Changes the rendered crosshair size.", 10, 50, 25, 1, function(value)
    crosshair_size = value / 1000
end)
show_crosshair:colour("Crosshair Colour", {}, "Changes the rendered crosshair colour.", crosshair_colour, false, function(colour)
    crosshair_colour = colour
end)

local hotkey_suicide = my_root:list("Hotkey Suicide")
local suicide_loop = false
local last_suicide_request = nil

hotkey_suicide:toggle_loop("Hotkey Suicide", {}, 'Makes it so you can instantly kill yourself on double-tapping "G" key.', function()
    local user = PLAYER.PLAYER_ID()

    if PLAYER.IS_PLAYER_PLAYING(user)
        and NETWORK.NETWORK_IS_PLAYER_CONNECTED(user)
        and NETWORK.NETWORK_IS_PLAYER_ACTIVE(user)
        and not PLAYER.IS_PLAYER_DEAD(user)
        and not NETWORK.IS_PLAYER_IN_CUTSCENE(user)
        and not NETWORK.NETWORK_IS_PLAYER_FADING(user)
        and not HUD.IS_PAUSE_MENU_ACTIVE()
        and not util.is_session_transition_active()
    then
        local user_ped = PLAYER.PLAYER_PED_ID()
        local suicide = false

        if suicide_loop then
            suicide = true
        else
            if PAD.IS_CONTROL_JUST_PRESSED(0, 47) then
                local currentTime = os.time()

                if last_suicide_request then
                    if currentTime - last_suicide_request <= 0.1 then
                        suicide = true
                    end
                end

                last_suicide_request = currentTime
            end
        end

        if suicide then
            ENTITY.SET_ENTITY_HEALTH(user_ped, 0.0, 0)
        end
    end
end)

hotkey_suicide:divider("---------------------------------------")
hotkey_suicide:divider("Options:")
hotkey_suicide:divider("---------------------------------------")
hotkey_suicide:toggle("Suicide Loop", {}, "Kill yourself on loop.", function(toggle)
    suicide_loop = toggle
end, false)

local hotkey_weapon_thermal_vision = my_root:list("Hotkey Weapon Thermal Vision")
local thermal_command = menu.ref_by_command_name("thermalvision")
local reload_with_thermal_vision = true

hotkey_weapon_thermal_vision:toggle_loop("Hotkey Weapon Thermal Vision", {}, 'Makes it so when you aim with any gun, you can toggle thermal vision on "E" key.', function()
    local user = PLAYER.PLAYER_ID()
    local thermal_state = menu.get_value(thermal_command)

    if PLAYER.IS_PLAYER_FREE_AIMING(user) then
        if PAD.IS_CONTROL_JUST_PRESSED(0, 38) then
            if thermal_state then
                disable_thermal_vision(thermal_command)
            else
                enable_thermal_vision(thermal_command)
            end
        end
    else
        local user_ped = PLAYER.PLAYER_PED_ID()

        if thermal_state then
            if PED.IS_PED_RELOADING(user_ped) then
                if not reload_with_thermal_vision then
                    disable_thermal_vision(thermal_command)
                    while PED.IS_PED_RELOADING(user_ped) do
                        util.yield()
                    end
                    if PLAYER.IS_PLAYER_FREE_AIMING(user) then
                        enable_thermal_vision(thermal_command)
                    end
                end
            else
                disable_thermal_vision(thermal_command)
            end
        end
    end
end)
hotkey_weapon_thermal_vision:divider("---------------------------------------")
hotkey_weapon_thermal_vision:divider("Options:")
hotkey_weapon_thermal_vision:divider("---------------------------------------")
hotkey_weapon_thermal_vision:toggle("Reload with Thermal Vision", {}, "", function(toggle)
    reload_with_thermal_vision = toggle
end, true)

local auto_refill_snacks_and_armours = my_root:list("Auto Refill Snacks & Armor")
local user_snacks_and_armors_to_refill = {
    NO_BOUGHT_YUM_SNACKS = 30,
    NO_BOUGHT_HEALTH_SNACKS = 15,
    NO_BOUGHT_EPIC_SNACKS = 5,
    NUMBER_OF_ORANGE_BOUGHT = 10,
    NUMBER_OF_BOURGE_BOUGHT = 10,
    NUMBER_OF_CHAMP_BOUGHT = 5,
    CIGARETTES_BOUGHT = 20,
    NUMBER_OF_SPRUNK_BOUGHT = 10,
    MP_CHAR_ARMOUR_1_COUNT = 10,
    MP_CHAR_ARMOUR_2_COUNT = 10,
    MP_CHAR_ARMOUR_3_COUNT = 10,
    MP_CHAR_ARMOUR_4_COUNT = 10,
    MP_CHAR_ARMOUR_5_COUNT = 10
}

auto_refill_snacks_and_armours:toggle_loop("Auto Refill Snacks & Armours", {}, "Automatically refill selected Snacks & Armor every 10 seconds.", function()
    STAT_SET_INT("NO_BOUGHT_YUM_SNACKS", user_snacks_and_armors_to_refill["NO_BOUGHT_YUM_SNACKS"])
    STAT_SET_INT("NO_BOUGHT_HEALTH_SNACKS", user_snacks_and_armors_to_refill["NO_BOUGHT_HEALTH_SNACKS"])
    STAT_SET_INT("NO_BOUGHT_EPIC_SNACKS", user_snacks_and_armors_to_refill["NO_BOUGHT_EPIC_SNACKS"])
    STAT_SET_INT("NUMBER_OF_ORANGE_BOUGHT", user_snacks_and_armors_to_refill["NUMBER_OF_ORANGE_BOUGHT"])
    STAT_SET_INT("NUMBER_OF_BOURGE_BOUGHT", user_snacks_and_armors_to_refill["NUMBER_OF_BOURGE_BOUGHT"])
    STAT_SET_INT("NUMBER_OF_CHAMP_BOUGHT", user_snacks_and_armors_to_refill["NUMBER_OF_CHAMP_BOUGHT"])
    STAT_SET_INT("CIGARETTES_BOUGHT", user_snacks_and_armors_to_refill["CIGARETTES_BOUGHT"])
    STAT_SET_INT("NUMBER_OF_SPRUNK_BOUGHT", user_snacks_and_armors_to_refill["NUMBER_OF_SPRUNK_BOUGHT"])
    for i = 1, 5 do
        STAT_SET_INT("MP_CHAR_ARMOUR_" .. i .. "_COUNT", user_snacks_and_armors_to_refill["MP_CHAR_ARMOUR_" .. i .. "_COUNT"])
    end

    util.yield(10000) -- No need to spam it.
end)

auto_refill_snacks_and_armours:divider("---------------------------------------")
auto_refill_snacks_and_armours:divider("Snacks to Refill:")
auto_refill_snacks_and_armours:divider("---------------------------------------")
auto_refill_snacks_and_armours:slider("P'S & Q's", {}, 'Number of "P\'S & Q\'s" to refill.', 0, 30, 30, 1, function(value)
    user_snacks_and_armors_to_refill["NO_BOUGHT_YUM_SNACKS"] = value
end)
auto_refill_snacks_and_armours:slider("EgoChaser", {}, 'Number of "EgoChaser" to refill.', 0, 15, 15, 1, function(value)
    user_snacks_and_armors_to_refill["NO_BOUGHT_HEALTH_SNACKS"] = value
end)
auto_refill_snacks_and_armours:slider("Meteorite", {}, 'Number of "Meteorite" to refill.', 0, 5, 5, 1, function(value)
    user_snacks_and_armors_to_refill["NO_BOUGHT_EPIC_SNACKS"] = value
end)
auto_refill_snacks_and_armours:slider("eCola", {}, 'Number of "eCola" to refill.', 0, 10, 10, 1, function(value)
    user_snacks_and_armors_to_refill["NUMBER_OF_ORANGE_BOUGHT"] = value
end)
auto_refill_snacks_and_armours:slider("Pisswasser", {}, 'Number of "Pisswasser" to refill.', 0, 10, 10, 1, function(value)
    user_snacks_and_armors_to_refill["NUMBER_OF_BOURGE_BOUGHT"] = value
end)
auto_refill_snacks_and_armours:slider("Blêuter'd Champagne", {}, 'Number of "Blêuter\'d Champagne" to refill.', 0, 5, 5, 1, function(value)
    user_snacks_and_armors_to_refill["NUMBER_OF_CHAMP_BOUGHT"] = value
end)
auto_refill_snacks_and_armours:slider("Smokes", {}, 'Number of "Smokes" to refill.', 0, 20, 20, 1, function(value)
    user_snacks_and_armors_to_refill["CIGARETTES_BOUGHT"] = value
end)
auto_refill_snacks_and_armours:slider("Sprunk", {}, 'Number of "Sprunk" to refill.', 0, 10, 10, 1, function(value)
    user_snacks_and_armors_to_refill["NUMBER_OF_SPRUNK_BOUGHT"] = value
end)
auto_refill_snacks_and_armours:divider("---------------------------------------")
auto_refill_snacks_and_armours:divider("Armors to Refill:")
auto_refill_snacks_and_armours:divider("---------------------------------------")
auto_refill_snacks_and_armours:slider("Super Light Armor", {}, 'Number of "Super Light Armor" to refill.', 0, 10, 10, 1, function(value)
    user_snacks_and_armors_to_refill["MP_CHAR_ARMOUR_1_COUNT"] = value
end)
auto_refill_snacks_and_armours:slider("Light Armor", {}, 'Number of "Light Armor" to refill.', 0, 10, 10, 1, function(value)
    user_snacks_and_armors_to_refill["MP_CHAR_ARMOUR_2_COUNT"] = value
end)
auto_refill_snacks_and_armours:slider("Standard Armor", {}, 'Number of "Standard Armor" to refill.', 0, 10, 10, 1, function(value)
    user_snacks_and_armors_to_refill["MP_CHAR_ARMOUR_3_COUNT"] = value
end)
auto_refill_snacks_and_armours:slider("Heavy Armor", {}, 'Number of "Heavy Armor" to refill.', 0, 10, 10, 1, function(value)
    user_snacks_and_armors_to_refill["MP_CHAR_ARMOUR_4_COUNT"] = value
end)
auto_refill_snacks_and_armours:slider("Super Heavy Armor", {}, 'Number of "Super Heavy Armor" to refill.', 0, 10, 10, 1, function(value)
    user_snacks_and_armors_to_refill["MP_CHAR_ARMOUR_5_COUNT"] = value
end)


-- (NOT NEEDED) local default_max_weapon_damage_modifier = 1
-- (NOT NEEDED) local default_max_weapon_damage_modifier = 0.72000002861023
-- (NOT NEEDED) local default_max_vehicle_weapon_damage_modifier = 0.93599998950958
-- (NOT NEEDED) local default_max_vehicle_weapon_damage_modifier = 1
local default_max_bst_weapon_damage_modifier = 1.4400000572205
local default_max_bst_melee_weapon_damage_modifier = 2

my_root:toggle_loop("Detect Cheaters", {""}, 'Detect cheaters who\'re using "Weapon/Melee Damage Multiplier".', function()
    local cheaters = {}

    for _, pid in pairs(players.list()) do
        local player = {pid = pid}
        if
            PLAYER.IS_PLAYER_PLAYING(player.pid)
            and NETWORK.NETWORK_IS_PLAYER_CONNECTED(player.pid)
            and NETWORK.NETWORK_IS_PLAYER_ACTIVE(player.pid)
            and players.are_stats_ready(player.pid)
            and not NETWORK.IS_PLAYER_IN_CUTSCENE(player.pid)
            and not NETWORK.NETWORK_IS_PLAYER_FADING(player.pid)
            and not players.is_in_interior(player.pid)
        then
            player.weapon_damage_modifier = players.get_weapon_damage_modifier(player.pid)
            player.melee_weapon_damage_modifier = players.get_melee_weapon_damage_modifier(player.pid)

            if
                (player.weapon_damage_modifier > default_max_bst_weapon_damage_modifier)
                or (player.melee_weapon_damage_modifier > default_max_bst_melee_weapon_damage_modifier)
            then
                player.name = players.get_name(player.pid)
                cheaters[player.pid] = player
            end
        end
    end

    for pid, player in pairs(cheaters) do
        util.toast(
            "[Lua Script]: " .. TITLE .. "\n"
            .. "\nPlayer " .. player.name .. " is detected as a cheater!\n"
            .. "\nWeapon Damage Modifier: " .. player.weapon_damage_modifier
            .. "\nMelee Damage Modifier: " .. player.melee_weapon_damage_modifier
        )
    end

    util.yield(1000) -- No need to spam it.
end)

my_root:divider("<- - - - - - -  STAND shortcuts  - - - - - - ->")
my_root:link(menu.ref_by_command_name("thermalvision"), true)
my_root:link(menu.ref_by_command_name("norollcooldown"), true)
my_root:link(menu.ref_by_command_name("bst"), true)
my_root:link(menu.ref_by_command_name("bottomless"), true)
my_root:link(menu.ref_by_command_name("lockwantedlevel"), true)
my_root:link(menu.ref_by_command_name("blockphonespam"), true)
my_root:link(menu.ref_by_path("Online>Session>Session Scripts"), true)