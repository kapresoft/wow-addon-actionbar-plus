--[[-----------------------------------------------------------------------------
Types
-------------------------------------------------------------------------------]]
--- @class KeybindTextUtil_Instance : KeybindTextUtil
--- @field private New fun(self:KeybindTextUtil_Instance)
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local K, O, GC = ns:K(), ns.O, ns.GC
local String = ns:String()
local IsNotBlank = String.IsNotBlank

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]

local libName = ns.M.KeybindTextUtil
--- @class KeybindTextUtil
local S = {}
local p = ns:CreateDefaultLogger(libName)

--- @type KeybindTextUtil
local LIB = S; ns:Register(libName, LIB)

--- @param buttonWidget ButtonUIWidget
--- @return KeybindTextUtil_Instance
function LIB:New(buttonWidget)  return K:CreateAndInitFromMixin(S, buttonWidget) end

--[[-----------------------------------------------------------------------------
Instance Methods
-------------------------------------------------------------------------------]]
--- @type KeybindTextUtil_Instance
local o = S

--- @private
--- @param buttonWidget ButtonUIWidget
function o:Init(buttonWidget)
    self.w           = buttonWidget
    self.keybindText = buttonWidget.button().keybindText
end

--- Shows the keybind text if a keybind exists,
--- otherwise will hide it.
function o:UpdateKeybindTextState()
    local hasBinding, bindings = self:GetBindingInfo()
    if not hasBinding then
        self:HideKeybindText()
        return self:SetText('')
    end
    self.keybindText.widget:SetVertexColorNormal()
    self:SetText(bindings.key1Short)
    return self:ShowKeybindText()
end

--- @param isHidden boolean
function o:SetKeybindTextHidden(isHidden)
    if true == isHidden then return self:HideKeybindText() end
    self:ShowKeybindText()
end

function o:ShowKeybindText() self.keybindText:Show() end
function o:ShowRangeIndicator() self:ShowKeybindText() end
function o:HideKeybindText() self.keybindText:Hide() end

--- @return BindingInfo
function o:GetBindings() return ns:Button_GetBindings(self.w.buttonName) end

--- @return boolean, BindingInfo
function o:GetBindingInfo()
    local b = self:GetBindings(); return b and IsNotBlank(b.key1Short), b
end

--- @return boolean
function o:HasKeybindings()
    local b = self:GetBindings(); if not b then return false end
    return b and IsNotBlank(b.key1)
end

--- @param text string
function o:SetText(text) self.keybindText:SetText(text) end

--- @return FontStringWidget
function o:GetKeybindText() return self.keybindText.widget end

--- @return string
function o:GetText() return self.keybindText:GetText() end

function o:IsShowingRangeIndicator() return self:GetText() == RANGE_INDICATOR end
