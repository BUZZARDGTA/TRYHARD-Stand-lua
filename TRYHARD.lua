-- TRYHARD lua for Stand by IB_U_Z_Z_A_R_Dl
-- GitHub repo: https://github.com/Illegal-Services/TRYHARD-lua

-- CREDITS:
-- Well this is my very first Lua script, and I'm so thanksfull to everyone who helped me get into this new world.
--
-- JerryScript lua by @Jerry123#4508: Original "Hotkey Weapon Thermal Vision" code before I tweaked it.
-- Heist Control lua by @icedoomfist: Original "Auto Refill Snacks & Armours" code before I tweaked it.
-- Crosshair lua by @CocoW: Original "Idle Crosshair" code before I tweaked it.
--
-- People that helped me in Stand's Discord server in #Programming:
-- @hexarobi, @someoneidfk, @asuka666, @prisuhm, @jaymontana36, @playboyprime
-- and everyone else that I forgot.

util.require_natives("1660775568-uno")

local GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH=function(...)return native_invoker.uno_int(0x2C83A9DA6BFFC4F9,...)end
local IS_WARNING_MESSAGE_READY_FOR_CONTROL=function(...)return native_invoker.uno_bool(0xAF42195A42C63BBA,...)end
local IS_MP_TEXT_CHAT_TYPING=function(...)return native_invoker.uno_bool(0xB118AF58B5F332A1,...)end
local IS_PED_SWITCHING_WEAPON=function(...)return native_invoker.uno_bool(0x3795688A307E1EB6,...)end
local IS_ENTITY_A_GHOST = function(...)return native_invoker.uno_bool(0x21D04D7BC538C146,...)end
local nv = native_invoker
local PAD_SET_CONTROL_VALUE_NEXT_FRAME= function(padIndex,control,amount)nv.begin_call();nv.push_arg_int(padIndex);nv.push_arg_int(control);nv.push_arg_float(amount);nv.end_call("E8A25867FBA3B05E");return nv.get_return_value_bool();end

local CURRENT_SCRIPT_VERSION <const> = "0.7"
local TITLE <const> = "TRYHARD " .. "v" .. CURRENT_SCRIPT_VERSION .. " by IBU_Z_Z_A_R_Dl"

local MY_ROOT <const> = menu.my_root()
local joaat <const> = util.joaat

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

function is_phone_open()
	return (
        GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("cellphone_flashhand")) > 0
    ) and true or false
end

function is_any_game_overlay_open()
    if HUD.IS_PAUSE_MENU_ACTIVE() then
        return true
    end

    local scripts_list = {
        "maintransition",
        "pausemenu",
        "pausemenucareerhublaunch",
        "pausemenu_example",
        "pausemenu_map",
        "pausemenu_multiplayer",
        "pausemenu_sp_repeat",
        "apparcadebusiness",
        "apparcadebusinesshub",
        "appavengeroperations",
        "appbikerbusiness",
        "appbroadcast",
        "appbunkerbusiness",
        "appbusinesshub",
        "appcamera",
        "appchecklist",
        "appcontacts",
        "appcovertops",
        "appemail",
        "appextraction",
        "appfixersecurity",
        "apphackertruck",
        "apphs_sleep",
        "appimportexport",
        "appinternet",
        "appjipmp",
        "appmedia",
        "appmpbossagency",
        "appmpemail",
        "appmpjoblistnew",
        "apporganiser",
        "appprogresshub",
        "apprepeatplay",
        "appsecurohack",
        "appsecuroserv",
        "appsettings",
        "appsidetask",
        "appsmuggler",
        "apptextmessage",
        "apptrackify",
        "appvlsi",
        "appzit",
    }

    for _, app in ipairs(scripts_list) do
        if GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat(app)) > 0 then
            return true
        end
    end

    return false
end

MY_ROOT:divider("<- " ..  TITLE .. " ->")

local SHOW_IDLE_CROSSHAIR <const> = MY_ROOT:list("Idle Crosshair")
local idle_crosshair_texture <const> = directx.create_texture(filesystem.scripts_dir() .. "cr1.png")
local idle_crosshair_default_colour <const> = {r=0.88,g=0.88,b=0.88,a=1.0}
local hide_idle_crosshair_in_vehicles = true
local hide_idle_crosshair_in_interaction_menu = true
local hide_idle_crosshair_in_chat_menu = true
local hide_idle_crosshair_in_phone_menu = true
local hide_idle_crosshair_in_stand_menu = true
local hide_idle_crosshair_in_stand_command_box_menu = true
local idle_crosshair_size = 0.028
local idle_crosshair_colour = idle_crosshair_default_colour

SHOW_IDLE_CROSSHAIR:toggle_loop("Idle Crosshair", {}, "Always render an enhanced and customizable crosshair.", function()
    if
        is_any_game_overlay_open()
        or util.is_session_transition_active()
        or HUD.IS_WARNING_MESSAGE_ACTIVE()
        or IS_WARNING_MESSAGE_READY_FOR_CONTROL()
        or HUD.IS_NAVIGATING_MENU_CONTENT()
        or not HUD.IS_MINIMAP_RENDERING()
        or GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("maintransition")) >= 1
        or (
            GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("pi_menu")) == 0
            and GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("am_pi_menu")) == 0
        )
        or (
            GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("main")) == 0
            and GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("freemode")) == 0
        )
        or (
            util.is_interaction_menu_open()
            and hide_idle_crosshair_in_interaction_menu
        )
        or (
            menu.is_open()
            and hide_idle_crosshair_in_stand_menu
        )
        or (
            menu.command_box_is_open()
            and hide_idle_crosshair_in_stand_command_box_menu
        )
        or (
            IS_MP_TEXT_CHAT_TYPING()
            and hide_idle_crosshair_in_chat_menu
        )
        or (
            is_phone_open()
            and hide_idle_crosshair_in_phone_menu
        )
    then
        return
    end

    if
        (
            menu.is_open()
            and hide_idle_crosshair_in_stand_menu
        )
            or util.is_session_transition_active()
            or HUD.IS_PAUSE_MENU_ACTIVE()
            or not HUD.IS_HUD_COMPONENT_ACTIVE(14)
    then
        return
    end

    local user = PLAYER.PLAYER_ID()
    if
        not NETWORK.NETWORK_IS_PLAYER_CONNECTED(user)
        or not NETWORK.NETWORK_IS_PLAYER_ACTIVE(user)
        or NETWORK.NETWORK_IS_PLAYER_FADING(user)
        or NETWORK.NETWORK_IS_PLAYER_IN_MP_CUTSCENE(user)
        or NETWORK.IS_PLAYER_IN_CUTSCENE(user)
        or not PLAYER.IS_PLAYER_PLAYING(user)
        or PLAYER.IS_PLAYER_DEAD(user)
    then
        return
    end
    local user_ped = PLAYER.PLAYER_PED_ID()
    if PED.IS_PED_IN_ANY_VEHICLE(user_ped, false) then
        if
            hide_idle_crosshair_in_vehicles
            or (
                PLAYER.IS_PLAYER_FREE_AIMING(user)
                or TASK.GET_IS_TASK_ACTIVE(user_ped, 190) -- CTaskMountThrowProjectile
            )
        then
            return
        end
    else
        if
            TASK.GET_IS_TASK_ACTIVE(user_ped, 15)     -- CTaskDoNothing (scripted player moves (ex: when reaching a laptop))
            or TASK.GET_IS_TASK_ACTIVE(user_ped, 135) -- CTaskSynchronizedScene (ex:player using laptop / transitions)
            or TASK.GET_IS_TASK_ACTIVE(user_ped, 997) -- CTaskDyingDead
            or TASK.GET_IS_TASK_ACTIVE(user_ped, 289) -- CTaskAimAndThrowProjectile -- Downside is that it adds the [BUG] bellow...
        then
            return
        end

        if
            PLAYER.IS_PLAYER_FREE_AIMING(user)

            and not IS_PED_SWITCHING_WEAPON(user_ped)
            and WEAPON.IS_PED_WEAPON_READY_TO_SHOOT(user_ped)

            and WEAPON.GET_SELECTED_PED_WEAPON(user_ped) ~= joaat("weapon_hominglauncher") -- Alternative: WEAPON.GET_CURRENT_PED_WEAPON
        then
            -- [BUG]: When the player aims in 1rd person view with a "ThrowProjectile", the crosshair is not rendering while not aiming.
            -- [BUG]: When the player aims in 3rd person view, for a short moment it doesn't have any crosshair. (this is due to camera adjusting)
            return
        end
    end

    directx.draw_texture(
        idle_crosshair_texture, -- id
        idle_crosshair_size,    -- sizeX
        idle_crosshair_size,    -- sizeY
        0.5,                    -- centerX
        0.5,                    -- centerY
        0.5,                    -- posX
        0.5,                    -- posY
        0.0,                    -- rotation
        idle_crosshair_colour   -- colour
    )
end)

SHOW_IDLE_CROSSHAIR:divider("---------------------------------------")
SHOW_IDLE_CROSSHAIR:divider("Options:")
SHOW_IDLE_CROSSHAIR:divider("---------------------------------------")
SHOW_IDLE_CROSSHAIR:toggle("Hide Idle Crosshair in Vehicles", {}, "Stops the idle crosshair rendering when in vehicles.", function(toggle)
    hide_idle_crosshair_in_vehicles = toggle
end, true)
SHOW_IDLE_CROSSHAIR:toggle("Hide Idle Crosshair if Interaction Opened", {}, "Stops the idle crosshair rendering when the interaction menu is opened.", function(toggle)
    hide_idle_crosshair_in_interaction_menu = toggle
end, true)
SHOW_IDLE_CROSSHAIR:toggle("Hide Idle Crosshair if Chat Opened", {}, "Stops the idle crosshair rendering when the chat menu is opened.", function(toggle)
    hide_idle_crosshair_in_chat_menu = toggle
end, true)
SHOW_IDLE_CROSSHAIR:toggle("Hide Idle Crosshair if Phone Opened", {}, "Stops the idle crosshair rendering when the phone menu is opened.", function(toggle)
    hide_idle_crosshair_in_phone_menu = toggle
end, true)
SHOW_IDLE_CROSSHAIR:toggle("Hide Idle Crosshair if Stand Opened", {}, "Stops the idle crosshair rendering when the Stand menu is opened.", function(toggle)
    hide_idle_crosshair_in_stand_menu = toggle
end, true)
SHOW_IDLE_CROSSHAIR:toggle("Hide Idle Crosshair if Command Box Opened", {}, "Stops the idle crosshair rendering when the Stand's Command Box menu is opened.", function(toggle)
    hide_idle_crosshair_in_stand_command_box_menu = toggle
end, true)
SHOW_IDLE_CROSSHAIR:slider_float("Idle Crosshair Size", {}, "Changes the rendered idle crosshair size.", 10, 50, 28, 1, function(value)
    idle_crosshair_size = value / 1000
end)
SHOW_IDLE_CROSSHAIR:colour("Idle Crosshair Colour", {}, "Changes the rendered idle crosshair colour.", idle_crosshair_colour, false, function(colour)
    idle_crosshair_colour = colour
end)

local HOTKEY_SUICIDE <const> = MY_ROOT:list("Hotkey Suicide")
local suicide_loop = false
local last_suicide_request

HOTKEY_SUICIDE:toggle_loop("Hotkey Suicide", {}, 'Plays a C4 EWO macro on double-tapping "G" key.\n\nFOR IT TO WORKS, YOU MIGHT NEED TO DISABLE "Lock Weapons" SO THAT YOUR PED CAN RECEIVES A C4 IN THEIR INVENTORY.\n\nIt has been reported that this option is not working for some people.', function()
    if
        is_any_game_overlay_open()
        or util.is_session_transition_active()
        or HUD.IS_WARNING_MESSAGE_ACTIVE()
        or IS_WARNING_MESSAGE_READY_FOR_CONTROL()
        or HUD.IS_NAVIGATING_MENU_CONTENT()
        or not HUD.IS_MINIMAP_RENDERING()
        or GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("maintransition")) >= 1
        or (
            GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("pi_menu")) == 0
            and GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("am_pi_menu")) == 0
        )
        or (
            GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("main")) == 0
            and GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("freemode")) == 0
        )
        or util.is_interaction_menu_open()
        or menu.is_open()
        or menu.command_box_is_open()
        or IS_MP_TEXT_CHAT_TYPING()
        or is_phone_open()
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
        or NETWORK.NETWORK_IS_PLAYER_IN_MP_CUTSCENE(user)
        or NETWORK.NETWORK_IS_PLAYER_FADING(user)
    then
        return
    end

    local user_ped = PLAYER.PLAYER_PED_ID()
    if
        PED.IS_PED_IN_ANY_VEHICLE(user_ped, false)
        or IS_ENTITY_A_GHOST(user_ped) -- is player in passive mode
    then
        return
    end

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
        WEAPON.GIVE_WEAPON_TO_PED(user_ped, joaat("WEAPON_STICKYBOMB"), 1, false, true)
        WEAPON.SET_CURRENT_PED_WEAPON(user_ped, joaat("WEAPON_STICKYBOMB"))
        local t1 = os.clock()
        while not (
            WEAPON.IS_PED_ARMED(user_ped, 2)
            and WEAPON.HAS_PED_GOT_WEAPON(user_ped, joaat("WEAPON_STICKYBOMB"), false)
            and WEAPON.IS_PED_WEAPON_READY_TO_SHOOT(user_ped)
        ) do
            if (os.clock() - t1) >= 0.2 then
                return
            end
            util.yield()
        end
        util.yield(250)
        PAD_SET_CONTROL_VALUE_NEXT_FRAME(0, 24, 1)
        util.yield()
        PAD_SET_CONTROL_VALUE_NEXT_FRAME(0, 24, 0)
        util.yield()
        local t1 = os.clock()
        while true do
            local pedCoords = ENTITY.GET_ENTITY_COORDS(user_ped)
            if MISC.IS_PROJECTILE_TYPE_WITHIN_DISTANCE(pedCoords.x, pedCoords.y, pedCoords.z, joaat("WEAPON_STICKYBOMB"), 5.0, true) then
                break
            end
            if (os.clock() - t1) >= 1 then
                return
            end
            util.yield()
        end
        WEAPON.EXPLODE_PROJECTILES(user_ped, joaat("WEAPON_STICKYBOMB"))
    end
end)
HOTKEY_SUICIDE:divider("---------------------------------------")
HOTKEY_SUICIDE:divider("Options:")
HOTKEY_SUICIDE:divider("---------------------------------------")
HOTKEY_SUICIDE:toggle("Suicide Loop", {}, 'Plays a C4 EWO macro in a loop.\n\nFOR IT TO WORKS, YOU MIGHT NEED TO DISABLE "Lock Weapons" SO THAT YOUR PED CAN RECEIVES A C4 IN THEIR INVENTORY.\n\nIt has been reported that this option is not working for some people.', function(toggle)
    suicide_loop = toggle
end, false)

local function enable_thermal_vision(thermal_command)
    local thermal_state = menu.get_value(thermal_command)

    if not thermal_state then
        menu.trigger_command(thermal_command, "on")
        --GRAPHICS._SEETHROUGH_SET_MAX_THICKNESS(50.0)
    end
end

local function disable_thermal_vision(thermal_command)
    local thermal_state = menu.get_value(thermal_command)

    if thermal_state then
        menu.trigger_command(thermal_command, "off")
        --GRAPHICS._SEETHROUGH_SET_MAX_THICKNESS(1.0)
    end
end

local HOTKEY_WEAPON_THERMAL_VISION <const> = MY_ROOT:list("Hotkey Weapon Thermal Vision")
local thermal_command <const> = menu.ref_by_command_name("thermalvision")
local disable_thermal_vision_off_aim = true
local remember_thermal_vision_last_state = true
local reload_with_thermal_vision = true
local combatroll_with_thermal_vision = true
local thermal_vision_last_state = menu.get_value(thermal_command)

HOTKEY_WEAPON_THERMAL_VISION:toggle_loop("Hotkey Weapon Thermal Vision", {}, 'Makes it so when you aim with any gun, you can toggle thermal vision on "E" key.', function()
    local user = PLAYER.PLAYER_ID()
    local user_ped = PLAYER.PLAYER_PED_ID()

    if
        PLAYER.IS_PLAYER_FREE_AIMING(user)
        and TASK.GET_IS_TASK_ACTIVE(user_ped, 4)
        and TASK.GET_IS_TASK_ACTIVE(user_ped, 6)
        and TASK.GET_IS_TASK_ACTIVE(user_ped, 8)
        and TASK.GET_IS_TASK_ACTIVE(user_ped, 9)
        and TASK.GET_IS_TASK_ACTIVE(user_ped, 290)
    then
        if
            PAD.IS_CONTROL_JUST_PRESSED(0, 22)
            and not PED.IS_PED_SHOOTING(user_ped)
            and PED.GET_PED_RESET_FLAG(user_ped, 254) -- is player in a Combat Roll
        then
            thermal_vision_last_state = menu.get_value(thermal_command)

            if not combatroll_with_thermal_vision then
                disable_thermal_vision(thermal_command)
                while PED.GET_PED_RESET_FLAG(user_ped, 254) do
                    util.yield()
                end
            end
        end

        if thermal_vision_last_state then
            enable_thermal_vision(thermal_command)
        else
            disable_thermal_vision(thermal_command)
        end

        if PAD.IS_CONTROL_JUST_PRESSED(0, 38) then
            if menu.get_value(thermal_command) then
                disable_thermal_vision(thermal_command)
            else
                enable_thermal_vision(thermal_command)
            end
        end
        thermal_vision_last_state = menu.get_value(thermal_command)
        return
    end

    if not menu.get_value(thermal_command) then
        return
    end

    if PED.IS_PED_RELOADING(user_ped) then
        thermal_vision_last_state = menu.get_value(thermal_command)

        if not reload_with_thermal_vision then
            disable_thermal_vision(thermal_command)
            while PED.IS_PED_RELOADING(user_ped) do
                util.yield()
            end
        end
        return
    end

    if disable_thermal_vision_off_aim then
        disable_thermal_vision(thermal_command)
    end
end)
HOTKEY_WEAPON_THERMAL_VISION:divider("---------------------------------------")
HOTKEY_WEAPON_THERMAL_VISION:divider("Options:")
HOTKEY_WEAPON_THERMAL_VISION:divider("---------------------------------------")
HOTKEY_WEAPON_THERMAL_VISION:toggle("Disable Thermal Vision Off-Aim", {}, "Disable thermal vision when not aiming.", function(toggle)
    disable_thermal_vision_off_aim = toggle
end, true)

HOTKEY_WEAPON_THERMAL_VISION:toggle("Remember Thermal Vision Last State", {}, "Remember the last state of thermal vision when toggling.", function(toggle)
    remember_thermal_vision_last_state = toggle
end, true)

HOTKEY_WEAPON_THERMAL_VISION:toggle("Reload with Thermal Vision", {}, "Enable thermal vision when reloading weapons.", function(toggle)
    reload_with_thermal_vision = toggle
end, true)

HOTKEY_WEAPON_THERMAL_VISION:toggle("Combat Roll with Thermal Vision", {}, "Enable thermal vision during combat rolls.", function(toggle)
    combatroll_with_thermal_vision = toggle
end, true)

local AUTO_REFILL_SNACKS_AND_ARMOURS <const> = MY_ROOT:list("Auto Refill Snacks & Armor")
local user_snacks_and_armors_to_refill <const> = {
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

AUTO_REFILL_SNACKS_AND_ARMOURS:toggle_loop("Auto Refill Snacks & Armours", {}, "Automatically refill selected Snacks & Armor every 10 seconds.", function()
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

AUTO_REFILL_SNACKS_AND_ARMOURS:divider("---------------------------------------")
AUTO_REFILL_SNACKS_AND_ARMOURS:divider("Snacks to Refill:")
AUTO_REFILL_SNACKS_AND_ARMOURS:divider("---------------------------------------")
AUTO_REFILL_SNACKS_AND_ARMOURS:slider("P'S & Q's", {}, 'Number of "P\'S & Q\'s" to refill.', 0, 30, 30, 1, function(value)
    user_snacks_and_armors_to_refill["NO_BOUGHT_YUM_SNACKS"] = value
end)
AUTO_REFILL_SNACKS_AND_ARMOURS:slider("EgoChaser", {}, 'Number of "EgoChaser" to refill.', 0, 15, 15, 1, function(value)
    user_snacks_and_armors_to_refill["NO_BOUGHT_HEALTH_SNACKS"] = value
end)
AUTO_REFILL_SNACKS_AND_ARMOURS:slider("Meteorite", {}, 'Number of "Meteorite" to refill.', 0, 5, 5, 1, function(value)
    user_snacks_and_armors_to_refill["NO_BOUGHT_EPIC_SNACKS"] = value
end)
AUTO_REFILL_SNACKS_AND_ARMOURS:slider("eCola", {}, 'Number of "eCola" to refill.', 0, 10, 10, 1, function(value)
    user_snacks_and_armors_to_refill["NUMBER_OF_ORANGE_BOUGHT"] = value
end)
AUTO_REFILL_SNACKS_AND_ARMOURS:slider("Pisswasser", {}, 'Number of "Pisswasser" to refill.', 0, 10, 10, 1, function(value)
    user_snacks_and_armors_to_refill["NUMBER_OF_BOURGE_BOUGHT"] = value
end)
AUTO_REFILL_SNACKS_AND_ARMOURS:slider("Blêuter'd Champagne", {}, 'Number of "Blêuter\'d Champagne" to refill.', 0, 5, 5, 1, function(value)
    user_snacks_and_armors_to_refill["NUMBER_OF_CHAMP_BOUGHT"] = value
end)
AUTO_REFILL_SNACKS_AND_ARMOURS:slider("Smokes", {}, 'Number of "Smokes" to refill.', 0, 20, 20, 1, function(value)
    user_snacks_and_armors_to_refill["CIGARETTES_BOUGHT"] = value
end)
AUTO_REFILL_SNACKS_AND_ARMOURS:slider("Sprunk", {}, 'Number of "Sprunk" to refill.', 0, 10, 10, 1, function(value)
    user_snacks_and_armors_to_refill["NUMBER_OF_SPRUNK_BOUGHT"] = value
end)
AUTO_REFILL_SNACKS_AND_ARMOURS:divider("---------------------------------------")
AUTO_REFILL_SNACKS_AND_ARMOURS:divider("Armors to Refill:")
AUTO_REFILL_SNACKS_AND_ARMOURS:divider("---------------------------------------")
AUTO_REFILL_SNACKS_AND_ARMOURS:slider("Super Light Armor", {}, 'Number of "Super Light Armor" to refill.', 0, 10, 10, 1, function(value)
    user_snacks_and_armors_to_refill["MP_CHAR_ARMOUR_1_COUNT"] = value
end)
AUTO_REFILL_SNACKS_AND_ARMOURS:slider("Light Armor", {}, 'Number of "Light Armor" to refill.', 0, 10, 10, 1, function(value)
    user_snacks_and_armors_to_refill["MP_CHAR_ARMOUR_2_COUNT"] = value
end)
AUTO_REFILL_SNACKS_AND_ARMOURS:slider("Standard Armor", {}, 'Number of "Standard Armor" to refill.', 0, 10, 10, 1, function(value)
    user_snacks_and_armors_to_refill["MP_CHAR_ARMOUR_3_COUNT"] = value
end)
AUTO_REFILL_SNACKS_AND_ARMOURS:slider("Heavy Armor", {}, 'Number of "Heavy Armor" to refill.', 0, 10, 10, 1, function(value)
    user_snacks_and_armors_to_refill["MP_CHAR_ARMOUR_4_COUNT"] = value
end)
AUTO_REFILL_SNACKS_AND_ARMOURS:slider("Super Heavy Armor", {}, 'Number of "Super Heavy Armor" to refill.', 0, 10, 10, 1, function(value)
    user_snacks_and_armors_to_refill["MP_CHAR_ARMOUR_5_COUNT"] = value
end)

-- (NOT NEEDED) local default_max_weapon_damage_modifier <const> = 1
-- (NOT NEEDED) local default_max_weapon_damage_modifier <const> = 0.72000002861023
-- (NOT NEEDED) local default_max_vehicle_weapon_damage_modifier <const> = 0.93599998950958
-- (NOT NEEDED) local default_max_vehicle_weapon_damage_modifier <const> = 1
local default_max_bst_weapon_damage_modifier <const> = 1.4400000572205
local default_max_bst_melee_weapon_damage_modifier <const> = 2

MY_ROOT:toggle_loop("Detect Cheaters", {""}, 'Detect cheaters who\'re using "Weapon/Melee Damage Multiplier".', function()
    local cheaters <const> = {}

    for players.list() as pid do
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
                player.weapon_damage_modifier > default_max_bst_weapon_damage_modifier
                or (
                    player.melee_weapon_damage_modifier > default_max_bst_melee_weapon_damage_modifier
                    and not (
                        player.melee_weapon_damage_modifier == 100.0
                        and GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("am_hunt_the_beast")) ~= 0
                        -- [TODO]: I'm not actually checking who is the beast player.
                    )
                )
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

MY_ROOT:divider("<- - - - - - -  STAND shortcuts  - - - - - - ->")
MY_ROOT:link(menu.ref_by_command_name("thermalvision"), true)
MY_ROOT:link(menu.ref_by_command_name("norollcooldown"), true)
MY_ROOT:link(menu.ref_by_command_name("bst"), true)
MY_ROOT:link(menu.ref_by_command_name("bottomless"), true)
MY_ROOT:link(menu.ref_by_command_name("lockwantedlevel"), true)
MY_ROOT:link(menu.ref_by_command_name("blockphonespam"), true)
MY_ROOT:link(menu.ref_by_path("Online>Session>Session Scripts"), true)
