--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M = ns.O, ns.GC, ns.M
local libName = M.M6Support
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class M6Support : AceEvent
--- @field enabled Enabled ActionbarPlus needs to know if ActionbarPlus-M6 is enabled otherwise it won't accept a drag-n-drop from M6.
local L = ns:NewLibWithEvent(libName)
local p = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o M6Support
local function PropsAndMethods(o)

    function o:OnAddOnReady()
        o.enabled = O.API:IsActionbarPlusM6Enabled() == true
        p:f3(function() return 'ActionbarPlus-M6 enabled: %s', tostring(o.enabled) end)
    end

    L:RegisterMessage(ns.GC.M.OnAddOnReady, function() o:OnAddOnReady() end)
end; PropsAndMethods(L)


