--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local p, t1, t2 = ns:log()

--- @class ABP_Core : AceAddonObj
local A = ns.AceAddon:NewAddon(ns.name, "AceEvent-3.0", "AceBucket-3.0", "AceConsole-3.0")
--ActionbarPlus_Core = ABP_Core

--- @type ABP_Core
local o = A

-- Called once, after:
-- • SavedVariables are loaded
-- • All addon Lua/XML files are loaded
-- • Init default AceDB
function o:OnInitialize()
  C_Timer.After(1, function() p('xx OnInitialize...') end)
end

function o:OnEnable()
  C_Timer.After(1, function() p('xx OnEnable...') end)
end
