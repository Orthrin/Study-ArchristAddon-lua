------------------------------------------------------------------------------------------------------------------------
-- Import: System, Locales, PrivateDB, ProfileDB, GlobalDB, PeopleDB, AlertColors AddonName
local A, L, V, P, G, C, R, M, N = unpack(select(2, ...));
local moduleName = 'Tactics';
local moduleAlert = M .. moduleName .. ": |r";
local module = A:GetModule(moduleName);
------------------------------------------------------------------------------------------------------------------------
-- ==== Variables
local boss = 'none';
local comms = '/p ';
--
local tacticDefault = {}
tacticDefault[1] = "{skull} Focus on [%t] {skull}"
tacticDefault[2] = '{square} Combat Res [%t] {square}'
tacticDefault[3] = '{circle} Heroism Now! {circle}'
tacticDefault[4] = '{triangle} Innervate Please {triangle}'
tacticDefault[5] = '{triangle} Innervate Please {triangle}'
tacticDefault[6] = '{triangle} Innervate Please {triangle}'
tacticDefault[8] = '{triangle} Innervate Please {triangle}'
tacticDefault[9] = '{triangle} Innervate Please {triangle}'
--
local tactics = {}
tactics[1] = ''
tactics[2] = ''
tactics[3] = ''
tactics[4] = ''
tactics[5] = ''
tactics[6] = ''
tactics[7] = ''
tactics[8] = ''

--
local fixArgs = Arch_fixArgs
local focus = Arch_focusColor
--

-- ==== Start
function module:Initialize()
    self.initialized = true

    if A.global.comms == nil then A.global.comms = '/p ' end
    --
    if A.global.tactics == nil then
        A.global.tactics = {
            tacticDefault[1], tacticDefault[2], tacticDefault[3],
            tacticDefault[4], tacticDefault[5], tacticDefault[6],
            tacticDefault[7], tacticDefault[8]
        }
    end
    --
    tactics[1] = A.global.tactics[1]
    tactics[2] = A.global.tactics[2]
    tactics[3] = A.global.tactics[3]
    tactics[4] = A.global.tactics[4]
    tactics[5] = A.global.tactics[5]
    tactics[6] = A.global.tactics[6]
    tactics[7] = A.global.tactics[7]
    tactics[8] = A.global.tactics[8]
    --
    comms = A.global.comms
    --
    -- Arch_callTactics()
    -- :: Register some events
end

-- :: sets raid warning
function Arch_callTactics()
    for ii = 1, 8 do
        if (tactics[ii] ~= '') then
            SendChatMessage(tactics[ii], "raid", nil, nil)
        end
    end
end

-- :: selecting boss via slash command
local function selectBoss(boss)
    local target = boss
    if boss~='' then
        local firsti, lasti, command, value =
            string.find(boss, "(%w+) \"(.*)\"");
        if (command == nil) then
            firsti, lasti, command, value = string.find(boss, "(%w+) (%w+)");
        end
        if (command == nil) then
            firsti, lasti, command = string.find(boss, "(%w+)");
        end
        -- :: komut varsa
        if (command ~= nil) then command = string.lower(command); end
        --
        -- :: Dungeons
        if (command == "skadi") then
            tactics[1] = focus('mdps') .. 'Kill the snobolds as they spawn'
            tactics[2] = '{triangle} LEFT {triangle}'
            tactics[3] = '{triangle} RIGHT {triangle}'
            tactics[4] = '{triangle} Use Harpoons {triangle}'
            tactics[5] = ''
            tactics[6] = ''
            tactics[7] = ''
            tactics[8] = ''
            --
            -- :: ToC
        elseif (command == "beasts") then
            tactics[1] = '1- Do not stand in fire'
            tactics[2] = '2- If you got Snobold in your head get in melee range'
            tactics[3] = '3- DPS hardswitch on Snobold as soon as it in melee range'
            tactics[4] = '4- [Shaman] Hero at first Charge'
            tactics[5] = '5'
            tactics[6] = '6'
            tactics[7] = '7'
            tactics[8] = '8'
            --
        elseif (command == "jarraxus") then
            tactics[1] = '1- [Interrupter] Interrupt Jarraxus\'s cast'
            tactics[2] = '2- Hardswitch on adds as soon as they spawn'
            tactics[3] = '3- [Mage] Steal Nether Power buff from Jarraxus with haste'
            tactics[4] = ''
            tactics[5] = ''
            tactics[6] = ''
            tactics[7] = ''
            tactics[8] = ''
            --
        elseif (command == "faction") then
            tactics[1] = '1- [Warlock] Banish/Fear Druid Healer'
            tactics[2] = '2- [Paladin] Turn evil warlock\'s pet'
            tactics[3] = '3- [Mage] Poly Paladin'
            tactics[4] = '4- [MT] keep warrior/dk away from raid'
            tactics[5] = ''
            tactics[6] = ''
            tactics[7] = ''
            tactics[8] = ''
            --
        elseif (command == "valkyr") then
            tactics[1] = '1- [Interrupter] Interrupt Jarraxus\'s cast'
            tactics[2] = '2- Hardswitch on adds as soon as they spawn'
            tactics[3] = '3- [Mage] Steal Nether Power buff from Jarraxus with haste'
            tactics[4] = ''
            tactics[5] = ''
            tactics[6] = ''
            tactics[7] = ''
            tactics[8] = ''
            --
        elseif (command == "anubarak") then
            tactics[1] = '1- [Interrupter] Interrupt Jarraxus\'s cast'
            tactics[2] = '2- Hardswitch on adds as soon as they spawn'
            tactics[3] = '3- [Mage] Steal Nether Power buff from Jarraxus with haste'
            tactics[4] = ''
            tactics[5] = ''
            tactics[6] = ''
            tactics[7] = ''
            tactics[8] = ''
            --
        else
            tactics[1] = ''
            tactics[2] = ''
            tactics[3] = ''
            tactics[4] = ''
            tactics[5] = ''
            tactics[6] = ''
            tactics[7] = ''
            tactics[8] = ''
            target = 'none'
        end
        SELECTED_CHAT_FRAME:AddMessage(moduleAlert .. 'Tactics for ' .. focus(target))
    else
        Arch_callTactics()
    end
end

-- -- ==== End
-- Arch_callTactics();
local function InitializeCallback() module:Initialize() end
A:RegisterModule(module:GetName(), InitializeCallback)

-- ==== Slash Handlers
SLASH_Tactics1 = "/tact"
SlashCmdList["Tactics"] = function(boss) selectBoss(boss) end

-- ==== Example Usage [last arg]
--[[
/click WarnButton1;  
/click WarnButton2; 
/click WarnButton3; 
/click WarnButton4; 
--]]