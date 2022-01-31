--[[-----------------------------------------------------------------------------
ActionButton.lua
-------------------------------------------------------------------------------]]

-- WoW APIs
local ClearCursor, GetCursorInfo, CreateFrame, UIParent =
ClearCursor, GetCursorInfo, CreateFrame, UIParent
local GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show =
GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show

-- Lua APIs
local pack, fmod = table.pack, math.fmod
local tostring, format, strlower, tinsert = tostring, string.format, string.lower, table.insert

-- Local APIs
local LibStub, M, A, P, LSM, W = ABP_WidgetConstants:LibPack()
local AceGUI = LibStub(M.AceLibFactory):GetAceGUI()

local CC = ABP_CommonConstants
local WAttr = CC.WidgetAttributes
local PrettyPrint, Table, String, LogFactory = ABP_LibGlobals:LibPackUtils()
local ToStringSorted = ABP_LibGlobals:LibPackPrettyPrint()
--local BFF, H, SAS, IAS, MAS, MTAS = W:LibPack_ButtonFactory()
local IsNotBlank = String.IsNotBlank

---@type LogFactory
local p = LogFactory:NewLogger('ButtonUI')

local noIconTexture = LSM:Fetch(LSM.MediaType.BACKGROUND, "Blizzard Dialog Background")
local buttonSize = 40
local frameStrata = 'LOW'

local AssertThatMethodArgIsNotNil, AssertNotNil = A.AssertThatMethodArgIsNotNil, A.AssertNotNil
local SECURE_ACTION_BUTTON_TEMPLATE, CONFIRM_RELOAD_UI = SECURE_ACTION_BUTTON_TEMPLATE, CONFIRM_RELOAD_UI
local TOPLEFT, BOTTOMLEFT, ANCHOR_TOPLEFT = TOPLEFT, BOTTOMLEFT, ANCHOR_TOPLEFT
local TEXTURE_EMPTY, TEXTURE_HIGHLIGHT = ABP_WidgetConstants:GetButtonTextures()

-- TODO: Move to config
local INTERNAL_BUTTON_PADDING = 2

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

local function RegisterWidget(widget, name)
    assert(widget ~= nil)
    assert(name ~= nil)

    local WidgetBase = AceGUI.WidgetBase
    widget.userdata = {}
    widget.events = {}
    widget.base = WidgetBase
    widget.frame.obj = widget
    local mt = {
        __tostring = function() return name  end,
        __index = WidgetBase
    }
    setmetatable(widget, mt)
    return widget
end

local function ShowTooltip(btnUI)
    if not btnUI then return end
    local btnData = btnUI.widget:GetConfig()
    if not btnData then return end
    local type = btnData.type
    if not type then return end

    local spellInfo = btnData[WAttr.SPELL]
    if not spellInfo.id then return end
    GameTooltip:SetOwner(btnUI, ANCHOR_TOPLEFT)
    GameTooltip:AddSpellByID(spellInfo.id)
    -- Replace 'Spell' with 'Spell (Rank #Rank)'
    if (IsNotBlank(spellInfo.rank)) then
        GameTooltip:AppendText(format(' |cff565656(%s)|r', spellInfo.rank))
    end
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function IsValidDragSource(cursorInfo)
    if String.IsBlank(cursorInfo.type) then
        -- This can happen if a chat tab or others is dragged into
        -- the action bar.
        p:log(5, 'Received drag event with invalid cursor info. Skipping...')
        return false
    end

    return true
end
---@param btnUI ButtonFrame
local function OnDragStart(btnUI)
    ---@type ButtonUIWidget
    local w = btnUI.widget

    if InCombatLockdown() then return end
    if w.profile:IsLockActionBars() and not IsShiftKeyDown() then return end
    w:ClearCooldown()
    p:log(20, 'DragStarted| Actionbar-Info: %s', pformat(btnUI.widget:GetActionbarInfo()))
    local btnData = btnUI.widget:GetConfig()
    local spellInfo = btnData[WAttr.SPELL]
    PickupSpell(spellInfo.id)
    w:ResetConfig()
    btnUI:SetNormalTexture(TEXTURE_EMPTY)
    btnUI:SetScript("OnEnter", nil)
end

local function OnReceiveDrag(btn)
    local BFF, H, SAS, IAS, MAS, MTAS = W:LibPack_ButtonFactory()

    AssertThatMethodArgIsNotNil(btn, 'btnUI', 'OnReceiveDrag(btnUI)')
    -- TODO: Move to TBC/API
    local actionType, info1, info2, info3 = GetCursorInfo()
    ClearCursor()

    local cursorInfo = { type = actionType or '', info1 = info1, info2 = info2, info3 = info3 }
    p:log(20, 'OnReceiveDrag Cursor-Info: %s', ToStringSorted(cursorInfo))
    if not IsValidDragSource(cursorInfo) then return end
    H:Handle(btn, actionType, cursorInfo)

    btn.widget:Fire('OnReceiveDrag')
end

local function OnEnter(self) ShowTooltip(self) end
local function OnLeave(self) GameTooltip:Hide() end
local function OnClick(btn, mouseButton, down)
    local actionType = GetCursorInfo()
    if String.IsBlank(actionType) then return end
    p:log(20, 'HookScript| Actionbar: %s', pformat(btn.widget:GetActionbarInfo()))
    OnReceiveDrag(btn)
end

--[[-----------------------------------------------------------------------------
Widget Methods
-------------------------------------------------------------------------------]]
---@param widget ButtonUIWidget
local function WidgetMethods(widget)

    function widget:GetName() return self.button:GetName() end

    ---Get Profile Button Config Data
    function widget:GetConfig()
        return self.profile:GetButtonData(self.frameIndex, self.buttonName)
    end

    function widget:ResetConfig()
        P:ResetButtonData(self)
        self:ResetWidgetAttributes()
    end

    ---@return ActionBarInfo
    function widget:GetActionbarInfo()
        local index = self.index
        local dragFrame = self.dragFrame;
        local frameName = dragFrame:GetName()
        local btnName = format('%sButton%s', frameName, tostring(index))

        ---@class ActionBarInfo
        local info = {
            name = frameName, index = dragFrame:GetFrameIndex(),
            button = { name = btnName, index = index },
        }
        return info
    end

    ---@deprecated Use #GetConfig()
    function widget:GetProfileButtonData()
        local info = self:GetActionbarInfo()
        if not info then
            return nil
        end
        return P:GetButtonData(info.index, info.button.name)
    end

    function widget:ClearCooldown()
        self:SetCooldownDelegate(0, 0)
    end

    function widget:SetCooldown(optionalInfo)
        local cd = optionalInfo or self.cooldownInfo
        if not cd then return end
        self:SetCooldownInfo(cd)
        self:SetCooldownDelegate(cd.start, cd.duration)
    end

    function widget:SetCooldownDelegate(start, duration)
        self.cooldown:SetCooldown(start, duration)
    end

    function widget:SetCooldownInfo(cooldownInfo)
        if not cooldownInfo then return end
        self.cooldownInfo = cooldownInfo
    end

    function widget:ResetWidgetAttributes()
        for _, v in pairs(self.buttonAttributes) do
            self.button:SetAttribute(v, nil)
        end
    end
end

--[[-----------------------------------------------------------------------------
Builder Methods
-------------------------------------------------------------------------------]]
---@class ButtonUIWidgetBuilder
local _B = LogFactory:NewLogger('ButtonUIWidgetBuilder', {})

---Creates a new ButtonUI
---@param dragFrame table The drag frame this button is attached to
---@param rowNum number The row number
---@param colNum number The column number
---@param btnIndex number The button numeric index
---@return ButtonUIWidget
function _B:Create(dragFrame, rowNum, colNum, btnIndex)
    local frameName = dragFrame:GetName()
    local btnName = format('%sButton%s', frameName, tostring(btnIndex))

    ---@class ButtonFrame
    local button = CreateFrame("Button", btnName, UIParent, SECURE_ACTION_BUTTON_TEMPLATE)
    button:SetFrameStrata(frameStrata)
    button:SetSize(buttonSize - INTERNAL_BUTTON_PADDING, buttonSize - INTERNAL_BUTTON_PADDING)

    -- Reference point is BOTTOMLEFT of dragFrame
    -- dragFrameBottomLeftAdjustX, dragFrameBottomLeftAdjustY adjustments from #dragFrame
    local referenceFrameAdjustX = buttonSize
    local referenceFrameAdjustY = 3
    --local adjX = (colNum * buttonSize) - referenceFrameAdjustX
    --local widthAdj = (colNum * buttonSize) - referenceFrameAdjustX + INTERNAL_BUTTON_PADDING
    --local height =  ((rowNum-1) * buttonSize) + INTERNAL_BUTTON_PADDING - referenceFrameAdjustY
    --local heightAdj =  ((rowNum-1) * buttonSize) + INTERNAL_BUTTON_PADDING - referenceFrameAdjustY
    local widthPaddingAdj = dragFrame.padding
    local heightPaddingAdj = dragFrame.padding + dragFrame.dragHandleHeight
    local widthAdj = ((colNum-1) * buttonSize) + widthPaddingAdj
    local heightAdj = ((rowNum-1) * buttonSize) + heightPaddingAdj

    --button:SetPoint(BOTTOMLEFT, dragFrame, TOPLEFT, adjX, -adjY)
    --button:SetPoint(BOTTOMLEFT, dragFrame, TOPLEFT, adjX + dragFrame.halfPadding, -adjY - dragFrame.halfPadding)
    local frameCenterAdjust = 5
    button:SetPoint(TOPLEFT, dragFrame, TOPLEFT, widthAdj, -heightAdj)
    button:SetNormalTexture(noIconTexture)
    button:HookScript('OnClick', OnClick)
    button:SetScript('OnEnter', OnEnter)
    button:SetScript('OnLeave', OnLeave)
    button:SetScript('OnReceiveDrag', OnReceiveDrag)
    button:SetScript('OnDragStart', OnDragStart)

    local cdFrameName = btnName .. 'CDFrame'
    local cooldown = CreateFrame("Cooldown", cdFrameName, button,  "CooldownFrameTemplate")
    cooldown:SetAllPoints(button)
    cooldown:SetSwipeColor(1, 1, 1)

    ---@class ButtonUIWidget
    local widget = {
        ---@type Logger
        p = p,
        ---@type Profile
        profile = P,
        ---@type number
        frameIndex = dragFrame:GetFrameIndex(),
        --@type string
        buttonName = btnName,
        ---@type Frame
        dragFrame = dragFrame,
        ---@type ButtonUI
        button = button,
        ---@type ButtonUI
        frame = button,
        ---@type Cooldown
        cooldown = cooldown,
        ---@type table
        cooldownInfo = nil,
        ---@type string
        frameStrata = 'LOW',
        ---@type number
        buttonSize = 40,
        ---@type table
        buttonAttributes = CC.ButtonAttributes,
    }
    dragFrame.widget, button.widget, cooldown.widget = widget, widget, widget

    --for method, func in pairs(methods) do widget[method] = func end
    WidgetMethods(widget)

    ---@type ButtonUIWidget
    return RegisterWidget(widget, btnName .. '::Widget')
end

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local function NewLibrary()

    ---@class ButtonUI
    local _L = LibStub:NewLibrary(M.ButtonUI, 1)

    function _L:WidgetBuilder() return _B end

    return _L
end

NewLibrary()


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methodsx = {
    ["OnAcquire"] = function(self)
        -- restore default values
        self:SetHeight(24)
        self:SetWidth(200)
        self:SetDisabled(false)
        self:SetAutoWidth(false)
        self:SetText()
    end,

    -- ["OnRelease"] = nil,

    ["SetText"] = function(self, text)
        self.text:SetText(text)
        if self.autoWidth then
            self:SetWidth(self.text:GetStringWidth() + 30)
        end
    end,

    ["SetAutoWidth"] = function(self, autoWidth)
        self.autoWidth = autoWidth
        if self.autoWidth then
            self:SetWidth(self.text:GetStringWidth() + 30)
        end
    end,

    ["SetDisabled"] = function(self, disabled)
        self.disabled = disabled
        if disabled then
            self.frame:Disable()
        else
            self.frame:Enable()
        end
    end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local Type, Version = "ActionButton", 1
local function Constructor()
    local name = "AceGUI30Button" .. AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Button", name, UIParent, "UIPanelButtonTemplate")
    frame:Hide()

    frame:EnableMouse(true)

    local text = frame:GetFontString()
    text:ClearAllPoints()
    text:SetPoint("TOPLEFT", 15, -1)
    text:SetPoint("BOTTOMRIGHT", -15, 1)
    text:SetJustifyV("MIDDLE")

    local widget = {
        text  = text,
        frame = frame,
        type  = Type
    }
    for method, func in pairs(methodsx) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

