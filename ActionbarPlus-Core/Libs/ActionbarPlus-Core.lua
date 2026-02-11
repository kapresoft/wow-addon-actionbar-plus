--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local p, t1, t2 = ns:log()
local AceAddon, DB = ns.O.AceAddon, ns.O.DatabaseMixin

--[[-------------------------------------------------------------------
AddOn: ActionbarPlus_Core
---------------------------------------------------------------------]]
--- @alias ABP_Core_2_0 AceAddonObj | AceEvent | AceBucketObj | AceConsole | Database_ABP_2_0
--- @class ABP_Core_2_0_Impl : AceAddonObj
local A = AceAddon:NewAddon(ns.name, "AceEvent-3.0", "AceBucket-3.0", "AceConsole-3.0")
--ActionbarPlus_Core = ABP_Core

--- @type ABP_Core_2_0_Impl | ABP_Core_2_0
local o = A

-- Called once, after:
-- • SavedVariables are loaded
-- • All addon Lua/XML files are loaded
-- • Init default AceDB
function o:OnInitialize()
  DB:InitDb(self)
  C_Timer.After(1, function()
    p('xx OnEnable:: db init:', ns:db().keys)
  end)
end

function o:OnEnable()
  --C_Timer.After(1, function() p('xx OnEnable...') end)
end
