function pace.Ban(ply, time)
	ply:SetPData("PAC_Banned", time and time + os.time() or -1)
	ply:ConCommand("pac_clear_parts")

	net.Start("pac_submit_acknowledged")
		net.WriteBool(false)
		net.WriteString("You have been banned from using pac!")
	net.Send(ply)
end

function pace.Unban(ply)
	ply:RemovePData("PAC_Banned")

	net.Start("pac_submit_acknowledged")
		net.WriteBool(false)
		net.WriteString("You are now permitted to use pac!")
	net.Send(ply)
end

concommand.Add("pac_ban", function(ply, cmd, args)
	if not args[1] then
		pac.Message("Please provide steamid")
		return
	end

	if IsValid(ply) and ply:IsAdmin() then
		local target_ply = player.GetBySteamID(args[1])

		if target_ply then
			pace.Ban(target_ply)
			pac.Message(ply, " banned ", target_ply, " from PAC.")
		end
	end
end)

concommand.Add("pac_unban", function(ply, cmd, args)
	if not args[1] then
		pac.Message("Please provide steamid")
		return
	end

	if IsValid(ply) and ply:IsAdmin() then
		local target_ply = player.GetBySteamID(args[1])

		if target_ply then
			pace.Unban(target_ply)
			pac.Message(ply, " unbanned ", target_ply, " from PAC.")
		end
	end
end)

hook.Add("PlayerInitialSpawn", "pace_RemoveTimedBan", function(ply)
	local ban = tonumber(ply:GetPData("PAC_Banned"))
	if not ban then return end

	if ban ~= -1 and ban <= os.time() then
		pace.Unban(ply)
	end
end)

function pace.IsBanned(ply)
	if not IsValid(ply) then
		return false
	end

	local time = tonumber(ply:GetPData("PAC_Banned"))

	if not time then
		return false
	end

	if time == -1 then
		return true
	else
		if time > os.time() then
			return true
		else
			ply:RemovePData("PAC_Banned")
			return false
		end
	end
end

function pace.GetBanTime(ply)
	return tonumber(ply:GetPData("PAC_Banned"))
end
