_addon.name = 'ChatLogger'
_addon.version = '1.0'
_addon.author = 'Sevu'
_addon.commands = {'cl', 'chatlogger'}

require('logger')
local res = require('resources')
local settings_path = windower.addon_path .. 'settings.lua'
local messages_path = windower.addon_path .. 'messages.lua'

local function load_settings()
    local settings_file = loadfile(settings_path)
    if settings_file then
        local settings = settings_file()
        if settings and type(settings.logging_enabled) == 'boolean' then
            return settings.logging_enabled
        end
    end
    return true
end

local function ensure_file_exists(filename)
    if not windower.file_exists(filename) then
        local file = io.open(filename, "w")
        if file then
            file:close()
        else
            error("Error creating file: " .. filename)
        end
    end
end

ensure_file_exists(settings_path)
ensure_file_exists(messages_path)

if not windower.file_exists(settings_path) then
    local settings_file = io.open(settings_path, 'w')
    if settings_file then
        settings_file:write('return {\n')
        settings_file:write('    logging_enabled = true\n')
        settings_file:write('}\n')
        settings_file:close()
        log('Settings file created with default values')
    else
        log('Error creating settings file')
    end
end

local function filter_message(message)
    local pattern = '[^%w%s%p]+'
    return message:gsub(pattern, '')
end

local function append_to_lua_file(filename, message)
    local timestamp = os.date("[%H:%M:%S] ")
    local filtered_message = filter_message(message)
    filtered_message = filtered_message:gsub('[\r\n]+$', '')
    local file = io.open(filename, "a")
    if file then
        file:write(timestamp .. filtered_message .. '\n')  
        file:close()  
        -- log('Message appended to Lua file: ' .. filtered_message)
    else
        error("Error opening file for writing: " .. filename)
    end
end

function initialize()
    local python_script = windower.addon_path .. 'Bot/incoming_tells.pyw'
    local message_file = windower.addon_path .. 'messages.lua'
    
    local command = 'start pythonw "' .. python_script .. '" "' .. message_file .. '"'
    
    local success = os.execute(command)
    
    if success then
        windower.add_to_chat(204, 'Starting Discord bot...')
        coroutine.sleep(5)
        windower.add_to_chat(204, 'Discord bot is online!')
    else
        error('Failed to start Discord bot!')
    end
end


function killDiscordBot()
    os.execute('taskkill /F /IM pythonw.exe')
end

windower.register_event('load', initialize)
windower.register_event('unload', killDiscordBot)
windower.register_event('logout', killDiscordBot)


windower.register_event('incoming text', function(original, modified, mode)
    -- if mode == 6 or mode == 14 then -- 6, 12 incoming and outgoing linkshell1
    -- if mode == 12 then -- 12 outgoing tell
    if mode == 213 or mode == 214 then -- 213 outgoing ls2
        append_to_lua_file(messages_path, original)
    end
end)


windower.register_event('addon command', function(command, ...)
    local color = 123

    local args = {...}
    if command:lower() == 'offline' or command:lower() == 'off' then
        windower.add_to_chat(204, 'Chatlogger: Discord Bot is offline.')
        killDiscordBot()

    elseif command:lower() == 'online' or command:lower() == 'on' then
        initialize()
    else
        windower.add_to_chat(color, '--- Chatlogger ---')
        windower.add_to_chat(color, 'Addon Commands: //cl')
        windower.add_to_chat(color, 'Chatlogger help - This menu.')
        windower.add_to_chat(color, 'Chatlogger online / on - Turn on Discord bot.')
        windower.add_to_chat(color, 'Chatlogger offline / off - Turn off Discord bot.')
    end
end)