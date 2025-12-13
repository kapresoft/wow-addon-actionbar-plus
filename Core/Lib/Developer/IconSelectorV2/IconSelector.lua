--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local HybridScrollFrame_Update = HybridScrollFrame_Update
local HybridScrollFrame_GetOffset = HybridScrollFrame_GetOffset
local HybridScrollFrame_CreateButtons = HybridScrollFrame_CreateButtons
--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
--- @class IconSelector
--- @field scrollFrame Frame

ABP_IconSelectorMixin = {}
--- @type IconSelector | Frame
local S = ABP_IconSelectorMixin

-- Settings
local ICON_SIZE = 32
local ICON_PAD = 6
local ICON_COLS = 10
local ROW_HEIGHT = ICON_SIZE + ICON_PAD
local ROW_WIDTH =
(ICON_COLS * ICON_SIZE) +
        ((ICON_COLS - 1) * ICON_PAD)

-- The button padding
local GRID_PADDING_LEFT = 0
local ROW_PADDING_LEFT = 5
local ROW_PADDING_TOP = 0

local MAX_BUTTONS = 200   -- cap regardless of scroll area height

--local frame = ABP_IconSelectorFrame
--local scrollFrame = frame.ScrollBox

--[[-----------------------------------------------------------------------------
Handlers
-------------------------------------------------------------------------------]]
-- -----------------------------------------------------
-- ROW TEMPLATE POPULATION (called by CreateButtons)
-- -----------------------------------------------------
--- @param self Frame The frame of the row
function S.OnLoadRow(self)
    self:SetHeight(ROW_HEIGHT)

    -- Each row gets 12 icon buttons
    for col = 1, ICON_COLS do
        --- @type Button
        local b = CreateFrame("Button", nil, self)
        b:SetSize(ICON_SIZE, ICON_SIZE)

        if col == 1 then
            b:SetPoint("LEFT", self, "LEFT", GRID_PADDING_LEFT, 0)
        else
            b:SetPoint("LEFT", self[col-1], "RIGHT", ICON_PAD, 0)
        end

        b.icon = b:CreateTexture(nil, "ARTWORK")
        b.icon:SetAllPoints()

        b:SetScript("OnClick", function(self)
            if S.callback then
                S.callback(self.iconTexture)
            end
        end)

        self[col] = b
    end
end

-- -----------------------------------------------------
-- PUBLIC API
-- -----------------------------------------------------
function S:OnLoad()
    C_Timer.After(1, function()
        print('xxx onLoad called.')
        print("xx Has BackdropTemplate:", self.SetBackdrop ~= nil)
    end)
    self.scrollFrame = self.ScrollBox

    --self:SetBackdrop(ABP_ICON_SELECTOR_BACKDROPS.backdropThemes.modernDark)
    self:SetBackdrop(ABP_ICON_SELECTOR_BACKDROPS.backdropThemes.modernDark)

    -- REQUIRED in modern WoW
    --self:SetBackdropColor(0, 0, 0, 0.85)
    --self:SetBackdropBorderColor(1, 1, 1, 1)
end

function S:ShowDialog(callback)
    self.callback = callback

    -- reload icons
    self.icons = ABP_IconSelectorProvider:GetIcons()
    self.filtered = self.icons

    self:InitGrid()
    self:Show()

end

function S:OnClickClose() self:Hide() end

function S:OnClickOkay()
    print(self:GetName() .. '::', 'OK clicked')
    self:Hide()
end
function S:OnClickCancel()
    print(self:GetName() .. '::', 'Cancel clicked')
    self:Hide()
end

-- -----------------------------------------------------
-- SEARCH FILTER
-- -----------------------------------------------------
function S:OnSearchChanged(text)
    text = text:lower()

    if text == "" then
        self.filtered = self.icons
    else
        local result = {}
        for _, tex in ipairs(self.icons) do
            if tex:lower():find(text) then
                table.insert(result, tex)
            end
        end
        self.filtered = result
    end

    self:Redraw()
end


-- -----------------------------------------------------
-- GRID INITIALIZATION
-- -----------------------------------------------------
function S:InitGrid()
    if not self.scrollFrame.buttons then
        HybridScrollFrame_CreateButtons(self.scrollFrame, "ABP_IconRowTemplate", ROW_HEIGHT, 0)
    end

    self:Redraw()
end

function S:ResetRowPoints(row, rowIndex)
    row:ClearAllPoints()
    if rowIndex == 1 then
        row:SetPoint("TOPLEFT", self.scrollFrame.scrollChild, "TOPLEFT", ROW_PADDING_LEFT, ROW_PADDING_TOP)
    else
        row:SetPoint("TOPLEFT", self.scrollFrame.buttons[rowIndex-1], "BOTTOMLEFT", 0, 0)
    end
end

-- -----------------------------------------------------
-- VIRTUAL SCROLL UPDATE
-- -----------------------------------------------------
function S:Redraw()
    local icons = self.filtered
    local total = #icons
    print('xx total icons:', total)
    local rows = math.ceil(total / ICON_COLS)

    local offset = HybridScrollFrame_GetOffset(self.scrollFrame)
    local visibleRows = #self.scrollFrame.buttons
    print('xx visibleRows:', visibleRows)

    for rowIndex = 1, visibleRows do
        local row = self.scrollFrame.buttons[rowIndex]

        self:ResetRowPoints(row, rowIndex)

        local virtualRow = rowIndex + offset

        if virtualRow > rows then
            row:Hide()
        else
            row:Show()

            for col = 1, ICON_COLS do
                local index = ((virtualRow - 1) * ICON_COLS) + col
                local b = row[col]

                if not b then break end

                if index <= total then
                    local tex = icons[index]
                    b.icon:SetTexture(tex)
                    b.iconTexture = tex
                    b:Show()
                else
                    b:Hide()
                end
            end
        end
    end

    local contentHeight = rows * ROW_HEIGHT
    self.scrollFrame.scrollChild:SetHeight(contentHeight)

    HybridScrollFrame_Update(
            self.scrollFrame,
            contentHeight,
            self.scrollFrame:GetHeight()
    )
end


