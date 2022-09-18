--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GameTooltip, IsUsableSpell, C_Timer = GameTooltip, IsUsableSpell, C_Timer
local GetNumBindings, GetBinding, GameTooltip_AddBlankLinesToTooltip = GetNumBindings, GetBinding, GameTooltip_AddBlankLinesToTooltip
local GetModifiedClick, IsShiftKeyDown, IsAltKeyDown, IsControlKeyDown = GetModifiedClick, IsShiftKeyDown, IsAltKeyDown, IsControlKeyDown
local UISpecialFrames, StaticPopup_Show = UISpecialFrames, StaticPopup_Show
--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local setglobal = setglobal

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub, M, Core, G = ABP_LibGlobals:LibPack_NewMixin()
local O = Core:O()
local MX, String, P = O.Mixin, O.String, O.Profile
local WC = O.WidgetConstants
local IsBlank, IsNotBlank, ParseBindingDetails = String.IsBlank, String.IsNotBlank, String.ParseBindingDetails
local sreplace = String.replace

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
function _L:Mixin(target, ...) return MX:MixinOrElseSelf(target, self, ...) end

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

function _L:SetEnabledActionBarStatesDelayed(isShown, delayInSec)
    local actualDelayInSec = delayInSec
    local showActionBars = isShown == true
    if type(actualDelayInSec) ~= 'number' then actualDelayInSec = delayInSec end
    if actualDelayInSec <= 0 then actualDelayInSec = 1 end
    --C_Timer.After(actualDelayInSec, function() self:SetEnabledActionBarStates(showActionBars) end)
    self:SetEnabledActionBarStates(showActionBars)
end

---@param isShown boolean Set to true to show action bar
function _L:SetEnabledActionBarStates(isShown)
    local bars = P:GetBars()
    for frameName, profileData in pairs(bars) do
        if profileData.enabled == true then
            ---@type ButtonFrameFactory
            local f = _G[frameName]
            if f and f.widget then
                ---@type FrameWidget
                local widget = f.widget
                widget:SetGroupState(isShown)
                --self:log('bar: %s shown=%s', frameName, isShown)
            end
        end
    end
end

function _L:IsHideWhenTaxi() return P:IsHideWhenTaxi() end

function _L:HideTooltipDelayed(delayInSec)
    local actualDelayInSec = delayInSec
    if not actualDelayInSec or actualDelayInSec < 0 then
        GameTooltip:Hide()
        return
    end
    C_Timer.After(actualDelayInSec, function() GameTooltip:Hide() end)
end

---@return table The binding map with button names as the key
function _L:GetBarBindingsMap()
    local barBindingsMap = {}
    local bindCount = GetNumBindings()
    if bindCount <=0 then return nil end
    for i = 1, bindCount do
        local command,cat,key1,key2 = GetBinding(i)
        local bindingDetails = ParseBindingDetails(command)
        if  bindingDetails then
            local key1Short = key1
            if IsNotBlank(key1Short) then
                key1Short = sreplace(key1Short, 'ALT', 'a')
                key1Short = sreplace(key1Short, 'CTRL', 'c')
                key1Short = sreplace(key1Short, 'SHIFT', 's')
                key1Short = sreplace(key1Short, 'META', 'm')
                key1Short = String.ReplaceAllCharButLast(key1Short, '-')
            end
            barBindingsMap[bindingDetails.buttonName] = {
                btnName = bindingDetails.buttonName, category = cat,
                key1 = key1, key1Short = key1Short, key2 = key2,
                details = { action = bindingDetails.action, buttonPressed = bindingDetails.buttonPressed }
            }
        end
    end
    return barBindingsMap
end

---@return BindingInfo
---@param btnName string The button name
function _L:GetBarBindings(btnName)
    if IsBlank(btnName) then return nil end
    local bindCount = GetNumBindings()
    if bindCount <=0 then return nil end
    for i = 1, bindCount do
        local command,cat,key1,key2 = GetBinding(i)
        local bindingDetails = ParseBindingDetails(command)
        if  bindingDetails and btnName == bindingDetails.buttonName then
            local key1Short = key1
            if IsNotBlank(key1Short) then
                key1Short = sreplace(key1Short, 'ALT', 'a')
                key1Short = sreplace(key1Short, 'CTRL', 'c')
                key1Short = sreplace(key1Short, 'SHIFT', 's')
                key1Short = sreplace(key1Short, 'META', 'm')
                key1Short = String.ReplaceAllCharButLast(key1Short, '-')
            end
            return {
                name = command, btnName = btnName, category = cat,
                key1 = key1, key1Short = key1Short, key2 = key2
            }
        end
    end
    return nil
end
---@param frame ButtonUI In retail owner can be any frame; should be treated as a generic frame
function _L:IsTypeMacro(frame)
    if not (frame and frame.widget and frame.widget.buttonName) then return false end
    ---@see ButtonProfileMixin#IsMacro
    return frame.widget:IsMacro()
end

function _L:SetupTooltipKeybindingInfo(tooltip)
    local button = tooltip:GetOwner()
    if not button then return end
    local btnWidget = button.widget
    if btnWidget then
        self:AddKeybindingInfo(btnWidget)
    end
    tooltip:Show()
end

---@param btnWidget ButtonUIWidget
function _L:AddKeybindingInfo(btnWidget)
    if not btnWidget:HasKeybindings() then return end
    GameTooltip_AddBlankLinesToTooltip(GameTooltip, 1)
    local bindings = btnWidget:GetBindings()
    if not bindings.key1 then return end
    GameTooltip:AddDoubleLine('Keybind ::', bindings.key1, 1, 0.5, 0, 0 , 0.5, 1);
end

function _L:AddItemKeybindingInfo(btnWidget)
    if not btnWidget:HasKeybindings() then return end
    local bindings = btnWidget:GetBindings()
    GameTooltip:AppendText(String.format(WC.C.ABP_KEYBIND_FORMAT, bindings.key1))
end

function _L:IsDragKeyDown()
    -- 'NONE' if not specified
    local pickupAction = GetModifiedClick(G.C.PICKUPACTION)
    pickupAction = pickupAction == G.C.CTRL and G.C.SHIFT or pickupAction
    local isDragKeyDown = pickupAction == G.C.SHIFT and IsShiftKeyDown()
            or pickupAction == G.C.ALT and IsAltKeyDown()
            or pickupAction == G.C.CTRL and IsControlKeyDown()
    return isDragKeyDown
end

---@param button ButtonUI
function _L:CreateFontString(button)
    local fs = button:CreateFontString(button:GetName() .. 'Text', nil, "NumberFontNormal")
    fs:SetPoint(G.C.BOTTOMRIGHT,-3, 2)
    button.text = fs
end

function _L:ConfigureFrameToCloseOnEscapeKey(frameName, frameInstance)
    local frame = frameInstance
    if frameInstance.frame then frame = frameInstance.frame end
    setglobal(frameName, frame)
    table.insert(UISpecialFrames, frameName)
end

function _L:ShowReloadUIConfirmation() StaticPopup_Show(WC.C.CONFIRM_RELOAD_UI) end
