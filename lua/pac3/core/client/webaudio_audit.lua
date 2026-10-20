if not CLIENT then return end

local PREFIX = Color(121, 221, 203)
local TEXT   = Color(200, 200, 200)

net.Receive("pac_webaudio_audit", function()
    
    local urls = net.ReadString()
    local nick = net.ReadString()
    local sid  = net.ReadString()

    pac.Message(PREFIX, "[WebAudio]", TEXT, nick, " (", sid, ") has loaded web sound: ", urls, "\n")

end)