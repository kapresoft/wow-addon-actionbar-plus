-- Dialog for Macro Textures
-- ## External -------------------------------------------------
local PrettyPrint, Table, String, LogFactory = ABP_LibGlobals:LibPackUtils()
local LibStub, M, G = ABP_LibGlobals:LibPack()


local type, tonumber = type, tonumber
local replace = String.replace

local GameTooltip, MC,
    ConfigureFrameToCloseOnEscapeKey, GetMacroItemIcons, ART_TEXTURES,
    TEXTURE_EMPTY, ANCHOR_TOPLEFT =
        GameTooltip, MacroIconCategories,
        ConfigureFrameToCloseOnEscapeKey, GetMacroItemIcons, ART_TEXTURES,
        TEXTURE_EMPTY, ANCHOR_TOPLEFT

local AceEvent, AceGUI = ABP_LibGlobals:LibPack_AceAddonLibs()

-- ## Local ----------------------------------------------------

---@class MacroTextureDialog
local _L = LibStub:NewLibrary(M.MacroTextureDialog)

-- ### Local Vars

local ICON_PREFIX = 'Interface/Icons/'
local TEXTURE_DIALOG_GLOBAL_FRAME_NAME = 'ABP_TextureDialogFrame'

local thisDialog = nil
local categoryCache = nil
local macroIcons = nil

-- ## Functions ------------------------------------------------

function _L:GetDialog()
    if thisDialog == nil then
        self:log('Creating new MacroTextureDialog')
        thisDialog = self:CreateTexturePopupDialog()
    end
    return thisDialog
end

function _L:Show()
    self:GetDialog():Show()
end

function _L:CreateTexturePopupDialog()
    local iconSize = 50
    local defaultIcon = TEXTURE_EMPTY

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

    local iconCategoryDropDown = AceGUI:Create("Dropdown")
    iconCategoryDropDown:SetWidth(250)
    iconCategoryDropDown:SetLabel("Category:")
    iconCategoryDropDown:SetList(MC:GetDropDownItems())
    frame:AddChild(iconCategoryDropDown)

    local function toIconName(iconPath)
        return replace(iconPath, ICON_PREFIX, '')
    end

    local function onValueChanged(selectedCategory)
        local categoryItems = categoryCache[selectedCategory]
        if categoryItems == nil or Table.isEmpty(categoryItems) then
            --self:log(1, 'Retrieving category items: %s', selectedCategory)
            categoryItems = MC:GetItemsByCategory(macroIcons, selectedCategory)
            categoryCache[selectedCategory] = categoryItems
        end
        frame:SetList(categoryItems)
        frame.iconsScrollFrame:ReleaseChildren()

        -- TODO: Toggle Children by Category (Cache)

        for iconId, iconPath in pairs(categoryItems) do
            local icon = AceGUI:Create("Icon")
            icon:SetImage(iconPath)
            icon:SetImageSize(iconSize, iconSize)
            icon:SetRelativeWidth(0.09)
            icon.iconDetails = {
                id = iconId, path = iconPath,
                getIconName = function()
                    return toIconName(iconPath)
                end,
                getTooltip = function()
                    return format("%s (%s)", iconPath, iconId)
                end,
            }
            icon:SetCallback('OnClick', function(widget)
                frame:SetEnteredIcon(widget.iconDetails.path)
                frame:SetIconPath(widget.iconDetails.id, widget.iconDetails.getIconName())
            end)
            icon:SetCallback('OnEnter', function(widget)
                GameTooltip:SetOwner(widget.frame, ANCHOR_TOPLEFT)
                GameTooltip:SetText(widget.iconDetails.getTooltip())
            end)
            icon:SetCallback('OnLeave', function(widget)
                GameTooltip:Hide()
            end)
            frame.iconsScrollFrame:AddChild(icon)
        end
    end

    iconCategoryDropDown:SetCallback("OnValueChanged", function(choice)
        onValueChanged(choice:GetValue())
    end)

    local baseWidth = 500
    local iconDropDown = AceGUI:Create("Dropdown")
    iconDropDown:SetLabel("Icon:")
    iconDropDown:SetWidth(baseWidth)
    iconDropDown:SetList({})
    iconDropDown:SetCallback("OnValueChanged", function(choice)
        -- choice is the drop-down list
        -- frame:SetTextContent(PrettyPrint.pformat(choice))
        local iconId = choice:GetValue()
        local iconTextPath = ART_TEXTURES[tonumber(iconId)]
        frame:SetSelectedIcon(iconId)
        frame:SetEnteredIcon(iconTextPath)
        frame:SetIconPath(iconId, toIconName(iconTextPath))
    end)
    frame:AddChild(iconDropDown)

    local iconFrameByDropDown = AceGUI:Create("Icon")
    iconFrameByDropDown:SetImage(defaultIcon)
    iconFrameByDropDown:SetImageSize(iconSize, iconSize)
    --iconFrameByDropDown:SetLabel("''")
    --ic:SetAttribute('type', 'spell')
    --ic:SetAttribute('spell', 'Cooking')
    frame:AddChild(iconFrameByDropDown)

    local iconEditbox = AceGUI:Create("EditBox")
    iconEditbox:SetLabel("or Select Icon By ID or Texture Path:")
    iconEditbox:SetWidth(baseWidth)
    iconEditbox:SetCallback("OnEnterPressed", function(widget, event, text)
        local value = ICON_PREFIX .. text
        if type(tonumber(text)) == 'number' then
            value = text
        end
        frame:SetEnteredIcon(value)
    end)
    frame:AddChild(iconEditbox)

    local iconFrameByInput = AceGUI:Create("Icon")
    -- ic:SetImage("Interface\\Icons\\inv_misc_note_05")
    iconFrameByInput:SetImage(defaultIcon)
    iconFrameByInput:SetImageSize(iconSize, iconSize)
    frame:AddChild(iconFrameByInput)

    local iconsScrollFrame = AceGUI:Create("ScrollFrame")
    iconsScrollFrame:SetFullHeight(true)
    iconsScrollFrame:SetFullWidth(true)
    iconsScrollFrame:SetLayout("Flow")

    --function iconsScrollFrame:HasChildren()
    --    return false
    --end
    --function iconsScrollFrame:SetVisibleState(self, isVisible)
    --    local children = self.children
    --    print('children:', children)
    --    for i = 1, #children do
    --        --AceGUI:Hide(children[i])
    --        if isVisible then
    --            children[i].frame:Show()
    --        else
    --            children[i].frame:Hide()
    --        end
    --        --children[i] = nil
    --    end
    --end

    frame:AddChild(iconsScrollFrame)
    frame.iconsScrollFrame = iconsScrollFrame

    -- ################################

    function frame:SetSelectedIcon(iconPathOrId)
        if not iconPathOrId then
            return
        end
        iconFrameByDropDown:SetImage(iconPathOrId)
    end
    function frame:SetEnteredIcon(iconPathOrId)
        if not iconPathOrId then
            return
        end
        iconFrameByInput:SetImage(iconPathOrId)
    end
    function frame:SetIconPath(iconId, iconPath)
        iconEditbox:SetText(iconPath)
        frame:SetStatusText(format("%s (%s)", iconPath, iconId))
    end
    function frame:SetList(list)
        iconDropDown:SetList(list)
    end

    function frame:SetSelectedCategory(category)
        iconCategoryDropDown:SetValue(category)
        onValueChanged(category)
    end

    --frame:SetSelectedCategory('Misc')
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
    macroIcons = GetMacroItemIcons()
    self:log(10, 'MacroIcons fetched')
end

