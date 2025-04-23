OCH = OCH or {}
local OCH = OCH

OCH.Twins = {
    titanicClashActive = false,
    debuffAssignments = {},
}

OCH.Twins.Constants = {
    sparkstorm_fortification = 234502,
    blazeforged_fortification = 234507,
    titanic_clash_jynorah = 232375,
    titanic_clash_skorkhif = 232376,
}

function OCH.Twins.TitanicClash(result, hitValue)
    if result == ACTION_RESULT_BEGIN and hitValue > 500 then
        CombatAlerts.Alert(nil, "Titanic Clash", 0xFF5555FF, nil, hitValue)
        LibCombatAlerts.PlaySounds("DUEL_BOUNDARY_WARNING", 2, 100, "DUEL_BOUNDARY_WARNING", 4)
    end
end