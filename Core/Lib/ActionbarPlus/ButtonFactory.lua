local _G = _G
local tostring, format, strlower, tinsert = tostring, string.format, string.lower, table.insert
local unpack, pack, fmod = table.unpackIt, table.pack, math.fmod
local CreateFrame, UIParent, SECURE_ACTION_BUTTON_TEMPLATE = CreateFrame, UIParent, SECURE_ACTION_BUTTON_TEMPLATE
local GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show = GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show
local TOPLEFT, ANCHOR_TOPLEFT, CONFIRM_RELOAD_UI = TOPLEFT, ANCHOR_TOPLEFT, CONFIRM_RELOAD_UI
local PU = ProfileUtil

local F = LibFactory:NewAceLib('ButtonFactory')
if not F then return end

local P, SM = LibFactory:GetButtonFactoryLibs()
local noIconTexture = SM:Fetch(SM.MediaType.BACKGROUND, "Blizzard Dialog Background")
local buttonSize = 40
local frameStrata = 'LOW'


---- ## Start Here ----

-- TODO: Load frame by index (from config toggle)
local frameDetails = {
    [1] = { rowSize = 2, colSize = 6 },
    [2] = { rowSize = 6, colSize = 2 },
    [3] = { rowSize = 3, colSize = 5 },
    [4] = { rowSize = 2, colSize = 6 },
    [5] = { rowSize = 2, colSize = 6 },
    [6] = { rowSize = 2, colSize = 6 },
    [7] = { rowSize = 2, colSize = 6 },
    [8] = { rowSize = 2, colSize = 6 },
}

-- Initialized on Logger#OnAddonLoaded()
F.addon = nil
F.profile = nil

local function isFirstButtonInRow(colSize, i) return fmod(i - 1, colSize) == 0 end
local function ShowConfigTooltip(frame)
    GameTooltip:SetOwner(frame, ANCHOR_TOPLEFT)
    GameTooltip:AddLine('Right-click to open config UI', 1, 1, 1)
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

function F:OnAfterInitialize()
    local frames = PU:GetAllFrameNames()
    for i,f in ipairs(frames) do
        local frameName = PU:GetFrameNameFromIndex(i)
        local frameEnabled = P:IsBarNameEnabled(frameName)
        --self:log('frame(%s): %s enabled: %s', tostring(i), f, tostring(frameEnabled))
        local config = frameDetails[i]
        if frameEnabled then self:CreateButtons(frameName, config.rowSize, config.colSize) end
    end
end

function F:CreateButtons(frameName, rowSize, colSize)
    if not P:IsBarNameEnabled(frameName) then
        return
    end

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
    f:MarkRendered()

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