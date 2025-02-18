
-- set the below variable to true to enable debug and testing features
NTL.TestingEnabled = false

Hook.Add('chatMessage', 'NTC.testing', function(msg, client)
    
    if(msg=="ntcyb1") then
        if not NTL.TestingEnabled then return end
        -- insert testing stuff here
        
        NTL.CyberifyLimb(client.Character,LimbType.RightLeg,true)
        NTL.CyberifyLimb(client.Character,LimbType.LeftLeg,true)
        NTL.CyberifyLimb(client.Character,LimbType.LeftArm,true)
        NTL.CyberifyLimb(client.Character,LimbType.RightArm,true)

        return true
    end
end)