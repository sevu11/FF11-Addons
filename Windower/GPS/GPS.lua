_addon.name = 'GPS'
_addon.author = 'Garyfromwork, Modified by Sevu'
_addon.version = '1.3.0.0'
_addon.command = 'gps'

require('tables')
require('logger')

res = require('resources')
zones = require('data/zones')
config = require('config')
texts = require('texts')
settings = require('data/settings')

settings = config.load(settings)
text_box = texts.new(settings)
text_box:visible(false)

local function hide_text_box()
    text_box:visible(false)
end

local function show_text_box()
    text_box:visible(true)
end

local function display_in_chat(message)
    windower.add_to_chat(207, message)
end

windower.register_event('addon command', function(...)
    local function T(tbl)
        local mt = getmetatable(tbl)
        if not mt then
            mt = {}
            setmetatable(tbl, mt)
        end
        mt.__index = table
        return tbl
    end
    local commands = T{...}
    if commands[1] == 'zone' then
        if #commands > 1 then
            local requested_zone_name = table.concat(commands, ' ', 2):lower()
            for zone_id, zone_data in pairs(res.zones) do
                if zone_data.en:lower() == requested_zone_name then
                    local zone_name = zone_data.en
                    local zone_exits = ''

                    local header_length = math.floor(#('GPS') * 10)
                    local separator_line = string.rep('-', header_length)
                    local results = 'GPS - Area And Exits\n' .. separator_line .. '\n' .. 'Zone:\n' .. zone_name

                    results = results .. '\n\nExit To:'
                    for _, exit in ipairs(zones[zone_id].exits) do
                        results = results .. '\n' .. exit
                    end

                    results = results .. '\n' .. separator_line

                    if settings.hide then
                        display_in_chat(results)
                    else
                        text_box:text(results)
                        show_text_box()
                    end
                    return
                end
            end
            windower.add_to_chat(100, 'Zone "' .. requested_zone_name .. '" not found.')
            return
        end

        local zone = windower.ffxi.get_info().zone
        local zone_name = res.zones[zone].en
        local zone_exits = ''

        local header_length = math.floor(#('GPS') * 10)
        local separator_line = string.rep('-', header_length)
        local results = 'GPS - Current Area And Exits\n' .. separator_line .. '\n' .. 'Current Zone:\n' .. zone_name

        results = results .. '\n\nExit To:'
        for _, exit in ipairs(zones[zone].exits) do
            results = results .. '\n' .. exit
        end

        results = results .. '\n' .. separator_line

        if settings.hide then
            display_in_chat(results)
        else
            text_box:text(results)
            show_text_box()
        end
    end

    if commands[1] == 'hide' then
        windower.add_to_chat(100, string.format('\30\03[%s]\30\01 - Window Disabled', _addon.name))
        windower.add_to_chat(100, string.format('\30\03[%s]\30\01 - //gps zone will now be displayed in the chat window.', _addon.name))
        hide_text_box()
        settings.hide = true
    end

    if commands[1] == 'show' then
        windower.add_to_chat(100, string.format('\30\03[%s]\30\01 - Window Enabled', _addon.name))
        windower.add_to_chat(100, string.format('\30\03[%s]\30\01 - //gps zone will now be displayed in the texts window.', _addon.name))
        show_text_box()
        settings.hide = false
    end

    if commands[1] == 'help' then
        log('Usage:')
        log('Command //gps')
        log('//gps help - This text')
        log('//gps zone - Display current zone and the exits')
        log('//gps zone "name" - Display specified zone and the exits')
        log('//gps hide - Hides the popup window and write to chat')
        log('//gps show - Disables hide command and write to window')
    end
end)

windower.register_event('zone change', function(new_zone_id, old_zone_id)
    hide_text_box()
end)

