OCH = OCH or {}
local OCH = OCH

OCH.Kazpian = {
    lastChains = 0,
    lastBombs = 0,
    chainsActive = false,
    chainedPlayer1 = nil,
    chainedPlayer2 = nil,
}

OCH.Kazpian.constants = {
    tether_cast = 232772,
    tether_a_predebuff = 232773,
    tether_b_predebuff = 232775,
    tether_b_actual = 232779,
    tether_a_actual = 232780,
    sword_pulse = 235495,
    sword_pulse_bridge = 233025,
    sword_cones = 232574,
    portal_phase = 233589,
}

function OCH.Kazpian.AddDominatorsChains(unitTag)
    if (OCH.Kazpian.chainedPlayer1 == unitTag or OCH.Kazpian.chainedPlayer2 == unitTag) then return end

    local iconPath = "esoui/art/icons/ability_u46_dominatorschains_dot.dds"
    OCH.AddIcon(unitTag, iconPath)

    if (not chainsPlayer1) then
        OCH.Kazpian.chainedPlayer1 = unitTag
    else
        OCH.Kazpian.chainedPlayer2 = unitTag
        local title = GetUnitDisplayName(OCH.Kazpian.chainedPlayer1) .. " & " .. GetUnitDisplayName(OCH.Kazpian.chainedPlayer2)
        CombatAlerts.Alert("Dominator's Chains", title, 0x7F7FFFFF, SOUNDS.BLACKSMITH_IMPROVE_TOOLTIP_GLOW_FAIL, hitValue)
        OCH.Kazpian.lastChains = GetGameTimeSeconds()
    end
end

function OCH.Kazpian.RemoveDominatorsChains()
    OCH.RemoveIcon(OCH.Kazpian.chainedPlayer1)
    OCH.RemoveIcon(OCH.Kazpian.chainedPlayer2)
    OCH.Kazpian.chainedPlayer1 = nil
    OCH.Kazpian.chainedPlayer2 = nil
    OCH.Kazpian.chainsActive = false
end

function OCH.Kazpian.DominatorsChainsInitial(changeType, unitTag)
    if changeType == EFFECT_RESULT_GAINED then
        OCH.Kazpian.AddDominatorsChains(unitTag)
    elseif changeType == EFFECT_RESULT_FADED then -- targets died before tether was real
        if OCH.Kazpian.chainsActive then return end
        OCH.Kazpian.RemoveDominatorsChains()
    end
end

function OCH.Kazpian.DominatorsChainsTether(changeType, unitTag)
    if changeType == EFFECT_RESULT_GAINED then
        OCH.Kazpian.chainsActive = true
    elseif changeType == EFFECT_RESULT_FADED then
        OCH.Kazpian.chainsActive = false
        OCH.Kazpian.RemoveDominatorsChains()
    end
end

function OCH.Kazpian.SwordPulseSpawn(result, hitValue, targetUnitId)
    if result == ACTION_RESULT_BEGIN and hitValue > 500 then
        local targetName = OCH.GetNameForId(targetUnitId)
        CombatAlerts.Alert(targetName, "Sword (Pulse)", 0xCCFFFFFF, SOUNDS.CHAMPION_POINTS_COMMITTED, hitValue)
    end
end

function OCH.Kazpian.SwordPulseSpawnBridge(result, hitValue)
    if result == ACTION_RESULT_BEGIN and hitValue > 500 then
        local targetName = OCH.GetNameForId(targetUnitId)
        CombatAlerts.Alert(nil, "Sword (Bridge)", 0xCCFFFFFF, SOUNDS.CHAMPION_POINTS_COMMITTED, hitValue)
    end
end

function OCH.Kazpian.SwordConesSpawn(result, hitValue, targetUnitId)
    if result == ACTION_RESULT_BEGIN and hitValue > 500 then
        local targetName = OCH.GetNameForId(targetUnitId)
        CombatAlerts.Alert(targetName, "Sword (Cones)", 0xCCFFFFFF, SOUNDS.CHAMPION_POINTS_COMMITTED, hitValue)
    end
end

function OCH.Kazpian.StartPortalPhase(result, hitValue)
    if result == ACTION_RESULT_BEGIN then
        CombatAlerts.Alert(nil, "Portal Phase", 0xCCFFFFFF, nil, hitValue)
    end
end