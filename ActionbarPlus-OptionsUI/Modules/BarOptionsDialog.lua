--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_OptionsUI_2_0
local ns = select(2, ...)
local cns, O, L = ns:cns()
local OPTIONS = OPTIONS or L['Options']

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'BarOptionsDialog'
local globalVarName = 'ABP_BAR_OPTIONS_DIALOG'
--- @class BarOptionsDialog_ABP_2_0 : AceEvent-3.0
local o = cns:NewAceEvent(); ns:Register(libName, o)
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Constants
-------------------------------------------------------------------------------]]
local DIALOG_WIDTH, DIALOG_HEIGHT  = 250, 320

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

--- @param frame AceGUIWindow
--- @param conf BarConfig_ABP_2_0
--- @return table @refs to widgets for refresh
local function AddWidgets(frame, conf)
  local AceGUI = cns:AceGUI()
  local refs = {}

  --- @type AceGUICheckBox
  local chkEnabled = AceGUI:Create('CheckBox')
  chkEnabled:SetLabel(L['Enabled'])
  chkEnabled:SetFullWidth(true)
  chkEnabled:SetValue(conf.enabled == true)
  chkEnabled:SetCallback('OnValueChanged', function(_, _, val)
    conf.enabled = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  frame:AddChild(chkEnabled)
  refs.chkEnabled = chkEnabled

  --- @type AceGUISlider
  local slRows = AceGUI:Create('Slider')
  slRows:SetLabel(L['Rows'])
  slRows:SetFullWidth(true)
  slRows:SetSliderValues(1, 5, 1)
  slRows:SetValue(conf.ui.rowSize)
  slRows:SetCallback('OnValueChanged', function(_, _, val)
    t('AddWidgets::RowSlider', 'val=', val)
    conf.ui.rowSize = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  frame:AddChild(slRows)
  refs.slRows = slRows

  --- @type AceGUISlider
  local slCols = AceGUI:Create('Slider')
  slCols:SetLabel(L['Columns'])
  slCols:SetFullWidth(true)
  slCols:SetSliderValues(1, 12, 1)
  slCols:SetValue(conf.ui.colSize)
  slCols:SetCallback('OnValueChanged', function(_, _, val)
    conf.ui.colSize = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  frame:AddChild(slCols)
  refs.slCols = slCols

  --- @type AceGUISlider
  local slAlpha = AceGUI:Create('Slider')
  slAlpha:SetLabel(L['Alpha'])
  slAlpha:SetFullWidth(true)
  slAlpha:SetSliderValues(0, 1, 0.05)
  slAlpha:SetValue(conf.ui.alpha)
  slAlpha:SetCallback('OnValueChanged', function(_, _, val)
    conf.ui.alpha = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  frame:AddChild(slAlpha)
  refs.slAlpha = slAlpha

  --- @type AceGUICheckBox
  local chkEmpty = AceGUI:Create('CheckBox')
  chkEmpty:SetLabel(L['Show Empty Buttons'])
  chkEmpty:SetFullWidth(true)
  chkEmpty:SetValue(conf.ui.showEmptyButtons == true)
  chkEmpty:SetCallback('OnValueChanged', function(_, _, val)
    conf.ui.showEmptyButtons = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  frame:AddChild(chkEmpty)
  refs.chkEmpty = chkEmpty

  --- @type AceGUISlider
  local slBtnSize = AceGUI:Create('Slider')
  slBtnSize:SetLabel(L['Button Size'])
  slBtnSize:SetFullWidth(true)
  slBtnSize:SetSliderValues(20, 120, 1)
  slBtnSize:SetValue(conf.ui.button.size)
  slBtnSize:SetCallback('OnValueChanged', function(_, _, val)
    conf.ui.button.size = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  frame:AddChild(slBtnSize)
  refs.slBtnSize = slBtnSize

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

  -- dialogbg is the 2nd texture (tooltip bg); AceGUI sets it to 0.75 alpha — override to fully opaque
  local regions = { frame.frame:GetRegions() }
  if regions[2] then regions[2]:SetVertexColor(0, 0, 0, 1) end

  tinsert(UISpecialFrames, globalVarName)

  return frame
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

ABP_BAR_OPTIONS_DIALOG = nil
--- @type AceGUIWindow
local dialogFrame
--- @type table
local widgetRefs

--- @param barIndex number
function o:ShowDialog(barIndex)
  if InCombatLockdown() then return end
  self.barIndex = barIndex
  local conf = cns:bar(barIndex)

  if not dialogFrame then
    dialogFrame = CreateDialogFrame()
    dialogFrame.frame:SetClampedToScreen(true)
  end

  -- rebuild widgets for the new bar's config
  dialogFrame:ReleaseChildren()
  widgetRefs = AddWidgets(dialogFrame, conf)

  dialogFrame:SetTitle(('%s %s — %s'):format(L['Bar'], barIndex, OPTIONS))
  dialogFrame.frame:ClearAllPoints()
  dialogFrame.frame:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
  dialogFrame:Show()
end

function o:OnFrameClose()
  -- no commit needed — changes applied live
end

--- Invalidate cached frame (call after layout changes, before next ShowDialog)
function o:Reset()
  if dialogFrame then
    dialogFrame:Hide()
    dialogFrame = nil
    widgetRefs = nil
  end
end