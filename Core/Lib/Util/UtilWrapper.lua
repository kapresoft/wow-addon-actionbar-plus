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

---@param start number
---@param increment number
---@return Kapresoft_LibUtil_Incrementer
function ns:CreateIncrementer(start, increment) return Kapresoft_LibUtil_CreateIncrementer(start, increment) end

