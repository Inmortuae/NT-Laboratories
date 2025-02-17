Hook.Add("empty_syringe_bone.onUse", function(effect, deltaTime, item, targets, worldPosition)

    -- Local Definitions
    local target = targets[1]
    local limb = targets[2]
    local limbtype = limb.type
    local char = effect.user
    local targetType = tostring(target)

    -- Check if target is either Human or Humanhusk
    if targetType == "Human" then
        if HF.GetSkillRequirementMet(char, "medical", 50) then   
            if HF.HasAfflictionLimb(target, "drilledbones", limbtype, 1) and not HF.HasAfflictionLimb(target, "bonemarrowextracted", limbtype, 100) then
                HF.AddAfflictionLimb(target, "bonemarrowextracted", limbtype, 20, char) -- Bone damage from harvest
                HF.GiveItem(char, "bone_marrow")
                HF.RemoveItem(item)
                print("Bone marrow extracted from limb")
            end
        else
            HF.AddAfflictionLimb(target, "severepain", limbtype, 40, char) -- Excruciating pain
            HF.AddAfflictionLimb(target, "bonedamage", limbtype, 50, char) -- Bone damage risk
            HF.AddAfflictionLimb(target, "t_fracture", limbtype, 25, char) -- Potential fracture
            HF.AddAfflictionLimb(target, "internalbleeding", limbtype, 45, char) -- Internal hemorrhage
        end
    end

end)
