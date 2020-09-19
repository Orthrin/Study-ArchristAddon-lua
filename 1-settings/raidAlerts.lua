----------------------------------------------------------------------------------------------------------
local A, L, V, P, G = unpack(select(2, ...)); -- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
----------------------------------------------------------------------------------------------------------
--[[
    --!! In use by CRIndicator
        Class {Spell{ID,cd}}

]]

Arch_raidAlerts = {
    ["community"] = {
        ["discord"] = "If you like to be informed about further runs please join https://discord.gg/wQTEexv ",
        ["guild"] = "If you like to be informed about further runs or join guild https://discord.gg/wQTEexv ",
    },
    ["vc"] = {
        ["voluntary"] = "Voice Comms is not mandatory but easing stuff to join: https://discord.gg/wQTEexv",
        ["mandatory"] = "Please join: https://discord.gg/wQTEexv",
    },
    ["lootrules"] = {
        ["loot"] = "Loot Rules: Armor/Stat Prio & MS > OS ",
        ["voa"] = "Loot Rules: Armor Prio & MS > OS & PvP Roll MS Prio if not indicated otherwise",
        ["toc"] = "Loot Rules: Armor/Stat Prio & MS > OS ",
        ["onetrophy"] = 'You could have only one trophy to distribute loot more justly',
        ["warning"] = "Rolling item for selling is forbidden will result you to ban for further raids",
        ["twoboss"] = "This is two boss raid, if you are going to leave after first one you'll not be invited in the future",
    },
}
