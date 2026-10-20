if not SERVER then return end

util.AddNetworkString("pac_webaudio_audit")

local PREFIX = Color(121, 221, 203)
local TEXT = Color(200, 200, 200)

local RATE_WINDOW = 10
local RATE_MAX = 5
local rate = {}

net.Receive("pac_webaudio_audit", function(len, ply)
    if not IsValid(ply) then return end
    if len > 2048 then return end

    local path = net.ReadString()
    if not isstring(path) or #path == 0 or #path > 1024 then return end

    --print(string.format("%q", path))
    pac.Message(PREFIX, "[WebAudio] ", TEXT, ply:Nick(), "(", ply:SteamID(), TEXT, "): ", path)

    net.Start("pac_webaudio_audit")
        net.WriteString(path)
        net.WriteString(ply:Nick())
        net.WriteString(ply:SteamID())
    net.Broadcast()

end)