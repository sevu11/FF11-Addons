_addon.name = 'PorterPacker'
_addon.author = 'Ivaar modified by Gimlic'
_addon.version = '0.0.1.02'
_addon.commands = {'porterpacker','packer','po'}

require('pack')
require('sets')
require('logger')
bit = require('bit')
slips = require('slips')
res = require('resources')
require('coroutine')

local equippable_bags = {
		0, 		--inventory
		5, 		--satchel
		6, 		--sack
		7, 		--case
		8, 		--wardrobe
		10, 	--wardrobe2
		11, 	--wardrobe3
		12, 	--wardrobe4
		13, 	--wardrobe5
		14, 	--wardrobe6
		15, 	--wardrobe7
		16, 	--wardrobe8
	}
local bag_priority = {
		0, 		--inventory
		12,		--wardrobe4
		11, 	--wardrobe3
		10, 	--wardrobe2
		8,		--wardrobe
		13, 	--wardrobe5
		14, 	--wardrobe6
		15, 	--wardrobe7
		16, 	--wardrobe8
	}
local storing_items = false
local continuous = false
local retrieve = {}
local original_retrive = {}
local store = {}
local original_store = {}
local state = 0
local zones = {
	[26]  = 621,	-- Tavnazian Safehold - (F-8)
	[50]  = 959,	-- Aht Urhgan Whitegate - (I-11)
	[53]  = 330,	-- Nashmau - (H-6)
	[80]  = 661,	-- Southern San d'Oria [S] - (M-5)
	[87]  = 603,	-- Bastok Markets [S] - (H-7)
	[94]  = 525,	-- Windurst Waters [S] - (L-10)
	[231] = 874,	-- Northern San d'Oria - (K-8)
	[235] = 547,	-- Bastok Markets - (I-9)
	[240] = 870,	-- Port Windurst - (L-6)
	[245] = 10106,	-- Lower Jeuno - (I-6)
	[247] = 138,	-- Rabao - (G-8)
	[248] = 1139,	-- Selbina - (I-9)
	[249] = 338,	-- Mhaura - (I-8)
	[250] = 309,	-- Kazham - (H-9)
	[252] = 246,	-- Norg - (G-7)
	[256] = 43,	 	-- Western Adoulin - (H-11)
	[280] = 802,	-- Mog Garden
	[298] = 13, 	--"Walk of Echoes [P1]"
	[279] = 13, 	--"Walk of Echoes [P2]"
}

local function space_available(bag_id)
	local bag = windower.ffxi.get_bag_info(bag_id)
	return bag.enabled and (bag.max - bag.count) or 0
end

local function put_away_items(items, bags)
	local inventory = {}
	local count = 0
	local moving = false
	local t1 = 0
	for  __, bag_id in pairs(bags) do
		inventory[bag_id] = space_available(bag_id)
		if space_available(bag_id) > 0 and not moving then
			moving = true
		end
	end
	while moving and t1 < 4 do
		for index, item in ipairs(windower.ffxi.get_items(0)) do	
			if items[item.id] and item.status == 0 then
				for __,bag_id in pairs(bags) do
					if inventory[bag_id] > 0 and windower.ffxi.get_bag_info(bag_id).enabled and bag_id ~=0 then
						moving = false
						count = count + item.count
						inventory[bag_id] = inventory[bag_id] - 1
						windower.ffxi.put_item(bag_id, index, item.count)
						break
					end
				end
			end
		end
	if moving then coroutine.sleep(1)end
	t1 = t1 + 1 
	end
	return count
end

local function retrieve_items(items, bags)
	local inventory = space_available(0)
	local count = 0
	if #items ~= 0 then
		for n = 1, #items do
			for  __, bag_id in pairs(bags) do
				if windower.ffxi.get_bag_info(bag_id).enabled and bag_id ~=0 then
					for index, item in ipairs(windower.ffxi.get_items(bag_id)) do
						if items[n].id == item.id and item.status == 0 then
							if inventory == 0 then return count end
							count = count + item.count
							inventory = inventory - 1
							windower.ffxi.get_item(bag_id, index, item.count)
						end
					end
				end
			end
		end
	end
	return count
end

local function find_item(bags, item_id, count)
	for _, bag_name in pairs(bags) do
		for _, item in ipairs(windower.ffxi.get_items(bag_name)) do
			if item.id == item_id and item.count >= count and item.status == 0 then
				return item
			end
		end
	end
	return nil
end

local function get_trade_items(items)
	local t = {}
	for _, item in ipairs(windower.ffxi.get_items(0)) do
		if items[item.id] and item.count >= items[item.id] and item.status == 0 then
			t[#t+1] = item
			if #t > 7 then
				break
			end
		end
	end
	return #t > 0 and t
end

local function find_npc(name)
	local npc = windower.ffxi.get_mob_by_name(name)
	if npc and math.sqrt(npc.distance) < 6 and npc.valid_target and npc.is_npc and bit.band(npc.spawn_type, 0xDF) == 2 then
		return npc
	end
	error('%s is not in range':format(name))
end

local function trade_npc(npc, items)
	local str = 'I2':pack(0, npc.id)
	for x = 1, 8 do
		str = str .. 'I':pack(items[x] and items[x].count or 0)
	end
	str = str .. 'I2':pack(0, 0)
	for x = 1, 8 do
		str = str .. 'C':pack(items[x] and items[x].slot or 0)
	end
	str = str .. 'C2HI':pack(0, 0, npc.index, #items > 8 and 8 or #items)
	windower.packets.inject_outgoing(0x36, str)
	state = 1
end

--finds storage slips in bag and returns as table
local function find_porter_items(bags)
	local slip_tables = {}
	local item_filter = table.length(store) > 0 and store
	for __, bag in ipairs(bags) do
		for _, item in ipairs(windower.ffxi.get_items(bag)) do
			if item.id ~= 0 and item.status == 0 then
				local slip_id = slips.get_slip_id_by_item_id(item.id)
				if slip_id and not slips.player_has_item(item.id) and
					(not item_filter or item_filter[item.id]) and not retrieve[item.id] and not original_retrive[item.id] and
					(slip_id ~= slips.storages[13] and item.extdata:byte(1) ~= 2 or item.extdata:byte(2)%0x80 >= 0x40 and item.extdata:byte(12) >= 0x80) then

					slip_tables[slip_id] = slip_tables[slip_id] or {}
					slip_tables[slip_id][#slip_tables[slip_id]+1] = item
				elseif slips.items[item.id] then
					slip_tables[item.id] = slip_tables[item.id] or {}
					table.insert(slip_tables[item.id], 1, item)
				end
			end
		end
	end
	return slip_tables
end

local function porter_trade()
	local npc = find_npc('Porter Moogle')
	if not npc then
		retrieve = {}
		store = {}
		storing_items = false
		return
	end
	if storing_items then
		for slip_id, items in pairs(find_porter_items({0})) do
			if #items > 1 and items[1].id == slip_id then
				return trade_npc(npc, items)
			end
		end
		store = {}
		storing_items = false
	end
	if table.length(retrieve) ~= 0 and space_available(0) ~= 0 then
		for slip_id, items in pairs(slips.get_player_items()) do
			if items.n ~= 0 then
				for _, item_id in ipairs(items) do
					if retrieve[item_id] and not find_item(slips.default_storages, item_id, 1) then
						local slip_item = find_item({slips.default_storages[1]}, slip_id, 1)
						if slip_item then
							return trade_npc(npc, {slip_item})
						end
					end
				end
			end
		end
	end
	retrieve = {}
end

local function inject_option(npc_id, npc_index, zone_id, menu_id, option_index, bool)
	windower.packets.inject_outgoing(0x5B, 'I3H4':pack(0, npc_id, option_index, npc_index, bool, zone_id, menu_id))
	return true
end

local function porter_store(data)
	if data:byte(0x0C+1) == 0 then
		return data:sub(0x00+1, 0x07+1) .. string.char(1, 0, 0, 0, 1) .. data:sub(0x0D+1)
	end
	return false
end

local function porter_retrieve(data, update, zone_id, menu_id)
	local npc_id = data:unpack('I', 0x04+1)
	local npc_index = data:unpack('H', 0x28+1)
	if space_available(0) ~= 0 then
		local option_index = 0
		local stored_items = update and update:sub(0x04+1, 0x1B+1) or data:sub(0x08+1, 0x1F+1)
		local slip_number = data:unpack('I', 0x24+1) + 1
		for bit_position = 0, 191 do
			if stored_items:unpack('b', math.floor(bit_position/8)+1, bit_position%8+1) == 1 then
				local item_id = slips.items[slips.storages[slip_number]][bit_position+1]
				if item_id and retrieve[item_id] and space_available(0) ~= 0 then -- added the space available check
					if update and bit_position == update:unpack('I', 0x2A+1) then
						retrieve[item_id] = nil
					else
						return inject_option(npc_id, npc_index, zone_id, menu_id, option_index, 1)
					end
				end
				option_index = option_index + 1
			end
		end
	end
	state = 3
	return inject_option(npc_id, npc_index, zone_id, menu_id, 0x40000000, 0)
end

local events = {}
for i,v in pairs(zones) do
	events[i] = {
		[v-1] = porter_store,
		[v] = porter_retrieve
	}
end

local function check_event(data, update)
	local zone_id, menu_id = data:unpack('H2', 0x2A+1)
	if events[zone_id] and events[zone_id][menu_id] then
		if update and update == last_update then
			return true
		end
		state = 2
		last_update = update
		return events[zone_id][menu_id](data, update, zone_id, menu_id)
	end
	return false
end

local function release_event(data, release)
	local zone_id, menu_id = data:unpack('H2', 0x2A+1)
	if menu_id == release:unpack('H', 0x05+1) then
		local npc_id = data:unpack('I', 0x04+1)
		local npc_index = data:unpack('H', 0x28+1)
		inject_option(npc_id, npc_index, zone_id, menu_id, 0x40000000, 0)
		state = 0
		last_update = nil
		retrieve = {}
		store = {}
		storing_items = false
	end
end

windower.register_event('incoming chunk', function(id, data, modified, injected, blocked)
	if id == 0x034 and state == 1 then
		return check_event(data)
	elseif id == 0x05C and state == 2 then
		check_event(windower.packets.last_incoming(0x34), data)
	elseif id == 0x052 and state ~= 0 then
		if state == 3 then
			state = 0
			last_update = nil
			porter_trade()
		elseif state == 2 and data:byte(0x04+1) == 2 then
			release_event(windower.packets.last_incoming(0x34), data)
		end
	end
end)

windower.register_event('outgoing chunk', function(id, data, modified, injected, blocked)
	if id == 0x05B and state ~= 0 and not injected then
		state = 3
	end
end)

local function load_file(...)
	local file_names = {...}
	for x = 1, 2 do local file_name = file_names[x]
		local file_path = windower.addon_path .. '/data/' .. file_name ..'.lua'
		if windower.file_exists(file_path) then
			local item_table = dofile(file_path)
			local item_names = {}
			for _, name in pairs(item_table) do
				item_names[name:lower()] = true
			end
			local item_ids = {}
			for id, item in pairs(res.items) do
				if item_names[item.name:lower()] or item_names[item.name_log:lower()] then
					item_ids[id] = true
				end
			end
			if table.length(item_ids) ~= 0 then
				notice('loaded file: %s.lua':format(file_name))
				return item_ids
			end
			error('unable to load items from %s.lua':format(file_name))
			return nil
		end
	end
	error('no matching file found: "%s.lua"':format(table.concat(file_names, '.lua" "', 1, 2)))
	return nil
end

local function return_stroage_slip()
	
	
	
end

local function continuous_porter()
	local npc = find_npc('Porter Moogle')
	if not npc then
		retrieve = {}
		store = {}
		storing_items = false
		return
	end
	
	--idintify all items to return in bag
	local Satchel_Slip_table = find_porter_items({5})
	local Sack_Slip_table = find_porter_items({6})
	local Case_Slip_table = find_porter_items({7})
	
	--save a copy of what needs to be returned up front. Otherwise it checks stuff off if you don't have slips in your inventory already.
	local original_retrive = {}
	if table.length(retrieve) ~= 0 then
		for k,v in pairs(retrieve) do
			original_retrive[k] = v
		end
	end
	
	local All_Table = find_porter_items(equippable_bags)--added
	
	--trade items to porter moogle
	if storing_items then
		local action=true
		local i=1
		while action do
			action=false
			for slip_id, items in pairs(All_Table) do
				if #items > 1 and items[1].id == slip_id then
					local item_tables = {}
					
					-- move items to bag
					if space_available(0) ~= 0 then
						retrieve_items(items, equippable_bags)
						coroutine.sleep(2)
					end
					for slip_id2, items2 in pairs(find_porter_items({0})) do
						if #items2 > 1 and items2[1].id == slip_id2 then
							action=true
							--check NPC range
							npc = find_npc('Porter Moogle')
							if not npc then
								retrieve = {}
								store = {}
								storing_items = false
								return
							end
							trade_npc(npc, items2)
							wait_for_trades()
							put_away_items(original_retrive, bag_priority)
						end
					end
					
					-- return Slip back to where we got it
					for slip_id2, items2 in pairs(Satchel_Slip_table) do
						if items2[1].id == slip_id then
							put_away_items({[slip_id]=true}, {5})
							coroutine.sleep(1)
						end
					end
					for slip_id2, items2 in pairs(Sack_Slip_table) do
						if items2[1].id == slip_id then
							put_away_items({[slip_id]=true}, {6})
							coroutine.sleep(1)
						end
					end
					for slip_id2, items2 in pairs(Case_Slip_table) do
						if items2[1].id == slip_id then
							put_away_items({[slip_id]=true}, {7})
							coroutine.sleep(1)
						end
					end
				elseif #items > 2 and i == 1 then
					windower.add_to_chat(200, 'Consider getting Storage Slip ' .. slips.get_slip_number_by_id(slip_id) .. '. Found ' .. #items .. ' items that could be stored not in your PorterPacker File.')
				end
			end
			for slip_id, items in pairs(slips.get_player_items()) do -- just added
				if items.n ~= 0 then
					for _, item_id in ipairs(items) do
						if original_retrive[item_id] then
							retrieve[item_id] = true
						end
					end
				end
			end
		i=i+1
		if i>80 then action = false end
		end
	 end
	--continue till all returned
	store = {}
	storing_items = false
	--pull items out
	if table.length(retrieve) ~= 0 and space_available(0) ~= 0 then
		i=1
		while table.length(retrieve) > 0 and i < 80 do
			for slip_id, items in pairs(slips.get_player_items()) do
				if items.n ~= 0 then
					for _, item_id in ipairs(items) do
						if retrieve[item_id] and not find_item(slips.default_storages, item_id, 1) then
							
							local slip_item = find_item(slips.default_storages, slip_id, 1)
							retrieve_items({[1]=slip_item}, equippable_bags)
							coroutine.sleep(1)
							slip_item = find_item({slips.default_storages[1]}, slip_id, 1)
							
							if slip_item then
								--check NPC range
								npc = find_npc('Porter Moogle')
								if not npc then
									retrieve = {}
									store = {}
									storing_items = false
									return
								end
								trade_npc(npc, {slip_item})
								wait_for_trades()
								put_away_items(original_retrive, bag_priority)
							end
						end
					end
				end
				-- return Slip back to where we got it
				for slip_id2, items2 in pairs(Satchel_Slip_table) do
					if items2[1].id == slip_id then
						put_away_items({[slip_id]=true}, {5})
						coroutine.sleep(1)
					end
				end
				for slip_id2, items2 in pairs(Sack_Slip_table) do
					if items2[1].id == slip_id then
						put_away_items({[slip_id]=true}, {6})
						coroutine.sleep(1)
					end
				end
				for slip_id2, items2 in pairs(Case_Slip_table) do
					if items2[1].id == slip_id and find_item({slips.default_storages[1]}, slip_id, 1) then
						put_away_items({[slip_id]=true}, {7})
						coroutine.sleep(1)
					end
				end
			end
			
			--tradenpc tries to trade everything as if it's in your inventory. Need to add back to the retrieve list in case you didn't have the slip yet.
			for slip_id, items in pairs(slips.get_player_items()) do
				if items.n ~= 0 then
					for _, item_id in ipairs(items) do
						if original_retrive[item_id] and not find_item(slips.default_storages, item_id, 1) and not retrieve[item_id] then
							retrieve[item_id] = true
						end
					end
				end
			end
			if space_available(0) <3 then
				coroutine.sleep(1)
				put_away_items(original_retrive, bag_priority)
				coroutine.sleep(1)
			end
			i = i +1
		end
	end
	coroutine.sleep(1)
	put_away_items(original_retrive, bag_priority)
	coroutine.sleep(1)
	retrieve = {}
end

function wait_for_trades()
	local trade_wait_count = 0
	while state ~= 0 and trade_wait_count < 100 do
		coroutine.sleep(.1)
		trade_wait_count = trade_wait_count + 1
	end	
end


function process_slip_in_inventory()
	
	if storing_items then
		for slip_id, items in pairs(find_porter_items({0})) do
			if #items > 1 and items[1].id == slip_id then
				return trade_npc(npc, items)
			end
		end
	 end
		
end


local handled_commands = {
	store = S{'pack','store','p','repack','swap','r'},
	retrieve = S{'get','unpack','retrieve','u','repack','swap','r'},
	all = S{'all','a','continuous'}
}

windower.register_event('addon command', function(...)
	local commands = {...}
	local player = windower.ffxi.get_player()
	commands[1] = commands[1] and commands[1]:lower()
	
	if not player then
	elseif not commands[1] or commands[1] == 'help' then
		notice('Commands: command | alias [optional]')
		notice(' //porterpacker | //packer | //po')
		notice(' export | exp [file] [all | a]		   - exports storable items in your current inventory to a .lua file')
		notice(' pack | store | p [file] [all | a]	  - stores current inventory items, if file is specified only items in the file will be stored')
		notice(' unpack | retrieve | u [file] [all | a] - retrieves matching items in the file from a porter moogle. file defaults to Name_JOB.lua or JOB.lua')
		notice(' repack | swap | r [file] [all | a]	- stores inventory items not in the file and retrieves matching items. file defaults to Name_JOB.lua or JOB.lua')
		notice(' all will search your Wardrobes to return items and store any items you pull into available wardrobe space')
	elseif commands[1] == 'export' or commands[1] == 'exp' then
		local str = 'return {\n'
		local bags ={0}
		if handled_commands.all:contains(commands[2]) or handled_commands.all:contains(commands[3]) then
			bags = {0,1,2,4,5,6,7,8,9,10,11,12,13,14,15,16}
		end
		for  __, bag_id in pairs(bags) do
			for _, item in ipairs(windower.ffxi.get_items(bag_id)) do
				if slips.get_slip_id_by_item_id(item.id) and res.items[item.id] then
					str = str .. '	"%s",\n':format(res.items[item.id].name)
				end
			end
		end
		str = str .. '}\n'
		local file_path = windower.addon_path .. '/data/'
		if not windower.dir_exists(file_path) then
			windower.create_dir(file_path)
		end
		if handled_commands.all:contains(commands[2]) then
			commands[2] = 'export_%s_%s':format(player.name, player.main_job)
		else
			commands[2] = commands[2] or 'export_%s_%s':format(player.name, player.main_job)
		end
		local export = io.open(file_path .. commands[2] .. '.lua', "w")
		export:write(str)
		export:close()
		notice('exporting storable inventory to %s.lua':format(commands[2]))
	elseif state ~= 0 or player.status ~= 0 then
		notice('busy state: %d, status: %d':format(state, player.status))
	elseif (handled_commands.retrieve+handled_commands.store):contains(commands[1]) then
		continuous = handled_commands.all:contains(commands[2])
		if not continuous then continuous = handled_commands.all:contains(commands[3]) end
		if commands[2] or handled_commands.retrieve:contains(commands[1]) then
			if handled_commands.all:contains(commands[2]) then
				commands[2] = player.main_job
			else
				commands[2] = commands[2] or player.main_job
			end
			local item_ids = load_file(commands[2], '%s_%s':format(player.name, commands[2]))
			if not item_ids then
				return
			elseif handled_commands.retrieve:contains(commands[1]) then
				retrieve = item_ids
			else
				store = item_ids
			end
		end
		storing_items = handled_commands.store:contains(commands[1])
		if continuous then
			continuous_porter()
			windower.add_to_chat(200, 'Completed Movements')
		else
			porter_trade()
		end
	end
end)