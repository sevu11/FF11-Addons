_addon.name = 'Countdown'
_addon.author = 'Sevu'
_addon.version = '1.0'
_addon.command = 'countdown'

local engageTimer = {}
local countdown_handle
local countdown_active = false

phCooldown = '00:05:00' -- Update to PH respawn window

------------------------------------------------------------------------------------------
-- Onload message
------------------------------------------------------------------------------------------

windower.register_event('load', function()
    windower.add_to_chat(16, 'Countdown loaded! See //countdown help')
end)

------------------------------------------------------------------------------------------
-- Check for Status Change
------------------------------------------------------------------------------------------

function engagedStatus()
    return windower.ffxi.get_player().status == 1 and 1 or 0
end

function targetName()
    local target = windower.ffxi.get_mob_by_target('t')
    if target then
        return target.name
    else
        return nil
    end
end

------------------------------------------------------------------------------------------
-- Check which target for Equipment handling
------------------------------------------------------------------------------------------

windower.register_event('target change', function(new_target_index)
    local name = targetName()
    if name == "Chesma" then
        windower.send_command("input /equip main 'Radennotachi'")
    else
        windower.send_command("input /equip main 'Shining One'")
    end
end)

------------------------------------------------------------------------------------------
-- Parse time and input
------------------------------------------------------------------------------------------

function parseTime(time)
    local hours, minutes, seconds = time:match("(%d+):(%d+):(%d+)")
    if hours and minutes and seconds then
        return tonumber(hours) * 3600 + tonumber(minutes) * 60 + tonumber(seconds)
    end
    
    local hours, minutes = time:match("(%d+)h(%d+)min")
    if hours and minutes then
        return tonumber(hours) * 3600 + tonumber(minutes) * 60
    end

------------------------------------------------------------------------------------------
-- Parse Hours
------------------------------------------------------------------------------------------

    local hours = time:match("(%d+)h")
    if hours then
        return tonumber(hours) * 3600
    end

    local hours = time:match("(%d+)hour")
    if hours then
        return tonumber(hours) * 3600
    end

    local hours = time:match("(%d+)hr")
    if hours then
        return tonumber(hours) * 3600
    end

------------------------------------------------------------------------------------------
-- Parse Minutes
------------------------------------------------------------------------------------------

    local minutes = time:match("(%d+)min")
    if minutes then
        return tonumber(minutes) * 60
    end
     
------------------------------------------------------------------------------------------
-- Parse Seconds
------------------------------------------------------------------------------------------

    local seconds = time:match("(%d+)sec")
    if seconds then
        return tonumber(seconds)
    end
    
    return tonumber(time)
end

------------------------------------------------------------------------------------------
-- Set Countdown
------------------------------------------------------------------------------------------

function engageTimer:startCountdown(time)
    if countdown_active then
        self:stopCountdown()
    end
    
    local timeInSeconds = parseTime(time)
    if not timeInSeconds or timeInSeconds <= 0 then
        windower.add_to_chat(207, "Invalid time specified. Please provide a valid time format.")
        return
    end
    
    countdown_active = true
    windower.add_to_chat(207, string.format("\30\02Countdown started for \30\01%s seconds.", timeInSeconds))
    countdown_handle = coroutine.schedule(engageTimer.update, timeInSeconds)
end

------------------------------------------------------------------------------------------
-- Stop countdown
------------------------------------------------------------------------------------------

local zone_changed = false

function engageTimer.stopCountdown()
    if not countdown_active then
        if not zone_changed then
            windower.add_to_chat(207, "No active countdown to stop.")
        end
        return
    end
    
    if not zone_changed then
        windower.add_to_chat(207, "Countdown stopped.") 
    end

    coroutine.close(countdown_handle)
    countdown_active = false
end

function engageTimer.update()
    windower.add_to_chat(100, string.format('\30\03[%s]\30\01 *ring ring* Countdown reached 0!', 'Countdown'))
    countdown_active = false
end

------------------------------------------------------------------------------------------
-- Set Starting message
------------------------------------------------------------------------------------------

-- windower.register_event('status change', function(new_status, old_status)
--     if old_status == 1 then
--         if engagedStatus() == 0 then
--             engageTimer:startCountdown(phCooldown)
--             coroutine.sleep(5)
--             windower.send_command("mr")
--         end
--     end
-- end)

------------------------------------------------------------------------------------------
-- Addon Commands
------------------------------------------------------------------------------------------

windower.register_event('addon command', function(command, time)

    if command == 'help' then
        windower.add_to_chat(16, '//countdown start ###')
        windower.add_to_chat(16, 'Start a countdown with desired value (//countdown start 3min)')
        windower.add_to_chat(16, ' ')
        windower.add_to_chat(16, '//countdown stop') 
        windower.add_to_chat(16, 'Stops current countdown')

    elseif command == 'start' then
        engageTimer:startCountdown(time)

    elseif command == 'status' then
        local status_msg = engagedStatus() == 1 and 'Engaged' or 'Not Engaged'
        windower.add_to_chat(207, "Current status: " .. status_msg)

    elseif command == 'stop' then
        engageTimer:stopCountdown()

    elseif command == 'name' then
        windower.add_to_chat(207, "Addon Name " .. _addon.name)

    elseif command == 'name' then
        local name = targetName()
        windower.add_to_chat(207, "Target's name: " .. name)
    end
end)

windower.register_event('zone change', function(new_zone_id, old_zone_id)
    -- zone_changed = true
    -- engageTimer:stopCountdown()
    -- zone_changed = false
end)