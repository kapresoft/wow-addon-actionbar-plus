--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_OptionsUI_2_0
local ns = select(2, ...)
local cns, O, L = ns:cns()
local AceGUI = cns:AceGUI()
local Str_IsAnyOf = cns:String().IsAnyOf

--- @type string
local RESET = RESET or L['Reset']
--- @type string
local BACKDROP = BACKDROP or L['Backdrop']
--- @type string
local NONE = NONE or L['None']

local NONE_THEME_HINT = L['Drag the bar by hovering over its top-left corner (above the first button).']

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'BarBackdropDialog'
local globalVarName = 'ABP_BAR_BACKDROP_DIALOG'
--- @class BarBackdropDialog_ABP_2_0 : AceEvent-3.0
local o = ns:Register(libName, cns:NewAceEvent())
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Constants
-------------------------------------------------------------------------------]]
local DIALOG_WIDTH, DIALOG_HEIGHT = 240, 255
local NONE_THEME_PADDING = 6

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @return BarModuleFactory_ABP_2_0
local function barModuleFactory() return cns:BarsUI():ns().O.BarModuleFactory end
--- @return Backdrops_ABP_2_0
local function backdrops() return cns:BarsUI():ns().O.Backdrops end
--- @return string
local function barOptionsChangedMessage() return ns:msg('OnBarOptionsChanged') end

--- @param borderDef BorderDef_ABP_2_0
--- @param key string
--- @return boolean @defaults to true when unset
local function dialogFlag(borderDef, key)
  local dlg = borderDef.dialog
  if not dlg or dlg[key] == nil then return true end
  return dlg[key]
end

--- Builds the theme dropdown list/order from Backdrops.lua's BORDER_DEFS keys,
--- sorted alphabetically (case-insensitive) by label, with 'none' pinned first.
--- @return table<string, string>, string[]
local function buildThemeList()
  local list = { none = NONE }
  local order = { 'none' }
  for key, def in pairs(backdrops().BORDER_DEFS) do
    list[key] = def.label
    tinsert(order, key)
  end
  table.sort(order, function(a, b)
    if a == 'none' then return true end
    if b == 'none' then return false end
    return strlower(list[a]) < strlower(list[b])
  end)
  return list, order
end

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
  local refs = {}
  local bc = conf.ui.backdrop
  local borderDef = backdrops().BORDER_DEFS[bc.theme] or backdrops().DEFAULT_BACKDROP

  local function OnResetTheme()
    bc.bgColor, bc.borderColor, bc.padding, bc.edgeSize = nil, nil, nil, nil
    o:SendMessage(barOptionsChangedMessage(), o.barIndex)
    o:RebuildDialog()
  end

  --- @type AceGUISimpleGroup
  local group = AceGUI:Create('SimpleGroup')
  group:SetLayout('Flow')
  group:SetFullWidth(true)
  frame:AddChild(group)

  --- @type AceGUIDropdown
  local ddTheme = AceGUI:Create('Dropdown')
  ddTheme:SetLabel(L['Theme'])
  ddTheme:SetRelativeWidth(0.90)
  local themeList, themeOrder = buildThemeList()
  ddTheme:SetList(themeList, themeOrder)
  ddTheme:SetValue(bc.theme or 'stone')
  ddTheme:SetCallback('OnValueChanged', function(_, _, val)
    bc.theme = val
    o:SendMessage(barOptionsChangedMessage(), o.barIndex)
    o:RebuildDialog()
  end)
  group:AddChild(ddTheme)
  refs.ddTheme = ddTheme

  --- @type IconButton|Button
  local resetBtn = CreateFrame("Button", nil, frame.frame, "ABP_OptionsUI_ResetButtonTemplate_2_0" --[[@as Template ]])
  resetBtn:SetScript("OnClick", OnResetTheme)
  resetBtn:SetPoint('LEFT', ddTheme.frame, 'RIGHT', 1, -7)
  resetBtn:SetFrameLevel(ddTheme.frame:GetFrameLevel() + 1)

  if not Str_IsAnyOf(bc.theme, 'none') and dialogFlag(borderDef, 'showBorderColor') then
    --- @type AceGUIColorPicker
    local cpBorderColor = AceGUI:Create('ColorPicker')
    cpBorderColor:SetLabel(L['Border Color'])
    cpBorderColor:SetFullWidth(true)
    cpBorderColor:SetHasAlpha(true)
    cpBorderColor:SetColor(unpack(bc.borderColor or borderDef.borderColor))
    local function OnBorderColorChanged(_, _, r, g, b, a)
      bc.borderColor = { r, g, b, a }
      o:SendMessage(barOptionsChangedMessage(), o.barIndex)
    end
    cpBorderColor:SetCallback('OnValueChanged', OnBorderColorChanged)
    cpBorderColor:SetCallback('OnValueConfirmed', OnBorderColorChanged)
    frame:AddChild(cpBorderColor)
    refs.cpBorderColor = cpBorderColor
  end

  if not Str_IsAnyOf(bc.theme, 'none') and dialogFlag(borderDef, 'showBgColor') then
    --- @type AceGUIColorPicker
    local cpBgColor = AceGUI:Create('ColorPicker')
    cpBgColor:SetLabel(L['Background Color'])
    cpBgColor:SetFullWidth(true)
    cpBgColor:SetHasAlpha(true)
    cpBgColor:SetColor(unpack(bc.bgColor or borderDef.bgColor))
    local function OnBgColorChanged(_, _, r, g, b, a)
      bc.bgColor = { r, g, b, a }
      o:SendMessage(barOptionsChangedMessage(), o.barIndex)
    end
    cpBgColor:SetCallback('OnValueChanged', OnBgColorChanged)
    cpBgColor:SetCallback('OnValueConfirmed', OnBgColorChanged)
    frame:AddChild(cpBgColor)
    refs.cpBgColor = cpBgColor
  end

  if Str_IsAnyOf(bc.theme, 'none') then
    bc.padding = NONE_THEME_PADDING
    o:SendMessage(barOptionsChangedMessage(), o.barIndex)
  else
    --- @type AceGUISlider
    local slPadding = AceGUI:Create('Slider')
    slPadding:SetLabel(L['Padding'])
    slPadding:SetFullWidth(true)
    slPadding:SetSliderValues(0, 30, 1)
    slPadding:SetValue(bc.padding or borderDef.padding)
    slPadding:SetCallback('OnValueChanged', function(_, _, val)
      bc.padding = val
      o:SendMessage(barOptionsChangedMessage(), o.barIndex)
    end)
    frame:AddChild(slPadding)
    refs.slPadding = slPadding
  end

  if not Str_IsAnyOf(bc.theme, 'none') and dialogFlag(borderDef, 'showBorderSize') then
    --- @type AceGUISlider
    local slEdgeSize = AceGUI:Create('Slider')
    slEdgeSize:SetLabel(L['Border Size'])
    slEdgeSize:SetFullWidth(true)
    local edgeSize = borderDef.edgeSize or {}
    slEdgeSize:SetSliderValues(edgeSize.min or 1, edgeSize.max or 48, 1)
    slEdgeSize:SetValue(bc.edgeSize or edgeSize.default or borderDef.backdrop.edgeSize)
    slEdgeSize:SetCallback('OnValueChanged', function(_, _, val)
      bc.edgeSize = val
      o:SendMessage(barOptionsChangedMessage(), o.barIndex)
    end)
    frame:AddChild(slEdgeSize)
    refs.slEdgeSize = slEdgeSize
  end

  frame:AddChild(cns:spacer())

  if Str_IsAnyOf(bc.theme, 'none') then
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
  local optDialogFrame = ns.O.BarOptionsDialog:GetFrame()
  if optDialogFrame and optDialogFrame:IsShown() then
    dialogFrame.frame:SetPoint('TOPLEFT', optDialogFrame, 'TOPRIGHT', -5, 0)
  else
    dialogFrame.frame:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
  end
  dialogFrame:Show()
  self:RegisterEvent('PLAYER_REGEN_DISABLED')
end

function o:PLAYER_REGEN_DISABLED()
  self:UnregisterEvent('PLAYER_REGEN_DISABLED')
  if dialogFrame then dialogFrame:Hide() end
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

--- @param barIndex Index
--- @return boolean
function o:IsShownForBar(barIndex)
  return self.barIndex == barIndex and dialogFrame ~= nil and dialogFrame.frame:IsShown()
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
