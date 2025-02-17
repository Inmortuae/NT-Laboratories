-- overwrites eye updates to outcast robots
function NTL.Update()
	--print("eyeupdatetest")
		local updateHumanEyes = {}
		local amountHumanEyes = 0


	--fetch character for update
	for key, character in pairs(Character.CharacterList) do
		if not character.IsDead then
			if character.IsHuman and (character.IsFemale or character.IsMale) then
				table.insert(updateHumanEyes, character)
				amountHumanEyes = amountHumanEyes + 1
			end
		end
	end
	
	--spread the characters out over the duration of an update so that the load isnt done all at once
    for key, value in pairs(updateHumanEyes) do
        -- make sure theyre still alive and human
        if (value ~= nil and not value.Removed and value.IsHuman and not value.IsDead) then
            Timer.Wait(function ()
                if (value ~= nil and not value.Removed and value.IsHuman and not value.IsDead) then
                NTL.UpdateHumanEye(value) end
            end, ((key + 1) / amountHumanEyes) * NTL.Deltatime * 1000)
        end
    end
end


--overwrites surgery check to disable eye surgeries for robots
function NTL.CanSurgery(character)
	if 
		HF.CanPerformSurgeryOn(character) 
		and not NTL.IsInDivingGear(character) 
		and not HF.HasAffliction(character,"stasis",0.1) 
		and (character.IsFemale or character.IsMale)
	then
	return true end
end


--overwrites eye check to disable eye surgeries for robots
function NTL.HasEyes(character)
	if 
		not HF.HasAffliction(character, "noeye") 
		and not HF.HasAffliction(character, "eyesdead") 
		and not HF.HasAffliction(character, "th_amputation")
		and (character.IsFemale or character.IsMale)
	then return true end

end
