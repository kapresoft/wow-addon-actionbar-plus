--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show =
    GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format, strlower, tinsert = string.format, string.lower, table.insert

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local C = O.GlobalConstants.C
local String, A, P = O.String, O.Assert, O.Profile
local ButtonFrameFactory = O.ButtonFrameFactory
local AssertNotNil = A.AssertNotNil
local WAttr = O.GlobalConstants.WidgetAttributes
local SPELL, ITEM, MACRO, MOUNT = WAttr.SPELL, WAttr.ITEM, WAttr.MACRO, WAttr.MOUNT

---@type ButtonUILib
local ButtonUI = O.ButtonUI
local WMX = O.WidgetMixin

---@class ButtonFactory
local L = LibStub:NewLibrary(Core.M.ButtonFactory)
---@type LoggerTemplate
local p = L:GetLogger()

local AttributeSetters = {
    [SPELL]       = O.SpellAttributeSetter,
    [ITEM]        = O.ItemAttributeSetter,
    [MACRO]       = O.MacroAttributeSetter,
    [MOUNT]       = O.MountAttributeSetter,
}

-- Initialized on Logger#OnAddonLoaded()
L.addon = nil
L.profile = nil
L.FRAMES = {}


--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--TODO: Move to ButtonFactory
local function InitButtonGameTooltipHooks()
    ---For macros not using spells
    GameTooltip:HookScript("OnShow", function(tooltip, ...)
        if not WMX:IsTypeMacro(tooltip:GetOwner()) then return end
        WMX:SetupTooltipKeybindingInfo(tooltip)
    end)
    GameTooltip:HookScript("OnTooltipSetSpell", function(tooltip, ...)
        if WMX:IsTypeMacro(tooltip:GetOwner()) then return end
        WMX:SetupTooltipKeybindingInfo(tooltip)
    end)
    GameTooltip:HookScript("OnTooltipSetItem", function(tooltip, ...)
        if WMX:IsTypeMacro(tooltip:GetOwner()) then return end
        WMX:SetupTooltipKeybindingInfo(tooltip)
    end)
end

---@param btnWidget ButtonUIWidget
local function OnMacroChanged(btnWidget)
    AttributeSetters[MACRO]:SetAttributes(btnWidget.button, btnWidget:GetConfig())
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

function L:OnAfterInitialize()
    local frameNames = P:GetAllFrameNames()
    --error(format('frames: %s', ABP_Table.toString(frames)))
    local inactiveFrameCount = 0
    for i,_ in ipairs(frameNames) do
        local frameEnabled = P:IsBarIndexEnabled(i)
        local f = self:CreateActionbarGroup(i)
        if frameEnabled then
            f:ShowGroup()
        else
            f:HideGroup()
            inactiveFrameCount = inactiveFrameCount + 1
        end
        tinsert(self.FRAMES, f)
    end

    --AceEvent:RegisterEvent('BAG_UPDATE_DELAYED', OnBagUpdate)
    p:log('Total frames loaded: %s, %s are hidden', #self.FRAMES, inactiveFrameCount)
end

function L:Fire(event, sourceEvent, ...)
    local args = ...
    ---@param frameWidget FrameWidget
    self:ApplyForEachFrames(function(frameWidget)
        frameWidget:Fire(event, sourceEvent, args)
    end)
end

---@param applyFunction function(FrameWidget) Should be in format function(frameWidget) {}
function L:ApplyForEachFrames(applyFunction)
    local frames = P:GetAllFrameNames()
    if #frames <= 0 then return end
    -- `_` is the index
    for _,f in ipairs(frames) do applyFunction(_G[f].widget) end
end

function L:UpdateKeybindText()
    local frames = P:GetAllFrameNames()
    for i,name in ipairs(frames) do
        local f = _G[name]
        if f and f.widget then
            ---@type FrameWidget
            local fw = f.widget
            if P:IsBarIndexEnabled(i) then fw:UpdateKeybindText() end
        end
    end
end

function L:RefreshActionbar(frameIndex)
    P:GetFrameWidgetByIndex(frameIndex):RefreshActionbarFrame()
end

function L:CreateActionbarGroup(frameIndex)
    local barConfig = P:GetBar(frameIndex)
    local widget = barConfig.widget
    ---@type FrameWidget
    local f = ButtonFrameFactory(frameIndex)
    self:CreateButtons(f, widget.rowSize, widget.colSize)
    f:SetInitialState()
    return f
end

---@param frameWidget FrameWidget
function L:CreateButtons(frameWidget, rowSize, colSize)
    local index = 0
    for row=1, rowSize do
        for col=1, colSize do
            index = index + 1
            local btnWidget = self:CreateSingleButton(frameWidget, row, col, index)
            frameWidget:AddButton(btnWidget:GetName())
        end
    end
end

---@param frameWidget FrameWidget
---@param row number
---@param col number
---@param btnIndex number The button index number
function L:CreateSingleButton(frameWidget, row, col, btnIndex)
    local btnWidget = ButtonUI:WidgetBuilder():Create(frameWidget, row, col, btnIndex)
    self:SetButtonAttributes(btnWidget)
    btnWidget:SetCallback("OnMacroChanged", OnMacroChanged)
    btnWidget:UpdateStateDelayed(0.05)
    return btnWidget
end


---@param btnWidget ButtonUIWidget
function L:SetButtonAttributes(btnWidget)
    local btnData = btnWidget:GetConfig()
    if btnData == nil or String.IsBlank(btnData.type) then return end
    local setter = self:GetAttributesSetter(btnData.type)
    if not setter then return end
    setter:SetAttributes(btnWidget.button, btnData)
end

function L:IsValidDragSource(cursorInfo)
    if String.IsBlank(cursorInfo.type) then
        -- This can happen if a chat tab or others is dragged into
        -- the action bar.
        self:log(5, 'Received drag event with invalid cursor info. Skipping...')
        return false
    end

    return true
end

function L:GetAttributesSetter(actionType)
    AssertNotNil(actionType, 'actionType')
    return AttributeSetters[actionType]
end

InitButtonGameTooltipHooks()