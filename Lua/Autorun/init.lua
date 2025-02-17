
NTL = {} -- Neurotrauma Laboratories
NTL.Name="NT Laboratories"
NTL.Version = "A1.0.0"
NTL.VersionNum = 01000602
NTL.MinNTVersion = "A1.9.0"
NTL.MinNTVersionNum = 01090000
NTL.Path = table.pack(...)[1]
Timer.Wait(function() if NTC ~= nil and NTC.RegisterExpansion ~= nil then NTC.RegisterExpansion(NTL) end end,1)

-- server-side code (also run in singleplayer)
if (Game.IsMultiplayer and SERVER) or not Game.IsMultiplayer then

    -- BioPrinter
    dofile(NTL.Path .. "/Lua/Scripts/Server/BioPrinter/EmptySyringe.lua")

    -- Pharmacy
    dofile(NTL.Path.."/Lua/Scripts/Pharmacy/humanupdate.lua")
    dofile(NTL.Path.."/Lua/Scripts/Pharmacy/items.lua")
    dofile(NTL.Path.."/Lua/Scripts/Pharmacy/pills.lua")
    dofile(NTL.Path.."/Lua/Scripts/Pharmacy/testing.lua")

    Timer.Wait(function()
        if NTC == nil then
            print("Error loading NT Laboratories: It appears Neurotrauma isn't loaded!")
            return
        end

        NTC.AddPreHumanUpdateHook(NTL.PreUpdateHuman)
        NTC.AddHumanUpdateHook(NTL.PostUpdateHuman)

        if SERVER or (CLIENT and not Game.IsMultiplayer) then
		
            dofile(NTL.Path.."/Lua/Scripts/Server/NTEye/eyeupdateServer.lua")
            dofile(NTL.Path.."/Lua/Scripts/Server/NTEye/eyesurgeryServer.lua")
            dofile(NTL.Path.."/Lua/Scripts/Server/NTEye/eyeondamageServer.lua")
            dofile(NTL.Path.."/Lua/Scripts/Server/NTEye/spoonServer.lua")
            dofile(NTL.Path.."/Lua/Scripts/Server/NTEye/itemspawnServer.lua")
            dofile(NTL.Path.."/Lua/Scripts/Server/NTEye/eyeNetworkServer.lua")
            dofile(NTL.Path.."/Lua/Scripts/Server/NTEye/LosModeServer.lua")
    
        end
            
            --client side scripts
        if CLIENT then
            dofile(NTL.Path.."/Lua/Scripts/Client/NTEye/eyeupdateClient.lua")
            dofile(NTL.Path.."/Lua/Scripts/Client/NTEye/clientControls.lua")
            dofile(NTL.Path.."/Lua/Scripts/Client/NTEye/eyeHealthScanner.lua") -- testing purpouses
            
        end
    
                
            --comp patches (decided to seperate these since some need to be both client and server)
                --Robotrauma Compatibility Patch
            for package in ContentPackageManager.EnabledPackages.All do
                    if 
                           tostring(package.UgcId) == "2948488019" --Robotrauma
                        or tostring(package.UgcId) == "2952546076" --Robo-Trauma-
                        or tostring(package.UgcId) == "3227815460" --Robotrauma (Afflictions Override)
                    then
                        if SERVER or (CLIENT and not Game.IsMultiplayer) then
                            dofile(NTL.Path.."/Lua/Scripts/Compatibility/NTEye/robotraumaCompServer.lua")
                            print("NT Eyes - Robotrauma Integrated Compatibility Patch")
                        end
                        
                        if CLIENT then
                            dofile(NTL.Path.."/Lua/Scripts/Compatibility/NTEye/robotraumaCompClient.lua")
                        end
                        
                    break
                end
            end
    
            
                    --Immersive Diving Gear Compatibility Patch
            for package in ContentPackageManager.EnabledPackages.All do
                    if 
                        tostring(package.UgcId) == "3074045632" 
                    then
                        if SERVER or (CLIENT and not Game.IsMultiplayer) then
                            dofile(NTL.Path.."/Lua/Scripts/Compatibility/NTEye/immersivedivingComp.lua")
                            print("NT Eyes - Immersive Diving Gear Integrated Compatibility Patch")
                        end
                    break
                end
            end
    end,1)

end

Timer.Wait(function()
    dofile(NTL.Path .. "/Lua/Scripts/configdata.lua")
end, 1)