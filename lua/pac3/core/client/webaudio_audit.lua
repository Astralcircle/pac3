if not CLIENT then return end

local PREFIX = Color(121, 221, 203)
local TEXT   = Color(200, 200, 200)

net.Receive("pac_webaudio_audit", function()
    local urls = net.ReadString()
    local nick = net.ReadString()
    local sid  = net.ReadString()

    MsgC(PREFIX, "[PAC WebAudio] ", TEXT, nick, " (", sid, ") загрузил: ", urls, "\n")
end)