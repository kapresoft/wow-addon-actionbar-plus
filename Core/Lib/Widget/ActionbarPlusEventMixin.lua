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
local _, ns = ...
local O, GC, LibStub = ns.O, ns.O.GlobalConstants, ns.O.LibStub

local BaseAPI, API = O.BaseAPI, O.API
local E, MSG, UnitId = GC.E, GC.M,  GC.UnitId
local B, PR, WMX = O.BaseAPI, O.Profile, O.WidgetMixin
local AceEvent = O.AceLibrary.AceEvent
local CURSOR_ITEM_TYPE = 1

--[[-----------------------------------------------------------------------------
Interface
-------------------------------------------------------------------------------]]
local ABPI = function() return O.ActionbarPlusAPI  end

--- @class EventFrameInterface : _Frame
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
--- @class ActionbarPlusEventMixin : BaseLibraryObject_WithAceEvent
local L = LibStub:NewLibrary(ns.M.ActionbarPlusEventMixin)
AceEvent:Embed(L)
local p = L:GetLogger()

--- @param msg string The message name
--- @param abp ActionbarPlus
L:RegisterMessage(MSG.OnAddOnEnabled, function(msg, abp)
    abp.addonEvents:RegisterEvents()
end)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param f EventFrameInterface
--- @param event string
local function OnPlayerCombatEvent(f, event, ...)
    -- p:log(40, 'Event[%s] received...', event)
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
    p:log(30, 'Event received: %s', event)
    if InCombatLockdown() then return end
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
local function OnMessageTransmitter(f, event, ...) L:SendMessage(GC.newMsg(event), ns.name, ...) end

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

--- @param eventFrame _Frame
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
    if BaseAPI:IsClassicEra() then return end
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
function L:RegisterEventToMessageTransmitter()
    local f = self:CreateEventFrame()
    f:SetScript(E.OnEvent, OnMessageTransmitter)
    --- @see GlobalConstants#M (Messages)
    RegisterFrameForEvents(f, {
        E.PLAYER_ENTERING_WORLD,
        E.EQUIPMENT_SETS_CHANGED, E.EQUIPMENT_SWAP_FINISHED,
        E.PLAYER_MOUNT_DISPLAY_CHANGED, E.ZONE_CHANGED_NEW_AREA,
        E.MODIFIER_STATE_CHANGED,
        E.CVAR_UPDATE,
    })
end

function L:RegisterEvents()
    p:log(30, 'RegisterEvents called..')

    self:RegisterActionbarGridEventFrame()
    self:RegisterCursorChangesInBagEvents()
    self:RegisterCombatFrame()
    self:RegisterEventToMessageTransmitter()
    self:RegisterSetCVarEvents()

    if B:SupportsPetBattles() then self:RegisterPetBattleFrame() end
    --TODO: Need to investigate Wintergrasp (hides/shows intermittently)
    if B:SupportsVehicles() then self:RegisterVehicleFrame() end
end
