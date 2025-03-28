Timer.Wait(function()
	-- make it so ending surgery gets rid of stuff
	NT.SutureAfflictions.surgery_huskhealth = {}
	NT.SutureAfflictions.bonecuttorso = {}

	-- add stabbing parasites to the scalpels functionality
	local tempScalpelFunction = NT.ItemMethods.advscalpel
	NT.ItemMethods.advscalpel = function(item, usingCharacter, targetCharacter, limb)
		tempScalpelFunction(item, usingCharacter, targetCharacter, limb)

		local limbtype = HF.NormalizeLimbType(limb.type)

		-- only the torso is interesting for the husk stuff
		if limbtype ~= LimbType.Torso then
			return
		end

		-- don't work on stasis
		if HF.HasAffliction(targetCharacter, "stasis", 0.1) then
			return
		end

		local huskHealth = HF.GetAfflictionStrength(targetCharacter, "surgery_huskhealth")
		local calyx = HF.GetAfflictionStrength(targetCharacter, "af_calyxanide")

		-- don't work if we're not in the "stabbing the shit out of the parasite" phase of treatment
		if huskHealth < 0.1 then
			return
		end

		if HF.CanPerformSurgeryOn(targetCharacter) then
			-- skill check is 30 with and 100 without calyxanide
			if HF.GetSurgerySkillRequirementMet(usingCharacter, 30 + 70 * HF.BoolToNum(calyx < 0.1)) then
				-- "treat" some husk health
				local newHuskHealth = HF.Clamp(huskHealth - 10, 5, 100)
				HF.SetAffliction(targetCharacter, "surgery_huskhealth", newHuskHealth)
				HF.GiveItem(targetCharacter, "ntsfx_huskhurt")
			else
				if calyx < 0.1 and huskHealth > 20 then
					-- no calyx and husk active, uh oh.

					-- determine what limb is being retaliated against
					local hitLimb = LimbType.RightArm
					if
						NT.LimbIsDislocated(usingCharacter, hitLimb)
						or NT.LimbIsBroken(usingCharacter, hitLimb)
						or NT.LimbIsAmputated(usingCharacter, hitLimb)
					then
						hitLimb = LimbType.LeftArm
					end

					HF.AddAfflictionLimb(usingCharacter, "bleeding", hitLimb, 5)
					HF.AddAfflictionLimb(usingCharacter, "bitewounds", hitLimb, 10)
					HF.AddAffliction(usingCharacter, "stun", 0.2)
					-- 20% chance of getting the unfortunate soul holding the scalpel infected
					if HF.Chance(0.2) then
						HF.AddAffliction(usingCharacter, "huskinfection", 1)
					end
					HF.GiveItem(targetCharacter, "ntsfx_huskhurt")
				else
					-- stop stabbing the patient, stupid
					HF.AddAfflictionLimb(targetCharacter, "bleeding", limbtype, 10, usingCharacter)
					HF.AddAfflictionLimb(targetCharacter, "lacerations", limbtype, 10, usingCharacter)
				end
			end
		end
	end

	-- add ripping parasites out of the patients chest cavity to the hemostats functionality
	local tempHemostatFunction = NT.ItemMethods.advhemostat
	NT.ItemMethods.advhemostat = function(item, usingCharacter, targetCharacter, limb)
		tempHemostatFunction(item, usingCharacter, targetCharacter, limb)

		local limbtype = HF.NormalizeLimbType(limb.type)

		-- only the torso is interesting for the husk stuff
		if limbtype ~= LimbType.Torso then
			return
		end

		-- don't work on stasis
		if HF.HasAffliction(targetCharacter, "stasis", 0.1) then
			return
		end

		local huskHealth = HF.GetAfflictionStrength(targetCharacter, "surgery_huskhealth")

		-- don't work if we're not in the "grabbing the parasite by the balls" phase of treatment
		if (huskHealth > 20) or (huskHealth < 0.1) then
			return
		end

		if HF.CanPerformSurgeryOn(targetCharacter) then
			if HF.GetSurgerySkillRequirementMet(usingCharacter, 30) then
				-- rip that sucker out for good
				-- ...but first, give the patient lung damage equivalent to the remaining husk health
				HF.AddAffliction(
					targetCharacter,
					"lungdamage",
					huskHealth * 2 + HF.Clamp(50 - HF.GetSurgerySkill(usingCharacter), 0, 30)
				)
				HF.SetAffliction(targetCharacter, "surgery_huskhealth", 0)
				HF.SetAffliction(targetCharacter, "huskinfection", 0)
				--HF.SetAffliction(targetCharacter,"husksymbiosis",0)
				HF.GiveItem(targetCharacter, "ntsfx_huskdeath")
				HF.GiveSkill(usingCharacter, "medical", 3)
			else
				-- stop stabbing the patient, stupid
				HF.AddAfflictionLimb(targetCharacter, "bleeding", limbtype, 10, usingCharacter)
				HF.AddAfflictionLimb(targetCharacter, "lacerations", limbtype, 10, usingCharacter)
			end
		end
	end

	-- Add sawing torso bones to the bonesaw
	local tempSawFunction = NT.ItemMethods.surgerysaw
	NT.ItemMethods.surgerysaw = function(item, usingCharacter, targetCharacter, limb)
		tempSawFunction(item, usingCharacter, targetCharacter, limb)

		local limbtype = HF.NormalizeLimbType(limb.type)

		-- Trauma amputation afflictions for each limb
		local traumaticAmputationAfflictions = {
			[LimbType.RightArm] = "gate_ta_ra",
			[LimbType.LeftArm] = "gate_ta_la",
			[LimbType.RightLeg] = "gate_ta_rl",
			[LimbType.LeftLeg] = "gate_ta_ll",
		}

		local amputationAffliction = traumaticAmputationAfflictions[limbtype]

		if
			not HF.HasAfflictionLimb(targetCharacter, "surgeryincision", limbtype, 99)
			and NTConfig.Get("TraumaSaw", true)
		then
			if HF.GetSurgerySkillRequirementMet(usingCharacter, 25) then
				if amputationAffliction then
					HF.SetAfflictionLimb(targetCharacter, amputationAffliction, limbtype, 1, usingCharacter)
					local reduction = (math.random(25, 50))
					item.Condition = item.Condition - reduction
				end
			end
		end

		-- Only the torso is interesting for the husk stuff
		if limbtype ~= LimbType.Torso then
			return
		end

		-- Don't work on stasis
		if HF.HasAffliction(targetCharacter, "stasis", 0.1) then
			return
		end

		local huskHealth = HF.GetAfflictionStrength(targetCharacter, "surgery_huskhealth")

		-- Don't work if we've already cut the torso open
		if HF.HasAffliction(targetCharacter, "bonecuttorso", 1) then
			return
		end

		if
			HF.CanPerformSurgeryOn(targetCharacter)
			and HF.HasAfflictionLimb(targetCharacter, "retractedskin", limbtype, 99)
		then
			if HF.GetSurgerySkillRequirementMet(usingCharacter, 50) then
				HF.AddAffliction(
					targetCharacter,
					"bonecuttorso",
					1 + HF.GetSurgerySkill(usingCharacter) / 2,
					usingCharacter
				)
			else
				HF.AddAfflictionLimb(targetCharacter, "bleeding", limbtype, 15, usingCharacter)
				HF.AddAfflictionLimb(targetCharacter, "internaldamage", limbtype, 6, usingCharacter)
				HF.AddAfflictionLimb(targetCharacter, "lacerations", limbtype, 4, usingCharacter)
			end
		end
	end

	-- make it so trying to defib someones parasite will do funny things
	local tempDefibFunction = NT.ItemMethods.defibrillator
	NT.ItemMethods.defibrillator = function(item, usingCharacter, targetCharacter, limb)
		-- new functionality conditionals

		local huskHealth = HF.GetAfflictionStrength(targetCharacter, "surgery_huskhealth")

		if huskHealth > 0.1 and HF.HasAffliction(targetCharacter, "bonecuttorso", 99) then
			-- don't work on stasis
			if HF.HasAffliction(targetCharacter, "stasis", 0.1) then
				return
			end

			local calyx = HF.GetAfflictionStrength(targetCharacter, "af_calyxanide")
			if calyx < 0.1 and huskHealth > 20 then
				-- trying to defib a very aggressive parasite

				if HF.Chance(0.3) then
					-- we're doing the funny double traumatic amputation now
					if not NT.LimbIsAmputated(usingCharacter, LimbType.RightArm) then
						NT.TraumamputateLimb(usingCharacter, LimbType.RightArm)
					end
					if not NT.LimbIsAmputated(usingCharacter, LimbType.LeftArm) then
						NT.TraumamputateLimb(usingCharacter, LimbType.LeftArm)
					end

					HF.GiveItem(targetCharacter, "ntsfx_huskhurt")
				else
					-- determine what limb is being retaliated against
					local hitLimb = LimbType.RightArm
					if HF.Chance(0.5) then
						hitLimb = LimbType.LeftArm
					end

					if NT.LimbIsAmputated(usingCharacter, LimbType.RightArm) then
						hitLimb = LimbType.LeftArm
					end
					if NT.LimbIsAmputated(usingCharacter, LimbType.LeftArm) then
						hitLimb = LimbType.RightArm
					end

					HF.AddAfflictionLimb(usingCharacter, "bleeding", hitLimb, 5)
					HF.AddAfflictionLimb(usingCharacter, "bitewounds", hitLimb, 10)
					HF.AddAffliction(usingCharacter, "stun", 0.2)
					-- 20% chance of getting the unfortunate soul holding the defib infected
					if HF.Chance(0.2) then
						HF.AddAffliction(usingCharacter, "huskinfection", 1)
					end
				end

				HF.GiveItem(targetCharacter, "ntsfx_huskhurt")
			else
				-- defibbing a stunned parasite

				local containedItem = item.OwnInventory.GetItemAt(0)
				if containedItem == nil then
					return
				end
				local hasVoltage = containedItem.Condition > 0

				if hasVoltage then
					HF.GiveItem(targetCharacter, "ntsfx_manualdefib")
					containedItem.Condition = containedItem.Condition - 10
					if containedItem.Prefab.Identifier.Value ~= "fulguriumbatterycell" then
						containedItem.Condition = containedItem.Condition - 10
					end

					local successChance = (HF.GetSkillLevel(usingCharacter, "medical") / 100) ^ 2

					Timer.Wait(function()
						HF.AddAffliction(targetCharacter, "stun", 0.5, usingCharacter)

						huskHealth = HF.GetAfflictionStrength(targetCharacter, "surgery_huskhealth")

						-- make sure surgery wasnt terminated in the 2 seconds it takes for the defib to do its job
						if huskHealth < 0.1 then
							return
						end

						if HF.Chance(successChance) then
							huskHealth = huskHealth - 30
						else
							huskHealth = huskHealth - 10
						end

						huskHealth = HF.Clamp(huskHealth, 5, 100)
						HF.SetAffliction(targetCharacter, "surgery_huskhealth", huskHealth)
						HF.GiveItem(targetCharacter, "ntsfx_huskdeath")
					end, 2000)
				end
			end
		else
			tempDefibFunction(item, usingCharacter, targetCharacter, limb)
		end
	end

	local function reattachLimb(item, user, target, limb, itemlimbtype)
		local limbtype = HF.NormalizeLimbType(limb.type)
		if limbtype ~= itemlimbtype then
			return
		end

		if NT.LimbIsAmputated(target, limbtype) and HF.HasAfflictionLimb(target, "bonecut", limbtype, 99) then
			HF.SetAfflictionLimb(target, "bonecut", limbtype, 0, user)
			NT.SurgicallyAmputateLimb(target, limbtype, 0, 0)
			if NTSP ~= nil and NTConfig.Get("NTSP_enableSurgerySkill", true) then
				HF.GiveSkillScaled(usingCharacter, "surgery", 8000)
			else
				HF.GiveSkillScaled(usingCharacter, "medical", 4000)
			end
			HF.RemoveItem(item)
		elseif NT.LimbIsAmputated(target, limbtype) and HF.HasAffliction(target, "husksymbiosis", 99) then
			-- Define correct fracture affliction identifiers for each limb type
			local fractureAffliction = {
				[LimbType.RightArm] = "ra_fracture",
				[LimbType.LeftArm] = "la_fracture",
				[LimbType.RightLeg] = "rl_fracture",
				[LimbType.LeftLeg] = "ll_fracture",
			}

			local arterialcutAffotion = {
				[LimbType.RightArm] = "ra_arterialcut",
				[LimbType.LeftArm] = "la_arterialcut",
				[LimbType.RightLeg] = "rl_arterialcut",
				[LimbType.LeftLeg] = "ll_arterialcut",
			}

			-- Get the fracture affliction for the limb being reattached
			local fractureID = fractureAffliction[limbtype]

			-- Perform the surgical reattachment
			NT.SurgicallyAmputateLimb(target, limbtype, 0, 0)

			-- Remove the arterial cut affliction
			local arterialcutID = arterialcutAffotion[limbtype]
			if arterialcutID then
				HF.SetAfflictionLimb(target, arterialcutID, limbtype, 0, user)
			end

			-- Apply the correct fracture with 50 severity
			if fractureID then
				HF.SetAfflictionLimb(target, fractureID, limbtype, 100, user)
			end

			HF.RemoveItem(item)
		end
	end
	NT.ItemMethods.rarm = function(item, usingCharacter, targetCharacter, limb)
		reattachLimb(item, usingCharacter, targetCharacter, limb, LimbType.RightArm)
	end
	NT.ItemMethods.larm = function(item, usingCharacter, targetCharacter, limb)
		reattachLimb(item, usingCharacter, targetCharacter, limb, LimbType.LeftArm)
	end
	NT.ItemMethods.rleg = function(item, usingCharacter, targetCharacter, limb)
		reattachLimb(item, usingCharacter, targetCharacter, limb, LimbType.RightLeg)
	end
	NT.ItemMethods.lleg = function(item, usingCharacter, targetCharacter, limb)
		reattachLimb(item, usingCharacter, targetCharacter, limb, LimbType.LeftLeg)
	end

	-- bionic prosthetics
	NT.ItemMethods.rarmp = NT.ItemMethods.rarm
	NT.ItemMethods.larmp = NT.ItemMethods.larm
	NT.ItemMethods.rlegp = NT.ItemMethods.rleg
	NT.ItemMethods.llegp = NT.ItemMethods.lleg
end, 2000)
