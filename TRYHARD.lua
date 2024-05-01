-- TRYHARD lua for STAND by IB_U_Z_Z_A_R_Dl
-- GitHub repo: https://github.com/Illegal-Services/TRYHARD-lua

-- CREDITS:
-- Well this is my very first Lua script, and I'm so thanksfull to everyone who helped me get into this new world.
--
-- JerryScript lua by @Jerry123#4508: Original "Hotkey weapon thermal vision" code before I tweaked it.
-- Heist Control lua by @icedoomfist: Original "Auto Refill Snacks & Armours" code before I tweaked it.
-- Crosshair lua by @CocoW: Original crosshair code. I just took what I need from it for a minimal experience.
--
-- People that helped me in Stand's Discord server in #Programming:
-- @hexarobi: For learning me about `my_root:link` from Stand's API.
-- @someoneidfk: For learning me about `util.on_stop` from Stand's API.
-- @asuka666 and @someoneidfk: For teaching me the basics of lua programming at my very begining lol.

util.require_natives("1660775568-uno")

-- global locals
local JSkey = require "JSkeyLib"
local my_root = menu.my_root()
local current_script_version = 0.4

-- CROSSHAIR's locals
local crosshair_file = "cr1.png" -- default file name
local crosshair_tex = directx.create_texture(filesystem.scripts_dir() .. crosshair_file) -- crosshair file
local crosshair_posX = 0.5       -- default position X
local crosshair_posY = 0.5       -- default position Y
local crosshair_size = 0.03      -- default size
local crosshair_rotation = 0.0   -- default crosshair_rotation

-- THERMAL VISION's locals
local thermal_command = menu.ref_by_command_name("thermalvision")

-- DETECT CHEATERS's locals
-- (NOT NEEDED) local default_max_weapon_damage_modifier = 1
-- (NOT NEEDED) local default_max_weapon_damage_modifier = 0.72000002861023
-- (NOT NEEDED) local default_max_vehicle_weapon_damage_modifier = 0.93599998950958
-- (NOT NEEDED) local default_max_vehicle_weapon_damage_modifier = 1
local default_max_bst_weapon_damage_modifier = 1.4400000572205
local default_max_bst_melee_weapon_damage_modifier = 2

--- AUTO REFILL's Functions
function STAT_SET_INT(stat, value)
    STATS.STAT_SET_INT(util.joaat(ADD_MP_INDEX(stat)), value, true)
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
    if not string.startswith(stat, "MP_") and not string.startswith(stat, "MPPLY_") then
        return "MP" .. util.get_char_slot() .. "_" .. stat
    end
    return stat
end

print(string.rep("-", 50))

my_root:divider("")
my_root:divider("TRYHARD " .. "v" .. current_script_version .. " by IBU_Z_Z_A_R_Dl")

my_root:toggle_loop("Show crosshair", {}, "Render a crosshair at the screen's center.",
    function()
        directx.draw_texture(
            crosshair_tex,      -- id
            crosshair_size,     -- sizeX
            crosshair_size,     -- sizeY
            0.5,                -- centerX
            0.5,                -- centerY
            crosshair_posX,     -- posX
            crosshair_posY,     -- posY
            crosshair_rotation, -- rotation
            {                   -- colour
                ["r"] = 1.0,
                ["g"] = 1.0,
                ["b"] = 1.0,
                ["a"] = 1.0
            }
        )
end)

my_root:toggle_loop("Hotkey weapon thermal vision", {}, 'Makes it so when you aim any gun you can toggle thermal vision on "E".',
    function()
        local thermal_state = menu.get_value(thermal_command)

        if PLAYER.IS_PLAYER_FREE_AIMING(players.user()) then
            if JSkey.is_key_just_down("VK_E") then
                if thermal_state == false then
                    menu.trigger_command(thermal_command, "on")
                    GRAPHICS._SEETHROUGH_SET_MAX_THICKNESS(50)
                elseif thermal_state == true then
                    menu.trigger_command(thermal_command, "off")
                    GRAPHICS._SEETHROUGH_SET_MAX_THICKNESS(1)
                end
            end
        else
            if thermal_state == true then
                if not PED.IS_PED_RELOADING(PLAYER.PLAYER_PED_ID()) then
                    menu.trigger_command(thermal_command, "off")
                    GRAPHICS._SEETHROUGH_SET_MAX_THICKNESS(1)
                end
            end
        end
    end, function()
        local thermal_state = menu.get_value(thermal_command)

        if thermal_state == true then
            menu.trigger_command(thermal_command, "off")
            GRAPHICS._SEETHROUGH_SET_MAX_THICKNESS(1)
        end
end)

my_root:toggle_loop("Auto Refill Snacks & Armours", {}, "Automatically refill Snacks & Armor every 10 seconds.",
    function()
        util.yield(10000) -- No need to spam it.

        STAT_SET_INT("NO_BOUGHT_YUM_SNACKS", 30)
        STAT_SET_INT("NO_BOUGHT_HEALTH_SNACKS", 15)
        STAT_SET_INT("NO_BOUGHT_EPIC_SNACKS", 15)
        STAT_SET_INT("NUMBER_OF_ORANGE_BOUGHT", 10)
        STAT_SET_INT("NUMBER_OF_BOURGE_BOUGHT", 0)
        STAT_SET_INT("NUMBER_OF_CHAMP_BOUGHT", 0)
        STAT_SET_INT("CIGARETTES_BOUGHT", 0)
        STAT_SET_INT("NUMBER_OF_SPRUNK_BOUGHT", 5)
        for i = 1, 5 do
            STAT_SET_INT("MP_CHAR_ARMOUR_" .. i .. "_COUNT", 10)
        end
end)

function is_player_driver(player_ped)
    local veh = entities.get_user_vehicle_as_handle(player_ped)
    local veh_seat_ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1, true)
    if veh_seat_ped == player_ped then
	    return true
    else return false
    end
end

my_root:toggle_loop("Detect cheaters (beta)", {""}, 'Detect cheaters who\'re using "Weapon Damage Multiplier".\nFor this to works, you must have enabled both your Stand\'s console, and the lua setting "Developper" preset.\nCheaters will only be showing up on your Stand\'s console for now.',
    function()
        util.yield(1000)
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
                    cheaters[player.pid] = {
                        weapon_damage_modifier = player.weapon_damage_modifier,
                        melee_weapon_damage_modifier = player.melee_weapon_damage_modifier,
                        organisation_type = player.org_type,
                        name = player.name
                    }
                end
            end
        end

        for pid, player in pairs(cheaters) do
            print("Player " .. player.name .. " is detected as a cheater! Weapon Damage Modifier: " .. player.weapon_damage_modifier)
        end
end)

my_root:divider("")
my_root:divider("STAND's shortcuts")
my_root:link(menu.ref_by_command_name("bst"), true)
my_root:link(menu.ref_by_command_name("blockphonespam"), true)
my_root:link(menu.ref_by_path("Online>Session>Session Scripts"), true)
