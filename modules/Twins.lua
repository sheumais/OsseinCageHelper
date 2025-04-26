OCH = OCH or {}
local OCH = OCH

OCH.Twins = {
    titanicClashActive = false,
    titanicClashTimestamp = 0,
    debuffAssignments = {},
}

OCH.Twins.constants = {
    sparkstorm_fortification = 234502, -- conjurer shield
    blazeforged_fortification = 234507, -- conjurer shield
    titanic_clash_jynorah = 232316, -- fly away id
    titanic_clash_skorkhif = 232317, -- fly away id
    myrinax_spawn = 233477, -- dropping into arena
    valneer_spawn = 233489, -- dropping into arena
    titanic_clash_length = 35, -- 35 seconds from fly away to beam hit
    myrinax_color = {51, 153, 255, 217},
    myrinax_hex = 0x3399FFD9,
    valneer_color = {255, 87, 51, 217},
    valneer_hex = 0xFF5733D9,
    reflective_scales_valneer = 233330, -- damage to player by dragon from dots
    reflective_scales_myrinax = 233321, -- damage to player by dragon from dots
    -- surge kite timer like lt dan
}

function OCH.Twins.Init()
    OCH.Twins.titanicClashActive = false
    OCH.Twins.titanicClashTimestamp = 0
    OCH.Twins.debuffAssignments = {}
    OCHStatusLabelTwins1:SetHidden(true)
    OCHStatusLabelTwins1Value:SetHidden(true)
end

function OCH.Twins.TitanClashTimer(result, hitValue)
    if result == ACTION_RESULT_BEGIN and hitValue > 500 then
        OCH.Twins.titanicClashActive = true
        OCH.Twins.titanicClashTimestamp = GetGameTimeSeconds()
    end
end

function OCH.Twins.TitanicClash(result, hitValue)
    if result == ACTION_RESULT_BEGIN and hitValue > 500 then
        CombatAlerts.Alert(nil, "Titanic Clash", 0xFF5555FF, nil, hitValue)
        LibCombatAlerts.PlaySounds("DUEL_BOUNDARY_WARNING", 2, 100, "DUEL_BOUNDARY_WARNING", 4)
    end
    local jynorah = nil
    local skorkhif = nil
    for i = 1,MAX_BOSSES do
        local name = string.lower(GetUnitName("boss" .. tostring(i)))
        if string.match(name, string.lower(OCH.data.jynorah)) then
            jynorah = "boss" .. tostring(i)
        elseif string.match(name, string.lower(OCH.data.skorkhif)) then
            skorkhif = "boss" .. tostring(i)
        end
    end
    local jynorah_health, _, _ = GetUnitPower(jynorah, POWERTYPE_HEALTH)
    local skorkhif_health, _, _ = GetUnitPower(skorkhif, POWERTYPE_HEALTH)
    if jynorah_health > skorkhif_health then 
        OCHStatusLabelTwins1:SetText("Myrinax wins:")
        local color = OCH.Twins.constants.myrinax_color
        OCHStatusLabelTwins1:SetColor(unpack(color))
        OCHStatusLabelTwins1Value:SetColor(unpack(color))
    else 
        OCHStatusLabelTwins1:SetText("Valneer wins:")
        local color = OCH.Twins.constants.valneer_color
        OCHStatusLabelTwins1:SetColor(unpack(color))
        OCHStatusLabelTwins1Value:SetColor(unpack(color))
    end
end

function OCH.Twins.DragonLanding(result, hitValue)
    if result == ACTION_RESULT_BEGIN and hitValue > 500 then
        CombatAlerts.Alert(nil, "Dragon Landing", 0xFF5555FF, SOUNDS.CHAMPION_POINTS_COMMITTED, hitValue)
    end
end

function OCH.Twins.ReflectiveScalesValneer(result, hitValue, targetName)
    if result == ACTION_RESULT_DAMAGE and hitValue > 500 and targetName == OCH.playerRawName then
        CombatAlerts.Alert(nil, "Reflective Scales", OCH.Twins.constants.valneer_hex, nil, hitValue)
        LibCombatAlerts.PlaySounds("SCRYING_ACTIVATE_BOMB", 2, nil)
    end
end

function OCH.Twins.ReflectiveScalesMyrinax(result, hitValue, targetName)
    if result == ACTION_RESULT_DAMAGE and hitValue > 500 and targetName == OCH.playerRawName then
        CombatAlerts.Alert(nil, "Reflective Scales", OCH.Twins.constants.myrinax_hex, nil, hitValue)
        LibCombatAlerts.PlaySounds("SCRYING_ACTIVATE_BOMB", 2, nil)
    end
end

function OCH.Twins.TitanicClashUpdateTick(timeSec)
    OCHStatusLabelTwins1:SetHidden(false)
    OCHStatusLabelTwins1Value:SetHidden(false)
    local delta = timeSec - OCH.Twins.titanicClashTimestamp

    local timeLeft = 0
    timeLeft = OCH.Twins.constants.titanic_clash_length - delta
    OCHStatusLabelTwins1Value:SetText(OCH.GetSecondsRemainingString(timeLeft))

    if delta > (OCH.Twins.constants.titanic_clash_length + 5) then -- little extra wiggle room for people to get off pad
        OCH.Twins.titanicClashActive = false
        OCH.Common.ResetCarrionStacks()
    end
end

-- /script d(OCH.Twins.titanicClashActive)
function OCH.Twins.UpdateTick(timeSec)
    if OCH.Twins.titanicClashActive then 
        LCHStatus:SetHidden(false)
        OCH.Twins.TitanicClashUpdateTick(timeSec)
    else 
        OCHStatusLabelTwins1:SetHidden(true)
        OCHStatusLabelTwins1Value:SetHidden(true)
    end
end