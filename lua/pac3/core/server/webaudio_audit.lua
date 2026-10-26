if not SERVER then return end

local cv_log = CreateConVar("pac_sv_webaudio_log", "1", FCVAR_ARCHIVE, "Log WebAudio sounds loaded by players (1 = enabled, 0 = disabled)")
util.AddNetworkString("pac_webaudio_audit")

local PREFIX = Color(121, 221, 203)
local TEXT = Color(200, 200, 200)

local RATE_BURST   = 10  -- max messages a player can send back-to-back
local RATE_REFILL  = 1   -- seconds per token

local pac_RatelimitPlayer = pac.RatelimitPlayer

net.Receive("pac_webaudio_audit", function(len, ply)
    if not IsValid(ply) then return end
    if len > 2048 then return end

    local path = net.ReadString()
    if not isstring(path) or #path == 0 or #path > 1024 then return end

    if not pac_RatelimitPlayer(ply,"webaudio_audit",RATE_BURST,RATE_REFILL) then
        return
    end

    if cv_log:GetBool() then
        pac.Message(PREFIX, "[WebAudio] ", TEXT, ply:Nick(), "(", ply:SteamID(), TEXT, "): ", path)
    end

    net.Start("pac_webaudio_audit")
        net.WriteString(path)
        net.WriteString(ply:Nick())
        net.WriteString(ply:SteamID())
    net.Broadcast()
end)