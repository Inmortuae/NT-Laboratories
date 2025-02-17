NTL.ConfigData = {
    NTL_header1 = {name=NTL.Name,type="category"},

    NTL_Nil= {name="Nil",default=20,range={0,100},type="float", description="Nil" },
    RS_VanillaDMG = {
        name = "Vanilla Damage Patch",
        default = true,
        type = "bool",
        description = "Enables standard afflictions without requiring Neurotrauma. If enabled With Neurotrauma, vanilla afflictions will be disabled.",
    },
    NTRS = {
        name = "Neurotrauma Patch",
        default = false,
        type = "bool",
        description = "Enables standard afflictions and afflictions from Neurotrauma. Includes vanilla afflictions unless vanilla damage patch is enabled.",
    },
    NTCRS = {
        name = "Cybernetics Enhanced Patch",
        default = false,
        type = "bool",
        description = "Allows the saving of Cyberlimbs and Cyberorgans.",
    },
    NTERS = {
        name = "Neurotrauma Eyes Patch",
        default = false,
        type = "bool",
        description = "Allows the saving of Positive Neurotrauma Eye afflictions. I.e. Implanted Eyes.",
    },
    NTLRS = {
        name = "Neurotrauma Removed Limb Patch",
        default = false,
        type = "bool",
        description = "Allows the saving of removed limbs. If Neurotrauma Eyes Patch is enabled, Neurotrauma Eye negative afflictions will be saved.",
    },
    FD = {
        name = "Instant Revive Patch",
        default = false,
        type = "bool",
        description = "Removes injuries upon revival when using the Revive Serum. Do not use alongside Neurotrauma Patch or Vanilla Damage.",
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