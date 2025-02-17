-- define all the afflictions and their update functions
Timer.Wait(function()
    NT.Afflictions.afbloodplasma={max=100}
    NT.Afflictions.bloodpressure={min=5,max=200,default=100,update=function(c,i)
        if c.stats.stasis then return end
        -- calculate new blood pressure
        local desiredbloodpressure =
            (c.stats.bloodamount
            - c.afflictions.tamponade.strength/2                            -- -50 if full tamponade
            - HF.Clamp(c.afflictions.afpressuredrug.strength*5,0,45)        -- -45 if blood pressure medication
            + HF.Clamp(c.afflictions.afadrenaline.strength*10,0,30)         -- +30 if adrenaline
            + HF.Clamp(c.afflictions.afsaline.strength*5,0,30)              -- +30 if saline
            + HF.Clamp(c.afflictions.afringerssolution.strength*5,0,30)     -- +30 if ringers
            + HF.Clamp(c.afflictions.afbloodplasma.strength*5,0,30)         -- +30 if plasma
            ) * 
            (1+0.5*((c.afflictions.liverdamage.strength/100)^2)) *              -- elevated if full liver damage
            (1+0.5*((c.afflictions.kidneydamage.strength/100)^2)) *             -- elevated if full kidney damage
            (1 + c.afflictions.alcoholwithdrawal.strength/200 ) *               -- elevated if alcohol withdrawal
            HF.Clamp((100-c.afflictions.traumaticshock.strength*2)/100,0,1) *   -- none if half or more traumatic shock
            ((100-c.afflictions.fibrillation.strength)/100) *                   -- lowered if fibrillated
            (1-math.min(1,c.afflictions.cardiacarrest.strength)) *              -- none if cardiac arrest
            NTC.GetMultiplier(c.character,"bloodpressure")
            
        local bloodpressurelerp = 0.2
        -- adjust three times slower to heightened blood pressure
        if(desiredbloodpressure>c.afflictions.bloodpressure.strength) then bloodpressurelerp = bloodpressurelerp/3 end
        c.afflictions.bloodpressure.strength = HF.Clamp(HF.Round(
            HF.Lerp(c.afflictions.bloodpressure.strength,desiredbloodpressure,bloodpressurelerp))
            ,5,200)
    end
    }

    local function InfuseBloodPlasma(item, packtype, usingCharacter, targetCharacter, limb)
        -- determine compatibility
        local packhasantibodyA = string.find(packtype, "a")
        local packhasantibodyB = string.find(packtype, "b")
        local packhasantibodyO = string.find(packtype, "o")
    
        local targettype = NT.GetBloodtype(targetCharacter)
    
        local targethasantibodyA = string.find(targettype, "a")
        local targethasantibodyB = string.find(targettype, "b")
        local targethasantibodyO = string.find(targettype, "o")
    
        local compatible = 
        (packhasantibodyA and packhasantibodyB) or
        (targethasantibodyO) or
        (targethasantibodyA and packhasantibodyA) or
        (targethasantibodyB and packhasantibodyB)
    
        local bloodloss = HF.GetAfflictionStrength(targetCharacter,"bloodloss",0)
        local usefulFraction = HF.Clamp(bloodloss/30,0,1)
    
        if compatible then 
            HF.AddAffliction(targetCharacter,"afbloodplasma",50,usingCharacter)
            HF.AddAffliction(targetCharacter,"bloodpressure",30,usingCharacter)
        else
            HF.AddAffliction(targetCharacter,"afbloodplasma",25,usingCharacter)
            HF.AddAffliction(targetCharacter,"bloodpressure",30,usingCharacter)
            local immunity = HF.GetAfflictionStrength(targetCharacter,"immunity",100)
            HF.AddAffliction(targetCharacter,"hemotransfusionshock",math.max(immunity/2-6,0),usingCharacter)
        end
    
        item.Condition = 0
        --HF.RemoveItem(item)
        HF.GiveItem(usingCharacter,"emptybloodpack")
        HF.GiveItem(targetCharacter,"ntsfx_syringe")
    end

    NT.ItemStartsWithMethods.bloodplasma = function(item, usingCharacter, targetCharacter, limb) 
        if item.Condition <= 0 then return end
    
        local identifier = item.Prefab.Identifier.Value
        local packtype = string.sub(identifier, string.len("bloodplasma")+1)
        InfuseBloodPlasma(item,packtype,usingCharacter,targetCharacter,limb)
    end

    -- define all the limb specific afflictions and their update functions
    NT.LimbAfflictions.burn = {max=200,update=function(c,limbaff,i)
            if limbaff[i].strength < 50 then
                limbaff[i].strength = limbaff[i].strength - (c.afflictions.immunity.prev/3000 + HF.Clamp(limbaff.bandaged.strength,0,1)*0.1)*c.stats.healingrate*NT.Deltatime*(HF.Clamp(c.afflictions.afbloodplasma.strength,0,1)+1)
            end
        end
        }

    -- Organ damage
    NT.Afflictions.cerebralhypoxia={max=200,update=function(c,i)
        if c.stats.stasis then return end
        -- calculate new neurotrauma
        local gain =  
            ( -0.1*c.stats.healingrate +                        -- passive regen
            c.afflictions.hypoxemia.strength/100 +              -- from hypoxemia
            HF.Clamp(c.afflictions.stroke.strength,0,20)*0.1 +  -- from stroke
            c.afflictions.sepsis.strength/100*0.4 +             -- from sepsis
            (c.afflictions.liverdamage.strength/800)*(1-HF.Clamp(c.afflictions.afbloodplasma.strength,0,1)) +            -- from liverdamage
            c.afflictions.kidneydamage.strength/1000 +          -- from kidneydamage
            c.afflictions.traumaticshock.strength/100           -- from traumatic shock
        )
        * NT.Deltatime

        if gain > 0 then
            gain = gain
            * NTC.GetMultiplier(c.character,"neurotraumagain")      -- NTC multiplier
            * NTConfig.Get("NT_neurotraumaGain",1)                     -- Config multiplier
            * (1-HF.Clamp(c.afflictions.afmannitol.strength,0,0.5)) -- half if mannitol
        end

        c.afflictions[i].strength = c.afflictions[i].strength + gain

        c.afflictions[i].strength = HF.Clamp(c.afflictions[i].strength,0,200)
    end
    }
    NTC.AddHematologyAffliction("afbloodplasma")
    end,1000)

