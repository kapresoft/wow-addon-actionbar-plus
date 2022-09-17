--[[-----------------------------------------------------------------------------
Lua vars
-------------------------------------------------------------------------------]]
local type, tonumber = type, tonumber

--[[-----------------------------------------------------------------------------
Blizzard vars
-------------------------------------------------------------------------------]]
local UIParent, CreateFrame, C_Timer = UIParent, CreateFrame, C_Timer
local GetMacroIcons, GetMacroItemIcons = GetMacroIcons, GetMacroItemIcons

--[[-----------------------------------------------------------------------------
Local vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local Table, String, AceGUI, WMX = O.Table, O.String, O.AceLibFactory:GetAceGUI(), O.WidgetMixin
local WC = O.WidgetConstants
local ICON_PREFIX = 'Interface/Icons/'
local TEXTURE_DIALOG_GLOBAL_FRAME_NAME = 'ABP_TextureDialogFrame'

---@type MacroTextureDialogFrame
local thisDialog
local categoryCache
local macroIcons
local iconsLoaded = false
local iconLoadTimer
local loadOptions = {
    macro = {
        enable = false,
        loaded = false,
        name = 'Macro',
        incrementInSeconds = 1.0,
        chunkSize = 100
    },
    item = {
        enable = false,
        loaded = false,
        name = 'Item',
        incrementInSeconds = 2.0,
        chunkSize = 10
    }
}
local dialogOptions = {
    width = 750,
    resizeable = true
}
local iconOptions = {
    size = 38,
    relativeWidth = 0.065
}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class MacroTextureDialog
local _L = LibStub:NewLibrary(Core.M.MacroTextureDialog)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param dlg MacroTextureDialogFrame
local function CreateIcon(dlg, name, iconChunks, chunkCount, chunkIndex)
    for _,iconId in ipairs(iconChunks) do
        local icon = AceGUI:Create("Icon")
        icon:SetImage(iconId)
        icon:SetImageSize(iconOptions.size, iconOptions.size)
        icon:SetRelativeWidth(iconOptions.relativeWidth)
        icon:SetCallback('OnClick', function() dlg:SetSelectedIcon(iconId) end)
        icon:SetCallback('OnEnter', function() dlg:PreviewIcon(iconId) end)
        dlg.iconsScrollFrame:AddChild(icon)
    end
    --_L:log(10, 'Loading %s Icon Chunk[%s of %s]', name, chunkIndex, chunkCount)
end

local function MacroIconsSupplier()
    if not loadOptions.macro.enable or loadOptions.macro.loaded then return end
    local macIcons = GetMacroIcons()
    --if #macIcons <= 0 then return end
    --macIcons = Table.slice(macIcons, 1, 100)
    return macIcons, loadOptions.macro
end

local function ItemIconsSupplier()
    if not loadOptions.item.enable or loadOptions.item.loaded then return end
    local icons = {}
    local _itemIcons = GetMacroItemIcons()
    for i,icon in ipairs(_itemIcons) do
        --_L:log("%s: %s", i, icon)
        if i % 2 == 0 then
            table.insert(icons, icon)
        end
    end
    --icons = Table.slice(icons, 1, 100)
    return icons, loadOptions.item
end

function _L:LoadChunkIcons(iconSupplier)
    local icons, options = iconSupplier()
    if icons == nil or #icons <= 0 or options == nil then return end
    if not options.enable or options.loaded then return end
    local iconChunks = Table.chunkedArray(icons, options.chunkSize)
    local chunkCount = #iconChunks
    local chunkIndex = 1
    _L:log(1, 'Loading[%s] %s Icons with Chunk Size [%s]', #icons, options.name, options.chunkSize)
    local dlg = _L:GetDialog()
    iconLoadTimer = C_Timer.NewTicker(options.incrementInSeconds, function()
        local chunk = table.remove(iconChunks, 1)
        if chunk ~= nil then
            CreateIcon(dlg, options.name, chunk, chunkCount, chunkIndex)
            chunkIndex = chunkIndex + 1
        end
        if #iconChunks <= 0 then
            iconLoadTimer:Cancel()
            options.loaded = true
            _L:log(1, 'Done loading %s icons.', options.name)
            self:LoadChunkIcons(ItemIconsSupplier)
        end
    end)
end

local function LoadIconsIncrementally()
    _L:LoadChunkIcons(MacroIconsSupplier)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

---@return MacroTextureDialogFrame
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
    local defaultIcon = WC.C.TEXTURE_EMPTY

    ---@class MacroTextureDialogFrame
    local frame = AceGUI:Create("Frame")
    frame:EnableResize(dialogOptions.resizeable)

    --self:FetchMacroIcons()
    --self:FetchCategoriesCache()

    WMX:ConfigureFrameToCloseOnEscapeKey(TEXTURE_DIALOG_GLOBAL_FRAME_NAME, frame)

    frame:SetTitle("Choose an Icon")
    frame:SetStatusText('')
    frame:SetCallback("OnClose", function(widget)
        widget:SetStatusText('')
    end)
    frame:SetLayout("Flow")
    frame:SetWidth(dialogOptions.width)
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
    iconPreview:SetImageSize(iconOptions.size, iconOptions.size)
    iconPreview:SetWidth(iconOptions.size + 20)
    frame:AddChild(iconPreview)

    local scrollContainer = AceGUI:Create("SimpleGroup")
    scrollContainer:SetFullWidth(true)
    scrollContainer:SetFullHeight(true) -- probably?
    scrollContainer:SetLayout("Fill") -- important!

    local iconsScrollFrame = AceGUI:Create("ScrollFrame")
    iconsScrollFrame:SetFullHeight(true)
    iconsScrollFrame:SetFullWidth(true)
    iconsScrollFrame:SetLayout("Flow")

    frame:AddChild(scrollContainer)
    scrollContainer:AddChild(iconsScrollFrame)

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
local f = CreateFrame("Frame", Core.addonName .. "MacroTextureDialogFrame", UIParent)
f:SetScript("OnEvent", function(self, event, ...)
    if event ~= 'PLAYER_ENTERING_WORLD' then return end
    --local isLogin, isReload = ...
    --_L:log('isLogin=%s isReload=%s', isLogin, isReload)
    C_Timer.After(5.0, function() LoadIconsIncrementally() end)
end)
f:RegisterEvent("PLAYER_ENTERING_WORLD")

