addon.name      = 'invite';                   
addon.author    = 'Sevu11';                     
addon.version   = '1.1';                        
addon.desc      = 'Automatically invite party members.'; 
addon.link      = 'https://ashitaxi.com/';    

require('common');
local chat = require('chat')
local settings = require('settings')

local default_settings = T{
    players = T{},
}

local inviteSettings = settings.load(default_settings)

local function saveConfig()
    settings.save()
end

local function sendInvite(player)
    print(chat.header('Invite'):append(chat.message(string.format('Attempting to invite: %s', player))))
    local success, err = pcall(function()
        AshitaCore:GetChatManager():QueueCommand(1, '/pcmd add ' .. player)
    end)
    if not success then
        print(string.format("[Invite] Error inviting %s: %s", player, err))
    end
    coroutine.sleep(1.5)
end

local function inviteMembers()
    local playerCount = #inviteSettings.players
    print(chat.header('Invite'):append(chat.message(string.format('Sending party invite to %s players.', playerCount))))
    for _, player in ipairs(inviteSettings.players) do
        sendInvite(player)
    end
    print(chat.header('Invite'):append(chat.message('All party invites has been sent.')))
end

local function displayPlayerList()
    local playerCount = #inviteSettings.players
    print(chat.header('Invite'):append(chat.message(string.format('Current player list (%d):', playerCount))))
    for _, player in ipairs(inviteSettings.players) do
        print(chat.message(player))
    end
end

local function showHelp()
    print(chat.header('Invite Help'):append(chat.message('Available commands:')))
    print(chat.message('/invite start - Start inviting players'))
    print(chat.message('/invite disband - Disband the party'))
    print(chat.message('/invite add <player> - Add a player to the invite list'))
    print(chat.message('/invite delete <player> - Remove a player from the invite list'))
    print(chat.message('/invite delete all - Remove all players from the invite list'))
    print(chat.message('/invite list - List all players in the invite list'))
    print(chat.message('/invite help - Show this help message'))
end

local function checkAndAddPlayer(newPlayer)
    if #inviteSettings.players >= 5 then
        table.remove(inviteSettings.players, 1)
        print(chat.header('Invite'):append(chat.message('Player list exceeded 5 members. Removed the oldest player.')))
    end
    table.insert(inviteSettings.players, newPlayer)
    saveConfig()
    print(chat.header('Invite'):append(chat.message(string.format('Player %s has been added to the list.', newPlayer))))
end

local function deleteAllPlayers()
    inviteSettings.players = T{}
    saveConfig()
    print(chat.header('Invite'):append(chat.message('All players have been removed from the list.')))
end

ashita.events.register('load', 'load_cb', function ()
end)

ashita.events.register('unload', 'unload_cb', function ()
    saveConfig()
end)

ashita.events.register('command', 'command_callback1', function (e)
    local args = e.command:split(' ')
    local command = args[1]:lower()

    if (command == '/invite') then
        local subcommand = args[2] and args[2]:lower()

        if (subcommand == 'start') then
            inviteMembers()
        elseif (subcommand == 'save') then
            print(chat.header('Invite'):append(chat.message(string.format('Settings saved.'))))
            saveConfig();

        elseif (subcommand == 'disband') then
            AshitaCore:GetChatManager():QueueCommand(-1, '/pcmd breakup')
            coroutine.sleep(1.75)
        elseif (subcommand == 'add' and args[3]) then
            local newPlayer = args[3]:lower()
            if not tableContains(inviteSettings.players, newPlayer) then
                checkAndAddPlayer(newPlayer)
                saveConfig()
            else
                print(chat.header('Invite'):append(chat.message(string.format('Player %s is already in the list.', newPlayer))))
            end
        elseif (subcommand == 'delete' and args[3]) then
            if args[3]:lower() == 'all' then
                deleteAllPlayers()
            else
                local deletePlayer = args[3]:lower()
                if tableContains(inviteSettings.players, deletePlayer) then
                    tableRemove(inviteSettings.players, deletePlayer)
                    saveConfig()
                    print(chat.header('Invite'):append(chat.message(string.format('%s has been removed from the list.', deletePlayer))))
                else
                    print(chat.header('Invite'):append(chat.message(string.format('%s not found in the list.', deletePlayer))))
                end
            end
        elseif (subcommand == 'list') then
            displayPlayerList()
        elseif (subcommand == 'help') then
            showHelp()
        else
            print(chat.header('Invite'):append(chat.message('Unknown subcommand. Use /invite help for a list of commands.')))
        end
        e.blocked = true
    end
end)

function string:split(delimiter)
    local result = {}
    for match in (self .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

function tableContains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

function tableRemove(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then
            table.remove(tbl, i)
            return
        end
    end
end
