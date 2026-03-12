function pace.Ban(ply, time)
	ply:SetPData("PAC_Banned", time or true)
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
	local ban = ply:GetPData("PAC_Banned", false)
	if not ban or not tonumber(ban) then return end

	if ban <= os.time() then
		pace.Unban(ply)
	end
end)

function pace.IsBanned(ply)
	return IsValid(ply) and ply:GetPData("PAC_Banned", false)
end
