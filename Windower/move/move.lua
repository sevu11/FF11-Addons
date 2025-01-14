_addon.name = 'Move'
_addon.author = 'Sevu11'
_addon.version = '0.1.4'
_addon.commands = {'move'}

------------------------------------------------------------------------------------
-- IMPORTS
------------------------------------------------------------------------------------
local items = require('items')
local slips_items = items.slips_items
local med_items = items.med_items

------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW
------------------------------------------------------------------------------------
function process_items(action, items, location)
    for _, item in pairs(items) do
        windower.send_command(action .. ' "' .. item .. '" ' .. location)
    end
end

function move_slips_to_satchel()
    process_items('put', slips_items, 'satchel')
end

function move_meds_to_case()
    process_items('put', med_items, 'case all')
end

function get_slips_to_satchel()
    process_items('get', slips_items, 'satchel')
end

function get_meds_to_case()
    process_items('get', med_items, 'case all')
end

function show_available_commands()
    windower.add_to_chat(222, 'Available commands:')
    windower.add_to_chat(222, '//move slips     - Move slips to inventory')
    windower.add_to_chat(222, '//move putslips  - Put slips into satchel')
    windower.add_to_chat(222, '//move meds      - Move meds/food to inventory')
    windower.add_to_chat(222, '//move putmeds   - Put meds/food into case')
end

windower.register_event('addon command', function(...)
    local args = {...}
    local command = args[1] and args[1]:lower() or ''

    if command == 'slips' then
        windower.add_to_chat(222, 'Moving Slips to inventory...')
        get_slips_to_satchel()
    elseif command == 'putslips' then
        windower.add_to_chat(222, 'Putting away Slips...')
        move_slips_to_satchel()
    elseif command == 'meds' then
        windower.add_to_chat(222, 'Moving meds and food to inventory...')
        get_meds_to_case()
    elseif command == 'putmeds' then
        windower.add_to_chat(222, 'Putting away meds/food...')
        move_meds_to_case()
    else
        show_available_commands()
    end
end)