--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local HybridScrollFrame_Update = HybridScrollFrame_Update
local HybridScrollFrame_GetOffset = HybridScrollFrame_GetOffset
local HybridScrollFrame_CreateButtons = HybridScrollFrame_CreateButtons

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
ABP_IconSelector = {}
local S = ABP_IconSelector

-- Settings
local ICON_SIZE = 32
local ICON_PAD = 6
local ICON_COLS = 10
local ROW_HEIGHT = ICON_SIZE + ICON_PAD

-- The button padding
local GRID_PADDING_LEFT = 0

local MAX_BUTTONS = 200   -- cap regardless of scroll area height

local frame = ABP_IconSelectorFrame
local scrollFrame = frame.ScrollBox
C_Timer.After(1, function()
    print('xx scrollFrame:', scrollFrame)
end)
-- -----------------------------------------------------
-- PUBLIC API
-- -----------------------------------------------------
function S:Show(callback)
    self.callback = callback
    frame:Show()

    -- reload icons
    self.icons = ABP_IconSelectorProvider:GetIcons()
    self.filtered = self.icons

    self:InitGrid()
end

function S:Hide()
    frame:Hide()
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
    if not scrollFrame.buttons then
        HybridScrollFrame_CreateButtons(scrollFrame, "ABP_IconRowTemplate", ROW_HEIGHT, 0)
    end

    self:Redraw()
end


-- -----------------------------------------------------
-- VIRTUAL SCROLL UPDATE
-- -----------------------------------------------------
function S:Redraw()
    local icons = self.filtered
    local total = #icons
    print('xx total icons:', total)
    local rows = math.ceil(total / ICON_COLS)

    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local visibleRows = #scrollFrame.buttons
    print('xx visibleRows:', visibleRows)

    for rowIndex = 1, visibleRows do
        local row = scrollFrame.buttons[rowIndex]
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
    scrollFrame.scrollChild:SetHeight(contentHeight)

    HybridScrollFrame_Update(
            scrollFrame,
            contentHeight,
            scrollFrame:GetHeight()
    )
end

-- -----------------------------------------------------
-- ROW TEMPLATE POPULATION (called by CreateButtons)
-- -----------------------------------------------------
function ABPIconRowTemplate_OnLoad(self)
    print("xx ROW LOAD", self)
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
