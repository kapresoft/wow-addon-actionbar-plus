--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns       = select(2, ...)
local O, GC    = ns.O, ns.GC
local api, mcu = O.API, O.MacroUtil

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = ns.M.MacroModifierStateChangeController
--- @class MacroModifierStateChangeController
local L = ns:NewController(libName); if not L then return end
local p = ns:LC().MACRO:NewLogger(libName)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @type MacroModifierStateChangeController | ControllerV2
local o = L

--[[-----------------------------------------------------------------------------
Methods: MacroModifierStateChangeController
This controller should only update the current icon associated with the macro
-------------------------------------------------------------------------------]]

--- Automatically called
--- @private
--- @see ModuleV2Mixin#Init
function o:OnAddOnReady()
    self:RegisterAddOnMessage(GC.E.MODIFIER_STATE_CHANGED, self.OnModifierStateChanged)
end

--- @param keyPressed string
--- @param downPress BooleanInt | "1" | "0"
function o.OnModifierStateChanged(evt, source, keyPressed, downPress)
    mcu:UpdateIconsDelayed(o)
end

