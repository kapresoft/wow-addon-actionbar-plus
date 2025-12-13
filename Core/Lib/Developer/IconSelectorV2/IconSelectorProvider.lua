ABP_IconSelectorProvider = {}
local P = ABP_IconSelectorProvider

local provider = nil


-- -----------------------------------------------------
-- Initialize unified provider on first use
-- -----------------------------------------------------
local function EnsureProvider()
    if provider then return end

    provider = CreateAndInitFromMixin(
            IconDataProviderMixin
            -- adding these will filter player-only spells/items
            --,IconDataProviderExtraType.Spellbook
            --,IconDataProviderExtraType.Equipment
    )
end


-- -----------------------------------------------------
-- Return unified icon list
-- -----------------------------------------------------
function P:GetIcons()
    EnsureProvider()

    local icons = {}
    local total = provider:GetNumIcons()
    print('xx totalIcons:', total)
    for i = 1, total do
        icons[i] = provider:GetIconByIndex(i)
    end

    return icons
end
