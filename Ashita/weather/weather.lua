addon.author = 'Sevi'
addon.name = 'weather'
addon.version = '1.0.0'

require('common')
local imgui = require('imgui')
local chat = require("chat")

local weather_text = ''
local show_weather = true
local last_weather_value = -1

--Window Settings
window_pos = {100, 350}
window_size = {250, 65}





local function GetWeather()
    local pWeather = ashita.memory.find('FFXiMain.dll', 0, '66A1????????663D????72', 0, 0)
    
    if pWeather == 0 then
        print('Error: Unable to find weather data in memory.')
        return nil
    end

    local pointer = ashita.memory.read_uint32(pWeather + 0x02)

    if pointer == 0 then
        print('Error: Invalid weather data pointer.')
        return nil
    end

    local weatherValue = ashita.memory.read_uint8(pointer + 0)

    if weatherValue < 0 or weatherValue > 19 then
        print('Error: Invalid weather value.')
        return nil
    end

    local weatherEnum = {
        [0] = 'Clear',
        [1] = 'Sunny',
        [2] = 'Cloudy',
        [3] = 'Fog',
        [4] = 'Fire',
        [5] = 'Fire (2)',
        [6] = 'Water',
        [7] = 'Water (2)',
        [8] = 'Earth',
        [9] = 'Earth (2)',
        [10] = 'Wind',
        [11] = 'Wind (2)',
        [12] = 'Ice',
        [13] = 'Ice (2)',
        [14] = 'Lightning',
        [15] = 'Lightning (2)',
        [16] = 'Light',
        [17] = 'Light (2)',
        [18] = 'Dark',
        [19] = 'Dark (2)'
    }

    return weatherValue, weatherEnum[weatherValue]
end

local function UpdateWeatherInfo()
    local weatherValue, weatherName = GetWeather()

    if weatherValue then
        if weatherValue ~= last_weather_value then
            weather_text = string.format("Current weather: %s", weatherName)
            last_weather_value = weatherValue
        end
    else
        weather_text = "Failed to retrieve weather data."
    end
end


ashita.events.register('load', 'load_cb', function()
    UpdateWeatherInfo()
end)

ashita.events.register('command', 'command_cb', function(e)
    local args = e.command:args()
    if (#args == 0 or args[1] ~= '/weather') then
        return
    end

    e.blocked = true

    if args[2] == 'reload' then
        AshitaCore:GetChatManager():QueueCommand(1, '/addon reload weather');

    elseif args[2] == 'help' then
        print('\31\207[Weather] \31\200Weather Addon Commands:')
        print('\31\207[Weather] \31\200/weather - Display current weather information.')
        print('\31\207[Weather] \31\200/weather reload - Reload the Weather addon.')
    else
        UpdateWeatherInfo()
        show_weather = true
    end
end)


ashita.events.register('d3d_present', 'present_cb', function()
    if show_weather then
        imgui.SetNextWindowBgAlpha(0.8)
        imgui.SetNextWindowSize(window_size, ImGuiCond_Always)
        imgui.SetNextWindowPos(window_pos, ImGuiCond_Always)

        if imgui.Begin('Weather Info', show_weather,
                       bit.bor(ImGuiWindowFlags_NoDecoration, ImGuiWindowFlags_AlwaysAutoResize, ImGuiWindowFlags_NoSavedSettings, ImGuiWindowFlags_NoFocusOnAppearing, ImGuiWindowFlags_NoNav)) then
            imgui.Text(weather_text)

            if imgui.Button('Close') then
                show_weather = false
            end

            imgui.End()
        end
    end
end)


ashita.events.register('packet_in', 'zonename_packet_in', function(event)
    if event.id == 0x0A then  
        UpdateWeatherInfo()
    else
        UpdateWeatherInfo()
    end
end)

ashita.events.register('unload', 'unload_cb', function()
end)
