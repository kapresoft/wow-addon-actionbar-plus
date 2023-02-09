---
--- This is where external libraries are integrated into our local source
---
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local K = ns.K().Objects

ns:Register(ns.M.Assert, K.Assert)
ns:Register(ns.M.Table, K.Table)
ns:Register(ns.M.String, K.String)
ns:Register(ns.M.Mixin, K.Mixin)
ns:Register(ns.M.LuaEvaluator, K.LuaEvaluator)
ns:Register(ns.M.AceLibrary, K.AceLibrary.O)
ns:Register(ns.M.Safecall, K.Safecall)
