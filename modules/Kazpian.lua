OCH = OCH or {}
local OCH = OCH

OCH.Kazpian = {
    lastChains = 0,
    lastBombs = 0,
}

OCH.Kazpian.constants = {
    tether_initial = 232772,
    tether_a_predebuff = 232773,
    tether_b_predebuff = 232775,
    sword_pulse = 235495,
    sword_cones = 232574,
}

-- CombatAlerts.Alert("", "Calamitous Sword", 0x99CCFFFF, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
-- LibCombatAlerts.PlaySounds("DUEL_BOUNDARY_WARNING", 2, 100, "DUEL_BOUNDARY_WARNING", 4)
-- CombatAlerts.Alert(nil, LCA.GetAbilityName(DATA.whirlwind.name), 0xFFFFCCFF, nil, 2000)
-- function CombatAlerts.Alert( textMinor, textMajor, color, sound, duration )

function OCH.Kazpian.DominatorsChains(result, hitValue)
    if result == ACTION_RESULT_BEGIN and hitValue > 500 then
        CombatAlerts.Alert(nil, "Dominator's Chains", 0x7F00FFFF, nil, hitValue)
        LibCombatAlerts.PlaySounds("DUEL_BOUNDARY_WARNING", 2, 100, "DUEL_BOUNDARY_WARNING", 4)
    end
end

function OCH.Kazpian.SwordPulseSpawn(result, hitValue, targetUnitId)
    if result == ACTION_RESULT_BEGIN and hitValue > 500 then
        local targetName = OCH.GetNameForId(targetUnitId)
        CombatAlerts.Alert(nil, "Sword (Pulse)", 0xCCFFFFFF, SOUNDS.CHAMPION_POINTS_COMMITTED, hitValue)
    end
end

function OCH.Kazpian.SwordConesSpawn(result, hitValue, targetUnitId)
    if result == ACTION_RESULT_BEGIN and hitValue > 500 then
        local targetName = OCH.GetNameForId(targetUnitId)
        CombatAlerts.Alert(nil, "Sword (Cones)", 0xCCFFFFFF, SOUNDS.CHAMPION_POINTS_COMMITTED, hitValue)
    end
end