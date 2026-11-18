concommand.Add("pac_in_editor", function(ply, _, args)
	ply.InPAC3Editor = tonumber(args[1]) == 1 and true or nil
end)

function pace.SpawnPart(ply, model)
	if pace.suppress_prop_spawn then return end
	if model then
		if IsValid(ply) and ply.InPAC3Editor then
			net.Start("pac_spawn_part")
				net.WriteString(model)
			net.Send(ply)
			return false
		end
	end
end

pac.AddHook( "PlayerSpawnProp", "pac_PlayerSpawnProp", pace.SpawnPart)
pac.AddHook( "PlayerSpawnRagdoll", "pac_PlayerSpawnRagdoll", pace.SpawnPart)
pac.AddHook( "PlayerSpawnEffect", "pac_PlayerSpawnEffect", pace.SpawnPart)

util.AddNetworkString("pac_spawn_part")