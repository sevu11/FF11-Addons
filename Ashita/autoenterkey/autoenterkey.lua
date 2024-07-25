addon.name    = 'autoenterkey'
addon.author  = 'sevu'
addon.version = '1.0'

local socket  = require('socket')

-------------------------------------
-- OS CONFIGURATION
-------------------------------------
is_Windows    = true
is_Linux      = false

local function getAddonDirectory()
    local info = debug.getinfo(1, "S")
    local path = info.source:match("@(.*)$")

    if path then
        path = path:gsub("\\", "/")
        local directory = path:match("^(.-)[/][^/]*%.lua$")
        if directory then
            directory = directory:gsub("/+", "/")
        end
        directory = directory:gsub("/$", "")
        return directory or "unknown directory"
    else
        return "unknown directory"
    end
end

local addonDirectory = getAddonDirectory()
local Linux_scriptPath = addonDirectory .. '/enter.sh'
local Win_scriptPath = addonDirectory .. '/enter.bat'

local function checkLoginStatus()
    local loginStatus = AshitaCore:GetMemoryManager():GetPlayer():GetLoginStatus()
    if loginStatus == 2 then
        AshitaCore:GetChatManager():QueueCommand(1, '/addon unload autoenterkey')
    else
        if is_Linux then
            os.execute(Linux_scriptPath)
        elseif is_Windows then
            os.execute(Win_scriptPath)
        else
            print("Unsupported OS")
        end
    end
end

checkLoginStatus()
socket.sleep(5)
AshitaCore:GetChatManager():QueueCommand(1, '/addon unload autoenterkey')
