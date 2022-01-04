local _G = _G
local tostring, format, strlower, tinsert = tostring, string.format, string.lower, table.insert
local unpack, pack, mod = table.unpackIt, table.pack, math.fmod
local CreateFrame, UIParent, SECURE_ACTION_BUTTON_TEMPLATE = CreateFrame, UIParent, SECURE_ACTION_BUTTON_TEMPLATE
local GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show = GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show
local ABP_ACE_NEWLIB, TOPLEFT, ANCHOR_TOPLEFT, CONFIRM_RELOAD_UI = ABP_ACE_NEWLIB, TOPLEFT, ANCHOR_TOPLEFT, CONFIRM_RELOAD_UI
local F = ABP_ACE_NEWLIB('ButtonFactory')
if not F then return end

local S, SM = ABP_BUTTON_FACTORY()
local noIconTexture = SM:Fetch(SM.MediaType.BACKGROUND, "Blizzard Dialog Background")
local buttonSize = 40
local frameStrata = 'LOW'

--- Initialized on #OnAddonLoaded
local addon = nil

---- ## Start Here ----

local function isFirstButtonInRow(colSize, i) return fmod(i - 1, colSize) == 0 end
local function ShowConfigTooltip(frame)
    GameTooltip:SetOwner(frame, ANCHOR_TOPLEFT)
    GameTooltip:AddLine('Right-click to open config UI', 1, 1, 1)
    GameTooltip:Show()
    frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end
local function OnShowConfigTooltip(frame) C_Timer.After(1, function() ShowConfigTooltip(frame) end) end
local function OnMouseDownFrame(_, mouseButton)
    --F:log(1, 'Mouse Button Clicked: %s', mouseButton or '')
    GameTooltip:Hide()
    if IsShiftKeyDown() and strlower(mouseButton) == 'leftbutton' then
        ReloadUI()
    elseif strlower(mouseButton) == 'rightbutton' then
        addon:OpenConfig()
    elseif strlower(mouseButton) == 'button5' then
        StaticPopup_Show(CONFIRM_RELOAD_UI)
    end
end



function F:OnAddonLoaded(_addon)
    addon = _addon
    self:CreateButtons('ActionbarPlusF1', 2, 6)
    self:CreateButtons('ActionbarPlusF2', 6, 2)
end

function F:CreateButtons(frameName, rowSize, colSize)
    local f = FrameFactory:GetFrame(frameName)
    f:SetWidth(colSize * buttonSize)
    f:SetScale(1.0)
    f:SetFrameStrata(frameStrata)
    f:Show()
    self:AttachFrameEvents(f)

    local index = 0
    for row=1, rowSize do
        for col=1, colSize do
            index = index + 1
            local btnUI = self:CreateSingleButton(f, row, col, index)
        end
    end
    --self:log('Buttons Added for %s(%s): %s',
    --        f:GetName(), f:GetButtonCount(), table.concatkv(f:GetButtons()))

    -- if not movable then hide
    --f:Hide()
    --local padding = 5 +  buttonSpacing
    --f:SetSize(40 + adjX + padding, 40 + adjY + padding)
end

function F:CreateSingleButton(anchorFrame, rowNum, colNum, index)
    local frameName = anchorFrame:GetName()
    local btnName = format('%sButton%s', frameName, tostring(index))
    --self:printf('frame name: %s button: %s index: %s', frameName, btnName, index)
    local btnUI = CreateFrame("Button", btnName, UIParent, SECURE_ACTION_BUTTON_TEMPLATE)
    anchorFrame:AddButton(btnName)
    btnUI:SetFrameStrata(frameStrata)

    local padding = 2
    btnUI:SetSize(buttonSize - padding, buttonSize - padding)
    local topLeftAdjustX = buttonSize + padding - 1
    local topLeftAdjustY = buttonSize - 10
    local adjX = (colNum * buttonSize) + padding - topLeftAdjustX
    local adjY =  (rowNum * buttonSize) + padding - topLeftAdjustY
    btnUI:SetPoint(TOPLEFT, anchorFrame, TOPLEFT, adjX, -adjY)
    btnUI:SetNormalTexture(noIconTexture)
    return btnUI
end

function F:AttachFrameEvents(frame)
    frame:SetScript("OnMouseDown", OnMouseDownFrame)
    frame:SetScript("OnEnter", OnShowConfigTooltip)
end