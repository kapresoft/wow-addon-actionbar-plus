local _G = _G
local ClearCursor, GetCursorInfo = ClearCursor, GetCursorInfo
local tostring, format, strlower, tinsert, toStringSorted = tostring, string.format, string.lower, table.insert, table.toStringSorted
local unpack, pack, fmod, pformat = table.unpackIt, table.pack, math.fmod, PrettyPrint
local AssertThatMethodArgIsNotNil, AssertNotNil = Assert.AssertThatMethodArgIsNotNil, Assert.AssertNotNil

local CreateFrame, UIParent, SECURE_ACTION_BUTTON_TEMPLATE = CreateFrame, UIParent, SECURE_ACTION_BUTTON_TEMPLATE
local GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show = GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show
local TOPLEFT, ANCHOR_TOPLEFT, CONFIRM_RELOAD_UI = TOPLEFT, ANCHOR_TOPLEFT, CONFIRM_RELOAD_UI
local ADDON_LIB, WLIB, H = AceLibAddonFactory, WidgetLibFactory, ReceiveDragEventHandler
local FrameFactory,SpellAttributeSetter  = FrameFactory,SpellAttributeSetter

local P = WidgetLibFactory:GetProfile()

local F = ADDON_LIB:NewAceLib('ButtonFactory')
if not F then return end

local P, SM = WLIB:GetButtonFactoryLibs()
local noIconTexture = SM:Fetch(SM.MediaType.BACKGROUND, "Blizzard Dialog Background")
local buttonSize = 40
local frameStrata = 'LOW'


---- ## Start Here ----

local AttributeSetters = {
    ['spell'] = SpellAttributeSetter,
    ['item'] = nil,
    ['macro'] = nil,
    ['macrotext'] = nil
}

-- Initialized on Logger#OnAddonLoaded()
F.addon = nil
F.profile = nil

local function isFirstButtonInRow(colSize, i) return fmod(i - 1, colSize) == 0 end

local function ShowConfigTooltip(frame)
    GameTooltip:SetOwner(frame, ANCHOR_TOPLEFT)
    GameTooltip:AddLine('Right-click to open config UI for Actionbar ' .. frame:GetFrameIndex(), 1, 1, 1)
    GameTooltip:Show()
    frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function OnShowConfigTooltip(frame)
    C_Timer.After(1, function() ShowConfigTooltip(frame) end)
    C_Timer.After(3, function() GameTooltip:Hide() end)
end

local function OnMouseDownFrame(_, mouseButton)
    --F:log(1, 'Mouse Button Clicked: %s', mouseButton or '')
    GameTooltip:Hide()
    if IsShiftKeyDown() and strlower(mouseButton) == 'leftbutton' then
        ReloadUI()
    elseif strlower(mouseButton) == 'rightbutton' then
        F.addon:OpenConfig()
    elseif strlower(mouseButton) == 'button5' then
        StaticPopup_Show(CONFIRM_RELOAD_UI)
    end
end


local function Embed(btnUI)
    -- TODO
end

function F:OnAfterInitialize()
    local frames = P:GetAllFrameNames()
    --error(format('frames: %s', table.toString(frames)))
    for i,f in ipairs(frames) do
        local frameEnabled = P:IsBarIndexEnabled(i)
        local f = self:CreateActionbarGroup(i)
        if frameEnabled then
            f:ShowGroup()
        else
            f:HideGroup()
        end
    end
end

function F:CreateActionbarGroup(frameIndex)
    -- TODO: config should be in profiles
    local config = P:GetActionBarSizeDetailsByIndex(frameIndex)
    local f = FrameFactory(frameIndex)
    f:SetWidth(config.colSize * buttonSize)
    f:SetScale(1.0)
    f:SetFrameStrata(frameStrata)
    self:CreateButtons(f, config.rowSize, config.colSize)
    f:MarkRendered()
    self:AttachFrameEvents(f)
    return f
end

function F:CreateButtons(dragFrame, rowSize, colSize)
    local index = 0
    for row=1, rowSize do
        for col=1, colSize do
            index = index + 1
            local btnUI = self:CreateSingleButton(dragFrame, row, col, index)
            self:SetButtonAttributes(btnUI)
            btnUI:SetScript("OnReceiveDrag", function(_btnUI) self.OnReceiveDrag(self, _btnUI) end)
            dragFrame:AddButton(btnUI:GetName())
        end
    end
end

function F:GetAttributesSetter(actionType)
    AssertNotNil(actionType, 'actionType')
    return AttributeSetters[actionType]
end

function F:SetButtonAttributes(btnUI)
    local actionbarInfo = btnUI:GetActionbarInfo()
    local btnName = btnUI:GetName()
    local btnData = P:GetButtonData(actionbarInfo.index, btnName)

    --local key = actionbarInfo.name .. btnName
    --local btnData = P.profile[key]

    if btnData == nil or btnData.type == nil then return end


    local setter = self:GetAttributesSetter(btnData.type)
    if not setter then
        self:log(1, 'No Attribute Setter found for type: %s', btnData.type)
        return
    end
    setter:SetAttributes(btnUI, btnData)
end

-- TODO: Move somewhere else
function F:CreateSingleButton(dragFrame, rowNum, colNum, index)
    local frameName = dragFrame:GetName()
    local btnName = format('%sButton%s', frameName, tostring(index))
    --self:printf('frame name: %s button: %s index: %s', frameName, btnName, index)
    local btnUI = CreateFrame("Button", btnName, UIParent, SECURE_ACTION_BUTTON_TEMPLATE)

    -- Custom
    function btnUI:GetActionbarInfo()
        return { name = frameName, index = dragFrame:GetFrameIndex() }
    end

    btnUI:SetFrameStrata(frameStrata)

    local padding = 2
    btnUI:SetSize(buttonSize - padding, buttonSize - padding)
    local topLeftAdjustX = buttonSize + padding - 1
    local topLeftAdjustY = buttonSize - 10
    local adjX = (colNum * buttonSize) + padding - topLeftAdjustX
    local adjY =  (rowNum * buttonSize) + padding - topLeftAdjustY
    btnUI:SetPoint(TOPLEFT, dragFrame, TOPLEFT, adjX, -adjY)
    btnUI:SetNormalTexture(noIconTexture)

    return btnUI
end

-- See: https://wowpedia.fandom.com/wiki/API_GetCursorInfo
--      This one is incorrect:  https://wowwiki-archive.fandom.com/wiki/API_GetCursorInfo
-- spell: spellId=info1 bookType=info2 ?=info3
-- item: itemId = info1, itemName/Link = info2
-- macro: macro-index=info1
function F:OnReceiveDrag(btnUI)
    AssertThatMethodArgIsNotNil(btnUI, 'btnUI', 'OnReceiveDrag(btnUI)')
    -- TODO: Move to TBC/API
    local actionType, info1, info2, info3 = GetCursorInfo()
    ClearCursor()
    local cursorData = { actionType=actionType, info1=tostring(info1), info2=tostring(info2), info3=tostring(info3) }
    self:log(10, 'Drag Data: %s', toStringSorted(cursorData))

    local cursorInfo = { type = actionType, bookIndex = info1, bookType = info2, id = info3 }
    if not H:CanHandle(actionType) then
        self:log('No handler found for type: %s %s', actionType, pformat('Cursor:', cursorInfo))
        return
    end
    H:Handle(btnUI, actionType, cursorInfo)

    --if 'spell' == actionType then
    --    local spellInfo = { type = actionType, name='TODO', bookIndex = info1, bookType = info2, id = info3 }
    --    self:logp('Spell Info', spellInfo)
    --elseif 'item' == actionType then
    --    local itemInfo = { type = actionType, id=info1, name='TODO', link=info2 }
    --   self:logp('Item Info', itemInfo)
    --end

end

function F:AttachFrameEvents(frame)
    frame:SetScript("OnMouseDown", OnMouseDownFrame)
    frame:SetScript("OnEnter", OnShowConfigTooltip)
end