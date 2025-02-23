NTL.ConfigData = {
    NTL_header1 = {name=NTL.Name,type="category"},

    NTCyb_waterDamage = {name="Cyberlimb Water Damage",default=1,range={0,5},type="float", difficultyCharacteristics={multiplier=0.5,max=2}},
    NTCyb_cyberpsychosisChance = {name="Cyberpsychosis Chance",default=1,range={0,1},type="float", difficultyCharacteristics={multiplier=0.5,max=2}},
    NTCyb_cyberarmSpeed = {name="Cyberarm Speed Increase",default=1,range={0,2},type="float", difficultyCharacteristics={multiplier=0.5,max=2}},
    NTCyb_cyberlegSpeed = {name="Cyberleg Speed Increase",default=1,range={0,2},type="float", difficultyCharacteristics={multiplier=0.5,max=2}},
    TraumaSaw = {
        name = "Traumatic Amputation",
        default = true,
        type = "bool",
        description = "Enables the ability to perform traumatic amputations using a saw. When enabled, the saw can be used to forcibly amputate limbs, causing significant damage and bleeding.",
    },
    RS_Affliction = {
        name = "Revive Affliction",
        default = true,
        type = "bool",
        description = "Applies a custom affliction that makes the Revive Serum only work on characters without the affliction, restricting revival for affected individuals. Does not affect Nanobots.",
    },
    NOREV = {
        name = "No Revive",
        default = true,
        type = "bool",
        description = "Prevents revival in cases of severe injuries such as extreme blood loss, gunshot wounds above a fatal threshold, pressure injuries, or missing vital limbs (e.g., head).",
    },
}
NTConfig.AddConfigOptions(NTL)