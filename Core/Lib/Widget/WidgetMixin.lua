--[[-----------------------------------------------------------------------------
Types
-------------------------------------------------------------------------------]]
--- @class BindingInfo
--- @field btnName Name
--- @field category string
--- @field key1 string
--- @field key1Short string
--- @field key2 string
--- @field details BindingDetails

--- @class _FontStringTemplate
--- @field widget FontStringWidget

--- @alias FontStringTemplate _FontStringTemplate | FontString
--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetNumBindings, GetBinding, GameTooltip_AddBlankLinesToTooltip = GetNumBindings, GetBinding, GameTooltip_AddBlankLinesToTooltip
local UISpecialFrames, StaticPopup_Visible, StaticPopup_Show = UISpecialFrames, StaticPopup_Visible, StaticPopup_Show
local StaticPopupDialogs, ReloadUI = StaticPopupDialogs, ReloadUI
--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local setglobal = setglobal

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

local api = O.API
local String, P = ns:String(), O.Profile
local IsBlank, IsNotBlank, ParseBindingDetails = String.IsBlank, String.IsNotBlank, String.ParseBindingDetails
local sreplace = String.replace

local MAX_NAME_CHARACTER_COUNT = 3

StaticPopupDialogs[GC.C.CONFIRM_RELOAD_UI] = {
    text = "Reload UI?", button1 = "Yes", button2 = "No",
    timeout = 0, whileDead = true, hideOnEscape = true,
    OnAccept = function() ReloadUI() end,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}
--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function abh() return O.ActionBarHandlerMixin end

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
-- todo next: rename to WidgetUtil?
--- @class WidgetMixin : BaseLibraryObject
local L = LibStub:NewLibrary(M.WidgetMixin)
local p = ns:CreateDefaultLogger(M.WidgetMixin)

--- @class FontStringWidget
local FontStringWidget = {
    --- @type FontStringTemplate
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
function FontStringWidget:SetTextAsRangeIndicator()
    self.fontString:SetText(RANGE_INDICATOR)
end
function FontStringWidget:ClearText() self.fontString:SetText('') end
function FontStringWidget:Show() self.fontString:Show() end
function FontStringWidget:Hide() self.fontString:Hide() end

function FontStringWidget:ScaleWithButtonSize(buttonSize)
    local fs = self.fontString
    local adjustX = buttonSize * 0.1
    local adjustY = buttonSize * 0.05
    fs:SetPoint("TOPRIGHT", -adjustX, -adjustY)
    local defaultFontHeight = 9
    local fontName, fontHeight = fs:GetFont()
    fontHeight = defaultFontHeight
    if buttonSize > 30 then
        local increase = math.ceil((buttonSize - 20) / 5)
        fontHeight = fontHeight + increase
    else
        fontHeight = defaultFontHeight
    end
    fs:SetFont(fontName, fontHeight, "OVERLAY")
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- @param button ButtonUI
--- @return FontString
function L:CreateFontString(button)
    local fs = button:CreateFontString(nil, nil, "NumberFontNormal")
    fs:SetPoint("BOTTOMRIGHT", -3, 2)
    local _, fontHeight = fs:GetFont()
    fs.textDefaultFontHeight = fontHeight
    return fs
end

--- ### See: "Interface/FrameXML/ActionButtonTemplate.xml"
--- ### See: [https://wowpedia.fandom.com/wiki/API_FontInstance_SetFont](https://wowpedia.fandom.com/wiki/API_FontInstance_SetFont)
--- @param b ButtonUI The button UI
--- @return FontString
function L:CreateNameTextFontString(b)
    --- @type FontString
    local fs = b:CreateFontString("$parentName", "OVERLAY", 'NumberFontNormalSmallGray')
    local fontName, fontHeight = fs:GetFont()
    fs:SetFont(fontName, fontHeight - 1, "OUTLINE")
    fs:SetPoint("BOTTOM", b,"BOTTOM", 3, 5)
    function fs:SetEllipsesText(text)
        if IsBlank(text) then self:SetText('') return end
        if #text > MAX_NAME_CHARACTER_COUNT then
            text = string.sub(text, 1, MAX_NAME_CHARACTER_COUNT) .. "..."
        end
        self:SetText(text)
    end
    return fs
end

---Font Flags: OUTLINE, THICKOUTLINE, MONOCHROME
--- @see "https://wowpedia.fandom.com/wiki/API_FontInstance_SetFont"
--- @param b ButtonUI The button UI
function L:CreateIndexTextFontString(b)
    --- @type FontStringTemplate
    local fs = b:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray")
    local fontName, fontHeight = fs:GetFont()
    fs:SetFont(fontName, fontHeight - 1, "OUTLINE")
    --fs:SetTextColor(100/255, 100/255, 100/255)
    fs:SetVertexColor(FontStringWidget:GetNormalFont():GetTextColor())
    fs:SetPoint("BOTTOMLEFT", 4, 4)

    return fs
end

---Font Flags: OUTLINE, THICKOUTLINE, MONOCHROME
--- @see "https://wowpedia.fandom.com/wiki/API_FontInstance_SetFont"
--- @param b ButtonUI The button UI
--- @return FontStringTemplate
function L:CreateKeybindTextFontString(b)
    --- @type FontStringTemplate
    local fs = b:CreateFontString(nil, "OVERLAY", 'ABP_NumberFontNormalShadow')
    fs:SetJustifyH("RIGHT")
    fs:SetJustifyV("TOP")
    --- @type FontStringWidget
    local widget = ns:K():Mixin({ }, FontStringWidget)
    widget.fontString = fs
    fs.widget = widget;

    return fs
end

--- @see ActionBarHandlerMixin
--- @deprecated
function L:ShowActionbarsDelayed(isShown, delayInSec)
    local actualDelayInSec = delayInSec
    local showActionBars = isShown == true
    if type(actualDelayInSec) ~= 'number' then actualDelayInSec = delayInSec end
    if actualDelayInSec <= 0 then actualDelayInSec = 1 end
    -- Hide immediately and then try again after delayInSec
    self:ShowActionbars(isShown)
    C_Timer.After(actualDelayInSec, function() self:ShowActionbars(showActionBars) end)
end

--- @param isShown boolean Set to true to show action bar
function L:ShowActionbars(isShown)
    abh():fevf(function(frameWidget)
        if frameWidget:IsShownInConfig() then
            frameWidget:SetGroupState(isShown)
        end
    end)
end

function L:IsHideWhenTaxi() return P:IsHideWhenTaxi() end

function L:HideTooltipDelayed(delayInSec)
    local actualDelayInSec = delayInSec
    if not actualDelayInSec or actualDelayInSec < 0 then
        GameTooltip:Hide()
        return
    end
    C_Timer.After(actualDelayInSec, function() GameTooltip:Hide() end)
end

--- @return table<string, BindingInfo> The binding map with button names as the key
function L:GetBarBindingsMap()
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
            --- @type BindingInfo
            local bindingInfo = {
                btnName = bindingDetails.buttonName, category = cat,
                key1 = key1, key1Short = key1Short, key2 = key2,
                details = { action = bindingDetails.action, buttonPressed = bindingDetails.buttonPressed }
            }
            barBindingsMap[bindingDetails.buttonName] = bindingInfo
        end
    end
    return barBindingsMap
end

--- @return BindingDetails
--- @param btnName string The button name
function L:GetBarBindings(btnName)
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

function L:OnShowAdditionalTooltipInfo(tooltip)
    --- @type ButtonUI
    local button = tooltip:GetOwner()
    if not (button and button.widget and button.widget.buttonName) then return end
    --- @type ButtonUIWidget
    local bw = button.widget
    local c  = bw:conf(); if c:IsEmpty() then return end
    if c:IsMacro() then
        self:AddMacroInfo(tooltip, bw, c.macro) end
    self:AddKeybindingInfo(tooltip, bw, c)
    tooltip:Show()
end

--- @param tooltip GameTooltip
--- @param bw ButtonUIWidget
--- @param c ButtonProfileConfigMixin
function L:AddKeybindingInfo(tooltip, bw, c)
    if not bw.kbt:HasKeybindings() then return end
    if not c:IsMacro() then
        GameTooltip_AddBlankLinesToTooltip(GameTooltip, 1)
    end
    local bindings = bw.kbt:GetBindings()
    if not bindings.key1 then return end
    tooltip:AddDoubleLine('Keybind ::', bindings.key1, 1, 0.5, 0, 0 , 0.5, 1);
end

--- @param tooltip GameTooltip
--- @param bw ButtonUIWidget
--- @param macroData Profile_Macro
function L:AddMacroInfo(tooltip, bw, macroData)
    GameTooltip_AddBlankLinesToTooltip(tooltip, 1)

    local spid = bw:GetEffectiveSpellID()
    if spid then
        --- @type FontString
        local right = GameTooltipTextRight1
        if right then
            local rank = api:GetSpellRankFormatted(spid)
            right:SetText(rank)
            right:Show()
        end
    end
    tooltip:AddDoubleLine('Macro ::', macroData.name, 1, 1, 1, 1, 1, 1);
end

function L:ConfigureFrameToCloseOnEscapeKey(frameName, frameInstance)
    local frame = frameInstance
    if frameInstance.frame then frame = frameInstance.frame end
    setglobal(frameName, frame)
    table.insert(UISpecialFrames, frameName)
end

function L:ShowReloadUIConfirmation() StaticPopup_Show(GC.C.CONFIRM_RELOAD_UI) end

function L:ConfirmAndReload()
    local reloadUI = GC.C.CONFIRM_RELOAD_UI
    if StaticPopup_Visible(reloadUI) == nil then return StaticPopup_Show(reloadUI) end
    return false
end
