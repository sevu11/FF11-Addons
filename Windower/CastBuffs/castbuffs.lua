_addon.name = 'CastBuffs'
_addon.author = 'Sevu'
_addon.version = '0.1'
_addon.commands = {'castbuffs', 'cb'}

-------------------------------------------------------------------------------------------------------------------
-- SETTINGS
-------------------------------------------------------------------------------------------------------------------
require('coroutine')
file_path = windower.addon_path .. 'spells.lua'
wait_time = 6.5
is_casting = false

-------------------------------------------------------------------------------------------------------------------
-- GENERATE SPELLS LIST
-------------------------------------------------------------------------------------------------------------------
function file_exists(file_path)
    local file = io.open(file_path, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

function create_spells_file()
    local default_spells = {
        "Aquaveil",
        "Phalanx",
        "Haste",
        "Regen",
        "Occultation",
        "Metallic Body",
        "Cocoon",
        "Battery Charge",
    }
    
    if not file_exists(file_path) then
        local file = io.open(file_path, 'w')
        if file then
            file:write('return {\n')
            for i, spell in ipairs(default_spells) do
                file:write('    "' .. spell .. '",\n')
            end
            file:write('}\n')
            file:write(comment_footer)
            file:close()
            windower.add_to_chat(122, 'Generated default spells.lua file')
        else
            windower.add_to_chat(123, 'Failed to generate spells.lua file')
        end
    end
end
    
-------------------------------------------------------------------------------------------------------------------
-- LOAD DEFAULT SPELLS
-------------------------------------------------------------------------------------------------------------------
function load_spells_file()
    local spells_file = loadfile(windower.addon_path .. 'spells.lua')
    if spells_file then
        local success, loaded_spells = pcall(spells_file)
        if success then
            spells = loaded_spells
        else
            windower.add_to_chat(123, 'Error loading spells.lua: ' .. loaded_spells)
        end
    else
        windower.add_to_chat(123, 'Failed to load spells.lua file')
    end
end

function initialize()
    create_spells_file()
    load_spells_file()
end

initialize()

-------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE
-------------------------------------------------------------------------------------------------------------------
function cast_buff(buff_index)
    if buff_index > #spells then
        windower.add_to_chat(122, '--- Finished casting all buffs ---')
        is_casting = false
        return
    end

    local buff = spells[buff_index]
    windower.add_to_chat(122, '--- Casting ' .. buff .. ' (' .. buff_index .. '/' .. #spells .. ') ---')
    windower.send_command('input /ma "' .. buff .. '" <me>')
    coroutine.sleep(wait_time)
    cast_buff(buff_index + 1)
end

function start_buffing()
    coroutine.sleep(1.5) -- Allow time for addon to load into Gearswap self_command
    if is_casting then
        windower.add_to_chat(122, "Already casting buffs. Please wait.")
        return
    end

    is_casting = true
    cast_buff(1)
end

windower.register_event('addon command', function(command)
    if command == 'start' then
        start_buffing()
    else
        windower.add_to_chat(122, "Unknown command. Use '//cb start' to cast buffs.")
    end
end)
