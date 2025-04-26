OCH = OCH or {}
local OCH = OCH

OCH.prefix = "|c007FFF[OCH]:|r "
OCH.debugMode = 0

function OCH:Trace(debugLevel, ...)
    if debugLevel <= OCH.debugMode then
      local message = zo_strformat(...)
      d(OCH.prefix .. message)
    end
end

function OCH.ClearUIOutOfCombat()
    OCH.HideAllUI(true)
    OCH.status.inCombat = false
    OCH.ResetAllPlayerIcons()
    OCH.Common.ResetCarrionStacks()
    OCH.Twins.Init()
end

function OCH.OnOCHStatusMove()
    OCH.sV.statusLeft = OCHStatus:GetLeft()
    OCH.sV.statusTop = OCHStatus:GetTop()
end

function OCH.HideAllUI(hide)
    OCHStatus:SetHidden(hide)
    OCHStatusLabelCommon1:SetHidden(hide)
    OCHStatusLabelCommon1Value:SetHidden(hide)
    OCHStatusLabelTwins1:SetHidden(hide)
    OCHStatusLabelTwins1Value:SetHidden(hide)
end

function OCH.RestorePosition()
    if OCH.sV.statusLeft ~= nil then
        OCHStatus:ClearAnchors()
        OCHStatus:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, OCH.sV.statusLeft, OCH.sV.statusTop)
    end
end

function OCH.DefaultPosition()
  OCH.savedVariables.statusLeft = nil
  OCH.savedVariables.statusTop = nil
end