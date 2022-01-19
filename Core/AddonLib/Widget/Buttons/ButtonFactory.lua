---
--- Button Factory
---
---@type table ButtonFactory
local PrettyPrint = ABP_PrettyPrint
local String, unpack, toStringSorted,
    ADDON_LIB, WLIB, H,
    ButtonFrameFactory, SpellAttributeSetter, ItemAttributeSetter, MacroAttributeSetter, MacrotextAttributeSetter,
    AssertThatMethodArgIsNotNil, AssertNotNil, pformat,
    ClearCursor, GetCursorInfo, CreateFrame, UIParent,
    GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show,
    SECURE_ACTION_BUTTON_TEMPLATE, TOPLEFT, BOTTOMLEFT, ANCHOR_TOPLEFT, CONFIRM_RELOAD_UI =

        ABP_String, ABP_Table.unpackIt, ABP_Table.toStringSorted,
        AceLibAddonFactory, WidgetLibFactory, ReceiveDragEventHandler,
        ABP_ButtonFrameFactory, SpellAttributeSetter, ItemAttributeSetter, MacroAttributeSetter, MacrotextAttributeSetter,
        Assert.AssertThatMethodArgIsNotNil, Assert.AssertNotNil, PrettyPrint.pformat,
        ClearCursor, GetCursorInfo, CreateFrame, UIParent,
        GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show,
        SECURE_ACTION_BUTTON_TEMPLATE, BOTTOMLEFT, TOPLEFT, ANCHOR_TOPLEFT, CONFIRM_RELOAD_UI

local pack, fmod = table.pack, math.fmod
local tostring, format, strlower, tinsert = tostring, string.format, string.lower, table.insert

-- TODO: Move to config
local INTERNAL_BUTTON_PADDING = 2
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
    ['item'] = ItemAttributeSetter,
    ['macro'] = MacroAttributeSetter,
    ['macrotext'] = MacrotextAttributeSetter,
}

-- Initialized on Logger#OnAddonLoaded()
F.addon = nil
F.profile = nil

local function isFirstButtonInRow(colSize, i) return fmod(i - 1, colSize) == 0 end

local function ShowConfigTooltip(frame)
    GameTooltip:SetOwner(frame, ANCHOR_TOPLEFT)
    GameTooltip:AddLine(format('Actionbar #%s: Right-click to open config UI', frame:GetFrameIndex(), 1, 1, 1))
    GameTooltip:Show()
    frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function OnLeaveFrame(_) GameTooltip:Hide() end
local function OnShowFrameTooltip(frame)
    ShowConfigTooltip(frame)
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
    --error(format('frames: %s', ABP_Table.toString(frames)))
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
    local f = ButtonFrameFactory(frameIndex)
    f:SetWidth((config.colSize * buttonSize) - INTERNAL_BUTTON_PADDING)
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

    btnUI:SetScript("OnLeave", function() GameTooltip:Hide() end)

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

    --{
    --    index = 2, name = 'ActionbarPlusF2',
    --    button = { index = 8, name = 'ActionbarPlusF2Button8' },
    --}
    function btnUI:GetActionbarInfo()
        return {
            name = frameName, index = dragFrame:GetFrameIndex(),
            button = { name = btnName, index = index },
        }
    end

    function btnUI:GetProfileButtonData()
        local info = self:GetActionbarInfo()
        if not info then return nil end
        return P:GetButtonData(info.index, info.button.name)
    end

    btnUI:SetFrameStrata(frameStrata)

    btnUI:SetSize(buttonSize - INTERNAL_BUTTON_PADDING, buttonSize - INTERNAL_BUTTON_PADDING)
    -- Reference point is BOTTOMLEFT of dragFrame
    -- dragFrameBottomLeftAdjustX, dragFrameBottomLeftAdjustY adjustments from #dragFrame
    local referenceFrameAdjustX = buttonSize
    local referenceFrameAdjustY = 2
    local adjX = (colNum * buttonSize) - referenceFrameAdjustX
    local adjY =  (rowNum * buttonSize) + INTERNAL_BUTTON_PADDING - referenceFrameAdjustY
    btnUI:SetPoint(TOPLEFT, dragFrame, TOPLEFT, adjX, -adjY)
    btnUI:SetNormalTexture(noIconTexture)

    --if btnName == 'ActionbarPlusF1Button3' then
    --    self:Bind()
    --end

    return btnUI
end

--function F:Bind()
--    local button3Binding = getBindingByName('ABP_ACTIONBAR1_BUTTON3')
--    print('Binding[ABP_ACTIONBAR1_BUTTON3]', pformat(button3Binding))
--    local button3 = 'ActionbarPlusF1Button3'
--    SetBindingClick(button3Binding.key1, button3)
--    if button3Binding.key2 then
--        SetBindingClick(button3Binding.key2, button3)
--    end
--end

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

    local cursorInfo = { type = actionType or '', info1 = info1, info2 = info2, info3 = info3 }
    if not self:IsValidDragSource(cursorInfo) then return end
    H:Handle(btnUI, actionType, cursorInfo)
end

function F:IsValidDragSource(cursorInfo)
    self:log(5, 'OnReceiveDrag Cursor-Info: %s', toStringSorted(cursorInfo))
    if String.IsBlank(cursorInfo.type) then
        -- This can happen if a chat tab or others is dragged into
        -- the action bar.
        self:log(5, 'Received drag event with invalid cursor info. Skipping...')
        return false
    end

    return true
end

function F:AttachFrameEvents(frame)
    frame:SetScript("OnMouseDown", OnMouseDownFrame)
    frame:SetScript("OnEnter", OnShowFrameTooltip)
    frame:SetScript("OnLEave", OnLeaveFrame)
end



