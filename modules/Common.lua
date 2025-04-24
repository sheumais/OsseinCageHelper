OCH = OCH or {}
local OCH = OCH
OCH.Common = {}

--[[ Options ---------------------------------------
1: Size of alert window
    0: None
    >0: Time, in milliseconds
    -1: Default (auto-detect)
    -2: Default (melee)
    -3: Default (projectile)
2: Alert text/ping (ignored if alert window is 0)
    0: Never
    1: Always
    2: Suppressed for tanks
3: Interruptible (optional, default false)
4: Color, regular (optional)
5: Color, alerted (optional)
vet: Vet-only?
offset: Offset to reported hitValue, in milliseconds
--------------------------------------------------]]
OCH.Common.DodgeIDs = {
    [236569] = { -2, 1 }, -- Spectral Revenge
    [239158] = { -3, 1, true}, -- Taking Aim
    [236473] = { -3, 2 }, -- Ethereal Burst
    [236458] = { -3, 1 }, -- Potent Ethereal Burst
    [245140] = { -3, 1 }, -- Incinerating Bolt
    [245131] = { -3, 1 }, -- Sparking Bolt
    [234678] = { -2, 2 }, -- Jagged Claw
    [234634] = { -2, 2 }, -- Burning Jaws
    [236356] = { -2, 2 }, -- Swipe
    [236379] = { -2, 2 }, -- Bat
    -- [232397] = { 3000, 2}, -- Effluvial Expellant
}

OCH.Common.constants = {
    caustic_carrion_id = 241089,
    caustic_carrion_id2 = 240708,
    abduct = 233762,
}

function OCH.Common.AddToCCADodgeList()
    for k, v in pairs(OCH.Common.DodgeIDs) do
        CombatAlertsData.dodge.ids[k] = v
    end
end

function OCH.Common.Init()
    OCH.Common.castSources = {}
    OCH.Common.ResetCarrionStacks()
end

function OCH.Common.ProcessInterrupts(result, targetUnitId) 
    if (CombatAlertsData.dodge.interrupts[result] and OCH.Common.castSources[targetUnitId]) then
		CombatAlerts.CastAlertsStop(OCH.Common.castSources[targetUnitId])
    end
end

function OCH.Common.ResetCarrionStacks()
    EVENT_MANAGER:UnregisterForUpdate(OCH.name .. "CarrionTimeout")
    local borderId = "caustic_carrion"
    OCH.Common.carrionStacks = {}
    OCH.Common.playerCarrionStacks = 0
    OCH.Common.maxCarrionStacks = 0
    CombatAlerts.ScreenBorderDisable(borderId)
    OCHStatusLabelCommon1:SetHidden(true)
    OCHStatusLabelCommon1Value:SetHidden(true)
end

function OCH.Common.CausticCarrion(changeType, stackCount, unitTag)
    local borderId = "caustic_carrion"
    local is_player = AreUnitsEqual(unitTag, "player")
    EVENT_MANAGER:UnregisterForUpdate(OCH.name .. "CarrionTimeout")

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        OCH.Common.carrionStacks[unitTag] = stackCount
        OCHStatusLabelCommon1:SetHidden(false)
        OCHStatusLabelCommon1Value:SetHidden(false)
        if is_player then
            CombatAlerts.ScreenBorderEnable(0x007FFF55, 3000, borderId)
        end
    end

    OCH.Common.playerCarrionStacks = is_player and (stackCount or 0) or OCH.Common.playerCarrionStacks
    OCH.Common.maxCarrionStacks = 0
    for tag, stacks in pairs(OCH.Common.carrionStacks) do
        if stacks > OCH.Common.maxCarrionStacks then
            OCH.Common.maxCarrionStacks = stacks
        end
    end
    OCHStatusLabelCommon1Value:SetText(zo_strformat("<<1>> (<<2>>)", OCH.Common.playerCarrionStacks, OCH.Common.maxCarrionStacks))
    EVENT_MANAGER:RegisterForUpdate(OCH.name .. "CarrionTimeout", 3000, OCH.Common.ResetCarrionStacks)
end