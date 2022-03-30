--[[-----------------------------------------------------------------------------
Lua vars
-------------------------------------------------------------------------------]]
local type, tonumber = type, tonumber

--[[-----------------------------------------------------------------------------
Blizzard vars
-------------------------------------------------------------------------------]]
local UIParent, CreateFrame, C_Timer = UIParent, CreateFrame, C_Timer
local GetMacroIcons, GetMacroItemIcons = GetMacroIcons, GetMacroItemIcons
local GameTooltip, ConfigureFrameToCloseOnEscapeKey = GameTooltip, ConfigureFrameToCloseOnEscapeKey

--[[-----------------------------------------------------------------------------
Local vars
-------------------------------------------------------------------------------]]
local _, Table, String = ABP_LibGlobals:LibPackUtils()
local LibStub, M = ABP_LibGlobals:LibPack()
local _, AceGUI = ABP_LibGlobals:LibPack_AceLibrary()
local MC = MacroIconCategories
local ART_TEXTURES, TEXTURE_EMPTY, ANCHOR_TOPLEFT = ART_TEXTURES, TEXTURE_EMPTY, ANCHOR_TOPLEFT
local replace = String.replace
local ADDON_NAME = ADDON_NAME

---@class MacroTextureDialog
local _L = LibStub:NewLibrary(M.MacroTextureDialog)
---@type MacroTextureDialog
ABP_MacroTextureDialog = _L

local ICON_PREFIX = 'Interface/Icons/'
local TEXTURE_DIALOG_GLOBAL_FRAME_NAME = 'ABP_TextureDialogFrame'

---@type MacroTextureDialogFrame
local thisDialog
local iconSize = 35
local categoryCache
local macroIcons
local iconsLoaded = false
local iconLoadTimer

local loadMacroIcons = true
local loadItemIcons = false
local loadIconChunkSize = 20
local loadingTickerIncrementInSeconds = 2.0

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param dlg MacroTextureDialogFrame
local function CreateIcon(dlg, iconChunks, chunkCount, chunkIndex)
    for _,iconId in ipairs(iconChunks) do
        local icon = AceGUI:Create("Icon")
        icon:SetImage(iconId)
        icon:SetImageSize(iconSize, iconSize)
        icon:SetRelativeWidth(0.06)
        icon:SetCallback('OnClick', function() dlg:SetSelectedIcon(iconId) end)
        icon:SetCallback('OnEnter', function() dlg:PreviewIcon(iconId) end)
        dlg.iconsScrollFrame:AddChild(icon)
    end
    _L:log(10, 'Loading Icon Chunk[%s of %s] Loaded: %s', chunkIndex, chunkCount, #iconChunks)
end

local function LoadIconsIncrementally()
    if iconsLoaded then return end

    local dlg = _L:GetDialog()

    local icons = {}
    if loadMacroIcons then
        local macIcons = GetMacroIcons()
        icons = Table.append(macIcons, icons)
    end
    if loadItemIcons then
        local itemIcons = GetMacroItemIcons()
        icons = Table.append(itemIcons, icons)
    end
    _L:log(1, 'Loading %s icons in the background...', #icons)

    dlg.iconsScrollFrame:ReleaseChildren()
    local chunks = Table.chunkedArray(icons, loadIconChunkSize)
    iconsLoaded = true
    local chunkCount = #chunks
    local chunkIndex = 1
    iconLoadTimer = C_Timer.NewTicker(loadingTickerIncrementInSeconds, function()
        local chunk = table.remove(chunks, 1)
        if chunk ~= nil then
            CreateIcon(dlg, chunk, chunkCount, chunkIndex)
            chunkIndex = chunkIndex + 1
        end
        if #chunks <= 0 then
            iconLoadTimer:Cancel()
            _L:log(1, 'Done loading icons.')
        end
    end)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

function _L:GetDialog()
    if thisDialog == nil then
        self:log(10, 'New MacroTextureDialog instance created.')
        thisDialog = self:CreateTexturePopupDialog()
    end
    return thisDialog
end

---called via optionalCallbackFn(selectedValue)
function _L:Show(closeOnSelect, optionalCallbackFn)
    self.closeOnSelect = closeOnSelect or false
    self.optionalCallbackFn = optionalCallbackFn
    self:GetDialog():Show()
end


---@return MacroTextureDialogFrame
function _L:CreateTexturePopupDialog()
    local defaultIcon = TEXTURE_EMPTY

    ---@class MacroTextureDialogFrame
    local frame = AceGUI:Create("Frame")

    self:FetchMacroIcons()
    self:FetchCategoriesCache()

    ConfigureFrameToCloseOnEscapeKey(TEXTURE_DIALOG_GLOBAL_FRAME_NAME, frame)

    frame:SetTitle("Macro Icons")
    frame:SetStatusText('')
    frame:SetCallback("OnClose", function(widget)
        widget:SetStatusText('')
    end)
    frame:SetLayout("Flow")
    --frame:SetWidth(700)
    --frame:SetHeight(700)
    frame.iconsScrollFrame = nil

    local iconEditbox = AceGUI:Create("EditBox")
    iconEditbox:SetLabel("Selected Icon ID:")
    iconEditbox:SetWidth(150)
    ---### Selects and focuses on input box so user can cut or copy text
    iconEditbox:SetCallback("OnEnter", function(widget, event, text)
        widget:HighlightText()
        widget:SetFocus()
    end)
    iconEditbox:SetCallback("OnEnterPressed", function(widget, event, text)
        local value = ICON_PREFIX .. text
        if type(tonumber(text)) == 'number' then
            value = text
        end
        frame:SetEnteredIcon(value)
    end)
    frame:AddChild(iconEditbox)

    local iconPreview = AceGUI:Create("Icon")
    -- ic:SetImage("Interface\\Icons\\inv_misc_note_05")
    iconPreview:SetImage(defaultIcon)
    iconPreview:SetImageSize(iconSize, iconSize)
    iconPreview:SetWidth(iconSize + 20)
    frame:AddChild(iconPreview)

    local iconsScrollFrame = AceGUI:Create("ScrollFrame")
    iconsScrollFrame:SetFullHeight(true)
    iconsScrollFrame:SetFullWidth(true)
    iconsScrollFrame:SetLayout("Flow")

    frame:AddChild(iconsScrollFrame)
    frame.iconsScrollFrame = iconsScrollFrame

    -- ################################

    function frame:SetSelectedIcon(iconId)
        if not iconId then return end
        self:SetIconId(iconId)
        iconPreview:SetImage(iconId)
        if _L.optionalCallbackFn then
            _L:log(10, 'optionalCallbackFn: %s', _L.optionalCallbackFn)
            _L.optionalCallbackFn(iconId)
        end
        if _L.closeOnSelect then self:Hide() end
    end
    function frame:PreviewIcon(iconId)
        if not iconId then return end
        if not _L.closeOnSelect then return end
        self:SetIconId(iconId)
        iconPreview:SetImage(iconId)
    end
    function frame:SetEnteredIcon(iconPathOrId)
        if not iconPathOrId then
            return
        end
        iconPreview:SetImage(iconPathOrId)
        self:SetIconId(iconPathOrId)
    end
    function frame:SetIconPath(iconId, iconPath)
        iconEditbox:SetText(iconPath)
        frame:SetStatusText(format("%s (%s)", iconPath, iconId))
    end
    function frame:SetIconId(iconId)
        iconEditbox:SetText(iconId)
        frame:SetStatusText(iconId)
    end

    frame:Hide()
    return frame
end


function _L:FetchCategoriesCache()
    if categoryCache or type(categoryCache) == 'table' then
        return
    end
    categoryCache = MC:GetCategoriesCache()
    self:log(10, 'Macro icon categories cache fetched')
end

function _L:FetchMacroIcons()
    if macroIcons or type(macroIcons) == 'table' then
        return
    end
    --macroIcons = GetMacroIcons()
    macroIcons = GetMacroItemIcons()
    self:log(10, 'MacroIcons fetched')
end

--[[-----------------------------------------------------------------------------
Frame
-------------------------------------------------------------------------------]]
local f = CreateFrame("Frame", ADDON_NAME .. "MacroTextureDialogFrame", UIParent)
f:SetScript("OnEvent", function(self, event, ...)
    if event ~= 'PLAYER_ENTERING_WORLD' then return end
    --local isLogin, isReload = ...
    --_L:log('isLogin=%s isReload=%s', isLogin, isReload)
    C_Timer.After(5.0, function() LoadIconsIncrementally() end)
end)
f:RegisterEvent("PLAYER_ENTERING_WORLD")

