OCH = OCH or {}
local OCH = OCH

OCH.name = "OsseinCageHelper"
OCH.version = "v0.3"
OCH.status = {
    isHMBoss = false,
    isShapers = false,
    isTwins = false,
    isKazpian = false,
    carrion = {},
    inCombat = false,
}

OCH.data = {
    valneer = "Blazeforged Valneer",
    myrinax = "Sparkstorm Myrinax",
    jynorah = "Jynorah",
    skorkhif = "Skorkhif",
    flesh_shapers = "Shaper of Flesh",
    kazpian = "Overfiend Kazpian",
    osseinCageID = 1548
}

OCH.units = {}
OCH.unitsTag = {}

function OCH.EffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    OCH.IdentifyUnit(unitTag, unitName, unitId)
    -- EFFECT_RESULT_GAINED = 1
    -- EFFECT_RESULT_FADED = 2
    -- EFFECT_RESULT_UPDATED = 3

    if abilityId == OCH.Common.constants.caustic_carrion_id then
        OCH.Common.CausticCarrion(changeType, stackCount, unitTag)
    elseif abilityId == OCH.Common.constants.caustic_carrion_id2 then
        OCH.Common.CausticCarrion(changeType, stackCount, unitTag)
    elseif abilityId == OCH.Kazpian.constants.tether_a_predebuff then

    elseif abilityId == OCH.Kazpian.constants.tether_b_predebuff then

    elseif abilityId == OCH.Kazpian.constants.tether_b_actual then

    elseif abilityId == OCH.Kazpian.constants.tether_a_actual then
        
    end
end

local DEBUG_EVENT = 3

local ignoredAbilityIds = {
    [193398] = true, --pragmatic fatecarver
    [193397] = true, --exhausting fatecarver
    [183006] = true, --cephaliarch's flail
}

function OCH.CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    
    if DEBUG_EVENT <= OCH.debugMode then
        if not ignoredAbilityIds[abilityId] then
            if result == ACTION_RESULT_BEGIN and sourceType == COMBAT_UNIT_TYPE_NONE then
                local displayTargetName = GetUnitDisplayName(OCH.GetTagForId(targetUnitId)) or ""
                OCH:Trace(DEBUG_EVENT, string.format(
                    "Ability: %s, ID: %d, Hit Value: %d, Target name: %s",
                    GetFormattedAbilityName(abilityId), abilityId, hitValue, displayTargetName
                ))
            end
        end
    end

    -- OCH.Common.ProcessInterrupts(result, targetUnitId) -- currently broken idk im just gonna disable it because it's not very useful anyway. TODO

    -- Handle events
    if abilityId == OCH.Kazpian.constants.sword_pulse then
        OCH.Kazpian.SwordPulseSpawn(result, hitValue, targetUnitId)
    elseif abilityId == OCH.Kazpian.constants.sword_cones then
        OCH.Kazpian.SwordConesSpawn(result, hitValue, targetUnitId)
    elseif abilityId == OCH.Kazpian.constants.sword_pulse_bridge then 
        OCH.Kazpian.SwordPulseSpawnBridge(result, hitValue)
    elseif abilityId == OCH.Kazpian.constants.portal_phase then 
        OCH.Kazpian.StartPortalPhase(result, hitValue)
    elseif abilityId == OCH.Twins.constants.titanic_clash_jynorah or abilityId == OCH.Twins.constants.titanic_clash_skorkhif then
        OCH.Twins.TitanicClash(result, hitValue)
    elseif abilityId == OCH.Twins.constants.myrinax_spawn or abilityId == OCH.Twins.constants.valneer_spawn then
        OCH.Twins.DragonLanding(result, hitValue)
    elseif abilityId == OCH.Twins.constants.titanic_clash_start then
        OCH.Twins.TitanClashTimer(result, hitValue)
    elseif abilityId == OCH.Twins.constants.reflective_scales_myrinax then
        OCH.Twins.ReflectiveScalesMyrinax(result, hitValue, targetUnitId)
    elseif abilityId == OCH.Twins.constants.reflective_scales_valneer then
        OCH.Twins.ReflectiveScalesValneer(result, hitValue, targetUnitId)
    end
end

function OCH.DeathState(event, unitTag, isDead)
    if unitTag == "player" and not isDead and not IsUnitInCombat("boss1") then
      OCH.ClearUIOutOfCombat()
    end
  end

function OCH.GetBossName()
    for i = 1,MAX_BOSSES do
        local name = string.lower(GetUnitName("boss" .. tostring(i)))
        if name ~= nil and name ~= "" then
            return name
        end
    end
    return ""
end

function OCH.BossesChanged(e, ...)
    local bossName = OCH.GetBossName()
    if bossName ~= nil then
        OCH.status.currentBoss = bossName
        OCH.status.isHMBoss = false
        OCH.status.isShapers = false
        OCH.status.isTwins = false
        OCH.status.isKazpian = false

        local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
        local hardmodeHealth = {
            [OCH.data.jynorah] = 70000000,
            [OCH.data.skorkhif] = 70000000,
            [OCH.data.flesh_shapers] = 8000000,
            [OCH.data.kazpian] = 100000000,
        }

        if bossName ~= nil and maxTargetHP ~= nil and hardmodeHealth[bossName] ~= nil then
            if maxTargetHP > hardmodeHealth[bossName] then
                OCH.status.isHMBoss = true
            end
        else
            OCH.status.isHMBoss = false
        end

        if string.match(bossName, string.lower(OCH.data.flesh_shapers)) then
            OCH.status.isShapers = true
        elseif string.match(bossName, string.lower(OCH.data.jynorah)) or string.match(bossName, string.lower(OCH.data.skorkhif)) then
            OCH.status.isTwins = true
        elseif string.match(bossName, string.lower(OCH.data.kazpian)) then
            OCH.status.isKazpian = true
        end
    end
end

function OCH.UpdateTick(gameTimeMs)
    local timeSec = GetGameTimeSeconds()
  
    if IsUnitInCombat("boss1") then
      if not OCH.status.inCombat then
        -- If it switched from non-combat to combat, re-check boss names.
        OCH.BossesChanged()
      end
      OCH.status.inCombat = true
    end
  
    if OCH.status.inCombat == false then
      return
    end
    
    if OCH.status.isShapers then
    --   OCH.Shapers.UpdateTick(timeSec)
    end
  
    if OCH.status.isTwins then
      OCH.Twins.UpdateTick(timeSec)
    end
  
    if OCH.status.isKazpian then
    --   OCH.Kazpian.UpdateTick(timeSec)
    end
  
  end


function OCH.PlayerActivated(e, initial)
    EVENT_MANAGER:UnregisterForEvent(OCH.name .. "BossChange", EVENT_BOSSES_CHANGED, OCH.BossesChanged)
    EVENT_MANAGER:UnregisterForEvent(OCH.name .. "CombatEvent", EVENT_COMBAT_EVENT )
    EVENT_MANAGER:UnregisterForEvent(OCH.name .. "Buffs", EVENT_EFFECT_CHANGED )
    EVENT_MANAGER:UnregisterForEvent(OCH.name .. "DeathState", EVENT_UNIT_DEATH_STATE_CHANGED, OCH.DeathState)

    OCHStatusLabelAddonName:SetText("Ossein Cage Helper " .. OCH.version)
    if GetZoneId(GetUnitZoneIndex("player")) ~= OCH.data.osseinCageID then return end
    if OCH.debugMode then d("Registering for Ossein Cage events") end

    EVENT_MANAGER:RegisterForEvent(OCH.name .. "BossChange", EVENT_BOSSES_CHANGED, OCH.BossesChanged)
    EVENT_MANAGER:RegisterForEvent(OCH.name .. "CombatEvent", EVENT_COMBAT_EVENT, OCH.CombatEvent)
    EVENT_MANAGER:RegisterForEvent(OCH.name .. "Buffs", EVENT_EFFECT_CHANGED, OCH.EffectChanged)
    EVENT_MANAGER:RegisterForEvent(OCH.name .. "DeathState", EVENT_UNIT_DEATH_STATE_CHANGED, OCH.DeathState)
end

local function OnAddOnLoaded(_, name)
    if name ~= OCH.name then return end
    EVENT_MANAGER:UnregisterForEvent(OCH.name, EVENT_ADD_ON_LOADED)
    OCH.sV = ZO_SavedVars:NewAccountWide("OCHSavedVariables", 1, nil, {})
    OCH.sV.combatEvents = OCH.sV.combatEvents or {}
    OCH.sV.effects = OCH.sV.effects or {}
    OCH.Common.AddToCCADodgeList()
    OCH.ClearUIOutOfCombat()
    OCH.RestorePosition()
    EVENT_MANAGER:RegisterForEvent(OCH.name .. "PlayerActived", EVENT_PLAYER_ACTIVATED, OCH.PlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(OCH.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)