--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()

local Assert = Kapresoft_LibUtil_Assert()
Core:Register(Core.M.Assert, Assert)

local Table = Kapresoft_LibUtil_Table()
Core:Register(Core.M.Table, Table)

local String = Kapresoft_LibUtil_String()
Core:Register(Core.M.String, String)

ABP_CreateIncrementer = Kapresoft_LibUtil_CreateIncrementer

local Mixin = Kapresoft_LibUtil_Mixin()
Core:Register(Core.M.Mixin, Mixin)

local LuaEvaluator = Kapresoft_LibUtil_LuaEvaluator()
Core:Register(Core.M.LuaEvaluator, LuaEvaluator)

