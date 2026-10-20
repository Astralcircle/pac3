if not CLIENT then return end

local cv_cl_log = CreateClientConVar("pac_cl_webaudio_log", "1", true, false, "Show WebAudio logs in console")
local PREFIX = Color(121, 221, 203)
local TEXT   = Color(200, 200, 200)

net.Receive("pac_webaudio_audit", function()
    
    if not cv_cl_log:GetBool() then return end

    local path = net.ReadString()
    local nick = net.ReadString()
    local sid  = net.ReadString()

    pac.Message(PREFIX, "[WebAudio] ", TEXT, nick, "(", sid, "): ", path)

end)