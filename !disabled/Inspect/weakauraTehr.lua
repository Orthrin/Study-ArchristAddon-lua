function (event, arg1, eventType, arg2, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool)
    
    local parentName = WeakAurasSaved.displays[WeakAuras.regions[aura_env.id].region:GetParent().id]
    if (parentName["TehrsRaidCDs"] == nil) then parentName["TehrsRaidCDs"] = {} end    
    if (parentName["TehrsRaidCDs"]["Show Settings"] == nil) then parentName["TehrsRaidCDs"]["Show Settings"] = {} end
    if (parentName["TehrsRaidCDs"]["Custom Abilities"] == nil) then parentName["TehrsRaidCDs"]["Custom Abilities"] = {} end    
    local TehrsCDs = parentName["TehrsRaidCDs"]        
    
    if (event == "TehrsCDs_DEBUGTOGGLE") then -- /script WeakAuras.ScanEvents("TehrsCDs_DEBUGTOGGLE")
        TehrsCDs.DEBUG = not TehrsCDs.DEBUG
        print("|cFF00A2E8Tehr's RaidCDs:|r Debugging is now "..( TehrsCDs.DEBUG and "|cFF00FF00ENABLED|r" or "|cFFFF0000DISABLED|r" ).."\nNote that you need to enable either TehrsCDs.DEBUG_Engine or TehrsCDs.DEBUG_GroupPoll in their respective On Init to get debug results")
        
        
        -- This allows you to reset all settings and repopulate with the default settings
        -- USE WITH CAUTION --
    elseif (event == "TehrsCDs_RESETGROUP") then -- /script WeakAuras.ScanEvents("TehrsCDs_RESETGROUP")
        if InCombatLockdown() == false then
            parentName["TehrsRaidCDs"] = nil
            ReloadUI()        
        else
            print("|cFF00A2E8Tehr's RaidCDs:|r Aborting command\nPlease leave combat before initiating this command")
        end
        
    elseif (event == "TehrsCDs_ShowAll") then -- /script WeakAuras.ScanEvents("TehrsCDs_ShowAll")
        TehrsCDs["Show Settings"].allExterns = true
        TehrsCDs["Show Settings"].allCDs = true
        TehrsCDs["Show Settings"].allUtility = true
        TehrsCDs["Show Settings"].allImmunityCDs = true
        TehrsCDs["Show Settings"].allAoECCs = true
        TehrsCDs["Show Settings"].allInterrupts = true
        TehrsCDs["Show Settings"].allRezzes = true
        
        print("|cFF00A2E8Tehr's RaidCDs:|r All CDs are now |cFF00FF00ENABLED|r")   a 
        
    elseif (event == "TehrsCDs_ShowDisplay") then -- /script WeakAuras.ScanEvents("TehrsCDs_ShowDisplay")
        TehrsCDs.minmaxDisplays = true
        
        print("|cFF00A2E8Tehr's RaidCDs:|r Display is now |cFF00FF00ENABLED|r")          
        
    elseif event == "ENCOUNTER_START" then
        if arg1 then
            TehrsCDs.encounterStart = true
            if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: encounter start") end
        end
        
    elseif event == "ENCOUNTER_END" then
        if arg1 then
            TehrsCDs.encounterStart = false
            if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: encounter end") end
            if TehrsCDs.instanceType == "raid" then
                TehrsCDs._rezCDs_dks = nil
                TehrsCDs._rezCDs_druids = nil
                TehrsCDs._rezCDs_warlocks = nil    
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: in a raid, resetting brezzes") end
            end
        end   
        
    elseif event == "CHALLENGE_MODE_START" then
        TehrsCDs._rezCDs_dks = nil
        TehrsCDs._rezCDs_druids = nil
        TehrsCDs._rezCDs_warlocks = nil  
        if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: challenge mode start, resetting brezzes") end
    end       
    
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        --local arg1, eventType, arg2, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool = CombatLogGetCurrentEventInfo()    
        
        local function getPetOwner(petName, petGUID)
            local ownerName
            
            if UnitGUID("pet") == petGUID then
                ownerName = GetUnitName("player")
            elseif IsInRaid() then
                for i=1, GetNumGroupMembers() do
                    if UnitGUID("raid"..i.."pet") == petGUID then
                        ownerName = GetUnitName("raid"..i)
                        break
                    end
                end
            else
                for i=1, GetNumSubgroupMembers() do
                    if UnitGUID("party"..i.."pet") == petGUID then
                        ownerName = GetUnitName("party"..i)
                        break
                    end
                end
            end
            
            if ownerName then
                return ownerName
            else
                return petName
            end
        end     
        
        if (not UnitInParty(sourceName)) and (sourceName ~= UnitName("player")) then
            if not (UnitInParty(getPetOwner(sourceName,sourceGUID)) or UnitName("player") == getPetOwner(sourceName,sourceGUID)) then
                return false
            end
        end    
        
        aura_env.GADuration = aura_env.GADuration or 0 --initializes GADuration 
        aura_env.shockwavehits = aura_env.shockwavehits or 0 --initializes shockwavehits
        aura_env.captotemhits = aura_env.captotemhits or 0 --initializes captotemhits
        
        -- IMMUNITIES --
        if (TehrsCDs["Show Settings"].allImmunityCDs and TehrsCDs.instanceType ~= "raid" and GetNumGroupMembers()<20) or (TehrsCDs["Show Settings"].allImmunityCDs_inRaid and (TehrsCDs.instanceType == "raid" or GetNumGroupMembers()>19)) then                
            if(eventType == "SPELL_CAST_SUCCESS" and TehrsCDs["Show Settings"].Turtle and spellID == 186265) then
                -- Aspect of the Turtle --
                if (TehrsCDs._immunityCDs_hunters == nil) then TehrsCDs._immunityCDs_hunters = { } end
                if (TehrsCDs._immunityCDs_hunters[sourceName] == nil) then TehrsCDs._immunityCDs_hunters[sourceName] = { } end   
                
                local Turtle1 = TehrsCDs._immunityCDs_hunters[sourceName]["Turtle"];
                local Turtle2 = TehrsCDs._immunityCDs_hunters[sourceName]["Turtle+"];
                
                if (Turtle1 ~= nil) then
                    TehrsCDs._immunityCDs_hunters[sourceName]["Turtle"] = GetTime() + 180
                    TehrsCDs._immunityCDs_hunters[sourceName]["Turtle+"] = nil;
                end
                if (Turtle2 ~= nil) then
                    TehrsCDs._immunityCDs_hunters[sourceName]["Turtle+"] = GetTime() + 144
                    TehrsCDs._immunityCDs_hunters[sourceName]["Turtle"] = nil;
                end    
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end
                
            elseif(eventType == "SPELL_CAST_SUCCESS" and TehrsCDs["Show Settings"].Cloak and spellID == 31224) then
                -- Cloak of Shadows --
                if (TehrsCDs._immunityCDs_rogues == nil) then TehrsCDs._immunityCDs_rogues = { } end
                if (TehrsCDs._immunityCDs_rogues[sourceName] == nil) then TehrsCDs._immunityCDs_rogues[sourceName] = { } end   
                
                TehrsCDs._immunityCDs_rogues[sourceName]["Cloak"] = GetTime() + 120
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end       
                
            elseif(eventType == "SPELL_CAST_SUCCESS" and TehrsCDs["Show Settings"].Block and spellID == 45438) then
                -- Ice Block --
                if (TehrsCDs._immunityCDs_mages == nil) then TehrsCDs._immunityCDs_mages = { } end
                if (TehrsCDs._immunityCDs_mages[sourceName] == nil) then TehrsCDs._immunityCDs_mages[sourceName] = { } end   
                
                local Block1 = TehrsCDs._immunityCDs_mages[sourceName]["Block"];
                local Block2 = TehrsCDs._immunityCDs_mages[sourceName]["Block+"];
                
                if (Block1 ~= nil) then
                    TehrsCDs._immunityCDs_mages[sourceName]["Block"] = GetTime() + 240;
                    TehrsCDs._immunityCDs_mages[sourceName]["Block+"] = nil;
                end
                if (Block2 ~= nil) then
                    TehrsCDs._immunityCDs_mages[sourceName]["Block+"] = GetTime() + 240;
                    TehrsCDs._immunityCDs_mages[sourceName]["Block"] = nil;
                end      
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end      
                
            elseif(eventType == "SPELL_CAST_SUCCESS" and TehrsCDs["Show Settings"].Block and spellID == 235219) then
                -- Ice Block: COLD SNAP --
                if (TehrsCDs._immunityCDs_mages == nil) then TehrsCDs._immunityCDs_mages = { } end
                if (TehrsCDs._immunityCDs_mages[sourceName] == nil) then TehrsCDs._immunityCDs_mages[sourceName] = { } end   
                
                TehrsCDs._immunityCDs_mages[sourceName]["Block+"] = GetTime()     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(eventType == "SPELL_CAST_SUCCESS" and TehrsCDs["Show Settings"].Netherwalk and spellID == 196555) then
                -- Netherwalk --
                if (TehrsCDs._immunityCDs_dhs == nil) then TehrsCDs._immunityCDs_dhs = { } end
                if (TehrsCDs._immunityCDs_dhs[sourceName] == nil) then TehrsCDs._immunityCDs_dhs[sourceName] = { } end   
                
                TehrsCDs._immunityCDs_dhs[sourceName]["Netherwalk"] = GetTime() + 120;         
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(eventType == "SPELL_AURA_APPLIED" and TehrsCDs["Show Settings"].Bubble and spellID == 642) then
                -- Divine Shield --
                if (TehrsCDs._immunityCDs_paladins == nil) then TehrsCDs._immunityCDs_paladins = { } end
                if (TehrsCDs._immunityCDs_paladins[sourceName] == nil) then TehrsCDs._immunityCDs_paladins[sourceName] = { } end   
                
                local Bubble1 = TehrsCDs._immunityCDs_paladins[sourceName]["Bubble"]; 
                local Bubble2 = TehrsCDs._immunityCDs_paladins[sourceName]["Bubble+"]; 
                
                if (Bubble1 ~= nil) then
                    TehrsCDs._immunityCDs_paladins[sourceName]["Bubble"] = GetTime() + 300;
                    TehrsCDs._immunityCDs_paladins[sourceName]["Bubble+"] = nil;          
                end
                if (Bubble2 ~= nil) then
                    TehrsCDs._immunityCDs_paladins[sourceName]["Bubble+"] = GetTime() + 210;
                    TehrsCDs._immunityCDs_paladins[sourceName]["Bubble"] = nil;          
                end           
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end                  
            end    
        end    
        
        -- CROWD CONTROL --
        if (TehrsCDs["Show Settings"].allAoECCs and TehrsCDs.instanceType ~= "raid" and GetNumGroupMembers()<20) or (TehrsCDs["Show Settings"].allAoECCs_inRaid and (TehrsCDs.instanceType == "raid" or GetNumGroupMembers()>19)) then        
            if(spellID == 192058 and TehrsCDs["Show Settings"].CapTotem and eventType == "SPELL_CAST_SUCCESS") then
                -- Capacitor Totem --
                if (TehrsCDs._aoeCCs_shamans == nil) then TehrsCDs._aoeCCs_shamans = { } end        
                if (TehrsCDs._aoeCCs_shamans[sourceName] == nil) then TehrsCDs._aoeCCs_shamans[sourceName] = { } end
                
                local cap1 = TehrsCDs._aoeCCs_shamans[sourceName]["Cap Totem"];
                local cap2 = TehrsCDs._aoeCCs_shamans[sourceName]["Cap Totem+"];
                
                if (cap1 ~= nil) then
                    TehrsCDs._aoeCCs_shamans[sourceName]["Cap Totem"] = GetTime() + 60;
                    TehrsCDs._aoeCCs_shamans[sourceName]["Cap Totem+"] = nil;
                end
                if (cap2 ~= nil) then
                    TehrsCDs._aoeCCs_shamans[sourceName]["Cap Totem+"] = GetTime() + 60;
                    TehrsCDs._aoeCCs_shamans[sourceName]["Cap Totem"] = nil;
                end  
                aura_env.captotemhits = 0                 
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end   
                
            elseif(spellID == 118905 and TehrsCDs["Show Settings"].CapTotem and eventType == "SPELL_AURA_APPLIED") then
                -- Capacitor STUN --
                if (TehrsCDs._aoeCCs_shamans == nil) then TehrsCDs._aoeCCs_shamans = { } end        
                if (TehrsCDs._aoeCCs_shamans[sourceName] == nil) then TehrsCDs._aoeCCs_shamans[sourceName] = { } end
                
                local CapTotem1 = TehrsCDs._aoeCCs_shamans[sourceName]["Cap Totem+"];
                
                if CapTotem1 then
                    aura_env.captotemhits = aura_env.captotemhits + 1
                    if aura_env.captotemhits <= 4 then
                        TehrsCDs._aoeCCs_shamans[sourceName]["Cap Totem+"] = TehrsCDs._aoeCCs_shamans[sourceName]["Cap Totem+"] - 5
                        if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." hit with "..spellName) end 
                    end   
                end                            
                
            elseif(spellID == 51490 and TehrsCDs["Show Settings"].Thunderstorm and eventType == "SPELL_CAST_SUCCESS") then
                -- Thunderstorm --
                if (TehrsCDs._aoeCCs_shamans == nil) then TehrsCDs._aoeCCs_shamans = { } end        
                if (TehrsCDs._aoeCCs_shamans[sourceName] == nil) then TehrsCDs._aoeCCs_shamans[sourceName] = { } end
                
                TehrsCDs._aoeCCs_shamans[sourceName]["Thunderstorm"] = GetTime() + 45;      
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 30283 and TehrsCDs["Show Settings"].Shadowfury and eventType == "SPELL_CAST_SUCCESS") then
                -- Shadowfury --
                if (TehrsCDs._aoeCCs_warlocks == nil) then TehrsCDs._aoeCCs_warlocks = { } end        
                if (TehrsCDs._aoeCCs_warlocks[sourceName] == nil) then TehrsCDs._aoeCCs_warlocks[sourceName] = { } end
                
                local shadowfury1 = TehrsCDs._aoeCCs_warlocks[sourceName]["Shadowfury"];
                local shadowfury2 = TehrsCDs._aoeCCs_warlocks[sourceName]["Shadowfury+"];
                
                if (shadowfury1 ~= nil) then
                    TehrsCDs._aoeCCs_warlocks[sourceName]["Shadowfury"] = GetTime() + 60;
                    TehrsCDs._aoeCCs_warlocks[sourceName]["Shadowfury+"] = nil;
                end
                if (shadowfury2 ~= nil) then
                    TehrsCDs._aoeCCs_warlocks[sourceName]["Shadowfury+"] = GetTime() + 45;
                    TehrsCDs._aoeCCs_warlocks[sourceName]["Shadowfury"] = nil;
                end       
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end     
                
            elseif(spellID == 1122 and TehrsCDs["Show Settings"].Infernal and eventType == "SPELL_CAST_SUCCESS") then
                -- Summon Infernal --
                if (TehrsCDs._aoeCCs_warlocks == nil) then TehrsCDs._aoeCCs_warlocks = { } end        
                if (TehrsCDs._aoeCCs_warlocks[sourceName] == nil) then TehrsCDs._aoeCCs_warlocks[sourceName] = { } end
                
                TehrsCDs._aoeCCs_warlocks[sourceName]["Infernal"] = GetTime() + 180; 
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end                  
                
            elseif(eventType == "SPELL_CAST_SUCCESS" and TehrsCDs["Show Settings"].Grasp and spellID == 108199) then
                -- Gorefiend's Grasp --
                if (TehrsCDs._aoeCCs_dks == nil) then TehrsCDs._aoeCCs_dks = { } end
                if (TehrsCDs._aoeCCs_dks[sourceName] == nil) then TehrsCDs._aoeCCs_dks[sourceName] = { } end   
                
                local grasp1 = TehrsCDs._aoeCCs_dks[sourceName]["Grasp"];
                local grasp2 = TehrsCDs._aoeCCs_dks[sourceName]["Grasp+"];
                
                if (grasp1 ~= nil) then
                    TehrsCDs._aoeCCs_dks[sourceName]["Grasp"] = GetTime() + 120;
                    TehrsCDs._aoeCCs_dks[sourceName]["Grasp+"] = nil;
                end
                if (grasp2 ~= nil) then
                    TehrsCDs._aoeCCs_dks[sourceName]["Grasp+"] = GetTime() + 90;
                    TehrsCDs._aoeCCs_dks[sourceName]["Grasp"] = nil;
                end     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(eventType == "SPELL_CAST_SUCCESS" and TehrsCDs["Show Settings"].Chains and spellID == 202138) then
                -- Sigil of Chains --
                if (TehrsCDs._aoeCCs_dhs == nil) then TehrsCDs._aoeCCs_dhs = { } end
                if (TehrsCDs._aoeCCs_dhs[sourceName] == nil) then TehrsCDs._aoeCCs_dhs[sourceName] = { } end   
                
                TehrsCDs._aoeCCs_dhs[sourceName]["Chains"] = GetTime() + 90;     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 109248 and TehrsCDs["Show Settings"].Binding and eventType == "SPELL_CAST_SUCCESS") then
                -- Binding Shot --
                if (TehrsCDs._aoeCCs_hunters == nil) then TehrsCDs._aoeCCs_hunters = { } end        
                if (TehrsCDs._aoeCCs_hunters[sourceName] == nil) then TehrsCDs._aoeCCs_hunters[sourceName] = { } end
                
                TehrsCDs._aoeCCs_hunters[sourceName]["Binding"] = GetTime() + 45;       
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 119381 and TehrsCDs["Show Settings"].Sweep and eventType == "SPELL_CAST_SUCCESS") then
                -- Leg Sweep --
                if (TehrsCDs._aoeCCs_monks == nil) then TehrsCDs._aoeCCs_monks = { } end        
                if (TehrsCDs._aoeCCs_monks[sourceName] == nil) then TehrsCDs._aoeCCs_monks[sourceName] = { } end
                
                local Sweep1 = TehrsCDs._aoeCCs_monks[sourceName]["Sweep"];
                local Sweep2 = TehrsCDs._aoeCCs_monks[sourceName]["Sweep+"];
                
                if (Sweep1 ~= nil) then
                    TehrsCDs._aoeCCs_monks[sourceName]["Sweep"] = GetTime() + 60;
                    TehrsCDs._aoeCCs_monks[sourceName]["Sweep+"] = nil;
                end
                if (Sweep2 ~= nil) then
                    TehrsCDs._aoeCCs_monks[sourceName]["Sweep+"] = GetTime() + 50;
                    TehrsCDs._aoeCCs_monks[sourceName]["Sweep"] = nil;
                end      
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 116844 and TehrsCDs["Show Settings"].Ring and eventType == "SPELL_CAST_SUCCESS") then
                -- Ring of Peace --
                if (TehrsCDs._aoeCCs_monks == nil) then TehrsCDs._aoeCCs_monks = { } end        
                if (TehrsCDs._aoeCCs_monks[sourceName] == nil) then TehrsCDs._aoeCCs_monks[sourceName] = { } end
                
                TehrsCDs._aoeCCs_monks[sourceName]["Ring"] = GetTime() + 45;       
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end        
                
            elseif(spellID == 102793 and TehrsCDs["Show Settings"].Ursol and eventType == "SPELL_CAST_SUCCESS") then
                -- Ursol's Vortex --
                if (TehrsCDs._aoeCCs_druids == nil) then TehrsCDs._aoeCCs_druids = { } end        
                if (TehrsCDs._aoeCCs_druids[sourceName] == nil) then TehrsCDs._aoeCCs_druids[sourceName] = { } end
                
                TehrsCDs._aoeCCs_druids[sourceName]["Ursol"] = GetTime() + 60;        
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 61391 and TehrsCDs["Show Settings"].Typhoon and eventType == "SPELL_CAST_SUCCESS") then
                -- Typhoon --
                if (TehrsCDs._aoeCCs_druids == nil) then TehrsCDs._aoeCCs_druids = { } end        
                if (TehrsCDs._aoeCCs_druids[sourceName] == nil) then TehrsCDs._aoeCCs_druids[sourceName] = { } end
                
                TehrsCDs._aoeCCs_druids[sourceName]["Typhoon"] = GetTime() + 30;         
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end           
                
            elseif(spellID == 205369 and TehrsCDs["Show Settings"].MindBomb and eventType == "SPELL_CAST_SUCCESS") then
                -- Mind Bomb --
                if (TehrsCDs._aoeCCs_priests == nil) then TehrsCDs._aoeCCs_priests = { } end        
                if (TehrsCDs._aoeCCs_priests[sourceName] == nil) then TehrsCDs._aoeCCs_priests[sourceName] = { } end
                
                TehrsCDs._aoeCCs_priests[sourceName]["Mind Bomb"] = GetTime() + 30;        
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end    
                
            elseif(spellID == 204263 and TehrsCDs["Show Settings"].Shining and eventType == "SPELL_CAST_SUCCESS") then
                -- Shining Force --
                if (TehrsCDs._aoeCCs_priests == nil) then TehrsCDs._aoeCCs_priests = { } end        
                if (TehrsCDs._aoeCCs_priests[sourceName] == nil) then TehrsCDs._aoeCCs_priests[sourceName] = { } end
                
                TehrsCDs._aoeCCs_priests[sourceName]["Shining"] = GetTime() + 45;        
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end           
                
            elseif(spellID == 20549 and TehrsCDs["Show Settings"].Stomp and eventType == "SPELL_CAST_SUCCESS") then
                -- War Stomp --
                if (TehrsCDs._aoeCCs_tauren == nil) then TehrsCDs._aoeCCs_tauren = { } end        
                if (TehrsCDs._aoeCCs_tauren[sourceName] == nil) then TehrsCDs._aoeCCs_tauren[sourceName] = { } end
                
                TehrsCDs._aoeCCs_tauren[sourceName]["Stomp"] = GetTime() + 90;           
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end     
                
            elseif(spellID == 255654 and TehrsCDs["Show Settings"].BullRush and eventType == "SPELL_CAST_SUCCESS") then
                -- Bull Rush --
                if (TehrsCDs._aoeCCs_hmtauren == nil) then TehrsCDs._aoeCCs_hmtauren = { } end        
                if (TehrsCDs._aoeCCs_hmtauren[sourceName] == nil) then TehrsCDs._aoeCCs_hmtauren[sourceName] = { } end
                
                TehrsCDs._aoeCCs_hmtauren[sourceName]["Bull Rush"] = GetTime() + 120;           
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end               
                
            elseif(spellID == 46968 and TehrsCDs["Show Settings"].Shockwave and eventType == "SPELL_CAST_SUCCESS") then
                -- Shockwave CAST --
                if (TehrsCDs._aoeCCs_warriors == nil) then TehrsCDs._aoeCCs_warriors = { } end        
                if (TehrsCDs._aoeCCs_warriors[sourceName] == nil) then TehrsCDs._aoeCCs_warriors[sourceName] = { } end
                
                local shockwave1 = TehrsCDs._aoeCCs_warriors[sourceName]["Shockwave"];
                local shockwave2 = TehrsCDs._aoeCCs_warriors[sourceName]["Shockwave+"];
                
                if (shockwave1 ~= nil) then
                    TehrsCDs._aoeCCs_warriors[sourceName]["Shockwave"] = GetTime() + 40;
                    TehrsCDs._aoeCCs_warriors[sourceName]["Shockwave+"] = nil;
                end
                if (shockwave2 ~= nil) then
                    TehrsCDs._aoeCCs_warriors[sourceName]["Shockwave+"] = GetTime() + 40;
                    TehrsCDs._aoeCCs_warriors[sourceName]["Shockwave"] = nil;
                end  
                aura_env.shockwavehits = 0     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 46968 and TehrsCDs["Show Settings"].Shockwave and eventType == "SPELL_DAMAGE") then
                -- Shockwave DAMAGE --
                if (TehrsCDs._aoeCCs_warriors == nil) then TehrsCDs._aoeCCs_warriors = { } end        
                if (TehrsCDs._aoeCCs_warriors[sourceName] == nil) then TehrsCDs._aoeCCs_warriors[sourceName] = { } end
                
                local Shockwave1 = TehrsCDs._aoeCCs_warriors[sourceName]["Shockwave+"];
                
                if Shockwave1 then
                    aura_env.shockwavehits = aura_env.shockwavehits + 1
                    if aura_env.shockwavehits == 3 then
                        TehrsCDs._aoeCCs_warriors[sourceName]["Shockwave+"] = TehrsCDs._aoeCCs_warriors[sourceName]["Shockwave+"] - 15
                    end   
                end            
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." hit with "..spellName) end 
                
            elseif (eventType == "SPELL_CAST_SUCCESS" and TehrsCDs["Show Settings"].Nova and spellID == 179057) then
                -- Chaos Nova --
                if (TehrsCDs._aoeCCs_dhs == nil) then TehrsCDs._aoeCCs_dhs = { } end
                if (TehrsCDs._aoeCCs_dhs[sourceName] == nil) then TehrsCDs._aoeCCs_dhs[sourceName] = { } end   
                
                local Nova1 = TehrsCDs._aoeCCs_dhs[sourceName]["Nova+"];
                local Nova2 = TehrsCDs._aoeCCs_dhs[sourceName]["Nova"];
                
                if (Nova1 ~= nil) then
                    TehrsCDs._aoeCCs_dhs[sourceName]["Nova+"] = GetTime() + 40;
                    TehrsCDs._aoeCCs_dhs[sourceName]["Nova"] = nil;
                end
                if (Nova2 ~= nil) then
                    TehrsCDs._aoeCCs_dhs[sourceName]["Nova"] = GetTime() + 60;
                    TehrsCDs._aoeCCs_dhs[sourceName]["Nova+"] = nil;
                end     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
            end    
        end    
        
        -- INTERRUPTS --
        if (TehrsCDs["Show Settings"].allInterrupts and TehrsCDs.instanceType ~= "raid" and GetNumGroupMembers()<20) or (TehrsCDs["Show Settings"].allInterrupts_inRaid and (TehrsCDs.instanceType == "raid" or GetNumGroupMembers()>19)) then
            if(spellID == 1766 and TehrsCDs["Show Settings"].Kick and eventType == "SPELL_CAST_SUCCESS") then
                -- Kick --
                if (TehrsCDs._interrupts_rogues == nil) then TehrsCDs._interrupts_rogues = { } end        
                if (TehrsCDs._interrupts_rogues[sourceName] == nil) then TehrsCDs._interrupts_rogues[sourceName] = { } end
                
                TehrsCDs._interrupts_rogues[sourceName]["Kick"] = GetTime() + 15;       
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 6552 and TehrsCDs["Show Settings"].Pummel and eventType == "SPELL_CAST_SUCCESS") then
                -- Pummel --
                if (TehrsCDs._interrupts_warriors == nil) then TehrsCDs._interrupts_warriors = { } end        
                if (TehrsCDs._interrupts_warriors[sourceName] == nil) then TehrsCDs._interrupts_warriors[sourceName] = { } end
                
                TehrsCDs._interrupts_warriors[sourceName]["Pummel"] = GetTime() + 15;        
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif (spellID == 106839 and TehrsCDs["Show Settings"].SBash and eventType == "SPELL_CAST_SUCCESS") then
                -- Skull Bash --
                if (TehrsCDs._interrupts_druids == nil) then TehrsCDs._interrupts_druids = { } end        
                if (TehrsCDs._interrupts_druids[sourceName] == nil) then TehrsCDs._interrupts_druids[sourceName] = { } end
                
                TehrsCDs._interrupts_druids[sourceName]["S-Bash"] = GetTime() + 15;       
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 47528 and TehrsCDs["Show Settings"].MindFreeze and eventType == "SPELL_CAST_SUCCESS") then
                -- Mind Freeze --
                if (TehrsCDs._interrupts_dks == nil) then TehrsCDs._interrupts_dks = { } end        
                if (TehrsCDs._interrupts_dks[sourceName] == nil) then TehrsCDs._interrupts_dks[sourceName] = { } end
                
                TehrsCDs._interrupts_dks[sourceName]["M-Freeze"] = GetTime() + 15;          
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 183752 and TehrsCDs["Show Settings"].Disrupt and eventType == "SPELL_CAST_SUCCESS") then
                -- Disrupt --
                if (TehrsCDs._interrupts_dhs == nil) then TehrsCDs._interrupts_dhs = { } end        
                if (TehrsCDs._interrupts_dhs[sourceName] == nil) then TehrsCDs._interrupts_dhs[sourceName] = { } end
                
                TehrsCDs._interrupts_dhs[sourceName]["Disrupt"] = GetTime() + 15;           
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end     
                
            elseif(spellID == 96231 and TehrsCDs["Show Settings"].Rebuke and eventType == "SPELL_CAST_SUCCESS") then
                -- Rebuke --
                if (TehrsCDs._interrupts_paladins == nil) then TehrsCDs._interrupts_paladins = { } end        
                if (TehrsCDs._interrupts_paladins[sourceName] == nil) then TehrsCDs._interrupts_paladins[sourceName] = { } end
                
                TehrsCDs._interrupts_paladins[sourceName]["Rebuke"] = GetTime() + 15;         
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end         
                
            elseif (spellID == 57994 and TehrsCDs["Show Settings"].WShear and eventType == "SPELL_CAST_SUCCESS") then
                -- Wind Shear --
                if (TehrsCDs._interrupts_shamans == nil) then TehrsCDs._interrupts_shamans = { } end        
                if (TehrsCDs._interrupts_shamans[sourceName] == nil) then TehrsCDs._interrupts_shamans[sourceName] = { } end
                
                TehrsCDs._interrupts_shamans[sourceName]["W-Shear"] = GetTime() + 12;     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 116705 and TehrsCDs["Show Settings"].SStrike and eventType == "SPELL_CAST_SUCCESS") then
                -- Spear Hand Strike --
                if (TehrsCDs._interrupts_monks == nil) then TehrsCDs._interrupts_monks = { } end        
                if (TehrsCDs._interrupts_monks[sourceName] == nil) then TehrsCDs._interrupts_monks[sourceName] = { } end
                
                TehrsCDs._interrupts_monks[sourceName]["S-Strike"] = GetTime() + 15;        
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end       
                
            elseif(spellID == 187707 and TehrsCDs["Show Settings"].Muzzle and eventType == "SPELL_CAST_SUCCESS") then
                -- Muzzle --
                if (TehrsCDs._interrupts_hunters == nil) then TehrsCDs._interrupts_hunters = { } end        
                if (TehrsCDs._interrupts_hunters[sourceName] == nil) then TehrsCDs._interrupts_hunters[sourceName] = { } end
                
                TehrsCDs._interrupts_hunters[sourceName]["Muzzle"] = GetTime() + 15;          
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end      
                
            elseif(spellID == 147362 and TehrsCDs["Show Settings"].CShot and eventType == "SPELL_CAST_SUCCESS") then
                -- Counter Shot --
                if (TehrsCDs._interrupts_hunters == nil) then TehrsCDs._interrupts_hunters = { } end        
                if (TehrsCDs._interrupts_hunters[sourceName] == nil) then TehrsCDs._interrupts_hunters[sourceName] = { } end
                
                TehrsCDs._interrupts_hunters[sourceName]["C-Shot"] = GetTime() + 24;        
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif (spellID == 2139 and TehrsCDs["Show Settings"].CSpell and eventType == "SPELL_CAST_SUCCESS") then
                -- Counterspell --        
                if (TehrsCDs._interrupts_mages == nil) then TehrsCDs._interrupts_mages = { } end        
                if (TehrsCDs._interrupts_mages[sourceName] == nil) then TehrsCDs._interrupts_mages[sourceName] = { } end
                
                TehrsCDs._interrupts_mages[sourceName]["C-Spell"] = GetTime() + 24;       
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif ((spellID == 171140 or spellID == 119910 or spellID == 19647 or spellID == 119898) and TehrsCDs["Show Settings"].SpellLock and eventType == "SPELL_CAST_SUCCESS") then
                -- Spell Lock --
                if (TehrsCDs._interrupts_warlocks == nil) then TehrsCDs._interrupts_warlocks = { } end        
                if (TehrsCDs._interrupts_warlocks[sourceName] == nil) then TehrsCDs._interrupts_warlocks[sourceName] = { } end    
                
                TehrsCDs._interrupts_warlocks[sourceName]["Spell Lock"] = GetTime() + 24;  
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif ((spellID == 171138 or spellID == 19647) and TehrsCDs["Show Settings"].SpellLock and eventType == "SPELL_CAST_SUCCESS") then
                -- Spell Lock : PET --
                if (TehrsCDs._interrupts_warlocks == nil) then TehrsCDs._interrupts_warlocks = { } end        
                if (TehrsCDs._interrupts_warlocks[sourceName] == nil) then TehrsCDs._interrupts_warlocks[sourceName] = { } end    
                
                local owner = getPetOwner(sourceName, sourceGUID)                 
                
                TehrsCDs._interrupts_warlocks[owner]["Spell Lock"] = GetTime() + 24;  
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif ((spellID == 171140 or spellID == 119910 or spellID == 119898 or spellID == 132409) and TehrsCDs["Show Settings"].SpellLock and eventType == "SPELL_CAST_SUCCESS") then
                -- Spell Lock : COMMAND DEMON --
                if (TehrsCDs._interrupts_warlocks == nil) then TehrsCDs._interrupts_warlocks = { } end        
                if (TehrsCDs._interrupts_warlocks[sourceName] == nil) then TehrsCDs._interrupts_warlocks[sourceName] = { } end    
                
                TehrsCDs._interrupts_warlocks[sourceName]["Spell Lock"] = GetTime() + 24;  
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end                 
                
            elseif (spellID == 15487 and TehrsCDs["Show Settings"].Silence and eventType == "SPELL_CAST_SUCCESS") then
                -- Priest: Silence --        
                if (TehrsCDs._interrupts_priests == nil) then TehrsCDs._interrupts_priests = { } end        
                if (TehrsCDs._interrupts_priests[sourceName] == nil) then TehrsCDs._interrupts_priests[sourceName] = { } end
                
                local Silence1 = TehrsCDs._interrupts_priests[sourceName]["Silence+"];
                local Silence2 = TehrsCDs._interrupts_priests[sourceName]["Silence"];
                
                if (Silence1 ~= nil) then
                    TehrsCDs._interrupts_priests[sourceName]["Silence+"] = GetTime() + 30;
                    TehrsCDs._interrupts_priests[sourceName]["Silence"] = nil;
                end
                if (Silence2 ~= nil) then
                    TehrsCDs._interrupts_priests[sourceName]["Silence"] = GetTime() + 45;
                    TehrsCDs._interrupts_priests[sourceName]["Silence+"] = nil;
                end   
                
            elseif (spellID == 78675 and TehrsCDs["Show Settings"].SBeam and eventType == "SPELL_CAST_SUCCESS") then
                -- Solar Beam: CAST --
                if (TehrsCDs._interrupts_druids == nil) then TehrsCDs._interrupts_druids = { } end        
                if (TehrsCDs._interrupts_druids[sourceName] == nil) then TehrsCDs._interrupts_druids[sourceName] = { } end
                
                TehrsCDs._interrupts_druids[sourceName]["S-Beam"] = GetTime() + 60;
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end   
                
            elseif(eventType == "SPELL_CAST_SUCCESS" and TehrsCDs["Show Settings"].SigilSilence and (spellID == 202137 or spellID == 207682)) then
                -- Sigil of Silence --
                if (TehrsCDs._interrupts_dhs == nil) then TehrsCDs._interrupts_dhs = { } end
                if (TehrsCDs._interrupts_dhs[sourceName] == nil) then TehrsCDs._interrupts_dhs[sourceName] = { } end   
                
                local silence1 = TehrsCDs._interrupts_dhs[sourceName]["S-Silence+"];
                local silence2 = TehrsCDs._interrupts_dhs[sourceName]["S-Silence"];
                
                if (silence1 ~= nil) then
                    TehrsCDs._interrupts_dhs[sourceName]["S-Silence+"] = GetTime() + 48;
                    TehrsCDs._interrupts_dhs[sourceName]["S-Silence"] = nil;
                end
                if (silence2 ~= nil) then
                    TehrsCDs._interrupts_dhs[sourceName]["S-Silence"] = GetTime() + 60;
                    TehrsCDs._interrupts_dhs[sourceName]["S-Silence+"] = nil;
                end     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end  
                
                --[[        
            elseif ((spellID == 28730 or spellID == 50613 or spellID == 202719 or spellID == 80483 or spellID == 129597 or spellID == 155145 or spellID == 232633 or spellID == 25046 or spellID == 69179) and eventType == "SPELL_CAST_SUCCESS" and TehrsCDs["Show Settings"].Torrent) then
                -- Arcane Torrent --  p.s. Blizzard why do you have a new spellID for each class? pls
                if (TehrsCDs._interrupts_belfs == nil) then TehrsCDs._interrupts_belfs = { } end        
                if (TehrsCDs._interrupts_belfs[sourceName] == nil) then TehrsCDs._interrupts_belfs[sourceName] = { } end
                
                TehrsCDs._interrupts_belfs[sourceName]["Torrent"] = GetTime() + 90;      
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end                
            
            Arcane Torrent isn't an interrupt anymore! Holding onto this until I add dispels.
            ]]    
            end        
        end        
        
        -- BATTLE REZZES --
        if (TehrsCDs["Show Settings"].allRezzes and TehrsCDs.instanceType ~= "raid" and GetNumGroupMembers()<20) or ((TehrsCDs["Show Settings"].allRezzes_inRaid or TehrsCDs["Show Settings"].Ankh_inRaid) and (TehrsCDs.instanceType == "raid" or GetNumGroupMembers()>19)) then
            if ((spellID == 20608 or spellID == 21169 or spellID == 27740) and eventType == "SPELL_CAST_SUCCESS" and TehrsCDs["Show Settings"].Ankh) then
                -- Reincarnation --
                if (TehrsCDs._rezCDs_shamans == nil) then TehrsCDs._rezCDs_shamans = { } end        
                if (TehrsCDs._rezCDs_shamans[sourceName] == nil) then TehrsCDs._rezCDs_shamans[sourceName] = { } end
                
                TehrsCDs._rezCDs_shamans[sourceName]["Ankh"] = GetTime() + 1800;       
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif (spellID == 61999 and TehrsCDs["Show Settings"].RaiseAlly and eventType == "SPELL_CAST_SUCCESS") then
                -- Raise Ally --
                if (TehrsCDs._rezCDs_dks == nil) then TehrsCDs._rezCDs_dks = { } end        
                if (TehrsCDs._rezCDs_dks[sourceName] == nil) then TehrsCDs._rezCDs_dks[sourceName] = { } end
                
                TehrsCDs._rezCDs_dks[sourceName]["Raise Ally"] = GetTime() + 600;         
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif (spellID == 20707 and TehrsCDs["Show Settings"].Soulstone and eventType == "SPELL_CAST_SUCCESS") then
                -- Soulstone --
                if (TehrsCDs._rezCDs_warlocks == nil) then TehrsCDs._rezCDs_warlocks = { } end        
                if (TehrsCDs._rezCDs_warlocks[sourceName] == nil) then TehrsCDs._rezCDs_warlocks[sourceName] = { } end
                
                TehrsCDs._rezCDs_warlocks[sourceName]["Soulstone"] = GetTime() + 600;       
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end   
                
            elseif (spellID == 20484 and TehrsCDs["Show Settings"].Rebirth and eventType == "SPELL_CAST_SUCCESS") then
                -- Rebirth --
                if (TehrsCDs._rezCDs_druids == nil) then TehrsCDs._rezCDs_druids = { } end        
                if (TehrsCDs._rezCDs_druids[sourceName] == nil) then TehrsCDs._rezCDs_druids[sourceName] = { } end
                
                TehrsCDs._rezCDs_druids[sourceName]["Rebirth"] = GetTime() + 600;        
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end  
            end
        end        
        
        -- UTILITY --  
        if (TehrsCDs["Show Settings"].allUtility and TehrsCDs.instanceType ~= "raid" and GetNumGroupMembers()<20) or (TehrsCDs["Show Settings"].allUtility_inRaid and (TehrsCDs.instanceType == "raid" or GetNumGroupMembers()>19)) then 
            if (spellID == 57934 and TehrsCDs["Show Settings"].Tricks and eventType == "SPELL_AURA_APPLIED") then
                -- Tricks of the Trade: BUFF APPLIED TO ROGUE --        
                if (TehrsCDs._utilityCDs_rogues == nil) then TehrsCDs._utilityCDs_rogues = { } end        
                if (TehrsCDs._utilityCDs_rogues[sourceName] == nil) then TehrsCDs._utilityCDs_rogues[sourceName] = { } end
                
                TehrsCDs._utilityCDs_rogues[sourceName]["Tricks"] = GetTime() + 30;        
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end
                
            elseif (spellID == 114018 and TehrsCDs["Show Settings"].Shroud and eventType == "SPELL_CAST_SUCCESS") then
                -- Shroud of Concealment --        
                if (TehrsCDs._utilityCDs_rogues == nil) then TehrsCDs._utilityCDs_rogues = { } end        
                if (TehrsCDs._utilityCDs_rogues[sourceName] == nil) then TehrsCDs._utilityCDs_rogues[sourceName] = { } end
                
                TehrsCDs._utilityCDs_rogues[sourceName]["Shroud"] = GetTime() + 360;        
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif (spellID == 34477 and TehrsCDs["Show Settings"].Misdirect and eventType == "SPELL_CAST_SUCCESS") then
                -- Misdirection --
                if (TehrsCDs._utilityCDs_hunters == nil) then TehrsCDs._utilityCDs_hunters = { } end        
                if (TehrsCDs._utilityCDs_hunters[sourceName] == nil) then TehrsCDs._utilityCDs_hunters[sourceName] = { } end
                
                TehrsCDs._utilityCDs_hunters[sourceName]["Misdirect"] = GetTime() + 30;       
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end       
                
            elseif(spellID == 64901 and TehrsCDs["Show Settings"].Hope and eventType == "SPELL_CAST_SUCCESS") then
                -- Symbol of Hope --
                if (TehrsCDs._utilityCDs_priests == nil) then TehrsCDs._utilityCDs_priests = { } end
                if (TehrsCDs._utilityCDs_priests[sourceName] == nil) then TehrsCDs._utilityCDs_priests[sourceName] = { } end
                
                TehrsCDs._utilityCDs_priests[sourceName]["Hope"] = GetTime() + 300;     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 73325 and TehrsCDs["Show Settings"].Grip and eventType == "SPELL_CAST_SUCCESS") then
                -- Leap of Faith --
                if (TehrsCDs._utilityCDs_priests == nil) then TehrsCDs._utilityCDs_priests = { } end
                if (TehrsCDs._utilityCDs_priests[sourceName] == nil) then TehrsCDs._utilityCDs_priests[sourceName] = { } end
                
                TehrsCDs._utilityCDs_priests[sourceName]["Grip"] = GetTime() + 90;     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 192077 and TehrsCDs["Show Settings"].WindRush and eventType == "SPELL_CAST_SUCCESS") then
                -- Wind Rush Totem --
                if (TehrsCDs._utilityCDs_shamans == nil) then TehrsCDs._utilityCDs_shamans = { } end
                if (TehrsCDs._utilityCDs_shamans[sourceName] == nil) then TehrsCDs._utilityCDs_shamans[sourceName] = { } end
                
                TehrsCDs._utilityCDs_shamans[sourceName]["Wind Rush"] = GetTime() + 120;     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end             
                
            elseif(spellID == 29166 and TehrsCDs["Show Settings"].Innervate and eventType == "SPELL_CAST_SUCCESS") then
                --  Innervate --
                if (TehrsCDs._utilityCDs_druids == nil) then TehrsCDs._utilityCDs_druids = { } end
                if (TehrsCDs._utilityCDs_druids[sourceName] == nil) then TehrsCDs._utilityCDs_druids[sourceName] = { } end
                
                TehrsCDs._utilityCDs_druids[sourceName]["Innervate"] = GetTime() + 180;        
                
            elseif(spellID == 205636 and TehrsCDs["Show Settings"].Treants and eventType == "SPELL_CAST_SUCCESS") then
                -- Treants --
                if (TehrsCDs._utilityCDs_druids == nil) then TehrsCDs._utilityCDs_druids = { } end
                if (TehrsCDs._utilityCDs_druids[sourceName] == nil) then TehrsCDs._utilityCDs_druids[sourceName] = { } end
                
                TehrsCDs._utilityCDs_druids[sourceName]["Treants"] = GetTime() + 60;     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end     
                
            elseif(spellID == 58984 and TehrsCDs["Show Settings"].Shadowmeld and eventType == "SPELL_CAST_SUCCESS") then
                -- Shadowmeld --
                if (TehrsCDs._utilityCDs_nightelf == nil) then TehrsCDs._utilityCDs_nightelf = { } end
                if (TehrsCDs._utilityCDs_nightelf[sourceName] == nil) then TehrsCDs._utilityCDs_nightelf[sourceName] = { } end
                
                TehrsCDs._utilityCDs_nightelf[sourceName]["Shadowmeld"] = GetTime() + 120;     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end             
                
            elseif (eventType == "SPELL_CAST_SUCCESS" and TehrsCDs["Show Settings"].Roar and spellID == 106898) then
                -- Stampeding Roar --
                if (TehrsCDs._utilityCDs_druids == nil) then TehrsCDs._utilityCDs_druids = { } end
                if (TehrsCDs._utilityCDs_druids[sourceName] == nil) then TehrsCDs._utilityCDs_druids[sourceName] = { } end   
                
                TehrsCDs._utilityCDs_druids[sourceName]["Roar"] = GetTime() + 120;
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif (eventType == "SPELL_CAST_SUCCESS" and TehrsCDs["Show Settings"].Roar and spellID == 77761) then
                -- Stampeding Roar: DEBUG --
                if (TehrsCDs._utilityCDs_druids == nil) then TehrsCDs._utilityCDs_druids = { } end
                if (TehrsCDs._utilityCDs_druids[sourceName] == nil) then TehrsCDs._utilityCDs_druids[sourceName] = { } end   
                
                TehrsCDs._utilityCDs_druids[sourceName]["Roar"] = GetTime() + 120;
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif (eventType == "SPELL_CAST_SUCCESS" and TehrsCDs["Show Settings"].Roar and spellID == 77764) then
                -- Stampeding Roar: FERAL --
                if (TehrsCDs._utilityCDs_druids == nil) then TehrsCDs._utilityCDs_druids = { } end
                if (TehrsCDs._utilityCDs_druids[sourceName] == nil) then TehrsCDs._utilityCDs_druids[sourceName] = { } end   
                
                TehrsCDs._utilityCDs_druids[sourceName]["Roar"] = GetTime() + 120;       
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end             
            end    
        end
        
        -- RAID CDs --
        if (TehrsCDs["Show Settings"].allCDs and TehrsCDs.instanceType ~= "raid" and GetNumGroupMembers()<20) or (TehrsCDs["Show Settings"].allCDs_inRaid and (TehrsCDs.instanceType == "raid" or GetNumGroupMembers()>19)) then 
            if (eventType == "SPELL_AURA_APPLIED" and TehrsCDs["Show Settings"].Tranq and spellID == 740) then
                -- Tranquility --
                if (TehrsCDs._raidCDs_druids == nil) then TehrsCDs._raidCDs_druids = { } end
                if (TehrsCDs._raidCDs_druids[sourceName] == nil) then TehrsCDs._raidCDs_druids[sourceName] = { } end   
                
                local tranq1 = TehrsCDs._raidCDs_druids[sourceName]["Tranq+"];
                local tranq2 = TehrsCDs._raidCDs_druids[sourceName]["Tranq"];
                
                if (tranq1 ~= nil) then
                    TehrsCDs._raidCDs_druids[sourceName]["Tranq+"] = GetTime() + 120;
                    TehrsCDs._raidCDs_druids[sourceName]["Tranq"] = nil;
                end
                if (tranq2 ~= nil) then
                    TehrsCDs._raidCDs_druids[sourceName]["Tranq"] = GetTime() + 180;
                    TehrsCDs._raidCDs_druids[sourceName]["Tranq+"] = nil;
                end     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif (spellID == 197721 and TehrsCDs["Show Settings"].Flourish and eventType == "SPELL_CAST_SUCCESS") then
                -- Flourish --        
                if (TehrsCDs._raidCDs_druids == nil) then TehrsCDs._raidCDs_druids = { } end        
                if (TehrsCDs._raidCDs_druids[sourceName] == nil) then TehrsCDs._raidCDs_druids[sourceName] = { } end
                
                TehrsCDs._raidCDs_druids[sourceName]["Flourish"] = GetTime() + 90;          
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end             
                
            elseif (spellID == 47536 and TehrsCDs["Show Settings"].Rapture and eventType == "SPELL_CAST_SUCCESS") then
                -- Rapture --        
                if (TehrsCDs._raidCDs_priests == nil) then TehrsCDs._raidCDs_priests = { } end        
                if (TehrsCDs._raidCDs_priests[sourceName] == nil) then TehrsCDs._raidCDs_priests[sourceName] = { } end
                
                TehrsCDs._raidCDs_priests[sourceName]["Rapture"] = GetTime() + 90;          
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end                 
                
            elseif (spellID == 64843 and TehrsCDs["Show Settings"].DHymn and eventType == "SPELL_AURA_APPLIED") then
                -- Divine Hymn --        
                if (TehrsCDs._raidCDs_priests == nil) then TehrsCDs._raidCDs_priests = { } end        
                if (TehrsCDs._raidCDs_priests[sourceName] == nil) then TehrsCDs._raidCDs_priests[sourceName] = { } end
                
                TehrsCDs._raidCDs_priests[sourceName]["D-Hymn"] = GetTime() + 180;          
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end  
                
            elseif (spellID == 200183 and TehrsCDs["Show Settings"].Apotheosis and eventType == "SPELL_CAST_SUCCESS") then
                -- Apotheosis --        
                if (TehrsCDs._raidCDs_priests == nil) then TehrsCDs._raidCDs_priests = { } end        
                if (TehrsCDs._raidCDs_priests[sourceName] == nil) then TehrsCDs._raidCDs_priests[sourceName] = { } end
                
                TehrsCDs._raidCDs_priests[sourceName]["Apotheosis"] = GetTime() + 120;          
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end     
                
            elseif (spellID == 265202 and TehrsCDs["Show Settings"].Salvation and eventType == "SPELL_CAST_SUCCESS") then
                -- Holy Word: Salvation --        
                if (TehrsCDs._raidCDs_priests == nil) then TehrsCDs._raidCDs_priests = { } end        
                if (TehrsCDs._raidCDs_priests[sourceName] == nil) then TehrsCDs._raidCDs_priests[sourceName] = { } end
                
                TehrsCDs._raidCDs_priests[sourceName]["Salvation"] = GetTime() + 720;          
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end                 
                
            elseif(spellID == 34861 and TehrsCDs["Show Settings"].Salvation and eventType == "SPELL_CAST_SUCCESS") then
                -- Holy Word: Sanctify --
                if (TehrsCDs._raidCDs_priests == nil) then TehrsCDs._raidCDs_priests = { } end        
                if (TehrsCDs._raidCDs_priests[sourceName] == nil) then TehrsCDs._raidCDs_priests[sourceName] = { } end
                
                local salvSpec = TehrsCDs._raidCDs_priests[sourceName]["Salvation"]
                
                if (salvSpec ~= nil) then
                    TehrsCDs._raidCDs_priests[sourceName]["Salvation"] = TehrsCDs._raidCDs_priests[sourceName]["Salvation"] - 30; 
                    if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                end      
                
            elseif(spellID == 2050 and TehrsCDs["Show Settings"].Salvation and eventType == "SPELL_CAST_SUCCESS") then
                -- Holy Word: Serenity --
                if (TehrsCDs._raidCDs_priests == nil) then TehrsCDs._raidCDs_priests = { } end        
                if (TehrsCDs._raidCDs_priests[sourceName] == nil) then TehrsCDs._raidCDs_priests[sourceName] = { } end
                
                local salvSpec = TehrsCDs._raidCDs_priests[sourceName]["Salvation"]
                
                if (salvSpec ~= nil) then
                    TehrsCDs._raidCDs_priests[sourceName]["Salvation"] = TehrsCDs._raidCDs_priests[sourceName]["Salvation"] - 30; 
                    if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                end                  
                
            elseif (spellID == 108281 and TehrsCDs["Show Settings"].AG and eventType == "SPELL_AURA_APPLIED") then
                -- Ancestral Guidance --
                if (TehrsCDs._raidCDs_shamans == nil) then TehrsCDs._raidCDs_shamans = { } end        
                if (TehrsCDs._raidCDs_shamans[sourceName] == nil) then TehrsCDs._raidCDs_shamans[sourceName] = { } end
                
                TehrsCDs._raidCDs_shamans[sourceName]["AG"] = GetTime() + 120;     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 97462 and TehrsCDs["Show Settings"].CShout and eventType == "SPELL_CAST_SUCCESS") then
                -- Commanding Shout --
                if (TehrsCDs._raidCDs_warriors == nil) then TehrsCDs._raidCDs_warriors = { } end        
                if (TehrsCDs._raidCDs_warriors[sourceName] == nil) then TehrsCDs._raidCDs_warriors[sourceName] = { } end
                
                TehrsCDs._raidCDs_warriors[sourceName]["R-Cry"] = GetTime() + 180;     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 108280 and TehrsCDs["Show Settings"].HTide  and eventType == "SPELL_CAST_SUCCESS") then
                -- Healing Tide --
                if (TehrsCDs._raidCDs_shamans == nil) then TehrsCDs._raidCDs_shamans = { } end        
                if (TehrsCDs._raidCDs_shamans[sourceName] == nil) then TehrsCDs._raidCDs_shamans[sourceName] = { } end
                
                TehrsCDs._raidCDs_shamans[sourceName]["H-Tide"] = GetTime() + 180;       
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 114052 and TehrsCDs["Show Settings"].Ascendance  and eventType == "SPELL_CAST_SUCCESS") then
                -- Ascendance --
                if (TehrsCDs._raidCDs_shamans == nil) then TehrsCDs._raidCDs_shamans = { } end        
                if (TehrsCDs._raidCDs_shamans[sourceName] == nil) then TehrsCDs._raidCDs_shamans[sourceName] = { } end
                
                TehrsCDs._raidCDs_shamans[sourceName]["Ascendance"] = GetTime() + 180;       
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end                 
                
            elseif(spellID == 62618 and TehrsCDs["Show Settings"].Barrier and eventType == "SPELL_CAST_SUCCESS") then
                -- Power Word: Barrier --
                if (TehrsCDs._raidCDs_priests == nil) then TehrsCDs._raidCDs_priests = { } end        
                if (TehrsCDs._raidCDs_priests[sourceName] == nil) then TehrsCDs._raidCDs_priests[sourceName] = { } end
                
                TehrsCDs._raidCDs_priests[sourceName]["Barrier"] = GetTime() + 180;         
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end         
                
            elseif(spellID == 271466 and TehrsCDs["Show Settings"].Barrier and eventType == "SPELL_CAST_SUCCESS") then
                -- Luminous Barrier --
                if (TehrsCDs._raidCDs_priests == nil) then TehrsCDs._raidCDs_priests = { } end        
                if (TehrsCDs._raidCDs_priests[sourceName] == nil) then TehrsCDs._raidCDs_priests[sourceName] = { } end
                
                TehrsCDs._raidCDs_priests[sourceName]["Barrier+"] = GetTime() + 180;         
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end                  
                
            elseif(spellID == 98008 and TehrsCDs["Show Settings"].SLT and eventType == "SPELL_CAST_SUCCESS") then
                -- Spirit Link Totem --
                if (TehrsCDs._raidCDs_shamans == nil) then TehrsCDs._raidCDs_shamans = { } end        
                if (TehrsCDs._raidCDs_shamans[sourceName] == nil) then TehrsCDs._raidCDs_shamans[sourceName] = { } end
                
                TehrsCDs._raidCDs_shamans[sourceName]["SLT"] = GetTime() + 180;            
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end  
                
            elseif(spellID == 31821 and TehrsCDs["Show Settings"].AuraM and eventType == "SPELL_CAST_SUCCESS") then
                -- Aura Mastery --
                if (TehrsCDs._raidCDs_paladins == nil) then TehrsCDs._raidCDs_paladins = { } end
                if (TehrsCDs._raidCDs_paladins[sourceName] == nil) then TehrsCDs._raidCDs_paladins[sourceName] = { } end
                
                TehrsCDs._raidCDs_paladins[sourceName]["Aura-M"] = GetTime() + 180;     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 31884 and TehrsCDs["Show Settings"].Wings and eventType == "SPELL_CAST_SUCCESS") then
                -- Avenging Wrath --
                if (TehrsCDs._raidCDs_paladins == nil) then TehrsCDs._raidCDs_paladins = { } end
                if (TehrsCDs._raidCDs_paladins[sourceName] == nil) then TehrsCDs._raidCDs_paladins[sourceName] = { } end
                
                TehrsCDs._raidCDs_paladins[sourceName]["Wings"] = GetTime() + 120;     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end         
                
            elseif(spellID == 216331 and TehrsCDs["Show Settings"].Wings and eventType == "SPELL_CAST_SUCCESS") then
                -- Avenging Crusader --
                if (TehrsCDs._raidCDs_paladins == nil) then TehrsCDs._raidCDs_paladins = { } end
                if (TehrsCDs._raidCDs_paladins[sourceName] == nil) then TehrsCDs._raidCDs_paladins[sourceName] = { } end
                
                TehrsCDs._raidCDs_paladins[sourceName]["Wings+"] = GetTime() + 120;     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end                 
                
            elseif(spellID == 204150 and TehrsCDs["Show Settings"].Aegis and eventType == "SPELL_AURA_APPLIED") then
                -- Aegis of Light --
                if (TehrsCDs._raidCDs_paladins == nil) then TehrsCDs._raidCDs_paladins = { } end
                if (TehrsCDs._raidCDs_paladins[sourceName] == nil) then TehrsCDs._raidCDs_paladins[sourceName] = { } end
                
                TehrsCDs._raidCDs_paladins[sourceName]["Aegis"] = GetTime() + 180;       
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end       
                
            elseif(spellID == 15286 and TehrsCDs["Show Settings"].VE and eventType == "SPELL_CAST_SUCCESS") then
                -- Vampiric Embrace --
                if (TehrsCDs._raidCDs_priests == nil) then TehrsCDs._raidCDs_priests = { } end        
                if (TehrsCDs._raidCDs_priests[sourceName] == nil) then TehrsCDs._raidCDs_priests[sourceName] = { } end
                
                local VE1 = TehrsCDs._raidCDs_priests[sourceName]["VE+"];
                local VE2 = TehrsCDs._raidCDs_priests[sourceName]["VE"];
                
                if (VE1 ~= nil) then
                    TehrsCDs._raidCDs_priests[sourceName]["VE+"] = GetTime() + 75;
                    TehrsCDs._raidCDs_priests[sourceName]["VE"] = nil;
                end
                if (VE2 ~= nil) then
                    TehrsCDs._raidCDs_priests[sourceName]["VE"] = GetTime() + 120;
                    TehrsCDs._raidCDs_priests[sourceName]["VE+"] = nil;
                end                 
                
            elseif(spellID == 196718 and TehrsCDs["Show Settings"].Darkness and eventType == "SPELL_CAST_SUCCESS") then
                -- Darkness --
                if (TehrsCDs._raidCDs_dhs == nil) then TehrsCDs._raidCDs_dhs = { } end        
                if (TehrsCDs._raidCDs_dhs[sourceName] == nil) then TehrsCDs._raidCDs_dhs[sourceName] = { } end
                
                TehrsCDs._raidCDs_dhs[sourceName]["Darkness"] = GetTime() + 180;       
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 207399 and TehrsCDs["Show Settings"].AProt and eventType == "SPELL_CAST_SUCCESS") then
                -- Ancestral Protection Totem --
                if (TehrsCDs._raidCDs_shamans == nil) then TehrsCDs._raidCDs_shamans = { } end        
                if (TehrsCDs._raidCDs_shamans[sourceName] == nil) then TehrsCDs._raidCDs_shamans[sourceName] = { } end
                
                TehrsCDs._raidCDs_shamans[sourceName]["A-Prot"] = GetTime() + 300;       
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end
                
            elseif(spellID == 115310 and TehrsCDs["Show Settings"].Revival and eventType == "SPELL_CAST_SUCCESS") then
                -- Revival --
                if (TehrsCDs._raidCDs_monks == nil) then TehrsCDs._raidCDs_monks = { } end        
                if (TehrsCDs._raidCDs_monks[sourceName] == nil) then TehrsCDs._raidCDs_monks[sourceName] = { } end
                
                TehrsCDs._raidCDs_monks[sourceName]["Revival"] = GetTime() + 180;     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end              
            end
        end
        
        -- EXTERNAL CDs --    
        if (TehrsCDs["Show Settings"].allExterns and TehrsCDs.instanceType ~= "raid" and GetNumGroupMembers()<20) or (TehrsCDs["Show Settings"].allExterns_inRaid and (TehrsCDs.instanceType == "raid" or GetNumGroupMembers()>19)) then         
            if(spellID == 47788 and TehrsCDs["Show Settings"].GSpirit and eventType == "SPELL_CAST_SUCCESS") then        
                -- Guardian Spirit --        
                if (TehrsCDs._externCDs_priests == nil) then TehrsCDs._externCDs_priests = { } end        
                if (TehrsCDs._externCDs_priests[sourceName] == nil) then TehrsCDs._externCDs_priests[sourceName] = { } end    
                
                local GA1 = TehrsCDs._externCDs_priests[sourceName]["G-Spirit"];
                local GA2 = TehrsCDs._externCDs_priests[sourceName]["G-Spirit+"];
                
                if (GA1 ~= nil) then
                    TehrsCDs._externCDs_priests[sourceName]["G-Spirit"] = GetTime() + 180;
                    TehrsCDs._externCDs_priests[sourceName]["G-Spirit+"] = nil;
                end
                if (GA2 ~= nil) then
                    TehrsCDs._externCDs_priests[sourceName]["G-Spirit+"] = GetTime() + 180;
                    TehrsCDs._externCDs_priests[sourceName]["G-Spirit"] = nil;
                end     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 47788 and TehrsCDs["Show Settings"].GSpirit and eventType == "SPELL_AURA_APPLIED") then        
                -- Guardian Angel Applied (talent 3,1) --
                if (TehrsCDs._externCDs_priests == nil) then TehrsCDs._externCDs_priests = { } end        
                if (TehrsCDs._externCDs_priests[sourceName] == nil) then TehrsCDs._externCDs_priests[sourceName] = { } end          
                
                local GA2 = TehrsCDs._externCDs_priests[sourceName]["G-Spirit+"];        
                if (GA2 ~= nil) then        
                    aura_env.GADuration = select(6, WA_GetUnitAura(destName, 47788))  
                end     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 47788 and TehrsCDs["Show Settings"].GSpirit and eventType == "SPELL_AURA_REMOVED") then        
                -- Guardian Angel Removed (talent 3,2) --
                if (TehrsCDs._externCDs_priests == nil) then TehrsCDs._externCDs_priests = { } end        
                if (TehrsCDs._externCDs_priests[sourceName] == nil) then TehrsCDs._externCDs_priests[sourceName] = { } end          
                
                local hasGA = TehrsCDs._externCDs_priests[sourceName]["G-Spirit+"];
                if (hasGA ~= nil) then
                    local timeLeft = aura_env.GADuration - GetTime()
                    if timeLeft <= 0.1 then
                        TehrsCDs._externCDs_priests[sourceName]["G-Spirit+"] = GetTime() + 60;  
                    end
                end           
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end   
                
            elseif(spellID == 198304 and TehrsCDs["Show Settings"].Safeguard and eventType == "SPELL_CAST_SUCCESS") then
                -- Intercept: Safeguard --
                if (TehrsCDs._externCDs_warriors == nil) then TehrsCDs._externCDs_warriors = { } end        
                if (TehrsCDs._externCDs_warriors[sourceName] == nil) then TehrsCDs._externCDs_warriors[sourceName] = { } end
                
                local safeguard = TehrsCDs._externCDs_warriors[sourceName]["Safeguard"];
                
                if (safeguard ~= nil) then
                    TehrsCDs._externCDs_warriors[sourceName]["Safeguard"] = GetTime() + 20;
                end 
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 102342 and TehrsCDs["Show Settings"].IBark and eventType == "SPELL_CAST_SUCCESS") then
                -- Ironbark --
                if (TehrsCDs._externCDs_druids == nil) then TehrsCDs._externCDs_druids = { } end
                if (TehrsCDs._externCDs_druids[sourceName] == nil) then TehrsCDs._externCDs_druids[sourceName] = { } end
                
                local ibark1 = TehrsCDs._externCDs_druids[sourceName]["I-Bark"];
                local ibark2 = TehrsCDs._externCDs_druids[sourceName]["I-Bark+"];
                
                if (ibark1 ~= nil) then
                    TehrsCDs._externCDs_druids[sourceName]["I-Bark"] = GetTime() + 60
                    TehrsCDs._externCDs_druids[sourceName]["I-Bark+"] = nil;
                end
                if (ibark2 ~= nil) then
                    TehrsCDs._externCDs_druids[sourceName]["I-Bark+"] = GetTime() + 45
                    TehrsCDs._externCDs_druids[sourceName]["I-Bark"] = nil;
                end     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 33206 and TehrsCDs["Show Settings"].PSup and eventType == "SPELL_CAST_SUCCESS") then
                -- Pain Suppression --
                if (TehrsCDs._externCDs_priests == nil) then TehrsCDs._externCDs_priests = { } end        
                if (TehrsCDs._externCDs_priests[sourceName] == nil) then TehrsCDs._externCDs_priests[sourceName] = { } end
                
                local Psup1 = TehrsCDs._externCDs_priests[sourceName]["P-Sup"];
                local Psup2 = TehrsCDs._externCDs_priests[sourceName]["P-Sup+"];
                
                if (Psup1 ~= nil) then
                    TehrsCDs._externCDs_priests[sourceName]["P-Sup"] = GetTime() + 200;    
                    TehrsCDs._externCDs_priests[sourceName]["P-Sup+"] = nil;
                end
                if (Psup2 ~= nil) then
                    TehrsCDs._externCDs_priests[sourceName]["P-Sup+"] = GetTime() + 200;    
                    TehrsCDs._externCDs_priests[sourceName]["P-Sup"] = nil;
                end
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end           
                
            elseif(spellID == 116849 and TehrsCDs["Show Settings"].LCocoon and eventType == "SPELL_CAST_SUCCESS") then
                -- Life Cocoon --
                if (TehrsCDs._externCDs_monks == nil) then TehrsCDs._externCDs_monks = { } end
                if (TehrsCDs._externCDs_monks[sourceName] == nil) then TehrsCDs._externCDs_monks[sourceName] = { } end
                
                TehrsCDs._externCDs_monks[sourceName]["L-Cocoon"] = GetTime() + 120;     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(spellID == 204018 and TehrsCDs["Show Settings"].Spellward and eventType == "SPELL_CAST_SUCCESS") then
                -- Blessing of Spellwarding --
                if (TehrsCDs._externCDs_paladins == nil) then TehrsCDs._externCDs_paladins = { } end
                if (TehrsCDs._externCDs_paladins[sourceName] == nil) then TehrsCDs._externCDs_paladins[sourceName] = { } end
                
                TehrsCDs._externCDs_paladins[sourceName]["Spellward"] = GetTime() + 180;     
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end 
                
            elseif(eventType == "SPELL_CAST_SUCCESS" and TehrsCDs["Show Settings"].LoH and spellID == 633) then
                -- Lay on Hands --
                if (TehrsCDs._externCDs_paladins == nil) then TehrsCDs._externCDs_paladins = { } end
                if (TehrsCDs._externCDs_paladins[sourceName] == nil) then TehrsCDs._externCDs_paladins[sourceName] = { } end   
                
                local loh1 = TehrsCDs._externCDs_paladins[sourceName]["LoH"];
                local loh2 = TehrsCDs._externCDs_paladins[sourceName]["LoH+"];
                local loh3 = TehrsCDs._externCDs_paladins[sourceName]["LoH+ "];
                local loh4 = TehrsCDs._externCDs_paladins[sourceName]["LoH+  "];    
                local multiplier = 1
                
                if (loh4 ~= nil) then
                    multiplier = multiplier * 0.3
                end
                if (loh3 ~= nil) then
                    multiplier = multiplier * 0.7
                end    
                if (loh2 ~= nil) then
                    multiplier = multiplier / 1.4
                    TehrsCDs._externCDs_paladins[sourceName]["LoH+"] = GetTime() + (600 * multiplier);
                    TehrsCDs._externCDs_paladins[sourceName]["LoH"] = nil;
                end
                if (loh1 ~= nil) then
                    TehrsCDs._externCDs_paladins[sourceName]["LoH"] = GetTime() + 600;
                    TehrsCDs._externCDs_paladins[sourceName]["LoH+"] = nil;
                end      
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end         
                
            elseif(spellID == 6940 and TehrsCDs["Show Settings"].Sac and eventType == "SPELL_CAST_SUCCESS") then
                -- Blessing of Sacrifice --
                if (TehrsCDs._externCDs_paladins == nil) then TehrsCDs._externCDs_paladins = { } end
                if (TehrsCDs._externCDs_paladins[sourceName] == nil) then TehrsCDs._externCDs_paladins[sourceName] = { } end
                
                TehrsCDs._externCDs_paladins[sourceName]["Sac"] = GetTime() + 120;
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end       
                
            elseif(spellID == 199448 and TehrsCDs["Show Settings"].Sac and eventType == "SPELL_CAST_SUCCESS") then
                -- Blessing of Sacrifice: DEBUG --
                if (TehrsCDs._externCDs_paladins == nil) then TehrsCDs._externCDs_paladins = { } end
                if (TehrsCDs._externCDs_paladins[sourceName] == nil) then TehrsCDs._externCDs_paladins[sourceName] = { } end
                
                TehrsCDs._externCDs_paladins[sourceName]["Sac"] = GetTime() + 120;    
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end                
                
            elseif(spellID == 187190 and TehrsCDs["Show Settings"].Sac and eventType == "SPELL_CAST_SUCCESS") then
                -- Blessing of Sacrifice: DEBUG --
                if (TehrsCDs._externCDs_paladins == nil) then TehrsCDs._externCDs_paladins = { } end
                if (TehrsCDs._externCDs_paladins[sourceName] == nil) then TehrsCDs._externCDs_paladins[sourceName] = { } end
                
                TehrsCDs._externCDs_paladins[sourceName]["Sac"] = GetTime() + 120;   
                
                if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end                       
            end
        end
        
        -- BOP --
        
        if(spellID == 1022 and TehrsCDs["Show Settings"].BoP and eventType == "SPELL_CAST_SUCCESS") then
            -- Blessing of Protection --
            if (TehrsCDs._utilityCDs_paladins == nil) then TehrsCDs._utilityCDs_paladins = { } end
            if (TehrsCDs._utilityCDs_paladins[sourceName] == nil) then TehrsCDs._utilityCDs_paladins[sourceName] = { } end
            if (TehrsCDs._externCDs_paladins == nil) then TehrsCDs._externCDs_paladins = { } end
            if (TehrsCDs._externCDs_paladins[sourceName] == nil) then TehrsCDs._externCDs_paladins[sourceName] = { } end        
            
            local bop1u = TehrsCDs._utilityCDs_paladins[sourceName]["BoP"];
            local bop2e = TehrsCDs._externCDs_paladins[sourceName]["BoP"];          
            
            -- BoP, Utility
            if (bop1u ~= nil) then
                TehrsCDs._utilityCDs_paladins[sourceName]["BoP"] = GetTime() + 300;
            end
            
            -- BoP, External            
            if (bop2e ~= nil) then
                TehrsCDs._externCDs_paladins[sourceName]["BoP"] = GetTime() + 300;
            end
            
            if TehrsCDs.DEBUG and TehrsCDs.DEBUG_Engine then print("Engine: "..sourceName.." cast "..spellName) end    
        end
        
        if TehrsCDs["Custom Abilities"].CustomAbilities then
            TehrsCDs["Custom Abilities"].UseCDs(event, arg1, eventType, arg2, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool)
        end
    end
end
