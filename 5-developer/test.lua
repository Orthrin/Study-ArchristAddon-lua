-- ------------------------------------------------------------------------------------------------------------------------
-- -- :: Import: System, Locales, PrivateDB, ProfileDB, GlobalDB, PeopleDB, AlertColors AddonName
-- local A, L, V, P, G, C, M, N = unpack(select(2, ...));
-- local moduleName = 'test';
-- local moduleAlert = M .. moduleName .. ": |r";
-- local module = A:GetModule(moduleName);
-- ------------------------------------------------------------------------------------------------------------------------
-- -- ==== Variables

-- -- ==== Start
-- function module:Initialize()
--     self.initialized = true
--     -- :: Register some events
--     -- module:RegisterEvent("CHAT_MSG_SAY");
-- end

-- -- ==== Methods
-- local function Archrist_PlayerDB_getRaidScore()
--     if GearScore_GetScore(Name, "mouseover") then
--         local Name = GameTooltip:GetUnit();
--         if A.people[Name] then
--             local gearScore = GearScore_GetScore(Name, "mouseover")
--             if gearScore and gearScore > 0 then
--                 local personalData = Archrist_PlayerDB_calcRaidScore(Name)
--                 -- local note = Archrist_PlayerDB_getNote(Name)
--                 local raidScore = gearScore + personalData
--                 if gearScore ~= raidScore then
--                     GameTooltip:AddLine('RaidScore: ' .. raidScore, 0, 78, 100)
--                 end
--             end
--         end
--     end
-- end

-- local function handleCommand() print('test') end

-- -- ==== Event Handlers
-- function module:CHAT_MSG_SAY()
--     -- print('test')
-- end

-- -- ==== Slash Handlersd
-- -- SLASH_test1 = "/test"
-- -- SlashCmdList["test"] = function() handleCommand() end

-- -- -- ==== GUI
-- GameTooltip:HookScript("OnTooltipSetUnit", Archrist_PlayerDB_getRaidScore)

-- -- -- ==== End
-- local function InitializeCallback() module:Initialize() end
-- A:RegisterModule(module:GetName(), InitializeCallback)

-- -- ==== Todo

-- -- ==== UseCase
