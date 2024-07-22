addon.name      = 'Segs';          
addon.author    = 'sevu';                 
addon.version   = '1.0';                      
addon.desc      = 'Tracks Mog Segments in Odyssey. Prints a report afterwards.'

require('common')
local imgui = require('imgui')
local chat = require("chat")

local total_segments = 0
local total_moogle_segments = 0
local current_zone = nil
local previous_zone = ''
local was_in_walk_of_echoes = false
local show_segment_info = true

local style = imgui.GetStyle()
    style.WindowRounding = 2 
    style.WindowBorderSize = 0.1 


ashita.events.register('text_in', 'segment_recorder_callback', function (e)
    if e.injected then
        return
    end

    local pattern = "You receive (%d+) moogle segments for a total of (%d+)."
    local segments_received, total = string.match(e.message, pattern)

    if segments_received and total then
        segments_received = tonumber(segments_received)
        total = tonumber(total)

        total_segments = total_segments + segments_received
        total_moogle_segments = total

    end
end)

local function zone_check()
    if current_zone == nil then
        show_segment_info = false
    else
        show_segment_info = true
    end
end

local function onZoneChange()
    local currentZoneID = AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0)
    current_zone = AshitaCore:GetResourceManager():GetString('zones.names', currentZoneID)
    zone_check()
end

ashita.events.register('packet_in', 'zonename_packet_in', function(event)
    if event.id == 0x0A then
        local moghouse = struct.unpack('b', event.data, 0x80 + 1)
        if moghouse ~= 1 then
            coroutine.sleep(2)
            onZoneChange()

            if current_zone == 'Walk of Echoes [P1]' or current_zone == 'Walk of Echoes [P2]' then
                was_in_walk_of_echoes = true
                total_segments = 0
                total_moogle_segments = 0                

            elseif current_zone == 'Rabao' and was_in_walk_of_echoes then

                print(chat.header(addon.name):append(chat.info('No longer in Odyssey. Tallying run...')))
                AshitaCore:GetChatManager():QueueCommand(1, '/seg total')

                was_in_walk_of_echoes = false

            else
                was_in_walk_of_echoes = false

            end
        end
    end
end)

ashita.events.register('command', 'command_callback1', function (e)
    local args = e.command:args()

    if args[1] ~= '/seg' then
        return
    end

    e.blocked = true 

    if args[2] == 'total' then
        print(string.format('\31\207[%s] \31\123 Segment Report:', addon.name))
        print(string.format('\31\207[%s] \31\123 You obtained: %d', addon.name, total_segments))
        print(string.format('\31\207[%s] \31\123 Your new total: %d', addon.name, total_moogle_segments))

    elseif args[2] == 'hide' then
        show_segment_info = false

    elseif args[2] == 'show' then
        show_segment_info = true

    elseif args[2] == 'reset' then
        total_segments = 0
        total_moogle_segments = 0
        print('\31\207[%d] \31\123 Reset.')

    else
        print(string.format('\31\207[%s] \31\123 Available commands:', addon.name))
        print(string.format('\31\207[%s] \31\123 /seg total - Display current segment totals.', addon.name))
        print(string.format('\31\207[%s] \31\123 /seg hide - Hide the segment info window.', addon.name))
        print(string.format('\31\207[%s] \31\123 /seg show - Show the segment info window.', addon.name))
    end
end)


local function imgui_render()
    if show_segment_info then
        imgui.SetNextWindowBgAlpha(0.8)        
        if imgui.Begin('Mog Segments', show_segment_info,
            bit.bor(
                ImGuiWindowFlags_NoDecoration, 
                ImGuiWindowFlags_AlwaysAutoResize, 
                ImGuiWindowFlags_NoFocusOnAppearing, 
                ImGuiWindowFlags_NoNav
            )) then

            imgui.Text(string.format("Segments: %d", total_segments))
            imgui.Text(string.format("Total Segments: %d", total_moogle_segments))
            if current_zone ~= nil then
                imgui.Text("Current Zone: " .. current_zone)
            end
            
            local button_spacing = 5
            
            if imgui.Button('Close') then
                show_segment_info = false
            end
            
            imgui.SameLine(0, button_spacing)
            
            if imgui.Button('Reset') then
                total_segments = 0
                total_moogle_segments = 0
                print('\31\207[Segments] \31\123 Reset.')
            end
            
            imgui.End()
        end
    end
end


ashita.events.register('d3d_present', 'present_cb', function()
    imgui_render()
end)

ashita.events.register('load', 'load_cb', function()
    zone_check()
end)


ashita.events.register('unload', 'unload_cb', function()
end)
