--[[-----------------------------------------------------------------------------
This Controller Handles keypress Updates
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, E, MSG = ns.O, ns.GC.E, ns.GC.E
local libName = 'ModifierStateChangeController'
local event2 = ns:AceEvent()
local toMsg = ns.GC.toMsg
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class ModifierStateChangeController
local L = ns:NewController(libName)
local p = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o ModifierStateChangeController | ControllerV2
local function PropsAndMethods(o)

    function o:OnAddOnReady()
        if not ns:IsRetail() then return end
        ----- Retail Only -----
        O.API:SyncUseKeyDownActionButtonSettings()
    end

    function o:OnModifierStateChangedRetailOnly(keyPressed, downPress)
        local isModKeyDown = O.API:IsDragKeyDown()
        if isModKeyDown ~= true then return end
        -- This will only occur if Mod key is on keyDown
        p:f1(function()
            return "keyPressed=%s downPress=%s modKey=%s OnModifierStateChangedRetailOnly()",
                        keyPressed, downPress, isModKeyDown end)

        O.API:SyncUseKeyDownActionButtonSettings()
    end

end; PropsAndMethods(L)

