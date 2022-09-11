--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub, M, Core, G = ABP_LibGlobals:LibPack_NewMixin()
local MX = Core:LibPack_Mixin()

---@return LoggerTemplate
local p = Core:NewLogger(M.WidgetMixin)

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class WidgetMixin
local _L = LibStub:NewLibrary(M.WidgetMixin)

---@class FontStringWidget
local FontStringWidget = {
    ---@type FontStringTemplate
    fontString = {}
}
---type Font (see _Buttons.xml)
function FontStringWidget:GetNormalFont() return ABP_NumberFontNormalShadow end
---NumberFontNormalRightRed is Blizz. Font
function FontStringWidget:GetRedFont() return NumberFontNormalRightRed end
function FontStringWidget:SetVertexColorNormal()
    self.fontString:SetVertexColor(self:GetNormalFont():GetTextColor())
end
function FontStringWidget:SetVertexColorOutOfRange()
    self.fontString:SetVertexColor(self:GetRedFont():GetTextColor())
end
function FontStringWidget:SetTextWithRangeIndicator()
    self.fontString:SetText(RANGE_INDICATOR)
end
function FontStringWidget:ClearText()
    self.fontString:SetText('')
end
function FontStringWidget:ScaleWithButtonSize(buttonSize)
    local fs = self.fontString
    local adjustX = buttonSize * 0.1
    local adjustY = buttonSize * 0.05
    fs:SetPoint("TOPRIGHT", -adjustX, -adjustY)
    local defaultFontHeight = 9
    local fontName, fontHeight = fs:GetFont()
    fontHeight = defaultFontHeight
    if buttonSize > 30 then
        local increase = math.ceil((buttonSize - 20) / 10)
        fontHeight = fontHeight + increase
    else
        fontHeight = defaultFontHeight
    end
    fs:SetFont(fontName, fontHeight, "OVERLAY")
end

---@class FontStringTemplate
local FontStringTemplate = {
    ---@type FontStringWidget
    widget = nil
}

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param target any
---@param mixins table A list of methods/properties to mix in
function _L:Mixin(target, mixins)
    if type(mixins) ~= 'table' then
        MX:Mixin(target, self)
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
    ---@type FontStringTemplate
    local fs = b:CreateFontString(b, "OVERLAY", "NumberFontNormalSmallGray")
    local fontName, fontHeight = fs:GetFont()
    fs:SetFont(fontName, fontHeight - 1, "OUTLINE")
    --fs:SetTextColor(100/255, 100/255, 100/255)
    fs:SetVertexColor(FontStringWidget:GetNormalFont():GetTextColor())
    fs:SetPoint("BOTTOMLEFT", 4, 4)

    return fs
end

---Font Flags: OUTLINE, THICKOUTLINE, MONOCHROME
---@see "https://wowpedia.fandom.com/wiki/API_FontInstance_SetFont"
---@param b ButtonUI The button UI
---@return FontStringTemplate
function _L:CreateKeybindTextFontString(b)
    ---@type FontStringTemplate
    local fs = b:CreateFontString(b, "OVERLAY", 'ABP_NumberFontNormalShadow')
    --local fontName, fontHeight = fs:GetFont()
    --fs:SetFont(fontName, fontHeight - 2, "THICKOUTLINE")
    fs:SetJustifyH("RIGHT")
    fs:SetJustifyV("TOP")
    ---@type FontStringWidget
    local widget = MX:Mixin({ }, FontStringWidget)
    widget.fontString = fs
    fs.widget = widget;

    return fs
end
