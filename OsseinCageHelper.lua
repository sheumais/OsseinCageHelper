OCH = OCH or {}
local OCH = OCH

OCH.name = "OsseinCageHelper"
OCH.debug = false
OCH.status = {
    isHMBoss = false,
    isShapers = false,
    isTwins = false,
    isKazpian = false,
    carrion = {},
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
end

local DEBUG_EVENT = 3

function OCH.CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    -- local eventLog = {
    --     timestamp = GetTimeStamp(),
    --     eventCode = eventCode,
    --     result = result,
    --     isError = isError,
    --     abilityName = abilityName,
    --     abilityGraphic = abilityGraphic,
    --     abilityActionSlotType = abilityActionSlotType,
    --     sourceName = sourceName,
    --     sourceType = sourceType,
    --     targetName = targetName,
    --     targetType = targetType,
    --     hitValue = hitValue,
    --     powerType = powerType,
    --     damageType = damageType,
    --     log = log,
    --     sourceUnitId = sourceUnitId,
    --     targetUnitId = targetUnitId,
    --     abilityId = abilityId,
    --     overflow = overflow
    -- }
    -- table.insert(OCH.sV.dataExport, eventLog)
    if DEBUG_EVENT <= OCH.debugMode then
        if result == ACTION_RESULT_BEGIN and sourceType == COMBAT_UNIT_TYPE_NONE then
            local displaySourceName = sourceName or GetUnitDisplayName(OCH.GetTagForId(sourceUnitId)) or ""
            local displayTargetName = GetUnitDisplayName(OCH.GetTagForId(targetUnitId)) or ""
            OCH:Trace(DEBUG_EVENT, string.format(
            "Ability: %s, ID: %d, Hit Value: %d, Source name: %s, Target name: %s",
            GetFormattedAbilityName(abilityId), abilityId, hitValue, displaySourceName, displayTargetName
            ))
        end
    end

    OCH.Common.ProcessInterrupts(result, targetUnitId)

    -- Handle events
    if abilityId == OCH.Common.constants.caustic_carrion_id then
        OCH.Common.CausticCarrion(result, targetType, targetUnitId, hitValue)
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

function OCH.PlayerActivated(e, initial)
    EVENT_MANAGER:UnregisterForEvent(OCH.name .. "BossChange", EVENT_BOSSES_CHANGED, OCH.BossesChanged)
    EVENT_MANAGER:UnregisterForEvent(OCH.name .. "CombatEvent", EVENT_COMBAT_EVENT )
    EVENT_MANAGER:UnregisterForEvent(OCH.name .. "Buffs", EVENT_EFFECT_CHANGED )

    -- if GetZoneId(GetUnitZoneIndex("player")) ~= OCH.data.osseinCageID then return end
    if OCH.debug then d("Registering for Ossein Cage events") end

    EVENT_MANAGER:RegisterForEvent(OCH.name .. "BossChange", EVENT_BOSSES_CHANGED, OCH.BossesChanged)
    EVENT_MANAGER:RegisterForEvent(OCH.name .. "CombatEvent", EVENT_COMBAT_EVENT, OCH.CombatEvent)
    EVENT_MANAGER:RegisterForEvent(OCH.name .. "Buffs", EVENT_EFFECT_CHANGED, OCH.EffectChanged)
end

local function OnAddOnLoaded(_, name)
    if name ~= OCH.name then return end
    EVENT_MANAGER:UnregisterForEvent(OCH.name, EVENT_ADD_ON_LOADED)
    OCH.sV = ZO_SavedVars:NewAccountWide("OCHSavedVariables", 1, nil, {})
    OCH.sV.dataExport = OCH.sV.dataExport or {}
    OCH.Common.AddToCCADodgeList()
    OCH.Common.Init()
    EVENT_MANAGER:RegisterForEvent(OCH.name .. "PlayerActived", EVENT_PLAYER_ACTIVATED, OCH.PlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(OCH.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)