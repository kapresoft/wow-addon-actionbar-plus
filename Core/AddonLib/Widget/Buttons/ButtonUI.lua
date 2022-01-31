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
local LibStub, M, A, P, LSM, W, CC, G = ABP_WidgetConstants:LibPack()
local AceEvent, AceGUI = G:LibPack_AceLibrary()
local ButtonDataBuilder = G:LibPack_ButtonDataBuilder()

local PrettyPrint, Table, String, LogFactory = G:LibPackUtils()
local toStringSorted = Table.toStringSorted

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
local TEXTURE_EMPTY, TEXTURE_HIGHLIGHT, TEXTURE_CASTING = ABP_WidgetConstants:GetButtonTextures()

-- TODO: Move to config
local INTERNAL_BUTTON_PADDING = 2

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local waitTable = {};
local waitFrame = nil;

---#### Source
---* [https://wowwiki-archive.fandom.com/wiki/USERAPI_wait]
local function ABP_wait(delay, func, ...)
    if (type(delay)~="number" or type(func)~="function") then return false end
    if (waitFrame == nil) then
        waitFrame = CreateFrame("Frame", "WaitFrame", UIParent);
        waitFrame:SetScript("onUpdate", function (self, elapse)
            local count = #waitTable
            local i = 1
            while (i<=count) do
                local waitRecord = tremove(waitTable, i)
                local d = tremove(waitRecord, 1)
                local f = tremove(waitRecord, 1)
                local p = tremove(waitRecord, 1)
                if(d>elapse) then
                    tinsert(waitTable,i,{d-elapse, f, p})
                    i = i + 1
                else
                    count = count - 1
                    f(unpack(p))
                end
            end
        end)
    end
    tinsert(waitTable,{delay, func,{...}})
    return true
end

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

---@param btnUI ButtonUI
---@param spell SpellInfo
local function updateCooldown(btnUI, event, spell)
    --local evt = event:gsub('UNIT_SPELLCAST_', '')
    ---@type ButtonUIWidget
    local widget = btnUI.widget
    local logCooldown = false
    local info = _API_Spell:GetSpellCooldown(spell.id, spell.name)
    --p:log('info: %s', toStringSorted(info))
    -- Don't update cooldown on instant cast spells
    if info.duration <= 0 then
        if logCooldown then
            p:log('%s[%s]::%s <<Instant Cast>>\n%s', spell.name, spell.id, event, toStringSorted(info))
        end
        return
    end
    widget:SetCooldown(info)

    if logCooldown then
        p:log('%s[%s]::%s\n%s', spell.name, spell.id, event, toStringSorted(info))
        if event == 'OnSpellCastSucceeded' then p:log('') end
    end
end

local function RegisterCallbacks(widget)
    ---@param _widget ButtonUIWidget
    ---@param spell SpellInfo
    widget:SetCallback('OnSpellCastSent', function(_widget, event, spell)
        local btnUI = _widget.button
        btnUI:SetHighlightTexture(TEXTURE_CASTING)
        btnUI:LockHighlight()
        updateCooldown(_widget.button, event, spell)
    end)
    ---@param _widget ButtonUIWidget
    ---@param spell SpellInfo
    widget:SetCallback('OnSpellCastSucceeded', function(_widget, event, spell)
        local btnUI = _widget.button
        btnUI:SetHighlightTexture(TEXTURE_HIGHLIGHT)
        btnUI:UnlockHighlight()
        _widget:ClearCooldown()
        ABP_wait(0, function()  updateCooldown(_widget.button, event, spell) end)
    end)
    widget:SetCallback('OnDragStart', function(self, event)
        p:log('%s:: %s', event, tostring(self))
    end)
    widget:SetCallback("OnReceiveDrag", function(self, event)
        p:log('%s:: %s', event, tostring(self))
    end)
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
    btnUI.widget:Fire('OnDragStart')
end

local function OnReceiveDrag(btnUI)
    local BFF, H, SAS, IAS, MAS, MTAS = W:LibPack_ButtonFactory()

    AssertThatMethodArgIsNotNil(btnUI, 'btnUI', 'OnReceiveDrag(btnUI)')
    -- TODO: Move to TBC/API
    local actionType, info1, info2, info3 = GetCursorInfo()
    ClearCursor()

    local cursorInfo = { type = actionType or '', info1 = info1, info2 = info2, info3 = info3 }
    p:log(20, 'OnReceiveDrag Cursor-Info: %s', ToStringSorted(cursorInfo))
    if not IsValidDragSource(cursorInfo) then return end
    H:Handle(btnUI, actionType, cursorInfo)

    btnUI.widget:Fire('OnReceiveDrag')
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
        --return ButtonDataBuilder:Create(self.button)
        --return self.profile:GetButtonData(self.frameIndex, self.buttonName)
        return self.buttonData:GetData()
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
        --p:log('%s::SetCooldown start=%s end=%s', self:GetName(), start, duration)
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
    button:SetHighlightTexture(TEXTURE_HIGHLIGHT)
    button:HookScript('OnClick', OnClick)
    button:SetScript('OnEnter', OnEnter)
    button:SetScript('OnLeave', OnLeave)
    button:SetScript('OnReceiveDrag', OnReceiveDrag)
    button:SetScript('OnDragStart', OnDragStart)
    button:RegisterForDrag('LeftButton')

    local cdFrameName = btnName .. 'CDFrame'
    ---@class Cooldown
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
    ---@type ButtonData
    local buttonData = ButtonDataBuilder:Create(widget)
    widget.buttonData =  buttonData

    dragFrame.widget, button.widget, cooldown.widget, buttonData.widget = widget, widget, widget, widget

    --for method, func in pairs(methods) do widget[method] = func end
    WidgetMethods(widget)

    ---@type ButtonUIWidget
    RegisterWidget(widget, btnName .. '::Widget')
    RegisterCallbacks(widget)

    return widget
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

