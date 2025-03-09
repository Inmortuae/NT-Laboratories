Hook.Add("revive_syringe.onUse", function(effect, deltaTime, item, targets, worldPosition)
	-- Local Definitions
	local target = targets[1]
	local char = effect.user
	local targetType = tostring(target)
	local headLimb = target.AnimController:GetLimb(LimbType.Head)

	-- Check if target is either Human or Humanhusk
	if targetType == "Human" or targetType == "Humanhusk" then
		-- Check if RS_Affliction is true
		if NTConfig.Get("RS_Affliction", true) then
			-- Check if target has revived affliction
			if HF.HasAffliction(target, "revived", 100) then
				return -- Do not allow reviving
			end
		end

		if NTConfig.Get("NOREV", true) then
			-- Check if target has revived afflictions
			if
				HF.HasAffliction(target, "pressure", 1)
				or HF.HasAffliction(target, "gunshotwound", 190)
				or HF.HasAffliction(target, "bloodloss", 100)
				or headLimb == nil
			then
				return -- Do not allow reviving
			end

			-- surgical head amputation and traumatic head amputation
			if HF.HasAffliction(target, "sh_amputation", 1) or HF.HasAffliction(target, "th_amputation", 1) then
				return
			end
		end

		HF.RemoveItem(item)
		regen(target, target.worldPosition, char)
	end
end)
