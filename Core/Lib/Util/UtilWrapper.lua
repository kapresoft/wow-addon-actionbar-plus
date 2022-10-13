--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local Core, K = ABP_Namespace(...).Core, Kapresoft_LibUtil

Core:Register(Core.M.Assert, K.Assert)
Core:Register(Core.M.Table, K.Table)
Core:Register(Core.M.String, K.String)
Core:Register(Core.M.Mixin, K.Mixin)
Core:Register(Core.M.LuaEvaluator, K.LuaEvaluator)

ABP_CreateIncrementer = Kapresoft_LibUtil_CreateIncrementer
