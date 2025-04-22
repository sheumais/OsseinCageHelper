OCH = OCH or {}
local OCH = OCH
OCH.Common = {}

OCH.Common.DodgeIDs = {
    [236569] = { -2, 1}, -- Spectral Revenge
    [239158] = { -3, 1, true}, -- Taking Aim
    [236473] = { -3, 2}, -- Ethereal Burst
    [245140] = { -3, 1},
}

OCH.Common.constants = {
    caustic_carrion_id = 241089,
}

function OCH.Common.AddToCCADodgeList()
    for k, v in pairs(OCH.Common.DodgeIDs) do
      CombatAlertsData.dodge.ids[k] = v
    end
end

function OCH.Common.Init()
  OCH.Common.castSources = {}
end

function OCH.Common.ProcessInterrupts(result, targetUnitId) 
    if (CombatAlertsData.dodge.interrupts[result] and OCH.Common.castSources[targetUnitId]) then
		CombatAlerts.CastAlertsStop(OCHCH.Common.castSources[targetUnitId])
    end
end

function OCH.Common.CausticCarrion(result, targetType, targetUnitId, hitValue)
    local borderId = "caustic_carrion"

    if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
        if targetType == COMBAT_UNIT_TYPE_PLAYER then
            CombatAlerts.ScreenBorderEnable(0x007FFF99, hitValue, borderId)
        end
  
    elseif result == ACTION_RESULT_EFFECT_FADED then
        if targetType == COMBAT_UNIT_TYPE_PLAYER then
            CombatAlerts.ScreenBorderDisable(borderId)
        end
    end
end