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
local E = GC.E
local B = O.BaseAPI

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class ActionbarPlusEventMixin
local L = LibStub:NewLibrary(Core.M.ActionbarPlusEventMixin)
---@return LoggerTemplate
local p = L:GetLogger()

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param f KeybindingsEventFrame
---@param event string
local function OnUpdateBindings(f, event, ...)
    if E.UPDATE_BINDINGS ~= event then return end
    local addon = f.widget.addon
    addon.barBindings = f.widget.widgetMixin:GetBarBindingsMap()
    if addon.barBindings then f.widget.buttonFactory:UpdateKeybindText() end
end

---@param f PetBattleEventFrame
---@param event string
local function OnPetBattleEvent(f, event, ...)
    if E.PET_BATTLE_OPENING_START == event then
        f.widget.buttonFactory:Fire(E.OnActionbarHideAll)
        return
    end
    f.widget.buttonFactory:Fire(E.OnActionbarShowAll)
end

---@param f VehicleEventFrame
---@param event string
local function OnVehicleEvent(f, event, ...)
    if E.UNIT_ENTERED_VEHICLE == event then
        f.widget.buttonFactory:Fire(E.OnActionbarHideAll)
        return
    end
    f.widget.buttonFactory:Fire(E.OnActionbarShowAll)
end

---@param f ActionbarGridEventFrame
---@param event string
local function OnActionbarGrid(f, event, ...)
    if E.ACTIONBAR_SHOWGRID == event then
        f.widget.buttonFactory:Fire(E.OnActionbarShowGrid)
        return
    end
    f.widget.buttonFactory:Fire(E.OnActionbarHideGrid)
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

---@param eventFrame _Frame
function L:CreateWidget(eventFrame)
    ---@class BaseEventFrameWidget
    local widget = {
        frame = eventFrame,
        addon = self.addon,
        buttonFactory = self.buttonFactory,
        widgetMixin = self.widgetMixin
    }
    return widget
end

function L:RegisterKeybindingsEventFrame()
    ---@class KeybindingsEventFrame : _Frame
    local f = CreateFrame("Frame", nil, self.addon.frame)
    ---@class KeybindingsEventFrameWidget : BaseEventFrameWidget
    local widget = self:CreateWidget(f)
    f.widget = widget

    f:SetScript(E.OnEvent, OnUpdateBindings)
    f:RegisterEvent(E.UPDATE_BINDINGS)
end

function L:RegisterVehicleFrame()
    ---@class VehicleEventFrame : _Frame
    local f = CreateFrame("Frame", nil, self.addon.frame)
    ---@class VehicleEventFrameWidget : BaseEventFrameWidget
    local widget = self:CreateWidget(f)
    f.widget = widget

    f:SetScript(E.OnEvent, OnVehicleEvent)
    f:RegisterEvent(E.UNIT_ENTERED_VEHICLE)
    f:RegisterEvent(E.UNIT_EXITED_VEHICLE)

end

function L:RegisterActionbarGridEventFrame()
    ---@class ActionbarGridEventFrame : _Frame
    local f = CreateFrame("Frame", nil, self.addon.frame)
    ---@class ActionbarGridEventFrameWidget : BaseEventFrameWidget
    local widget = self:CreateWidget(f)
    f.widget = widget

    f:SetScript(E.OnEvent, OnActionbarGrid)
    f:RegisterEvent(E.ACTIONBAR_SHOWGRID)
    f:RegisterEvent(E.ACTIONBAR_HIDEGRID)
end

function L:RegisterPetBattleFrame()
    ---@class PetBattleEventFrame : _Frame
    local f = CreateFrame("Frame", nil, self.addon.frame)
    ---@class PetBattleEventFrameWidget : BaseEventFrameWidget
    local widget = self:CreateWidget(f)
    f.widget = widget

    f:SetScript(E.OnEvent, OnPetBattleEvent)
    f:RegisterEvent(E.PET_BATTLE_OPENING_START)
    f:RegisterEvent(E.PET_BATTLE_CLOSE)
end

function L:RegisterEvents()
    self:RegisterKeybindingsEventFrame()
    self:RegisterActionbarGridEventFrame()
    if B:SupportsPetBattles() then self:RegisterPetBattleFrame() end
    if B:SupportsVehicles() then self:RegisterVehicleFrame() end
end