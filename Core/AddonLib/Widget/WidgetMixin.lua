--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub, M, Core, G = ABP_LibGlobals:LibPack_NewMixin()
local Mixin = Core:LibPack_Mixin()

---@return LoggerTemplate
local p = Core:NewLogger(M.WidgetMixin)

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class WidgetMixin
local _L = LibStub:NewLibrary(M.WidgetMixin)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function _L:Mixin(target, mixins)
    if type(mixins) ~= 'table' then
        Mixin:Mixin(target, self)
        return
    end
    for _, v in pairs(mixins) do target[v] = self[v] end
    return target
end

---@param button ButtonUI
function _L:CreateFontString(button)
    local fs = button:CreateFontString(button:GetName() .. 'Text', nil, "NumberFontNormal")
    fs:SetPoint("BOTTOMRIGHT",-3, 2)
    button.text = fs
end

---Font Flags: OUTLINE, THICKOUTLINE, MONOCHROME
---@see "https://wowpedia.fandom.com/wiki/API_FontInstance_SetFont"
---@param b ButtonUI The button UI
function _L:CreateIndexTextFontString(b)
    local fs = b:CreateFontString(b, "OVERLAY", "NumberFontNormalSmallGray")
    local fontName, fontHeight = fs:GetFont()
    fs:SetFont(fontName, fontHeight - 1, "OUTLINE")
    fs:SetTextColor(100/255, 100/255, 100/255)
    fs:SetPoint("BOTTOMLEFT", 4, 4)
    return fs
end

---Font Flags: OUTLINE, THICKOUTLINE, MONOCHROME
---@see "https://wowpedia.fandom.com/wiki/API_FontInstance_SetFont"
---@param b ButtonUI The button UI
function _L:CreateKeybindTextFontString(b)
    local fs = b:CreateFontString(b, "OVERLAY", "NumberFontNormalSmallGray")
    fs:SetTextColor(200/255, 200/255, 200/255)
    fs:SetPoint("TOP", 2, -2)
    return fs
end
