--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = ABP_Namespace(...)
local Core, K = ns.Core, Kapresoft_LibUtil

Core:Register(Core.M.Assert, K.Assert)
Core:Register(Core.M.Table, K.Table)
Core:Register(Core.M.String, K.String)
Core:Register(Core.M.Mixin, K.Mixin)
Core:Register(Core.M.LuaEvaluator, K.LuaEvaluator)
Core:Register(Core.M.AceLibrary, K.AceLibrary.O)

