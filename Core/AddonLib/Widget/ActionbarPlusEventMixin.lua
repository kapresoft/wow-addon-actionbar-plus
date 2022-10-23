--This mixin handles events for the addon
--
--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFrame = CreateFrame

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = ABP_Namespace(...)
local O, Core, LibStub = ns:LibPack()
local GC = O.GlobalConstants
local E, UnitId = GC.E, GC.UnitId
local B = O.BaseAPI
local AceEvent = O.AceLibFactory:A().AceEvent
local CURSOR_ITEM_TYPE = 1

--[[-----------------------------------------------------------------------------
Interface
-------------------------------------------------------------------------------]]
---@class EventFrameInterface : _Frame
local EventsFrameInterface = {
    ---@type EventFrameWidgetInterface
    widget = {}
}

---@class EventFrameWidgetInterface
local EventFrameWidgetInterface = {
    ---@type EventFrameInterface
    frame = {},
    ---@type ActionbarPlus
    addon = {},
    ---@type ButtonFactory
    buttonFactory = {},
    ---@type WidgetMixin
    widgetMixin = {},
}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class ActionbarPlusEventMixin
local L = LibStub:NewLibrary(Core.M.ActionbarPlusEventMixin)
---@return LoggerTemplate
local p = L:GetLogger()

AceEvent:RegisterMessage(E.AddonMessage_OnAfterInitialize, function(evt, ...)
    ---@type ActionbarPlus
    local addon = ...
    p:log(30, 'RegisterMessage: %s called...', evt)
    addon.addonEvents:RegisterEvents()
end)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param f EventFrameInterface
---@param event string
local function OnUpdateBindings(f, event, ...)
    if E.UPDATE_BINDINGS ~= event then return end
    local addon = f.widget.addon
    addon.barBindings = f.widget.widgetMixin:GetBarBindingsMap()
    if addon.barBindings then f.widget.buttonFactory:UpdateKeybindText() end
end

---@param f EventFrameInterface
---@param event string
local function OnPetBattleEvent(f, event, ...)
    if E.PET_BATTLE_OPENING_START == event then
        f.widget.buttonFactory:Fire(E.OnActionbarHideAll)
        return
    end
    f.widget.buttonFactory:Fire(E.OnActionbarShowAll)
end

---@param f EventFrameInterface
---@param event string
local function OnVehicleEvent(f, event, ...)
    if E.UNIT_ENTERED_VEHICLE == event then
        f.widget.buttonFactory:Fire(E.OnActionbarHideAll)
        return
    end
    f.widget.buttonFactory:Fire(E.OnActionbarShowAll)
end

---@param f EventFrameInterface
---@param event string
local function OnActionbarGrid(f, event, ...)
    if E.ACTIONBAR_SHOWGRID == event then
        f.widget.buttonFactory:Fire(E.OnActionbarShowGrid)
        return
    end
    f.widget.buttonFactory:Fire(E.OnActionbarHideGrid)
end

--- See Also: [https://wowpedia.fandom.com/wiki/CURSOR_CHANGED](https://wowpedia.fandom.com/wiki/CURSOR_CHANGED)
---@param f EventFrameInterface
---@param event string
local function OnCursorChangeInBags(f, event, ...)
    local isDefault, newCursorType, oldCursorType, oldCursorVirtualID = ...
    --p:log(40, 'OnCursorChangeInBags: isDefault: %s new=%s old=%s', isDefault, newCursorType, oldCursorType)
    if true == isDefault and oldCursorType == CURSOR_ITEM_TYPE then
        f.widget.buttonFactory:Fire(E.OnActionbarHideGrid)
        ABP.ActionbarEmptyGridShowing = false
        return
    end
    if newCursorType ~= CURSOR_ITEM_TYPE then return end
    f.widget.buttonFactory:Fire(E.OnActionbarShowGrid)
    ABP.ActionbarEmptyGridShowing = true
end

--- Non-Instant Start-Cast Handler
--- @param f EventFrameInterface
local function OnSpellCastStart(f, ...)
    --todo next: include item spells (i.e., quest items)
    local spellCastEvent = B:ParseSpellCastEventArgs(...)
    if UnitId.player ~= spellCastEvent.unitTarget then return end
    --p:log(50, 'OnSpellCastStart: %s', spellCastEvent)
    local w = f.widget
    ---@param fw FrameWidget
    w.buttonFactory:ApplyForEachVisibleFrames(function(fw)
        ---@param btn ButtonUIWidget
        fw:ApplyForEachSpellOrMacroButtons(spellCastEvent.spellID,
                function(btn) btn:SetHighlightInUse() end)
    end)
end

--- Non-Instant Stop-Cast Handler
--- @param f EventFrameInterface
local function OnSpellCastStop(f, ...)
    local spellCastEvent = B:ParseSpellCastEventArgs(...)
    if UnitId.player ~= spellCastEvent.unitTarget then return end
    p:log(50, 'OnSpellCastStop: %s', spellCastEvent)
    local w = f.widget
    ---@param fw FrameWidget
    w.buttonFactory:ApplyForEachVisibleFrames(function(fw)
        ---@param btn ButtonUIWidget
        fw:ApplyForEachSpellOrMacroButtons(spellCastEvent.spellID,
                function(btn) btn:ResetHighlight() end)
    end)
end

--- Non-Instant Stop-Cast Handler
--- @param f EventFrameInterface
local function OnSpellCastFailed(f, ...)
    local spellCastEvent = B:ParseSpellCastEventArgs(...)
    if UnitId.player ~= spellCastEvent.unitTarget then return end
    --p:log(50, 'OnSpellCastFailed: %s', spellCastEvent)
    local w = f.widget
    ---@param fw FrameWidget
    w.buttonFactory:ApplyForEachVisibleFrames(function(fw)
        ---@param btn ButtonUIWidget
        fw:ApplyForEachSpellOrMacroButtons(spellCastEvent.spellID,
                function(btn) btn:SetButtonStateNormal() end)
    end)
end

--- This handles 3-state spells like mage blizzard, hunter flares,
--- or basic campfire in retail
---@param f EventFrameInterface
local function OnSpellCastSent(f, ...)
    local spellCastSentEvent = B:ParseSpellCastSentEventArgs(...)
    if not spellCastSentEvent or spellCastSentEvent.unit ~= UnitId.player then return end
    local w = f.widget
    ---@param fw FrameWidget
    w.buttonFactory:ApplyForEachVisibleFrames(function(fw)
        ---@param btn ButtonUIWidget
        fw:ApplyForEachSpellOrMacroButtons(spellCastSentEvent.spellID,
                function(btn) btn:SetButtonStateNormal() end)
    end)
end

---@param f EventFrameInterface
---@param event string
local function OnActionbarEvents(f, event, ...)
    if E.UNIT_SPELLCAST_START == event then
        OnSpellCastStart(f, ...)
    elseif E.UNIT_SPELLCAST_STOP == event then
        OnSpellCastStop(f, ...)
    elseif E.UNIT_SPELLCAST_SENT == event then
        OnSpellCastSent(f, ...)
    elseif E.UNIT_SPELLCAST_FAILED_QUIET == event then
        OnSpellCastFailed(f, ...)
    end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param addon ActionbarPlus
function L:Init(addon)
    self.addon = addon
    self.buttonFactory = O.ButtonFactory
    self.widgetMixin = O.WidgetMixin
end

---@return EventFrameInterface
function L:CreateEventFrame()
    local f = CreateFrame("Frame", nil, self.addon.frame)
    f.widget = self:CreateWidget(f)
    return f
end

---@param eventFrame _Frame
---@return EventFrameWidgetInterface
function L:CreateWidget(eventFrame)
    local widget = {
        frame = eventFrame,
        addon = self.addon,
        buttonFactory = self.buttonFactory,
        widgetMixin = self.widgetMixin
    }
    return widget
end

function L:RegisterActionbarsEventFrame()
    local f = self:CreateEventFrame()
    f:SetScript(E.OnEvent, OnActionbarEvents)
    f:RegisterEvent(E.UNIT_SPELLCAST_START)
    f:RegisterEvent(E.UNIT_SPELLCAST_STOP)
    f:RegisterEvent(E.UNIT_SPELLCAST_SENT)
    f:RegisterEvent(E.UNIT_SPELLCAST_FAILED_QUIET)
end

function L:RegisterKeybindingsEventFrame()
    local f = self:CreateEventFrame()
    f:SetScript(E.OnEvent, OnUpdateBindings)
    f:RegisterEvent(E.UPDATE_BINDINGS)
end

function L:RegisterVehicleFrame()
    local f = self:CreateEventFrame()
    f:SetScript(E.OnEvent, OnVehicleEvent)
    f:RegisterEvent(E.UNIT_ENTERED_VEHICLE)
    f:RegisterEvent(E.UNIT_EXITED_VEHICLE)
end

function L:RegisterActionbarGridEventFrame()
    local f = self:CreateEventFrame()
    f:SetScript(E.OnEvent, OnActionbarGrid)
    f:RegisterEvent(E.ACTIONBAR_SHOWGRID)
    f:RegisterEvent(E.ACTIONBAR_HIDEGRID)
end

function L:RegisterCursorChangesInBagEvents()
    local f = self:CreateEventFrame()
    f:SetScript(E.OnEvent, OnCursorChangeInBags)
    f:RegisterEvent(E.CURSOR_CHANGED)
end

function L:RegisterPetBattleFrame()
    local f = self:CreateEventFrame()
    f:SetScript(E.OnEvent, OnPetBattleEvent)
    f:RegisterEvent(E.PET_BATTLE_OPENING_START)
    f:RegisterEvent(E.PET_BATTLE_CLOSE)
end

function L:RegisterEvents()
    p:log(30, 'RegisterEvents called..')
    self:RegisterActionbarsEventFrame()
    self:RegisterKeybindingsEventFrame()
    self:RegisterActionbarGridEventFrame()
    self:RegisterCursorChangesInBagEvents()
    if B:SupportsPetBattles() then self:RegisterPetBattleFrame() end
    if B:SupportsVehicles() then self:RegisterVehicleFrame() end
end