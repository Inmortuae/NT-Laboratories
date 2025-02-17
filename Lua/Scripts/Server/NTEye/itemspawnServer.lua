NTL.ItemsSpawned=nil

--spawns items needed for special eyes at the beginning of the round
Hook.Add("roundStart", "SpawnEyeHUDItems", function()

	NTL.ItemsSpawned=nil
	NTL.SpawnEffectItems()
	
end)

--function to spawn HUD items, sometimes roundstart fucks up
--thats why this is being called multiple times in the code
--kind of a failsafe
function NTL.SpawnEffectItems()

	local itemprefab
	local SubPosition = Submarine.MainSub.WorldPosition
		
	itemprefab = ItemPrefab.GetItemPrefab("eyethermalHUDitem")
	Entity.Spawner.AddItemToSpawnQueue(itemprefab, SubPosition, nil, nil, nil, function(item) end)
		
	itemprefab = ItemPrefab.GetItemPrefab("eyemedicalHUDitem")
	Entity.Spawner.AddItemToSpawnQueue(itemprefab, SubPosition, nil, nil, nil, function(item) end)
		
	itemprefab = ItemPrefab.GetItemPrefab("eyeelectricalHUDitem")
	Entity.Spawner.AddItemToSpawnQueue(itemprefab, SubPosition, nil, nil, nil, function(item) end)
		
	NTL.ItemsSpawned=1
end


--Receive item spawn request from client
Networking.Receive("SendItemSpawnRequest", function(message, client)
	
	if NTL.ItemsSpawned==1 then return end
	
	NTL.SpawnEffectItems()
	--print("aidsbooger")
end)