if not SERVER then return end

util.AddNetworkString("pac_webaudio_audit")

local PREFIX = Color(121, 221, 203)
local TEXT = Color(160, 190, 160)
local STEAMIDCOLOR = Color(140,200,255)

local RATE_WINDOW = 10
local RATE_MAX = 5
local rate = {}

local function rate_ok(ply)
    local sid = ply:SteamID()
    local now = CurTime()
    local t = rate[sid] or {}
    local keep = {}

    for _, ts in ipairs(t) do
        if now - ts < RATE_WINDOW then keep[#keep + 1] = ts end
    end

    if #keep >= RATE_MAX then
        rate[sid] = keep
        return false
    end

    keep[#keep + 1] = now
    rate[sid] = keep
    return true
end

net.Receive("pac_webaudio_audit", function(len, ply)
    if not IsValid(ply) then return end
    if len > 2048 then return end

    local urls = net.ReadString()
    if not isstring(urls) or #urls == 0 or #urls > 1024 then return end

    pac.Message(PREFIX, "[WebAudio] ", TEXT, ply:Nick(), " (", STEAMIDCOLOR, ply:SteamID(), TEXT, ") has loaded web sound: ", urls)

    net.Start("pac_webaudio_audit")
        net.WriteString(urls)
        net.WriteString(ply:Nick())
        net.WriteString(ply:SteamID())
    net.Broadcast()

end)