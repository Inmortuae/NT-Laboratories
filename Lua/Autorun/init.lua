NTL = {} -- Neurotrauma Laboratories
NTL.Name = "NT Laboratories"
NTL.Version = "A1.0.6"
NTL.VersionNum = 01000602
NTL.MinNTVersion = "A1.9.0"
NTL.MinNTVersionNum = 01090000
NTL.Path = table.pack(...)[1]
Timer.Wait(function()
	if NTC ~= nil and NTC.RegisterExpansion ~= nil then
		NTC.RegisterExpansion(NTL)
	end
end, 1)

-- server-side code (also run in singleplayer)
if (Game.IsMultiplayer and SERVER) or not Game.IsMultiplayer then
	-- BioPrinter
	dofile(NTL.Path .. "/Lua/Scripts/Server/BioPrinter/EmptySyringe.lua")

	-- Pharmacy
	dofile(NTL.Path .. "/Lua/Scripts/Pharmacy/items.lua")
	dofile(NTL.Path .. "/Lua/Scripts/Pharmacy/pills.lua")
	-- Blood Work
	dofile(NTL.Path .. "/Lua/Scripts/BloodWork/plasma.lua")

	-- Undead's Medical
	dofile(NTL.Path .. "/Lua/Scripts/Server/UndeadsMed/Server_SaveScripts/Talents.lua")
	dofile(NTL.Path .. "/Lua/Scripts/Server/UndeadsMed/Server_SaveScripts/Inv.Lua")
	dofile(NTL.Path .. "/Lua/Scripts/Server/UndeadsMed/Server_SaveScripts/Affliction.lua")
	dofile(NTL.Path .. "/Lua/Scripts/Server/UndeadsMed/Regen.lua")
	dofile(NTL.Path .. "/Lua/Scripts/Server/UndeadsMed/revivesyringe.lua")
	dofile(NTL.Path .. "/Lua/Scripts/Server/UndeadsMed/nanobots.lua")
	dofile(NTL.Path .. "/Lua/Scripts/Server/UndeadsMed/refinedcalyxsyringe.lua")

	Timer.Wait(function()
		if NTC == nil then
			print("Error loading NT Laboratories: It appears Neurotrauma isn't loaded!")
			return
		end

		--Cyber
		dofile(NTL.Path .. "/Lua/Scripts/Cyber/empexplosionpatch.lua")
		dofile(NTL.Path .. "/Lua/Scripts/Cyber/humanupdate.lua")
		dofile(NTL.Path .. "/Lua/Scripts/Cyber/items.lua")
		dofile(NTL.Path .. "/Lua/Scripts/Cyber/items.shared.lua")
		dofile(NTL.Path .. "/Lua/Scripts/Cyber/ondamaged.lua")
		dofile(NTL.Path .. "/Lua/Scripts/Cyber/helperfunctions.lua")

		dofile(NTL.Path .. "/Lua/Scripts/Cyber/testing.lua")

		--Symbiote + Infection
		dofile(NTL.Path .. "/Lua/Scripts/NT Symbiote+Infection/humanupdate.lua")
		dofile(NTL.Path .. "/Lua/Scripts/NT Symbiote+Infection/items.lua")

		--Human Update Hooks
		NTC.AddPreHumanUpdateHook(NTL.UpdateHuman)
	end, 1)
else
	Timer.Wait(function()
		if NT ~= nil and NT.VersionNum < 01090000 then
			local msg =
				"Error loading NT Cybernetics: old Neurotrauma detected, use the modern fork published by 'guns'"
			print(msg)
			Game.ChatBox.AddMessage(ChatMessage.Create("", msg, ChatMessageType.Server, nil))
			return
		end
		dofile(NTL.Path .. "/Lua/Scripts/Cyber/items.client.lua")
		dofile(NTL.Path .. "/Lua/Scripts/Cyber/items.shared.lua")
	end, 1)
end

Timer.Wait(function()
	dofile(NTL.Path .. "/Lua/Scripts/configdata.lua")
end, 1)
