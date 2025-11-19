ABP_BACKDROPS = {
    backdrop = "stone",
    backdropThemes = {
        modernDark = {
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
            bgColor = {0.1, 0.3, 0.7, 0.8 },
            borderColor = {1, 1, 1, 1},
        },
        stone = {
            bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
            edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 12, right = 12, top = 12, bottom = 12 },
            bgColor = { 1, 1, 1, 1 },
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

function ABP_ApplyBackdrop(frame, theme)
    if theme == "none" then
        frame:SetBackdrop(nil)
        return
    end

    local config = ABP_BACKDROPS.backdropThemes[theme]
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
