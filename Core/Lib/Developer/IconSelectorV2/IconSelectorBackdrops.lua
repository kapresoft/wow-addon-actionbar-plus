ABP_ICON_SELECTOR_BACKDROPS = {
    backdrop = "modernDark", -- or 'none'
    backdropThemes = {
        modernDark = BACKDROP_DARK_DIALOG_32_32,
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
        arena = BACKDROP_ARENA_32_32,
        gold = BACKDROP_GOLD_DIALOG_32_32,
        dark = BACKDROP_DARK_DIALOG_32_32,

    },
}
