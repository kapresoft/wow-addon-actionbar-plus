--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_OptionsUI_2_0
local ns = select(2, ...)
local cns, O, L = ns:cns()
local OPTIONS = OPTIONS or L['Options']
local SETTINGS = SETTINGS or L['Settings']

local DIALOG_WIDTH, DIALOG_HEIGHT  = 300, 330
local HELP_ICON_SIZE = 24

local function syncHandleGlow(barIndex)
  local w = cns:BarsUI():ns().O.BarModuleFactory:GetBarWidget(barIndex)
  if not w then return end
  local theme = cns:bar(barIndex).ui.backdrop.theme
  if theme == 'none' then w:StartHandleGlow() else w:StopHandleGlow() end
end

local function stopHandleGlow(barIndex)
  if not barIndex then return end
  local w = cns:BarsUI():ns().O.BarModuleFactory:GetBarWidget(barIndex)
  if w then w:StopHandleGlow() end
end

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'BarOptionsDialog'
local globalVarName = 'ABP_BAR_OPTIONS_DIALOG'
--- @class BarOptionsDialog_ABP_2_0 : AceEvent-3.0
local o = ns:Register(libName, cns:NewAceEvent())
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

local function backdrops() return cns:BarsUI():ns().O.Backdrops end
local function OnSettingsClicked() ns.O.OptionsDialog:Open() end
local function OnBackdropSettingsClicked() ns.O.BarBackdropDialog:ShowDialog(o.barIndex) end

--- Creates a help icon frame with a GameTooltip on hover.
--- Caller is responsible for anchoring the returned frame.
--- @param parent Frame
--- @param tooltipText string
--- @return Frame
local function CreateHelpIcon(parent, tooltipText)
  local f = CreateFrame('Frame', nil, parent)
  f:SetSize(HELP_ICON_SIZE, HELP_ICON_SIZE)
  f:EnableMouse(true)
  local icon = f:CreateTexture(nil, 'ARTWORK')
  icon:SetAllPoints()
  icon:SetTexture('Interface\\Common\\help-i')
  f:SetScript('OnEnter', function(self)
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true)
    GameTooltip:Show()
  end)
  f:SetScript('OnLeave', function() GameTooltip:Hide() end)
  return f
end

--- @param window BarOptionsDialogWindow_ABP_2_0
--- @param conf BarConfig_ABP_2_0
--- @return table @refs to widgets for refresh
local function AddWidgets(window, conf)
  local AceGUI = cns:AceGUI()
  local refs = {}
  local bc, wf = conf.ui.backdrop, window.frame
  local borderDef = backdrops().BORDER_DEFS[bc.theme] or backdrops().DEFAULT_BACKDROP

  -- Row 1: Enabled
  --- @type AceGUICheckBox
  local chkEnabled = AceGUI:Create('CheckBox')
  chkEnabled:SetLabel(L['Enabled'])
  chkEnabled:SetRelativeWidth(0.5)
  chkEnabled:SetValue(conf.enabled == true)
  chkEnabled:SetCallback('OnValueChanged', function(_, _, val)
    conf.enabled = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  window:AddChild(chkEnabled)
  refs.chkEnabled = chkEnabled

  if not wf.enabledHelp then
    wf.enabledHelp = CreateHelpIcon(wf, L['Re-enable from General Settings > General > Bars.'])
  end
  -- re-anchor each rebuild to track the current chkEnabled text position
  local enabledHelp = wf.enabledHelp
  enabledHelp:SetFrameLevel(chkEnabled.frame:GetFrameLevel() + 2)
  enabledHelp:ClearAllPoints()
  enabledHelp:SetPoint('LEFT', chkEnabled.text, 'LEFT', chkEnabled.text:GetUnboundedStringWidth() + 4, 0)
  refs.enabledHelp = enabledHelp

  --- @type AceGUICheckBox
  local chkEmpty = AceGUI:Create('CheckBox')
  chkEmpty:SetLabel(L['Show Empty Buttons'])
  chkEmpty:SetFullWidth(true)
  chkEmpty:SetValue(conf.ui.showEmptyButtons == true)
  chkEmpty:SetCallback('OnValueChanged', function(_, _, val)
    conf.ui.showEmptyButtons = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  window:AddChild(chkEmpty)
  refs.chkEmpty = chkEmpty

  if not wf.settingsIconBtn then
    --- @type IconButton|Button
    local settingsIconBtn = CreateFrame("Button", nil, wf, "ABP_OptionsUI_SettingsIconButtonTemplate_2_0" --[[@as Template ]] )
    settingsIconBtn:SetScript("OnClick", OnSettingsClicked)
    settingsIconBtn:SetFrameLevel(chkEnabled.frame:GetFrameLevel() + 1)
    wf.settingsIconBtn = settingsIconBtn

    --- @type IconButton|Button
    local backdropIconBtn = CreateFrame("Button", nil, wf, "ABP_OptionsUI_BackdropIconButtonTemplate_2_0" --[[@as Template ]] )
    backdropIconBtn:SetScript("OnClick", OnBackdropSettingsClicked)
    backdropIconBtn:SetFrameLevel(settingsIconBtn:GetFrameLevel())
    wf.backdropIconBtn = backdropIconBtn
  end

  -- re-anchor icon buttons each rebuild so they track the current chkEnabled frame position
  local settingsIconBtn = wf.settingsIconBtn
  local backdropIconBtn = wf.backdropIconBtn
  settingsIconBtn:ClearAllPoints()
  settingsIconBtn:SetPoint('RIGHT', wf, 'TOPRIGHT', -12, -42)
  settingsIconBtn:SetPoint('CENTER', chkEnabled.frame, 'CENTER', 0, 0)
  backdropIconBtn:ClearAllPoints()
  backdropIconBtn:SetPoint('RIGHT', settingsIconBtn, 'LEFT', 2, 0)

  -- Row 2: Rows | Columns
  --- @type AceGUISlider
  local slRows = AceGUI:Create('Slider')
  slRows:SetLabel(L['Rows'])
  slRows:SetRelativeWidth(0.5)
  slRows:SetSliderValues(1, 5, 1)
  slRows:SetValue(conf.ui.rowSize)
  slRows:SetCallback('OnValueChanged', function(_, _, val)
    t('AddWidgets::RowSlider', 'val=', val)
    conf.ui.rowSize = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  window:AddChild(slRows)
  refs.slRows = slRows

  --- @type AceGUISlider
  local slCols = AceGUI:Create('Slider')
  slCols:SetLabel(L['Columns'])
  slCols:SetRelativeWidth(0.5)
  slCols:SetSliderValues(1, 12, 1)
  slCols:SetValue(conf.ui.colSize)
  slCols:SetCallback('OnValueChanged', function(_, _, val)
    conf.ui.colSize = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  window:AddChild(slCols)
  refs.slCols = slCols

  -- Row 3: Alpha | Button Size
  --- @type AceGUISlider
  local slAlpha = AceGUI:Create('Slider')
  slAlpha:SetLabel(L['Alpha'])
  slAlpha:SetRelativeWidth(0.5)
  slAlpha:SetSliderValues(0, 1, 0.05)
  slAlpha:SetValue(conf.ui.alpha)
  slAlpha:SetCallback('OnValueChanged', function(_, _, val)
    conf.ui.alpha = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  window:AddChild(slAlpha)
  refs.slAlpha = slAlpha

  --- @type AceGUISlider
  local slBtnSize = AceGUI:Create('Slider')
  slBtnSize:SetLabel(L['Button Size'])
  slBtnSize:SetRelativeWidth(0.5)
  slBtnSize:SetSliderValues(20, 120, 1)
  slBtnSize:SetValue(conf.ui.button.size)
  slBtnSize:SetCallback('OnValueChanged', function(_, _, val)
    conf.ui.button.size = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  window:AddChild(slBtnSize)
  refs.slBtnSize = slBtnSize

  -- Extra Button section
  local eb = conf.ui.extraButton

  --- @type AceGUICheckBox
  local chkExtraBtn = AceGUI:Create('CheckBox')
  chkExtraBtn:SetLabel(L['Extra Buttons'])
  chkExtraBtn:SetFullWidth(true)
  chkExtraBtn:SetValue(eb.enabled == true)
  chkExtraBtn:SetCallback('OnValueChanged', function(_, _, val)
    eb.enabled = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  window:AddChild(chkExtraBtn)
  refs.chkExtraBtn = chkExtraBtn

  if not wf.extraBtnHelp then
    wf.extraBtnHelp = CreateHelpIcon(wf, L['Extra Buttons Tooltip'])
  end
  local extraBtnHelp = wf.extraBtnHelp
  extraBtnHelp:SetFrameLevel(chkExtraBtn.frame:GetFrameLevel() + 2)
  extraBtnHelp:ClearAllPoints()
  extraBtnHelp:SetPoint('LEFT', chkExtraBtn.text, 'LEFT', chkExtraBtn.text:GetUnboundedStringWidth() + 4, 0)
  refs.extraBtnHelp = extraBtnHelp

  --- @type AceGUIDropdown
  local ddAnchor = AceGUI:Create('Dropdown')
  ddAnchor:SetLabel(L['Anchor'])
  ddAnchor:SetRelativeWidth(0.6)
  ddAnchor:SetList({
    TOPLEFT     = L['Top Left'],
    TOP         = L['Top'],
    TOPRIGHT    = L['Top Right'],
    BOTTOMLEFT  = L['Bottom Left'],
    BOTTOM      = L['Bottom'],
    BOTTOMRIGHT = L['Bottom Right'],
  }, { 'TOPLEFT', 'TOP', 'TOPRIGHT', 'BOTTOMLEFT', 'BOTTOM', 'BOTTOMRIGHT' })
  ddAnchor:SetValue(eb.anchor or 'TOPRIGHT')
  ddAnchor:SetCallback('OnValueChanged', function(_, _, val)
    eb.anchor = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  window:AddChild(ddAnchor)
  refs.ddAnchor = ddAnchor

  local ddAnchorSp = cns:spacer()
  ddAnchorSp:SetRelativeWidth(0.3)
  window:AddChild(ddAnchorSp)

  --- @type AceGUISlider
  local slExtraCols = AceGUI:Create('Slider')
  slExtraCols:SetLabel(L['Extra Button Columns'])
  slExtraCols:SetRelativeWidth(0.5)
  slExtraCols:SetSliderValues(1, 12, 1)
  slExtraCols:SetValue(eb.colSize or 1)
  slExtraCols:SetCallback('OnValueChanged', function(_, _, val)
    eb.colSize = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  window:AddChild(slExtraCols)
  refs.slExtraCols = slExtraCols

  --- @type AceGUISlider
  local slExtraBtnSize = AceGUI:Create('Slider')
  slExtraBtnSize:SetLabel(L['Extra Button Size'])
  slExtraBtnSize:SetRelativeWidth(0.5)
  slExtraBtnSize:SetSliderValues(16, 80, 1)
  slExtraBtnSize:SetValue(eb.size or 30)
  slExtraBtnSize:SetCallback('OnValueChanged', function(_, _, val)
    eb.size = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  window:AddChild(slExtraBtnSize)
  refs.slExtraBtnSize = slExtraBtnSize

  return refs
end

--- @return AceGUIWindow
local function CreateDialog()
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

--- @class BarOptionsDialogFrame_ABP_2_0 : Frame
--- @field enabledHelp Frame
--- @field extraBtnHelp Frame
--- @field settingsIconBtn Button
--- @field backdropIconBtn Button

ABP_BAR_OPTIONS_DIALOG = nil
--- @class BarOptionsDialogWindow_ABP_2_0 : AceGUIWindow
--- @field frame BarOptionsDialogFrame_ABP_2_0
local dialogWindow
--- @type table
local widgetRefs

--- @param barIndex number
function o:ShowDialog(barIndex)
  if InCombatLockdown() then return end
  self.barIndex = barIndex
  local conf = cns:bar(barIndex)

  if not dialogWindow then
    dialogWindow = CreateDialog()
    dialogWindow.frame:SetClampedToScreen(true)
  end

  -- rebuild widgets for the new bar's config
  dialogWindow:ReleaseChildren()
  widgetRefs = AddWidgets(dialogWindow, conf)

  dialogWindow:SetTitle(('%s %s — %s'):format(L['Bar'], barIndex, OPTIONS))
  dialogWindow.frame:ClearAllPoints()
  dialogWindow.frame:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
  syncHandleGlow(barIndex)
  dialogWindow:Show()
  self:RegisterEvent('PLAYER_REGEN_DISABLED')
end

function o:PLAYER_REGEN_DISABLED()
  self:UnregisterEvent('PLAYER_REGEN_DISABLED')
  if dialogWindow then dialogWindow:Hide() end
end

--- @param barIndex Index
--- @return boolean
function o:IsShownForBar(barIndex)
  return self.barIndex == barIndex and dialogWindow ~= nil and dialogWindow.frame:IsShown()
end

--- @return Frame?
function o:GetFrame()
  return dialogWindow and dialogWindow.frame
end

function o:OnFrameClose()
  stopHandleGlow(self.barIndex)
end

--- Invalidate cached frame (call after layout changes, before next ShowDialog)
function o:Reset()
  if not dialogWindow then return end
  dialogWindow:Hide()
  dialogWindow = nil
  widgetRefs = nil
end