
-- set the below variable to true to enable debug and testing features
NTL.TestingEnabled = false

Hook.Add('chatMessage', 'NTL.testing', function(msg, client)
    
    if(msg=="ntp1") then
        if not NTL.TestingEnabled then return end
        -- insert testing stuff here
        

        return true
    end
end)