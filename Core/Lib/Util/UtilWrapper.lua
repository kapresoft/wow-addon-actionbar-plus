--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = ABP_Namespace(...)
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()

---@type Kapresoft_LibUtil_Assert
local Assert = Kapresoft_LibUtil_Assert()
Core:Register(Core.M.Assert, Assert)

---@type Kapresoft_LibUtil_Table
local Table = Kapresoft_LibUtil_Table()
Core:Register(Core.M.Table, Table)

---@typ Kapresoft_LibUtil_String
local String = Kapresoft_LibUtil_String()
Core:Register(Core.M.String, String)

ABP_CreateIncrementer = Kapresoft_LibUtil_CreateIncrementer

---@type Kapresoft_LibUtil_Mixin
local Mixin = Kapresoft_LibUtil_Mixin()
Core:Register(Core.M.Mixin, Mixin)

---@type Kapresoft_LibUtil_LuaEvaluator
local LuaEvaluator = Kapresoft_LibUtil_LuaEvaluator()
Core:Register(Core.M.LuaEvaluator, LuaEvaluator)
