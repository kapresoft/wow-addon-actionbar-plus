--This mixin handles events for the addon
--
--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFrame, FrameUtil = CreateFrame, FrameUtil
local RegisterFrameForEvents, RegisterFrameForUnitEvents = FrameUtil.RegisterFrameForEvents, FrameUtil.RegisterFrameForUnitEvents

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

local E, MSG, UnitId = GC.E, GC.M,  GC.UnitId
local B = O.BaseAPI
local AceEvent = O.AceLibrary.AceEvent
local CURSOR_ITEM_TYPE = 1

--[[-----------------------------------------------------------------------------
Interface
-------------------------------------------------------------------------------]]
local ABPI = function() return O.ActionbarPlusAPI  end

--- @class EventFrameInterface : Frame
local _EventFrame = {
    --- @type EventContext
    ctx = {}
}

--- @class EventContext
local _EventContext = {
    --- @type EventFrameInterface
    frame = {},
    --- @type ActionbarPlus
    addon = {},
    --- @type ButtonFactory
    buttonFactory = {},
    --- @type WidgetMixin
    widgetMixin = {},
}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = M.ActionbarPlusEventMixin
--- @class ActionbarPlusEventMixin : BaseLibraryObject_WithAceEvent
local L = LibStub:NewLibrary(libName); if not L then return end
AceEvent:Embed(L)
local p = ns:CreateDefaultLogger(libName)
local pe = ns:LC().EVENT:NewLogger(libName)
local pu = ns:LC().UNIT:NewLogger(libName)

--- @param msg string The message name
--- @param abp ActionbarPlus
L:RegisterMessage(MSG.OnAddOnEnabled, function(msg, source, abp)
    abp.addonEvents:RegisterEvents()
end)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param f EventFrameInterface
--- @param event string
local function OnPlayerCombatEvent(f, event, ...)
    pu:d(function() return 'Event[%s] received...', event end)
    if E.PLAYER_REGEN_ENABLED == event then
        f.ctx.buttonFactory:Fire(E.OnPlayerLeaveCombat)
    end

    f.ctx.buttonFactory:Fire(E.OnUpdateItemStates)
    -- This second fire is for fail-safety
    C_Timer.After(2, function() f.ctx.buttonFactory:Fire(E.OnUpdateItemStates) end)
end

--- @param f EventFrameInterface
--- @param event string
local function OnPetBattleEvent(f, event, ...)
    if E.PET_BATTLE_OPENING_START == event then
        f.ctx.buttonFactory:Fire(E.OnActionbarHideGroup)
        return
    end
    f.ctx.buttonFactory:Fire(E.OnActionbarShowGroup)
end

--- @param f EventFrameInterface
--- @param event string
local function OnVehicleEvent(f, event, ...)
    local unitTarget = ...
    pe:d(function() return 'Event[%s]:: unitTarget=%s', event, unitTarget end)
    if UnitId.player ~= unitTarget then return end
    if E.UNIT_ENTERED_VEHICLE == event then
        f.ctx.buttonFactory:Fire(E.OnActionbarHideGroup)
        return
    end
    f.ctx.buttonFactory:Fire(E.OnActionbarShowGroup)
end

--- @param f EventFrameInterface
--- @param event string
local function OnActionbarGrid(f, event, ...)
    local inCombat = InCombatLockdown()
    pe:d(function() return 'Event[%s]:: inCombat=%s', event, tostring(inCombat) end)
    if inCombat == true then return end
    if E.ACTIONBAR_SHOWGRID == event then
        f.ctx.buttonFactory:Fire(E.OnActionbarShowGrid)
        return
    end
    f.ctx.buttonFactory:Fire(E.OnActionbarHideGrid)
end

--- See Also: [https://wowpedia.fandom.com/wiki/CURSOR_CHANGED](https://wowpedia.fandom.com/wiki/CURSOR_CHANGED)
--- @param f EventFrameInterface
--- @param event string
local function OnCursorChangeInBags(f, event, ...)
    local isDefault, newCursorType, oldCursorType, oldCursorVirtualID = ...
    if true == isDefault and oldCursorType == CURSOR_ITEM_TYPE then
        f.ctx.buttonFactory:Fire(E.OnActionbarHideGrid)
        ABP.ActionbarEmptyGridShowing = false
        return
    end
    if InCombatLockdown() then return end
    if newCursorType ~= CURSOR_ITEM_TYPE then return end
    f.ctx.buttonFactory:Fire(E.OnActionbarShowGrid)
    ABP.ActionbarEmptyGridShowing = true
end

--- @param f EventFrameInterface
--- @param event string
local function OnSetCVarEvents(f, event, ...)
    local varName, val = ...
    if varName ~= 'lockActionBars' then return end
    local isLockedActionBarsInGameOptions = val == '1'
    if isLockedActionBarsInGameOptions == true then SetCVar('ActionButtonUseKeyDown', 1); return end
    SetCVar('ActionButtonUseKeyDown', 0)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param addon ActionbarPlus
function L:Init(addon)
    self.addon = addon
    self.buttonFactory = O.ButtonFactory
    self.widgetMixin = O.WidgetMixin
end

--- @return EventFrameInterface
function L:CreateEventFrame()
    local f = CreateFrame("Frame", nil, self.addon.frame)
    f.ctx = self:CreateContext(f)
    return f
end

--- @param eventFrame Frame
--- @return EventContext
function L:CreateContext(eventFrame)
    local ctx = {
        frame = eventFrame,
        addon = self.addon,
        buttonFactory = self.buttonFactory,
        widgetMixin = self.widgetMixin
    }
    return ctx
end

function L:RegisterSetCVarEvents()
    local f = self:CreateEventFrame()
    f:SetScript(E.OnEvent, OnSetCVarEvents)
    RegisterFrameForEvents(f, { E.CVAR_UPDATE })
end

function L:RegisterVehicleFrame()
    local f = self:CreateEventFrame()
    f:SetScript(E.OnEvent, OnVehicleEvent)
    RegisterFrameForUnitEvents(f, { E.UNIT_ENTERED_VEHICLE, E.UNIT_EXITED_VEHICLE }, GC.UnitId.player)
end

function L:RegisterActionbarGridEventFrame()
    local f = self:CreateEventFrame()
    f:SetScript(E.OnEvent, OnActionbarGrid)
    RegisterFrameForEvents(f, { E.ACTIONBAR_SHOWGRID, E.ACTIONBAR_HIDEGRID })
end

function L:RegisterCursorChangesInBagEvents()
    if B:IsClassicEra() then return end
    local f = self:CreateEventFrame()
    f:SetScript(E.OnEvent, OnCursorChangeInBags)
    -- Note that this event does not fire in WoW Classic (i.e. 1.14.x)
    -- for non-consumable items in the bag like quest items
    RegisterFrameForEvents(f, { E.CURSOR_CHANGED })
end

function L:RegisterPetBattleFrame()
    local f = self:CreateEventFrame()
    f:SetScript(E.OnEvent, OnPetBattleEvent)
    RegisterFrameForEvents(f, { E.PET_BATTLE_OPENING_START, E.PET_BATTLE_CLOSE })
end

--- Use PLAYER_REGIN[ENABLED|DISABLED] is more reliable than using
--- PLAYER_[ENTER|LEAVE]_COMBAT event
function L:RegisterCombatFrame()
    local f = self:CreateEventFrame()
    f:SetScript(E.OnEvent, OnPlayerCombatEvent)
    RegisterFrameForEvents(f, { E.PLAYER_REGEN_ENABLED, E.PLAYER_REGEN_DISABLED })
end

function L:RegisterEvents()
    p:d('RegisterEvents called..')

    self:RegisterActionbarGridEventFrame()
    self:RegisterCursorChangesInBagEvents()
    self:RegisterCombatFrame()
    self:RegisterSetCVarEvents()

    if B:SupportsPetBattles() then self:RegisterPetBattleFrame() end
    --TODO: Need to investigate Wintergrasp (hides/shows intermittently)
    if B:SupportsVehicles() then self:RegisterVehicleFrame() end
end
