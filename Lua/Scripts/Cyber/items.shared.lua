NTL.AllowInHealthInterface = {
	-- general compatability if anything has a higher mod load order than us
	"crowbar",
	"screwdriver",
	"repairpack",
	"steel",
	"fpgacircuit",
	-- Immersive Repairs compatibility
	"weldingtool",
	"weldingstinger",
	"halligantool",
	-- EK Mods compatibility
	"ekutility_metalfoam_gun",
	"ekutility_hullrepairkit",
	"ekutility_arcwelder",
	-- Baroverhaul compatibility
	"tadementoniteweldingtool",
}

local function evaluateExtraUseInHealthInterface()
	LuaUserData.MakeMethodAccessible(Descriptors["Barotrauma.ItemPrefab"], "set_UseInHealthInterface")
	for _, tool in ipairs(NTL.AllowInHealthInterface) do
		if ItemPrefab.Prefabs.ContainsKey(tool) then
			ItemPrefab.Prefabs[tool].set_UseInHealthInterface(true)
		end
	end
end

-- todo: can we move these into a new type of xml file?
NTL.ExtraSkillRequirementHints = {
	[[
        <ExtraSkillRequirementHints identifier="steel">
            <SkillRequirementHint identifier="mechanical" level="60" />
        </ExtraSkillRequirementHints>
    ]],
	[[
        <ExtraSkillRequirementHints identifier="fpgacircuit">
            <SkillRequirementHint identifier="electrical" level="40" />
        </ExtraSkillRequirementHints>
    ]],
	[[
        <ExtraSkillRequirementHints identifier="screwdriver">
            <SkillRequirementHint identifier="mechanical" level="40" />
        </ExtraSkillRequirementHints>
    ]],
	[[
        <ExtraSkillRequirementHints identifier="screwdriverhardened">
            <SkillRequirementHint identifier="mechanical" level="40" />
        </ExtraSkillRequirementHints>
    ]],
	[[
        <ExtraSkillRequirementHints identifier="screwdriverdementonite">
            <SkillRequirementHint identifier="mechanical" level="40" />
        </ExtraSkillRequirementHints>
    ]],
	[[
        <ExtraSkillRequirementHints identifier="weldingtool">
            <SkillRequirementHint identifier="mechanical" level="50" />
        </ExtraSkillRequirementHints>
    ]],
	[[
        <ExtraSkillRequirementHints identifier="weldingstinger">
            <SkillRequirementHint identifier="mechanical" level="50" />
        </ExtraSkillRequirementHints>
    ]],
	[[
        <ExtraSkillRequirementHints identifier="repairpack">
            <SkillRequirementHint identifier="mechanical" level="40" />
            <SkillRequirementHint identifier="medical" level="60"/>
        </ExtraSkillRequirementHints>
    ]],
	[[
        <ExtraSkillRequirementHints identifier="ekutility_metalfoam_gun">
            <SkillRequirementHint identifier="mechanical" level="60" />
        </ExtraSkillRequirementHints>
    ]],
	[[
        <ExtraSkillRequirementHints identifier="ekutility_hullrepairkit">
            <SkillRequirementHint identifier="mechanical" level="60" />
        </ExtraSkillRequirementHints>
    ]],
	[[
        <ExtraSkillRequirementHints identifier="ekutility_arcwelder">
            <SkillRequirementHint identifier="mechanical" level="50" />
        </ExtraSkillRequirementHints>
    ]],
	[[
        <ExtraSkillRequirementHints identifier="tadementoniteweldingtool">
            <SkillRequirementHint identifier="mechanical" level="50" />
        </ExtraSkillRequirementHints>
    ]],
}

local function addNullableImmutableArrayElements(builder, array)
	local success, length = pcall(function()
		return array.Length -- this throws (making pcall return false) if the array is null, and I can't find a better way to check for null
	end)
	if success then
		for i = 0, length - 1 do
			if not builder.Contains(array[i]) then
				builder.Add(array[i])
			end
		end
	end
end
local function evaluateExtraSkillRequirementHints()
	if CLIENT then
		LuaUserData.RegisterType(
			"System.Collections.Immutable.ImmutableArray`1[[Barotrauma.SkillRequirementHint,Barotrauma]]"
		)
		LuaUserData.RegisterType(
			"System.Collections.Immutable.ImmutableArray`1+Builder[[Barotrauma.SkillRequirementHint,Barotrauma]]"
		)
	elseif SERVER then
		LuaUserData.RegisterType(
			"System.Collections.Immutable.ImmutableArray`1[[Barotrauma.SkillRequirementHint,DedicatedServer]]"
		)
		LuaUserData.RegisterType(
			"System.Collections.Immutable.ImmutableArray`1+Builder[[Barotrauma.SkillRequirementHint,DedicatedServer]]"
		)
	end

	LuaUserData.RegisterType("Barotrauma.SkillRequirementHint")
	SkillRequirementHint = LuaUserData.CreateStatic("Barotrauma.SkillRequirementHint")
	LuaUserData.MakeMethodAccessible(Descriptors["Barotrauma.ItemPrefab"], "set_SkillRequirementHints")

	for _, xml in ipairs(NTL.ExtraSkillRequirementHints) do
		local xdoc = XDocument.Parse(xml)
		local itemIdentifier = xdoc.Root.GetAttributeString("identifier")
		if ItemPrefab.Prefabs.ContainsKey(itemIdentifier) then
			local item = ItemPrefab.Prefabs[itemIdentifier]
			local skillReqsBuilder = nil
			if item.get_SkillRequirementHints().IsDefaultOrEmpty then
				skillReqsBuilder = item.get_SkillRequirementHints().Empty.ToBuilder()
			else
				skillReqsBuilder = item.get_SkillRequirementHints().ToBuilder()
			end

			--addNullableImmutableArrayElements(skillReqsBuilder, item.get_SkillRequirementHints())

			for element in xdoc.Root.Elements() do
				local skillReq = SkillRequirementHint.__new(ContentXElement(item.ContentPackage, element))
				if not skillReqsBuilder.Contains(skillReq) then
					skillReqsBuilder.Add(skillReq)
				end
			end
			item.set_SkillRequirementHints(skillReqsBuilder.ToImmutable())
		end
	end
end

NTL.ExtraTreatmentSuitability = {
	[[
        <ExtraTreatmentSuitability identifier="steel">
            <SuitableTreatment identifier="ntc_materialloss" suitability="50"/>
        </ExtraTreatmentSuitability>
    ]],
	[[
        <ExtraTreatmentSuitability identifier="fpgacircuit">
            <SuitableTreatment identifier="ntc_damagedelectronics" suitability="50"/>
        </ExtraTreatmentSuitability>
    ]],
	[[
        <ExtraTreatmentSuitability identifier="screwdriver">
            <SuitableTreatment identifier="ntc_loosescrews" suitability="50"/>
        </ExtraTreatmentSuitability>
    ]],
	[[
        <ExtraTreatmentSuitability identifier="screwdriverhardened">
            <SuitableTreatment identifier="ntc_loosescrews" suitability="50"/>
        </ExtraTreatmentSuitability>
    ]],
	[[
        <ExtraTreatmentSuitability identifier="screwdriverdementonite">
            <SuitableTreatment identifier="ntc_loosescrews" suitability="50"/>
        </ExtraTreatmentSuitability>
    ]],
	[[
        <ExtraTreatmentSuitability identifier="weldingtool">
            <SuitableTreatment identifier="ntc_bentmetal" suitability="50"/>
        </ExtraTreatmentSuitability>
    ]],
	[[
        <ExtraTreatmentSuitability identifier="repairpack">
            <SuitableTreatment identifier="ntc_loosescrews" suitability="50"/>
            <SuitableTreatment identifier="dislocation1" suitability="50"/>
            <SuitableTreatment identifier="dislocation2" suitability="50"/>
            <SuitableTreatment identifier="dislocation3" suitability="50"/>
            <SuitableTreatment identifier="dislocation4" suitability="50"/>
        </ExtraTreatmentSuitability>
    ]],
	[[
        <ExtraTreatmentSuitability identifier="weldingstinger">
            <SuitableTreatment identifier="ntc_bentmetal" suitability="50"/>
        </ExtraTreatmentSuitability>
    ]],
	[[
        <ExtraTreatmentSuitability identifier="ekutility_metalfoam_gun">
            <SuitableTreatment identifier="ntc_materialloss" suitability="50"/>
        </ExtraTreatmentSuitability>
    ]],
	[[
        <ExtraTreatmentSuitability identifier="ekutility_hullrepairkit">
            <SuitableTreatment identifier="ntc_materialloss" suitability="50"/>
        </ExtraTreatmentSuitability>
    ]],
	[[
        <ExtraTreatmentSuitability identifier="ekutility_arcwelder">
            <SuitableTreatment identifier="ntc_bentmetal" suitability="50"/>
        </ExtraTreatmentSuitability>
    ]],
	[[
        <ExtraTreatmentSuitability identifier="tadementoniteweldingtool">
            <SuitableTreatment identifier="ntc_materialloss" suitability="50"/>
        </ExtraTreatmentSuitability>
    ]],
}

local function evaluateExtraTreatmentSuitability()
	LuaUserData.MakeFieldAccessible(Descriptors["Barotrauma.ItemPrefab"], "treatmentSuitability")

	local wasAlreadyRegistered = LuaUserData.IsRegistered(
		"System.Collections.Immutable.ImmutableDictionary`2[[Barotrauma.Identifier,BarotraumaCore],[System.Single,mscorlib]]"
	)

	if not wasAlreadyRegistered then
		LuaUserData.RegisterType(
			"System.Collections.Immutable.ImmutableDictionary`2[[Barotrauma.Identifier,BarotraumaCore],[System.Single,mscorlib]]"
		)
		LuaUserData.RegisterType(
			"System.Collections.Immutable.ImmutableDictionary`2+Builder[[Barotrauma.Identifier,BarotraumaCore],[System.Single,mscorlib]]"
		)
	end

	for _, xml in ipairs(NTL.ExtraTreatmentSuitability) do
		local xdoc = XDocument.Parse(xml)
		local itemIdentifier = xdoc.Root.GetAttributeString("identifier")
		if ItemPrefab.Prefabs.ContainsKey(itemIdentifier) then
			local item = ItemPrefab.Prefabs[itemIdentifier]
			local dictBuilder = item.treatmentSuitability.ToBuilder()
			for element in xdoc.Root.Elements() do
				dictBuilder.Add(
					Identifier(element.GetAttributeString("identifier")),
					Single(element.GetAttributeString("suitability")).Value
				)
			end
			item.treatmentSuitability = dictBuilder.ToImmutable()
			item.set_UseInHealthInterface(true)
		end
	end
	-- unregister for compatability, as when unregistered these will be converted into lua tables, and eg. BetterFabricatorUI expects that
	if not wasAlreadyRegistered then
		LuaUserData.UnregisterType(
			"System.Collections.Immutable.ImmutableDictionary`2+Builder[[Barotrauma.Identifier,BarotraumaCore],[System.Single,mscorlib]]"
		)
		LuaUserData.UnregisterType(
			"System.Collections.Immutable.ImmutableDictionary`2[[Barotrauma.Identifier,BarotraumaCore],[System.Single,mscorlib]]"
		)
	end
end

local function addCyberOrgansToSuperSoldiersTalent()
	if not TalentPrefab.TalentPrefabs.ContainsKey("supersoldiers") then
		return
	end
	local supersoldiersTalent = TalentPrefab.TalentPrefabs["supersoldiers"]
	local xmlDefinition = [[
        <overwrite>
            <AddedRecipe itemidentifier="cyberliver" />
            <AddedRecipe itemidentifier="cyberkidney" />
            <AddedRecipe itemidentifier="cyberlung" />
            <AddedRecipe itemidentifier="cyberheart" />
            <AddedRecipe itemidentifier="cyberbrain" />
        </overwrite>
    ]]
	local xml = XDocument.Parse(xmlDefinition)
	for element in xml.Root.Elements() do
		supersoldiersTalent.ConfigElement.Element.Add(element)
	end

	for descNode in supersoldiersTalent.ConfigElement.GetChildElements("Description") do
		if descNode.GetAttributeString("tag") == "talentdescription.unlockrecipe" then
			for replaceTag in descNode.Elements() do
				replaceTag.SetAttributeValue(
					"value",
					replaceTag.GetAttributeString("value")
						.. ",entityname.cyberliver,entityname.cyberkidney,entityname.cyberlung,entityname.cyberheart,entityname.cyberbrain"
				)
				break
			end
		end
	end
	while TalentPrefab.TalentPrefabs.ContainsKey("supersoldiers") do
		-- remove all existing versions of this talent (including overrides), as we're going to add a new combined one on top
		TalentPrefab.TalentPrefabs.Remove(TalentPrefab.TalentPrefabs["supersoldiers"])
	end
	TalentPrefab.TalentPrefabs.Add(
		TalentPrefab.__new(supersoldiersTalent.ConfigElement, supersoldiersTalent.ContentFile),
		false
	)
end

local function patchDamageWeldingTool(itemId)
	if not ItemPrefab.Prefabs.ContainsKey(itemId) then
		return
	end
	local itemPrefab = ItemPrefab.Prefabs[itemId]

	local targetElement = nil
	for subElement in itemPrefab.ConfigElement.Elements() do
		if subElement.Name.ToString() == "RepairTool" then
			targetElement = subElement
			break
		end
	end
	if targetElement == nil then
		return
	end

	local targetEffect = nil
	for effect in targetElement.GetChildElements("StatusEffect") do
		if
			effect.GetAttribute("targettype")
			and string.lower(effect.GetAttributeString("targettype") or "") == "limb"
			and string.lower(effect.GetAttributeString("targetlimb") or "") ~= "head"
		then
			targetEffect = effect
			break
		end
	end
	if targetEffect == nil then
		return
	end

	local afflictions = { "cyberarm", "cyberleg" }
	for affliction in afflictions do
		local conditionalString = "<Conditional " .. affliction .. '="0"/>'
		local conditionalElement = XElement.Parse(conditionalString)
		local conditionalContentElement = ContentXElement(targetEffect.contentPackage, conditionalElement)
		targetEffect.Add(conditionalContentElement)
	end
	targetEffect.SetAttributeValue("comparison", "And")
end

local function addCyberWorkbenchToRoboticsTalent()
	if not TalentPrefab.TalentPrefabs.ContainsKey("robotics") then
		return
	end
	local roboticsTalent = TalentPrefab.TalentPrefabs["robotics"]
	local xmlDefinition = [[
        <overwrite>
            <AddedRecipe itemidentifier="cyberbench" />
        </overwrite>
    ]]
	local xml = XDocument.Parse(xmlDefinition)
	for element in xml.Root.Elements() do
		roboticsTalent.ConfigElement.Element.Add(element)
	end

	for descNode in roboticsTalent.ConfigElement.GetChildElements("Description") do
		if descNode.GetAttributeString("tag") == "talentdescription.unlockrecipe" then
			for replaceTag in descNode.Elements() do
				replaceTag.SetAttributeValue(
					"value",
					replaceTag.GetAttributeString("value") .. ",entityname.cyberbench"
				)
				break
			end
		end
	end
	while TalentPrefab.TalentPrefabs.ContainsKey("robotics") do
		-- remove all existing versions of this talent (including overrides), as we're going to add a new combined one on top
		TalentPrefab.TalentPrefabs.Remove(TalentPrefab.TalentPrefabs["robotics"])
	end
	TalentPrefab.TalentPrefabs.Add(TalentPrefab.__new(roboticsTalent.ConfigElement, roboticsTalent.ContentFile), false)
end

local function addRevivesToMiracleWorker()
	if not TalentPrefab.TalentPrefabs.ContainsKey("miracleworker") then
		return
	end
	local miracleworkerTalent = TalentPrefab.TalentPrefabs["miracleworker"]
	local xmlDefinition = [[
        <overwrite>
            <AddedRecipe itemidentifier="revive_syringe" />
            <AddedRecipe itemidentifier="nanobots" />
            <AddedRecipe itemidentifier="brainjar" />
            <AddedRecipe itemidentifier="mannitolplus" />
        </overwrite>
    ]]
	local xml = XDocument.Parse(xmlDefinition)
	for element in xml.Root.Elements() do
		miracleworkerTalent.ConfigElement.Element.Add(element)
	end
	local xmlDefinitionRecipes = [[
        <overwrite>
        <Description tag="talentdescription.unlockrecipe">
            <Replace tag="[itemname]" value="entityname.revive_syringe,entityname.nanobots,entityname.brainjar,entityname.mannitolplus" color="gui.orange" />
        </Description>
        </overwrite>
        ]]
	local xml = XDocument.Parse(xmlDefinitionRecipes)
	for element in xml.Root.Elements() do
		miracleworkerTalent.ConfigElement.Element.Add(element)
	end

	while TalentPrefab.TalentPrefabs.ContainsKey("miracleworker") do
		-- remove all existing versions of this talent (including overrides), as we're going to add a new combined one on top
		TalentPrefab.TalentPrefabs.Remove(TalentPrefab.TalentPrefabs["miracleworker"])
	end
	TalentPrefab.TalentPrefabs.Add(
		TalentPrefab.__new(miracleworkerTalent.ConfigElement, miracleworkerTalent.ContentFile),
		false
	)
end

local function addCentrifugeToBloodyBusinessTalent()
	if not TalentPrefab.TalentPrefabs.ContainsKey("bloodybusiness") then
		return
	end
	local bloodybusinessTalent = TalentPrefab.TalentPrefabs["bloodybusiness"]
	local xmlDefinition = [[
        <overwrite>
            <AddedRecipe itemidentifier="centrifugestation" />
        </overwrite>
    ]]
	local xml = XDocument.Parse(xmlDefinition)
	for element in xml.Root.Elements() do
		bloodybusinessTalent.ConfigElement.Element.Add(element)
	end
	local existscsrecipe = false
	for descNode in bloodybusinessTalent.ConfigElement.GetChildElements("Description") do
		if descNode.GetAttributeString("tag") == "talentdescription.unlockrecipe" then
			for replaceTag in descNode.Elements() do
				replaceTag.SetAttributeValue(
					"value",
					replaceTag.GetAttributeString("value") .. ",entityname.centrifugestation"
				)
				existscsrecipe = true
				break
			end
		end
	end
	if existscsrecipe == false then
		local xmlDefinitionRecipes = [[
            <overwrite>
            <Description tag="talentdescription.unlockrecipe">
                <Replace tag="[itemname]" value="entityname.centrifugestation" color="gui.orange" />
            </Description>
            </overwrite>
        ]]
		local xml = XDocument.Parse(xmlDefinitionRecipes)
		for element in xml.Root.Elements() do
			bloodybusinessTalent.ConfigElement.Element.Add(element)
		end
	end
	while TalentPrefab.TalentPrefabs.ContainsKey("bloodybusiness") do
		-- remove all existing versions of this talent (including overrides), as we're going to add a new combined one on top
		TalentPrefab.TalentPrefabs.Remove(TalentPrefab.TalentPrefabs["bloodybusiness"])
	end
	TalentPrefab.TalentPrefabs.Add(
		TalentPrefab.__new(bloodybusinessTalent.ConfigElement, bloodybusinessTalent.ContentFile),
		false
	)
end

local function addBioToGeneticGeniousTalent()
	if not TalentPrefab.TalentPrefabs.ContainsKey("geneticgenious") then
		return
	end
	local geneticgeniousTalent = TalentPrefab.TalentPrefabs["geneticgenious"]
	local xmlDefinition = [[
        <overwrite>
            <AddedRecipe itemidentifier="geneextractor" />
            <AddedRecipe itemidentifier="stemcellprocessor" />
            <AddedRecipe itemidentifier="bioprinter" />
        </overwrite>
    ]]
	local xml = XDocument.Parse(xmlDefinition)
	for element in xml.Root.Elements() do
		geneticgeniousTalent.ConfigElement.Element.Add(element)
	end

	for descNode in geneticgeniousTalent.ConfigElement.GetChildElements("Description") do
		if descNode.GetAttributeString("tag") == "talentdescription.unlockrecipe" then
			for replaceTag in descNode.Elements() do
				replaceTag.SetAttributeValue(
					"value",
					replaceTag.GetAttributeString("value")
						.. ",entityname.geneextractor,entityname.stemcellprocessor,entityname.bioprinter"
				)
				break
			end
		end
	end
	while TalentPrefab.TalentPrefabs.ContainsKey("geneticgenious") do
		-- remove all existing versions of this talent (including overrides), as we're going to add a new combined one on top
		TalentPrefab.TalentPrefabs.Remove(TalentPrefab.TalentPrefabs["geneticgenious"])
	end
	TalentPrefab.TalentPrefabs.Add(
		TalentPrefab.__new(geneticgeniousTalent.ConfigElement, geneticgeniousTalent.ContentFile),
		false
	)
end

local function addChemmasterToMacroDosingTalent()
	if not TalentPrefab.TalentPrefabs.ContainsKey("macrodosing") then
		return
	end
	local macrodosingTalent = TalentPrefab.TalentPrefabs["macrodosing"]
	local xmlDefinition = [[
        <overwrite>
            <AddedRecipe itemidentifier="chemmaster" />
        </overwrite>
    ]]
	local xml = XDocument.Parse(xmlDefinition)
	for element in xml.Root.Elements() do
		macrodosingTalent.ConfigElement.Element.Add(element)
	end

	for descNode in macrodosingTalent.ConfigElement.GetChildElements("Description") do
		if descNode.GetAttributeString("tag") == "talentdescription.unlockrecipe" then
			for replaceTag in descNode.Elements() do
				replaceTag.SetAttributeValue(
					"value",
					replaceTag.GetAttributeString("value") .. ",entityname.chemmaster"
				)
				break
			end
		end
	end
	while TalentPrefab.TalentPrefabs.ContainsKey("macrodosing") do
		-- remove all existing versions of this talent (including overrides), as we're going to add a new combined one on top
		TalentPrefab.TalentPrefabs.Remove(TalentPrefab.TalentPrefabs["macrodosing"])
	end
	TalentPrefab.TalentPrefabs.Add(
		TalentPrefab.__new(macrodosingTalent.ConfigElement, macrodosingTalent.ContentFile),
		false
	)
end

Timer.Wait(function()
	addCyberOrgansToSuperSoldiersTalent()
	addCyberWorkbenchToRoboticsTalent()
	addRevivesToMiracleWorker()
	addCentrifugeToBloodyBusinessTalent()
	addBioToGeneticGeniousTalent()
	addChemmasterToMacroDosingTalent()
	evaluateExtraUseInHealthInterface()
	evaluateExtraSkillRequirementHints()
	evaluateExtraTreatmentSuitability()
	patchDamageWeldingTool("weldingtool")
	patchDamageWeldingTool("weldingstinger")
	patchDamageWeldingTool("ekutility_arcwelder")
	patchDamageWeldingTool("ekutility_metalfoam_gun")
end, 1)
