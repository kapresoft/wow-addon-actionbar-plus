local L = {}

local NUM_COLUMNS = 8
local ICON_BUTTON_SIZE = 32
local ICON_BUTTON_PADDING = 4

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local BACKDROPS = {
    backdrop = "modernDark", -- or 'none'
    backdropThemes = {
        modernDark = {
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
            --bgColor = {0.1, 0.3, 0.7, 0.8 },
            bgColor = { 0, 0, 0, 1 },
            borderColor = {1, 1, 1, 1},
        },
        stone = {
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 12, right = 12, top = 12, bottom = 12 },
            --bgColor = { 0.5, 0.4, 0.1, 0.8 },
            --bgColor = {0.1, 0.3, 0.7, 0.8 },
            bgColor = { 0, 0, 0, 1 },
            borderColor = { 0.9, 0.9, 0.9, 0.9 },
        },
        minimalist = {
            bgFile = "Interface/Buttons/WHITE8x8",
            edgeFile = nil,
            tile = false, tileSize = 0, edgeSize = 0,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
            bgColor = {0, 0, 0, 0.25},
            borderColor = {0, 0, 0, 0},
        },
    },
}

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

-- /run ABP_IconSelector:Show()
-- /dump ABP_IconSelector.iconDataProvider
function L:OnLoad()
    C_Timer.After(1, function()
        print('xx IconSelector::OnLoad called...')
    end)

    self.totalCount = 0

    -- Load all icons using Blizzard's provider (no Macro UI needed)
    self.iconDataProvider = CreateAndInitFromMixin(IconDataProviderMixin,
                                                   IconDataProviderExtraType.Spellbook,
                                                   IconDataProviderExtraType.Equipment)
    self.equipProvider = CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.Equipment)

    self.selectedTexture = nil
    self.SelectedIcon = self.SelectedIconArea.SelectedIconButton.Icon

    --self.ApplyBackdrop(self, BACKDROPS.backdrop)
    if self:GetName() == "ABP_IconSelector" then
        L.xApplyBackdrop(self, 'stone')
    end
end

function L:OnShow()
    print('xx IconSelectorPopupFrameMixin:OnLoad called...')
    self.IconSelector = self.IconSelectorScroll:GetScrollChild()
    if not self.initialized then
        self:BuildIconButtons()
        self:RefreshIcons()
        self.initialized = true
    end
end

----------------------------------------------------
-- Grid Creation
----------------------------------------------------
function L:BuildIconButtons()
    self.buttons = {}

    local spellProvider = CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.Spellbook)
    SP = spellProvider
    local equipProvider = CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.Equipment)

    local totalSpell = spellProvider:GetNumIcons()
    local totalEquip = equipProvider:GetNumIcons()
    self.totalCount = totalSpell + totalEquip
    print('xx Total Icons:', self.totalCount, 'Total SpellIcons:', totalSpell, 'Total Equip Icons:', totalEquip)
    -- Total Icons: 7854 SpellIcons: 3942 Total-Equip-Icons: 3912

    for i = 1, 500 do
        local button = CreateFrame("Button", nil, self.IconSelector, "ABP_IconSelectorButtonTemplate")
        button:SetSize(ICON_BUTTON_SIZE, ICON_BUTTON_SIZE)

        if i == 1 then
            button:SetPoint("TOPLEFT", 0, 0)
        else
            local row = math.floor((i-1) / NUM_COLUMNS)
            local col = (i-1) % NUM_COLUMNS

            button:SetPoint("TOPLEFT",
                            self.IconSelector,
                            "TOPLEFT",
                            col * (ICON_BUTTON_SIZE + ICON_BUTTON_PADDING),
                            -row * (ICON_BUTTON_SIZE + ICON_BUTTON_PADDING)
            )
        end

        button:SetScript("OnClick", function() self:SelectIcon(i) end)

        self.buttons[i] = button
    end
end


----------------------------------------------------
-- Icon Display
----------------------------------------------------
function L:RefreshIcons()
    local total = self.iconDataProvider:GetNumIcons()

    for i, button in ipairs(self.buttons) do
        if i <= total then
            local tex = self.iconDataProvider:GetIconByIndex(i)
            button.Icon:SetTexture(tex)
            button:Show()
        else
            button:Hide()
        end
    end
end


----------------------------------------------------
-- Selection Behavior
----------------------------------------------------
function L:SelectIcon(index)
    local texture = self.iconDataProvider:GetIconByIndex(index)
    self.selectedTexture = texture
    self.SelectedIcon:SetTexture(texture)
end


----------------------------------------------------
-- OK / Cancel
----------------------------------------------------
function L:OkayButton_OnClick()
    if self.callback then
        self.callback(self.selectedTexture)
    end
    self:Hide()
end

function L:CancelButton_OnClick()
    self:Hide()
end

function L.xApplyBackdrop(frame, theme)
    if theme == "none" then
        frame:SetBackdrop(nil)
        return
    end

    local config = BACKDROPS.backdropThemes[theme]
    if not config then return end

    frame:SetBackdrop({
                          bgFile = config.bgFile,
                          edgeFile = config.edgeFile,
                          tile = config.tile,
                          tileSize = config.tileSize,
                          edgeSize = config.edgeSize,
                          insets = config.insets,
                      })

    frame:SetBackdropColor(unpack(config.bgColor))
    frame:SetBackdropBorderColor(unpack(config.borderColor))

end

ABP_IconSelectorMixin = L
