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
local TOPLEFT, BOTTOMLEFT, ANCHOR_TOPLEFT = BOTTOMLEFT, TOPLEFT, ANCHOR_TOPLEFT
local TEXTURE_EMPTY, TEXTURE_HIGHLIGHT = ABP_WidgetConstants:GetButtonTextures()

-- TODO: Move to config
local INTERNAL_BUTTON_PADDING = 2

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

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
local function OnDragStart(btnUI)
    if InCombatLockdown() then return end
    if P:IsLockActionBars() and not IsShiftKeyDown() then return end
    btnUI.widget:ClearCooldown()
    p:log(20, 'DragStarted| Actionbar-Info: %s', pformat(btnUI.widget:GetActionbarInfo()))
    local btnData = btnUI.widget:GetConfig()
    local spellInfo = btnData[WAttr.SPELL]
    PickupSpell(spellInfo.id)
    btnUI.widget:ResetConfig()
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
Methods
-------------------------------------------------------------------------------]]
-- ButtonUI:Factory():NewButton(dragFrame, rowNum, colNum, index)
-- ButtonUI:Factory():FromButton(btnUI)
--- Widget Methods
---@class ButtonUI ButtonUIWidget methods
local methods = {
    ['GetName'] = function(self) return self.button:GetName() end,
    ['GetConfig'] = function(self) return P:GetButtonDataFromWidget(self) end,
    ['ResetConfig'] = function(self)
        P:ResetButtonData(self)
        self:ResetWidgetAttributes()
    end,
    ---@return ActionBarInfo
    ['GetActionbarInfo'] = function(self)
        local index = self.index
        local dragFrame = self.frame;
        local frameName = dragFrame:GetName()
        local btnName = format('%sButton%s', frameName, tostring(index))

        ---@class ActionBarInfo
        local info = {
            name = frameName, index = dragFrame:GetFrameIndex(),
            button = { name = btnName, index = index },
        }
        return info
    end,
    ---@deprecated Use #GetConfig()
    ['GetProfileButtonData'] = function(self)
        local info = self:GetActionbarInfo()
        if not info then return nil end
        return P:GetButtonData(info.index, info.button.name)
    end,
    ['ClearCooldown'] = function(self)
        self:SetCooldownDelegate(0, 0)
    end,
    ['SetCooldown'] = function(self, optionalInfo)
        local cd = optionalInfo or self.cooldownInfo
        if not cd then return end
        self:SetCooldownInfo(cd)
        self:SetCooldownDelegate(cd.start, cd.duration)
    end,
    ['SetCooldownDelegate'] = function(self, start, duration)
        self.cooldown:SetCooldown(start, duration)
    end,
    ['SetCooldownInfo'] = function(self, cooldownInfo)
        if not cooldownInfo then return end
        self.cooldownInfo = cooldownInfo
    end,
    ['ResetWidgetAttributes'] = function(self)
        for _,v in pairs(self.buttonAttributes) do
            self.button:SetAttribute(v, nil)
        end
    end,
}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local function NewLibrary()

    ---@class ButtonUIFactory
    local _L = LibStub:NewLibrary(M.ButtonUI, 1)

    ---@return ButtonUI
    function _L:Create(dragFrame, rowNum, colNum, index)
        local frameName = dragFrame:GetName()
        local btnName = format('%sButton%s', frameName, tostring(index))
        --self:printf('frame name: %s button: %s index: %s', frameName, btnName, index)
        local button = CreateFrame("Button", btnName, UIParent, SECURE_ACTION_BUTTON_TEMPLATE)
        --error('button: ' .. button:GetName())
        button:SetFrameStrata(frameStrata)
        button:SetSize(buttonSize - INTERNAL_BUTTON_PADDING, buttonSize - INTERNAL_BUTTON_PADDING)
        -- Reference point is BOTTOMLEFT of dragFrame
        -- dragFrameBottomLeftAdjustX, dragFrameBottomLeftAdjustY adjustments from #dragFrame
        local referenceFrameAdjustX = buttonSize
        local referenceFrameAdjustY = 2
        local adjX = (colNum * buttonSize) - referenceFrameAdjustX
        local adjY =  (rowNum * buttonSize) + INTERNAL_BUTTON_PADDING - referenceFrameAdjustY
        button:SetPoint(TOPLEFT, dragFrame, TOPLEFT, adjX, -adjY)
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
        --button.cooldownFrame = cooldown

        local mt = { __tostring = function() return 'ButtonUIWidget'  end }
        local widget = {
            p = p,
            frame = dragFrame,
            button = button,
            cooldown = cooldown,
            cooldownInfo = nil,
            frameStrata = 'LOW',
            buttonSize = 40,
            buttonAttributes = CC.ButtonAttributes,
        }
        setmetatable(widget, mt)

        dragFrame.widget, button.widget, cooldown.widget = widget, widget, widget
        for method, func in pairs(methods) do widget[method] = func end

        --error('widget:' .. pformat(widget))
        return widget
    end

    return _L
end

NewLibrary()