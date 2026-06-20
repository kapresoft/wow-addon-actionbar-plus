--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_OptionsUI_2_0
local ns = select(2, ...)
local cns, O, L = ns:cns()
local Str_IsAnyOf = cns:String().IsAnyOf

local BACKDROP = BACKDROP or L['Backdrop']
local NONE = NONE or L['None']

local THEME_LIST = { none = NONE, modernDark = L['Modern Dark'], stone = L['Stone'], minimalist = L['Minimalist'] }
local THEME_ORDER = { 'none', 'modernDark', 'stone', 'minimalist' }
local NONE_THEME_HINT = L['Drag the bar by hovering over its top-left corner (above the first button).']

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'BarBackdropDialog'
local globalVarName = 'ABP_BAR_BACKDROP_DIALOG'
--- @class BarBackdropDialog_ABP_2_0 : AceEvent-3.0
local o = cns:NewAceEvent(); ns:Register(libName, o)
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Constants
-------------------------------------------------------------------------------]]
local DIALOG_WIDTH, DIALOG_HEIGHT = 250, 260

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

--- @return BarModuleFactory_ABP_2_0
local function barModuleFactory() return cns:BarsUI():ns().O.BarModuleFactory end

--- @param barIndex Index
local function stopHandleGlow(barIndex)
  if not barIndex then return end
  local w = barModuleFactory():GetBarWidget(barIndex)
  if w then w:StopHandleGlow() end
end

--- @param barIndex Index
--- @param theme string
local function syncHandleGlow(barIndex, theme)
  local w = barModuleFactory():GetBarWidget(barIndex)
  if not w then return end
  if theme == 'none' then w:StartHandleGlow() else w:StopHandleGlow() end
end

--- @param frame AceGUIWindow
--- @param conf BarConfig_ABP_2_0
--- @return table @refs to widgets for refresh
local function AddWidgets(frame, conf)
  local AceGUI = cns:AceGUI()
  local refs = {}
  local bc = conf.ui.backdrop

  --- @type AceGUIDropdown
  local ddTheme = AceGUI:Create('Dropdown')
  ddTheme:SetLabel(L['Theme'])
  ddTheme:SetFullWidth(true)
  ddTheme:SetList(THEME_LIST, THEME_ORDER)
  ddTheme:SetValue(bc.theme or 'stone')
  ddTheme:SetCallback('OnValueChanged', function(_, _, val)
    bc.theme = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
    o:RebuildDialog()
  end)
  frame:AddChild(ddTheme)
  refs.ddTheme = ddTheme

  if not Str_IsAnyOf(bc.theme, 'none') then
    --- @type AceGUIColorPicker
    local cpBgColor = AceGUI:Create('ColorPicker')
    cpBgColor:SetLabel(L['Background Color'])
    cpBgColor:SetFullWidth(true)
    cpBgColor:SetHasAlpha(true)
    cpBgColor:SetColor(unpack(bc.bgColor))
    local function OnBgColorChanged(_, _, r, g, b, a)
      bc.bgColor = { r, g, b, a }
      o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
    end
    cpBgColor:SetCallback('OnValueChanged', OnBgColorChanged)
    cpBgColor:SetCallback('OnValueConfirmed', OnBgColorChanged)
    frame:AddChild(cpBgColor)
    refs.cpBgColor = cpBgColor
  end

  if not Str_IsAnyOf(bc.theme, 'minimalist', 'none') then
    --- @type AceGUIColorPicker
    local cpBorderColor = AceGUI:Create('ColorPicker')
    cpBorderColor:SetLabel(L['Border Color'])
    cpBorderColor:SetFullWidth(true)
    cpBorderColor:SetHasAlpha(true)
    cpBorderColor:SetColor(unpack(bc.borderColor))
    local function OnBorderColorChanged(_, _, r, g, b, a)
      bc.borderColor = { r, g, b, a }
      o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
    end
    cpBorderColor:SetCallback('OnValueChanged', OnBorderColorChanged)
    cpBorderColor:SetCallback('OnValueConfirmed', OnBorderColorChanged)
    frame:AddChild(cpBorderColor)
    refs.cpBorderColor = cpBorderColor
  end

  if bc.theme == 'none' then
    --- @type AceGUILabel
    local lblHintSpacer = AceGUI:Create('Label')
    frame:AddChild(lblHintSpacer)
    --- @type AceGUILabel
    local lblHint = AceGUI:Create('Label')
    lblHint:SetText(NONE_THEME_HINT)
    lblHint:SetFullWidth(true)
    frame:AddChild(lblHint)
    refs.lblHint = lblHint
  end

  return refs
end

--- @return AceGUIWindow
local function CreateDialogFrame()
  local AceGUI = cns:AceGUI()

  --- @type AceGUIWindow
  local frame = AceGUI:Create('Window'); _G[globalVarName] = frame.frame
  frame:SetWidth(DIALOG_WIDTH)
  frame:SetHeight(DIALOG_HEIGHT)
  frame:SetLayout('Flow')
  frame:SetCallback('OnClose', function()
    o:OnFrameClose()
  end)
  frame:SetCallback("OnShow", function ()
    frame.frame:SetSize(DIALOG_WIDTH, DIALOG_HEIGHT)
    frame:DoLayout()
  end)

  -- dialogbg is the 2nd texture (tooltip bg); AceGUI sets it to 0.75 alpha — override to fully opaque
  local regions = { frame.frame:GetRegions() }
  if regions[2] then regions[2]:SetVertexColor(0, 0, 0, 1) end

  tinsert(UISpecialFrames, globalVarName)

  return frame
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

ABP_BAR_BACKDROP_DIALOG = nil
--- @type AceGUIWindow
local dialogFrame
--- @type table
local widgetRefs

--- @param barIndex number
function o:ShowDialog(barIndex)
  if InCombatLockdown() then return end
  stopHandleGlow(self.barIndex) -- stop previous bar's glow if switching bars
  self.barIndex = barIndex
  local conf = cns:bar(barIndex)

  if not dialogFrame then
    dialogFrame = CreateDialogFrame()
    dialogFrame.frame:SetClampedToScreen(true)
  end

  -- rebuild widgets for the new bar's config
  dialogFrame:ReleaseChildren()
  widgetRefs = AddWidgets(dialogFrame, conf)
  syncHandleGlow(barIndex, conf.ui.backdrop.theme)

  dialogFrame:SetTitle(('%s %s — %s'):format(L['Bar'], barIndex, BACKDROP))
  dialogFrame.frame:ClearAllPoints()
  dialogFrame.frame:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
  dialogFrame:Show()
end

--- Rebuilds the widget list in place (e.g. theme hint label appears/disappears)
--- without repositioning or re-titling the already-open dialog.
function o:RebuildDialog()
  if not dialogFrame then return end
  local conf = cns:bar(self.barIndex)
  dialogFrame:ReleaseChildren()
  widgetRefs = AddWidgets(dialogFrame, conf)
  syncHandleGlow(self.barIndex, conf.ui.backdrop.theme)
end

function o:OnFrameClose()
  stopHandleGlow(self.barIndex)
end

--- Invalidate cached frame (call after layout changes, before next ShowDialog)
function o:Reset()
  if dialogFrame then
    stopHandleGlow(self.barIndex)
    dialogFrame:Hide()
    dialogFrame = nil
    widgetRefs = nil
  end
end
