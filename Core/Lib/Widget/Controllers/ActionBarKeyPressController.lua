--[[-----------------------------------------------------------------------------
This Controller Handles keypress Updates
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, E, MSG = ns.O, ns.GC.E, ns.GC.E
local libName = 'ActionBarKeyPressController'
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class ActionBarKeyPressController
local L = ns:NewLib(libName)
local p = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o ActionBarKeyPressController | ModuleV2
local function PropsAndMethods(o)

    function o:OnAddOnReady()
        self.isRetail = ns:IsRetail()

        O.API:SyncUseKeyDownActionButtonSettings()

        if self.isRetail ~= true then return end

        self:RegisterAddOnMessage(E.MODIFIER_STATE_CHANGED,
                function(evt, source, ...) self:OnModifierStateChanged(...)
        end)
    end

    function o:OnModifierStateChanged(keyPressed, downPress)
        local isModKeyDown = O.API:IsDragKeyDown()
        if isModKeyDown ~= true then return end

        -- This will only occur if Mod key is on keyDown
        p:vv(function() return "keyPressed=%s downPress=%s modKey=%s", keyPressed, downPress, isModKeyDown end)
        O.API:SyncUseKeyDownActionButtonSettings()
    end

end; PropsAndMethods(L)

