
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

    dofile(NTL.Path .. "/Lua/Scripts/Server/BioPrinter/EmptySyringe.lua")
    dofile(NTL.Path.."/Lua/Scripts/Pharmacy/humanupdate.lua")
    dofile(NTL.Path.."/Lua/Scripts/Pharmacy/items.lua")
    dofile(NTL.Path.."/Lua/Scripts/Pharmacy/pills.lua")
    dofile(NTL.Path.."/Lua/Scripts/Pharmacy/testing.lua")

    Timer.Wait(function()
        if NTC == nil then
            print("Error loading NT Laboratories: It appears Neurotrauma isn't loaded!")
            return
        end

        NTC.AddPreHumanUpdateHook(NTP.PreUpdateHuman)
        NTC.AddHumanUpdateHook(NTP.PostUpdateHuman)
    end,1)

end

Timer.Wait(function()
    dofile(NTL.Path .. "/Lua/Scripts/configdata.lua")
end, 1)