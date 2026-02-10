--- @type Namespace_ABP_BarsUI
local ns = select(2, ...)
local p, t1, t2 = ns:log()

--- @class ABP_BarsUI
local a = ns:cns().AceAddon:NewAddon(ns.name, "AceEvent-3.0", "AceBucket-3.0", "AceConsole-3.0")
ABP_BarsUI = a
a:Enable()


C_Timer.After(1, function()
    p('AddOn created. name=', a:GetName())
end)
