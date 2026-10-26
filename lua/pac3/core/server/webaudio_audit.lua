if not SERVER then return end

local cv_log = CreateConVar("pac_sv_webaudio_log", "1", FCVAR_ARCHIVE, "Log WebAudio sounds loaded by players (1 = enabled, 0 = disabled)")
util.AddNetworkString("pac_webaudio_audit")

local PREFIX = Color(121, 221, 203)
local TEXT = Color(200, 200, 200)

--[[
    token-bucket rate limit.

    every player has a bucket that holds up to RATE_BURST 'points'.
    each net message costs 1 point. points are added back over time at
    RATE_REFILL per second, but never above RATE_BURST (the bucket
    just stays full, it doesn't overflow into savings).

    why:
      - players CAN send a short burst (e.g. pac load with a few sounds queued)
      - players CANNOT sustain a flood (refill is much slower than burst)
      - sitting idle doesn't let them bank up thousands of points — the
        bucket caps at RATE_BURST, so after a long break they still only
        get one burst, not more

    example with RATE_BURST = 5, RATE_REFILL = 1:

      t=0s    bucket full (5). Player sends 5 messages -> all pass.
              bucket = 0.
      t=0s    Player sends an 11th message -> dropped (0 points).
      t=1s    +1 point -> bucket = 1. Sends 1 -> all pass. bucket = 0.
      t=3s    bucket = 3. Player can send 3 more, then it's empty again.
      t=5s   bucket = 5 (capped). Player can burst again.
      t=1h    bucket = 5. Still just one burst. No hoarding.

    result: burst up to 5 instantly, sustained 60/min, no way to
    "save up" points by going quiet.
]]

local RATE_BURST   = 3  -- max messages a player can send back-to-back
local RATE_REFILL  = 1   -- points restored per second (5 points back in 5s)
local RATE_MAX_CAP = RATE_BURST

local buckets = {} 
-- [SteamID64] = { tokens = number, last = CurTime() }

local function checkRate(ply)
    local id = ply:SteamID64()
    if not id then return false end

    local now = CurTime()
    local b = buckets[id]
    if not b then
        b = { tokens = RATE_BURST, last = now }
        buckets[id] = b
    end

    local dt = now - b.last
    if dt > 0 then
        b.tokens = math.min(RATE_MAX_CAP, b.tokens + dt * RATE_REFILL)
        b.last = now
    end

    if b.tokens < 1 then
        return false
    end

    b.tokens = b.tokens - 1
    return true
end

-- drop full buckets for players who've been gone for a while or afk
-- why: we only remove FULL buckets — removing a partially-filled one would be a free burst the next time we see that player (fresh bucket = full).
timer.Create("pac_webaudio_audit_ratelimit_gc", 120, 0, function()
    local now = CurTime()
    for id, b in pairs(buckets) do
        if b.tokens >= RATE_MAX_CAP and (now - b.last) > 300 then
            buckets[id] = nil
        end
    end
end)

net.Receive("pac_webaudio_audit", function(len, ply)
    if not IsValid(ply) then return end
    if len > 2048 then return end

    local path = net.ReadString()
    if not isstring(path) or #path == 0 or #path > 1024 then return end

    if not checkRate(ply) then
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