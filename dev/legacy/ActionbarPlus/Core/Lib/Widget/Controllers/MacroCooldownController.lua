--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns       = select(2, ...)
local O, GC    = ns.O, ns.GC
local api, mcu, cdu = O.API, O.MacroUtil, O.CooldownUtil

local THROTTLE_INTERVAL_MACRO_UPDATES = 0.3

--- @type C_TimerTicker
local unregisterTask
--- @type table
local spellUpdateUsableHandle

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'MacroCooldownController'
--- @class MacroCooldownController
local L = ns:NewController(libName, O.ThrottledUpdaterMixin); if not L then return end
local p = ns:LC().MACRO:NewLogger(libName)

--- @type MacroCooldownController | ControllerV2
local o = L

--[[-----------------------------------------------------------------------------
Methods

Cooldowns need update when
- The SPELL_UPDATE_COOLDOWN is fired
- MODIFIER_STATE_CHANGED is fired
- After an action drag completes
-------------------------------------------------------------------------------]]

--- Automatically called
--- @see ModuleV2Mixin#Init
--- @private
function o:OnAddOnReady()
    self:RegisterAddOnMessage(GC.E.MODIFIER_STATE_CHANGED, o.OnModifierStateChanged)
    self:RegisterMessage(GC.M.OnAfterReceiveDrag, o.OnAfterReceiveDrag)
    self:RegisterAddOnMessage(GC.E.SPELL_UPDATE_COOLDOWN, o.OnSpellUpdateCooldown)
    self:RegisterAddOnMessage(GC.E.ACTIONBAR_UPDATE_COOLDOWN, o.OnSpellUpdateCooldown)
    mcu:UpdateCooldowns(o)
end

function o.OnSpellUpdateCooldown() mcu:UpdateCooldowns(o) end
function o.OnAfterReceiveDrag()
    mcu:UpdateCooldowns(o)
end

--- This part is essential for macros with conditionals. For example, /cast [mod:shift] Renew; Lesser Heal
---@param keyPressed string
---@param downPress number | "1" | "0"
function o.OnModifierStateChanged(evt, source, keyPressed, downPress) mcu:UpdateCooldowns(o) end

