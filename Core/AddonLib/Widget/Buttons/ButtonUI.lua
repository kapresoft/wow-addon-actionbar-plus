--[[-----------------------------------------------------------------------------
WoW Vars
-------------------------------------------------------------------------------]]
local PickupSpell, ClearCursor, GetCursorInfo, CreateFrame, UIParent =
    PickupSpell, ClearCursor, GetCursorInfo, CreateFrame, UIParent
local GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show =
GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show

--[[-----------------------------------------------------------------------------
LUA Vars
-------------------------------------------------------------------------------]]
local pack, fmod = table.pack, math.fmod
local tostring, format, strlower, tinsert = tostring, string.format, string.lower, table.insert

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub, M, A, P, LSM, W, CC, G = ABP_WidgetConstants:LibPack()
local _, AceGUI, AceHook = G:LibPack_AceLibrary()
local ButtonDataBuilder = G:LibPack_ButtonDataBuilder()

local _, Table, String, LogFactory = G:LibPackUtils()
local ToStringSorted = ABP_LibGlobals:LibPackPrettyPrint()
local IsBlank = String.IsBlank
local PH = ABP_PickupHandler

---@type LogFactory
local p = LogFactory:NewLogger('ButtonUI')

local noIconTexture = LSM:Fetch(LSM.MediaType.BACKGROUND, "Blizzard Dialog Background")

local AssertThatMethodArgIsNotNil, AssertNotNil = A.AssertThatMethodArgIsNotNil, A.AssertNotNil
local SECURE_ACTION_BUTTON_TEMPLATE, CONFIRM_RELOAD_UI = SECURE_ACTION_BUTTON_TEMPLATE, CONFIRM_RELOAD_UI
local TOPLEFT, BOTTOMLEFT, ANCHOR_TOPLEFT = TOPLEFT, BOTTOMLEFT, ANCHOR_TOPLEFT
local TEXTURE_EMPTY, TEXTURE_HIGHLIGHT, TEXTURE_CASTING = ABP_WidgetConstants:GetButtonTextures()

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

---@param widget ButtonUIWidget
---@param name string The widget name.
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
end

local function RegisterCallbacks(widget)
    -----@param _widget ButtonUIWidget
    -----@param event 'OnSpellCastSent'
    --widget:SetCallback('OnSpellCastSent', function(_widget)
    --    _widget:UpdateState()
    --end)
    ---@param _widget ButtonUIWidget
    ---@param event 'OnSpellUpdateCooldown'
    widget:SetCallback('OnSpellUpdateCooldown', function(_widget)
        p:log('Received: OnSpellUpdateCooldown')
        _widget:UpdateState()
        --_widget:Fire('OnAfterSpellCastSent', spell)
    end)
    ---@param _widget ButtonUIWidget
    widget:SetCallback('OnSpellCastSucceeded', function(_widget)
        --local spell = _widget:GetSpellData()
        _widget:UpdateState()
        --_widget:Fire('OnAfterSpellCastSucceeded', spell)
        --p:log(1, '%s:: %s', event, {...})
    end)
    widget:SetCallback('OnSpellCastFailed', function(_widget)
        _widget:UpdateCooldown()
    end)
    widget:SetCallback('OnDragStart', function(self, event)
        --p:log(50, '%s:: %s', event, tostring(self))
    end)
    widget:SetCallback("OnReceiveDrag", function(_widget)
        --p:log(50, '%s:: %s', event, tostring(self))
        _widget:UpdateCooldown()
    end)
    --widget:SetCallback('OnAfterSpellCastSent', function(_widget, event, spell)
    --    --p:log(50, '%s:: %s(%s)', event, spell.name, spell.id)
    --end)
    --widget:SetCallback('OnAfterSpellCastSucceeded', function(_widget, event, spell)
    --    --p:log(50, '%s:: %s(%s)', event, spell.name, spell.id)
    --end)
end

---@param widget ButtonUIWidget
---@param rowNum number The row number
---@param colNum number The column number
local function SetButtonLayout(widget, rowNum, colNum)
    local buttonSize = widget.buttonSize
    local buttonPadding = widget.buttonPadding
    local frameStrata = widget.frameStrata
    local button = widget.button
    local dragFrameWidget = widget.dragFrame

    local widthPaddingAdj = dragFrameWidget.padding
    local heightPaddingAdj = dragFrameWidget.padding + dragFrameWidget.dragHandleHeight
    local widthAdj = ((colNum - 1) * buttonSize) + widthPaddingAdj
    local heightAdj = ((rowNum - 1) * buttonSize) + heightPaddingAdj

    button:SetFrameStrata(frameStrata)
    button:SetSize(buttonSize - buttonPadding, buttonSize - buttonPadding)
    button:SetPoint(TOPLEFT, dragFrameWidget.frame, TOPLEFT, widthAdj, -heightAdj)
end

local function CreateFontString(button)
    local fs = button:CreateFontString(button:GetName() .. 'Text', nil, "NumberFontNormal")
    fs:SetPoint("BOTTOMRIGHT",-3, 2)
    button.text = fs
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function IsValidDragSource(cursorInfo)
    if IsBlank(cursorInfo.type) then
        -- This can happen if a chat tab or others is dragged into
        -- the action bar.
        p:log(5, 'Received drag event with invalid cursor info. Skipping...')
        return false
    end

    return true
end
---@param btnUI ButtonUI
local function OnDragStart(btnUI)
    ---@type ButtonUIWidget
    local w = btnUI.widget

    if InCombatLockdown() then return end
    if w.buttonData:IsLockActionBars() and not IsShiftKeyDown() then return end
    w:Reset()
    p:log(20, 'DragStarted| Actionbar-Info: %s', pformat(btnUI.widget:GetActionbarInfo()))

    local btnData = btnUI.widget:GetConfig()
    PH:Pickup(btnData)

    w:ResetConfig()
    btnUI:SetNormalTexture(TEXTURE_EMPTY)
    btnUI:SetScript("OnEnter", nil)
    btnUI.widget:Fire('OnDragStart')

    -- TODO NEXT: Handle Drag-And-Drop for Macro and Item
end

--- Used with `button:RegisterForDrag('LeftButton')`
---@param btnUI ButtonUI
local function OnReceiveDrag(btnUI)
    AssertThatMethodArgIsNotNil(btnUI, 'btnUI', 'OnReceiveDrag(btnUI)')

    -- TODO: Move to TBC/API
    local actionType, info1, info2, info3 = GetCursorInfo()
    ClearCursor()

    local cursorInfo = { type = actionType or '', info1 = info1, info2 = info2, info3 = info3 }
    p:log(20, 'OnReceiveDrag Cursor-Info: %s', ToStringSorted(cursorInfo))
    if not IsValidDragSource(cursorInfo) then return end

    local dragEventHandler = W:LibPack_ReceiveDragEventHandler()
    dragEventHandler:Handle(btnUI, actionType, cursorInfo)

    btnUI.widget:Fire('OnReceiveDrag')
end

local function OnLeave(_) GameTooltip:Hide() end
local function OnClick(btn, mouseButton, down)
    p:log(20, 'SecureHookScript| Actionbar: %s', pformat(btn.widget:GetActionbarInfo()))
    local actionType = GetCursorInfo()
    if String.IsBlank(actionType) then return end
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
        return self.buttonData:GetData()
    end

    function widget:SetText(text)
        if text == nil then text = '' end
        widget.button.text:SetText(text)
    end
    function widget:ClearText() self:SetText('') end

    function widget:GetSpellData()
        local btnData = self:GetConfig()
        if btnData.type ~= 'spell' and Table.isEmpty(btnData['spell']) then return nil end
        local spell = btnData['spell']
        if String.IsBlank(spell.id) then return nil end
        return spell
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

    function widget:Reset()
        self:ResetCooldown()
        self:ClearText()
    end

    function widget:ResetCooldown() self:SetCooldown(0, 0) end

    function widget:SetCooldown(start, duration)
        self.cooldown:SetCooldown(start, duration)
        --p:log('%s::SetCooldown start=%s end=%s', self:GetName(), start, duration)
    end

    function widget:UpdateState()
        self:UpdateCooldown()
        self:UpdateItemState()
    end

    function widget:UpdateCooldown()
        ---@type SpellCooldown
        local cd = self:GetSpellCooldown()
        if not cd or cd.enabled == 0 then return end
        -- Instant cast spells have zero duration, skip
        if cd.duration <= 0 then
            self:ResetCooldown()
            return
        end
        self:SetCooldown(cd.start, cd.duration)
        --p:log('%s::SetCooldown start=%s end=%s', self:GetName(), cd.start, cd.duration)
        --p:log('Cooldown[%s]: %s', self:GetName(), cd)
    end

    function widget:UpdateItemState()
        local btnData = self:GetConfig()
        if btnData.type ~= 'item' and Table.isEmpty(btnData['item']) then return nil end
        local itemInfo = _API:GetItemInfo(btnData.item.id)
        --if itemInfo == nil then return end
        btnData.item.count = itemInfo.count
        if itemInfo then self:SetText(btnData.item.count) end
    end

    function widget:GetSpellCooldown()
        local spell = self:GetSpellData()
        if not spell then return end
        return _API:GetSpellCooldown(spell.id, spell)
    end

    function widget:ResetWidgetAttributes()
        for _, v in pairs(self.buttonAttributes) do
            self.button:SetAttribute(v, nil)
        end
    end

    function widget:HasActionAssigned()
        local d = self.buttonData:GetData()
        local type = d.type
        if String:IsBlank(type) then return false end
        local spellDetails = d[type]
        if Table.size(spellDetails) <= 0 then return false end
        return true
    end

end

--[[-----------------------------------------------------------------------------
Builder Methods
-------------------------------------------------------------------------------]]
---@class ButtonUIWidgetBuilder
local _B = LogFactory:NewLogger('ButtonUIWidgetBuilder', {})

---Creates a new ButtonUI
---@param dragFrameWidget FrameWidget The drag frame this button is attached to
---@param rowNum number The row number
---@param colNum number The column number
---@param btnIndex number The button numeric index
---@return ButtonUIWidget
function _B:Create(dragFrameWidget, rowNum, colNum, btnIndex)

    local frameName = dragFrameWidget:GetName()
    local btnName = format('%sButton%s', frameName, tostring(btnIndex))

    ---@class ButtonUI
    local button = CreateFrame("Button", btnName, UIParent, SECURE_ACTION_BUTTON_TEMPLATE)
    button:SetNormalTexture(noIconTexture)
    button:SetHighlightTexture(TEXTURE_HIGHLIGHT)
    AceHook:SecureHookScript(button, 'OnClick', OnClick)
    button:SetScript('OnDragStart', OnDragStart)
    button:SetScript('OnReceiveDrag', OnReceiveDrag)
    button:SetScript('OnLeave', OnLeave)
    CreateFontString(button)


    button:RegisterForDrag('LeftButton')

    ---@class Cooldown
    local cooldown = CreateFrame("Cooldown", btnName .. 'Cooldown', button,  "CooldownFrameTemplate")
    cooldown:SetAllPoints(button)
    cooldown:SetSwipeColor(1, 1, 1)

    ---@class ButtonUIWidget
    local widget = {
        ---@type Logger
        p = p,
        ---@type Profile
        profile = P,
        ---@type number
        frameIndex = dragFrameWidget:GetFrameIndex(),
        --@type string
        buttonName = btnName,
        ---@type Frame
        dragFrame = dragFrameWidget,
        ---@type ButtonUI
        button = button,
        ---@type ButtonUI
        frame = button,
        ---@type Cooldown
        cooldown = cooldown,
        ---@type table
        cooldownInfo = nil,
        ---Don't make this 'LOW'. ElvUI AFK Disables it after coming back from AFK
        ---@type string
        frameStrata = 'MEDIUM',
        ---@type number
        buttonSize = dragFrameWidget.buttonSize,
        ---@type number
        buttonPadding = 2,
        ---@type table
        buttonAttributes = CC.ButtonAttributes,
    }
    ---@type ButtonData
    local buttonData = ButtonDataBuilder:Create(widget)
    widget.buttonData =  buttonData

    button.widget, cooldown.widget, buttonData.widget = widget, widget, widget

    --for method, func in pairs(methods) do widget[method] = func end
    WidgetMethods(widget)
    SetButtonLayout(widget, rowNum, colNum)

    RegisterWidget(widget, btnName .. '::Widget')
    RegisterCallbacks(widget)

    return widget
end

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local function NewLibrary()

    local _L = LibStub:NewLibrary(M.ButtonUI, 1)

    function _L:WidgetBuilder() return _B end

    return _L
end

NewLibrary()

