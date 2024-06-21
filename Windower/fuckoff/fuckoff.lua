_addon.name = 'FuckOff'
_addon.version = '0.22'
_addon.author = 'Chiaia (Asura), Updated by Sevu (Bahamut)'
_addon.commands = {'fuckoff','fo'}

require('luau')
packets = require('packets')

local block_skillup = true

local function load_or_create_blacklist()
    local file_path = windower.addon_path .. 'blacklist.lua'
    local file = io.open(file_path, 'r')
    if file then
        file:close()
        return dofile(file_path) or {} 
    else
        -- Create the file with default content
        local default_content = '-- When adding a name to "patterns", it needs to include .* \nreturn {\n    patterns = {},\n    exact_names = {}\n}'
        local new_file = io.open(file_path, 'w')
        if new_file then
            new_file:write(default_content)
            new_file:close()
            return {}  -- Return an empty table as the file is created but empty
        else
            return nil  -- Return nil if there was an error creating the file
        end
    end
end


local blacklist = load_or_create_blacklist()
local black_listed_patterns = T(blacklist.patterns) -- Convert patterns to Lua table
local black_listed_exact_names = T(blacklist.exact_names) -- Convert exact names to Lua table

local black_listed_words = T{
    string.char(0x81,0x69), string.char(0x81,0x99), string.char(0x81,0x9A),
    '1%-99', 'Job Points.*2100', 'Job Points.*500', 'Job Points.*4m',
    'JP.*2100', 'JP.*500', 'Capacity Points.*2100', 'Capacity Points.*500',
    'CPS*.*2100', 'CPS*.*500', 'ｆｆｘｉｓｈｏｐ', 'Jinpu 99999', 'Jinpu99999',
    'This is IGXE', 'Clear Mind*.*15mins rdy start', 'Reisenjima*.*Helms*.*T4*.*Buy',
    'Aeonic Weapon*.*3zone*.*Buy', 'Tumult Curator*.*Kill', 'Aeonic Weapon*.*Mind',
    'Aeonic Weapon*.*Buy', 'Selling Aeonic', 'Empy Weapons Abyssea', '50 50 75'
}

local black_listed_skill_pages = T{
    '6147', '6148', '6149', '6150', '6151', '6152', '6153', '6154', '6155',
    '6156', '6157', '6158', '6159', '6160', '6161', '6162', '6163', '6164',
    '6165', '6166', '6167', '6168', '6169', '6170', '6171', '6172', '6173',
    '6174', '6175', '6176', '6177', '6178', '6179', '6180', '6181', '6182',
    '6183', '6184', '6185'
}

----------------------------------------------------------------------------
-- Start v0.22 Added by Sevu (Bahamut)
----------------------------------------------------------------------------
function is_blacklisted(user_name)
    for _, pattern in ipairs(black_listed_patterns) do
        if string.match(user_name, pattern) then
            return true
        end
    end
    return black_listed_exact_names:contains(user_name)
end

function add_to_blacklist(name)
    if string.find(name, "*") then
        local pattern = string.gsub(name, "%*", ".*")
        if not name:endswith("*") then
            pattern = pattern .. ".*"
        end
        table.insert(black_listed_patterns, pattern)
        windower.add_to_chat(123, 'Added pattern ' .. pattern .. ' to the blacklist.')
    else
        table.insert(black_listed_exact_names, name)
        windower.add_to_chat(123, 'Added exact name ' .. name .. ' to the blacklist.')
    end

    update_blacklist_file()
end

function remove_from_blacklist(name)
    local removed = false
    
    -- Check if the name ends with *
    if name:sub(-1) == '*' then
        name = name:gsub("%*", ".*") -- Convert * to .*
    end
    
    -- Iterate over patterns and exact names to find and remove the specified name or pattern
    for i, pattern in ipairs(black_listed_patterns) do
        if pattern == name then
            table.remove(black_listed_patterns, i)
            removed = true
            break
        end
    end
    
    for i, exact_name in ipairs(black_listed_exact_names) do
        if exact_name == name then
            table.remove(black_listed_exact_names, i)
            removed = true
            break
        end
    end
    
    -- If the name or pattern was removed, update the blacklist file
    if removed then
        windower.add_to_chat(123, 'Removed ' .. name .. ' from the blacklist.')
        update_blacklist_file()
    else
        windower.add_to_chat(123, 'Name or pattern not found in the blacklist.')
    end
end

function update_blacklist_file()
    local file_path = windower.addon_path .. 'blacklist.lua'
    local file = io.open(file_path, 'r')
    if file then
        local lines = {}
        for line in file:lines() do
            -- Preserve existing comments
            if not line:find('--') then
                table.insert(lines, line)
            end
        end
        file:close()

        -- Open the file in write mode to update it
        local file = io.open(file_path, 'w')
        if file then
            -- Write existing lines back to the file
            for _, line in ipairs(lines) do
                file:write(line .. '\n')
            end
            -- Write new content
            file:write('return {\n')
            file:write('    patterns = {\n')
            for _, pattern in ipairs(black_listed_patterns) do
                file:write(string.format('        "%s",\n', pattern))
            end
            file:write('    },\n')
            file:write('    exact_names = {\n')
            for _, name in ipairs(black_listed_exact_names) do
                file:write(string.format('        "%s",\n', name))
            end
            file:write('    }\n')
            file:write('}')
            file:close()
            windower.add_to_chat(123, 'Blacklist file updated.')
        else
            windower.add_to_chat(123, 'Error: Unable to open blacklist file for writing.')
        end
    else
        windower.add_to_chat(123, 'Error: Unable to open blacklist file for reading.')
    end
end


function blacklist_file_exists()
    local file = io.open(windower.addon_path .. 'blacklist.lua', 'r')
    if file then
        file:close()
        return true
    else
        return false
    end
end

function generate_default_blacklist()
    local file = io.open(windower.addon_path .. 'blacklist.lua', 'w')
    if file then
        file:write('return {\n')
        file:write('    patterns = {\n')
        -- Add a comment indicating that patterns should include `.*`
        file:write('        -- Patterns should include .* at the end\n')
        file:write('    },\n')
        file:write('    exact_names = {\n')
        file:write('    }\n')
        file:write('}')
        file:close()
        return true
    else
        return false
    end
end


if not blacklist_file_exists() then
    if generate_default_blacklist() then
    else
        -- windower.add_to_chat(123, 'Error: Unable to create default blacklist.lua.')
    end
end

function list_blacklist()
    windower.add_to_chat(204, '--- Blacklisted Names ---')
    windower.add_to_chat(204, 'Wildcard Patterns:')
    for _, pattern in ipairs(black_listed_patterns) do
        windower.add_to_chat(204, pattern)
    end
    windower.add_to_chat(204, ' ')
    windower.add_to_chat(204, 'Exact Names:')
    for _, name in ipairs(black_listed_exact_names) do
        windower.add_to_chat(204, name)
    end
    windower.add_to_chat(204, '------------------------')
end

windower.register_event('addon command', function(command, ...)
    local args = {...}
    if command:lower() == 'add' or command:lower() == 'a' then
        if #args > 0 then
            local name = args[1]
            add_to_blacklist(name)
        else
            log('Usage: //fo add <name> or //fo add <name>*')
        end

    elseif command:lower() == 'list' then
        windower.send_command('lua r fuckoff')
        list_blacklist()

    elseif command:lower() == 'remove' or command:lower() == 'r' then
        if #args > 0 then
            local name = args[1]
            remove_from_blacklist(name)
        else
            log('Usage: //fo remove <name>')
        end

    elseif command:lower() == 'reload' then
        windower.send_command('lua r fuckoff')

    else
        -- Print out help messages
        log('--- Help Menu ---')
        log('Addon Commands: //fo or //fuckoff')
        log('fo help - This menu')
        log('fo a/add <name> or fo add <name>*')
        log('fo r/remove <name>')
        log('fo list - Print a list of blacklisted names or wildcard names')
        log('fo reload - Reload addon')
    end
end)

----------------------------------------------------------------------------
-- Stop v0.22 Added by Sevu (Bahamut)
----------------------------------------------------------------------------

windower.register_event('incoming chunk', function(id, data)
    if id == 0x017 then -- 0x017 is incoming chat.
        local chat = packets.parse('incoming', data)
        local cleaned = windower.convert_auto_trans(chat['Message']):lower()

        if is_blacklisted(chat['Sender Name']) then -- Check if sender is blacklisted
            return true
        elseif (chat['Mode'] == 3 or chat['Mode'] == 1 or chat['Mode'] == 26) then -- Check for RMT messages in tell, shouts, and yells
            for k, v in ipairs(black_listed_words) do
                if cleaned:match(v:lower()) then
                    return true
                end
            end
        end
    elseif id == 0x028 and block_skillup then -- Action message
        local data = packets.parse('incoming', data)
        if black_listed_skill_pages:contains(data['Target 1 Action 1 Param']) then
            return true
        end
    end
end)
