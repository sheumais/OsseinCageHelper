OCH = OCH or {}
local OCH = OCH

OCH.prefix = "|c007FFF[OCH]:|r "

-- Level of debug output
-- 1: Low    - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High   - Everything
OCH.debugMode = 0

function OCH:Trace(debugLevel, ...)
    if debugLevel <= OCH.debugMode then
      local message = zo_strformat(...)
      d(OCH.prefix .. message)
    end
end