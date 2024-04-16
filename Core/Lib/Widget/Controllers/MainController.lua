--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, MSG, E = ns.O, ns.GC, ns.GC.M, ns.GC.E
local WMX = O.WidgetMixin
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'MainController'
--- @class MainController
local L = ns:NewLib(libName)
local p = ns:CreateDefaultLogger(libName)
--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function _l1() return "OnPlayerEnteringWorld(): Sending message [%s]", MSG.OnAddOnReady end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o MainController | ModuleV2
local function PropsAndMethods(o)

    function o.OnPlayerEnteringWorld(event, src, ...)
        local isLogin, isReload = ...

        p:f1(_l1)
        o:SendMessage(MSG.OnAddOnReady, ns.name)

        --@debug@
        isLogin = true
        --@end-debug@

        if not isLogin then return end

        local pa = ns:CreateDefaultLogger(ns.name)
        pa:a(GC:GetMessageLoadedText())
    end

    function o.OnAddOnInitialized(event, src, ...)
        o:RegisterAddOnMessage(E.PLAYER_ENTERING_WORLD, o.OnPlayerEnteringWorld)
    end

    o:RegisterMessage(MSG.OnAddOnInitialized, o.OnAddOnInitialized)

end; PropsAndMethods(L)
