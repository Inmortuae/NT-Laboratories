
NTOP = {} -- Neurotrauma Organ Printer
NTOP.Name="NT Bio Printer"
NTOP.Version = "A1.0.2"
NTOP.VersionNum = 01000602
NTOP.MinNTVersion = "A1.9.0"
NTOP.MinNTVersionNum = 01090000
NTOP.Path = table.pack(...)[1]
Timer.Wait(function() if NTC ~= nil and NTC.RegisterExpansion ~= nil then NTC.RegisterExpansion(NTOP) end end,1)

-- server-side code (also run in singleplayer)
if (Game.IsMultiplayer and SERVER) or not Game.IsMultiplayer then

    Timer.Wait(function()
        if NTC == nil then
            print("Error loading NT Bio Printer: It appears Neurotrauma isn't loaded!")
            return
        end
        dofile(NTOP.Path .. "/Lua/Scripts/Server/EmptySyringe.lua")
    end,1)

end

Timer.Wait(function()
    dofile(NTOP.Path .. "/Lua/Scripts/configdata.lua")
end, 1)