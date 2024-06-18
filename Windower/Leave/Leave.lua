--[[
Copyright © 2020, DaneBlood
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of SirPopaLot nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sammeh BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

---------------------------------------------------------------------------------
-- CHANGELOG
---------------------------------------------------------------------------------
--[[
1.1:
Added print command for debugging and, revised command code to handle when 
zone_id changed
1.0:
First release
]]

---------------------------------------------------------------------------------
-- ADDON INFO
---------------------------------------------------------------------------------
_addon.name = 'Leave'
_addon.author = 'Daneblood, Sevu'
_addon.version = '1.1'
_addon.description = 'Will use exit item based on zone. Items are kept in items.lua'
_addon.command = 'Leave'

---------------------------------------------------------------------------------
-- SETTINGS
---------------------------------------------------------------------------------
res = require('resources')
local items_by_zone = require('items')
local chatColor = 207

---------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE
---------------------------------------------------------------------------------
function print_zone()
	local zone = res.zones[279].en
	local zone_id = res.zones[279].id
	windower.add_to_chat(122, 'Name: '.. zone.. '\nID: '.. zone_id)
end

windower.register_event('addon command', function(...)
    local args = T{...}
    local cmd = args[1]
    local zone = windower.ffxi.get_info()['zone']

    if cmd == 'print' then
        print_zone()
        return

    elseif cmd == 'all' then
        windower.send_ipc_message('Leave_all')
        return

    elseif cmd == 'exit' then
        windower.send_command('Leave')
        return
    end

    if items_by_zone[zone] then
        windower.send_command(items_by_zone[zone])
        return

    elseif zone == 78 then -- Einhejar
        windower.send_command('Treasury drop add "Glowing lamp";wait 1;Treasury drop remove "Glowing lamp"')
        return

    elseif zone == 298 or zone == 279 then -- Odyssey & HTMB: A Stygian Pact, Champion of the Dawn, Divine Interference, Maiden of the Dusk
        windower.send_command('input /item \\"moglophone II\\" <me>') -- Odyssey
        windower.send_command('input /item \\"V. Con. Shard\\" <me>') -- HTMB: A Stygian Pact, Champion of the Dawn, Divine Interference, Maiden of the Dusk
        return
    end

    windower.add_to_chat(chatColor, 'This location is unknown. Unable to leave')
end)


windower.register_event('ipc message',function (msg)
    if msg == 'Leave_all' then
		windower.send_command('Leave')
    end
end)
