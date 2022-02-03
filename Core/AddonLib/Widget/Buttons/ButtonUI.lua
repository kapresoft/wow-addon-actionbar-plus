--[[-----------------------------------------------------------------------------
ActionButton.lua
-------------------------------------------------------------------------------]]

-- WoW APIs
local PickupSpell, ClearCursor, GetCursorInfo, CreateFrame, UIParent =
    PickupSpell, ClearCursor, GetCursorInfo, CreateFrame, UIParent
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

local AssertThatMethodArgIsNotNil, AssertNotNil = A.AssertThatMethodArgIsNotNil, A.AssertNotNil
local SECURE_ACTION_BUTTON_TEMPLATE, CONFIRM_RELOAD_UI = SECURE_ACTION_BUTTON_TEMPLATE, CONFIRM_RELOAD_UI
local TOPLEFT, BOTTOMLEFT, ANCHOR_TOPLEFT = TOPLEFT, BOTTOMLEFT, ANCHOR_TOPLEFT
local TEXTURE_EMPTY, TEXTURE_HIGHLIGHT, TEXTURE_CASTING = ABP_WidgetConstants:GetButtonTextures()

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
    local info = _API_Spell:GetSpellCooldown(spell.id, spell)
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
---@param btnUI ButtonUI
local function OnDragStart(btnUI)
    ---@type ButtonUIWidget
    local w = btnUI.widget

    if InCombatLockdown() then return end
    if w.buttonData:IsLockActionBars() and not IsShiftKeyDown() then return end
    w:ClearCooldown()
    p:log(20, 'DragStarted| Actionbar-Info: %s', pformat(btnUI.widget:GetActionbarInfo()))

    local btnData = btnUI.widget:GetConfig()

    -- TODO: Temp. Skip non-spell stuff for now
    if btnData.type ~= WAttr.SPELL then return end

    local spellInfo = btnData[WAttr.SPELL]
    PickupSpell(spellInfo.id)
    w:ResetConfig()
    btnUI:SetNormalTexture(TEXTURE_EMPTY)
    btnUI:SetScript("OnEnter", nil)
    btnUI.widget:Fire('OnDragStart')
end

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
    button:HookScript('OnClick', OnClick)
    button:SetScript('OnEnter', OnEnter)
    button:SetScript('OnLeave', OnLeave)
    button:SetScript('OnDragStart', OnDragStart)
    button:SetScript('OnReceiveDrag', OnReceiveDrag)
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
        frameStrata = 'HIGH',
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

    ---@type ButtonUIWidget
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

