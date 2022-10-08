--This mixin handles events for the addon
--
--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFrame = CreateFrame

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
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
    p:log('%s: called, widgetMixin=%s', event, tostring(f.widget.widgetMixin))
    addon.barBindings = f.widget.widgetMixin:GetBarBindingsMap()
    if addon.barBindings then f.widget.buttonFactory:UpdateKeybindText() end
end

---@param f PetBattleEventFrame
---@param event string
local function OnPetBattle(f, event, ...)
    if E.PET_BATTLE_OPENING_START == event then
        f.widget.buttonFactory:Fire(E.OnPetBattleStart)
    elseif E.PET_BATTLE_CLOSE == event then
        f.widget.buttonFactory:Fire(E.OnPetBattleEnd)
    end
end

---@param f ActionbarGridEventFrame
---@param event string
local function OnActionbarGrid(f, event, ...)
    if E.ACTIONBAR_SHOWGRID == event then
        f.widget.buttonFactory:Fire('OnActionbarShowGrid')
        return
    end
    f.widget.buttonFactory:Fire('OnActionbarHideGrid')
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

    f:SetScript(E.OnEvent, OnPetBattle)
    f:RegisterEvent(E.PET_BATTLE_OPENING_START)
    f:RegisterEvent(E.PET_BATTLE_CLOSE)
end

function L:RegisterEvents()
    self:RegisterKeybindingsEventFrame()
    self:RegisterActionbarGridEventFrame()
    if B:SupportsPetBattles() then self:RegisterPetBattleFrame() end
end