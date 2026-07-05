--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_OptionsUI_2_0
local ns = select(2, ...)
local cns, O, L = ns:cns()
local DS = O.DatabaseSchema
local OPTIONS = OPTIONS or L['Options']

local DIALOG_WIDTH, DIALOG_HEIGHT = 340, 300
local HELP_ICON_SIZE = 24
local TAB_GENERAL = 'general'
local TAB_BACKDROP = 'backdrop'
local TAB_EXTRA_BTNS = 'extrabuttons'

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

local Str_IsAnyOf = cns:String().IsAnyOf
local NONE_THEME_PADDING = 6
local NONE = NONE or L['None']
local RESET = RESET or L['Reset']

local DRAG_HINT = L['Drag the bar by hovering over the handle at the selected location.']

local function backdrops() return cns:BarsNS().O.Backdrops end
local function OnSettingsClicked() ns.O.SettingsDialog:Open() end

local function syncHandleGlow(barIndex)
  local w = cns:BarsUI():ns().O.BarModuleFactory:GetBarWidget(barIndex)
  if not w then return end
  local theme = cns:bar(barIndex).ui.backdrop.theme
  if theme == 'none' then
    w:StartHandleGlow()
  else
    w:StopHandleGlow()
  end
end

local function stopHandleGlow(barIndex)
  if not barIndex then return end
  local w = cns:BarsUI():ns().O.BarModuleFactory:GetBarWidget(barIndex)
  if w then w:StopHandleGlow() end
end

--- @param dropdown AceGUIDropdown
--- @param size number
local function SetDropdownLabelFontSize(dropdown, size)
  local f, _, fl = dropdown.label:GetFont()
  dropdown.label:SetFont(f, size, fl)
end

--- @class HelpIconFrame : Frame
--- @field tooltipText string

--- Creates a help icon frame with a GameTooltip on hover.
--- Caller is responsible for anchoring the returned frame.
--- @param parent Frame
--- @param tooltipText string
--- @return HelpIconFrame
local function CreateHelpIcon(parent, tooltipText)
  local f = CreateFrame('Frame', nil, parent)
  f:SetSize(HELP_ICON_SIZE, HELP_ICON_SIZE)
  f:EnableMouse(true)
  local icon = f:CreateTexture(nil, 'ARTWORK')
  icon:SetAllPoints()
  icon:SetTexture('Interface\\Common\\help-i')
  f.tooltipText = tooltipText
  f:SetScript('OnEnter', function(self)
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
    GameTooltip:Show()
  end)
  f:SetScript('OnLeave', function() GameTooltip:Hide() end)
  return f
end

--- @param tab AceGUITabGroup
--- @param window BarOptionsDialogWindow_ABP_2_0
--- @param conf BarConfig_ABP_2_0
--- @return table
local function AddGeneralTab(tab, window, conf)
  local AceGUI = cns:AceGUI()
  local refs = {}
  local wf = window.frame

  -- Count enabled bars to guard against disabling the last one
  local enabledCount = 0
  for i = 1, DS:GetMaxBarCount() do
    if cns:bar(i).enabled then enabledCount = enabledCount + 1 end
  end
  local isLastEnabled = enabledCount == 1 and conf.enabled == true

  -- Row 1: Enabled
  --- @type AceGUICheckBox
  local chkEnabled = AceGUI:Create('CheckBox')
  chkEnabled:SetLabel(L['Enabled'])
  chkEnabled:SetRelativeWidth(0.5)
  chkEnabled:SetValue(conf.enabled == true)
  chkEnabled:SetDisabled(isLastEnabled)
  chkEnabled:SetCallback('OnValueChanged', function(_, _, val)
    conf.enabled = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  tab:AddChild(chkEnabled)
  refs.chkEnabled = chkEnabled

  local helpText = isLastEnabled and L['At least one bar must remain enabled.']
    or L['Toggle bar visibility from the right-click context menu.']
  if not wf.enabledHelp then
    wf.enabledHelp = CreateHelpIcon(wf, helpText)
  else
    wf.enabledHelp.tooltipText = helpText
  end
  local enabledHelp = wf.enabledHelp
  enabledHelp:SetFrameLevel(chkEnabled.frame:GetFrameLevel() + 2)
  enabledHelp:ClearAllPoints()
  enabledHelp:SetPoint(
    'LEFT',
    chkEnabled.text,
    'LEFT',
    chkEnabled.text:GetUnboundedStringWidth() + 4,
    0
  )
  enabledHelp:Show()
  if wf.extraBtnHelp then wf.extraBtnHelp:Hide() end
  refs.enabledHelp = enabledHelp

  --- @type AceGUICheckBox
  local chkCharPos = AceGUI:Create('CheckBox')
  chkCharPos:SetLabel(L['Character Specific Frame Positions'])
  chkCharPos:SetRelativeWidth(0.95)
  chkCharPos:SetValue(cns:p().characterSpecificAnchors == true)
  chkCharPos:SetCallback('OnValueChanged', function(_, _, val)
    cns:p().characterSpecificAnchors = val
    local BMF = cns:BarsUI():ns().O.BarModuleFactory
    local AC = cns:BarsUI():ns().O.BarAnchorController
    for i = 1, DS:GetMaxBarCount() do
      local frame = BMF:GetBarWidget(i) and BMF:GetBarWidget(i).frame
      if frame then
        if val then AC.SeedAnchor(frame) end
        AC.ApplyAnchor(frame)
      end
    end
  end)
  tab:AddChild(chkCharPos)
  refs.chkCharPos = chkCharPos

  if not wf.charPosHelp then
    wf.charPosHelp = CreateHelpIcon(wf, L['Character Specific Frame Positions Tooltip'])
  end
  local charPosHelp = wf.charPosHelp
  charPosHelp:SetFrameLevel(chkCharPos.frame:GetFrameLevel() + 2)
  charPosHelp:ClearAllPoints()
  charPosHelp:SetPoint('LEFT', chkCharPos.text, 'LEFT', chkCharPos.text:GetUnboundedStringWidth() + 4, 0)
  charPosHelp:Show()
  refs.charPosHelp = charPosHelp

  --- @type AceGUICheckBox
  local chkMouseoverHighlight = AceGUI:Create('CheckBox')
  chkMouseoverHighlight:SetLabel(L['Mouseover Highlight'])
  chkMouseoverHighlight:SetRelativeWidth(0.95)
  chkMouseoverHighlight:SetValue(cns:g().mouseoverHighlight ~= false)
  chkMouseoverHighlight:SetCallback('OnValueChanged', function(_, _, val)
    cns:g().mouseoverHighlight = val
    WorldEventsFrame_ABP_2_0:ForEachFrame(function(btn) btn.widget:UpdateMouseoverHighlight() end)
  end)
  tab:AddChild(chkMouseoverHighlight)
  refs.chkMouseoverHighlight = chkMouseoverHighlight

  if not wf.mouseoverHighlightHelp then
    wf.mouseoverHighlightHelp = CreateHelpIcon(wf, L['Mouseover Highlight Tooltip'] .. ABP_GLOBAL_SUFFIX)
  end
  local mouseoverHighlightHelp = wf.mouseoverHighlightHelp
  mouseoverHighlightHelp:SetFrameLevel(chkMouseoverHighlight.frame:GetFrameLevel() + 2)
  mouseoverHighlightHelp:ClearAllPoints()
  mouseoverHighlightHelp:SetPoint('LEFT', chkMouseoverHighlight.text, 'LEFT', chkMouseoverHighlight.text:GetUnboundedStringWidth() + 4, 0)
  mouseoverHighlightHelp:Show()
  refs.mouseoverHighlightHelp = mouseoverHighlightHelp

  --- @type AceGUICheckBox
  local chkEmpty = AceGUI:Create('CheckBox')
  chkEmpty:SetLabel(L['Show Empty Buttons'])
  chkEmpty:SetRelativeWidth(0.65)
  chkEmpty:SetValue(conf.ui.showEmptyButtons == true)
  chkEmpty:SetCallback('OnValueChanged', function(_, _, val)
    conf.ui.showEmptyButtons = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  tab:AddChild(chkEmpty)
  refs.chkEmpty = chkEmpty
  local chkEmptySpacer = cns:spacer()
  chkEmptySpacer:SetRelativeWidth(0.35)
  tab:AddChild(chkEmptySpacer)

  -- Row 2: Rows | Columns
  --- @type AceGUISlider
  local slRows = AceGUI:Create('Slider')
  slRows:SetLabel(L['Rows'])
  slRows:SetRelativeWidth(0.5)
  slRows:SetSliderValues(1, DS:GetMaxRowSize(), 1)
  slRows:SetValue(conf.ui.rowSize)
  slRows:SetCallback('OnValueChanged', function(_, _, val)
    t('AddWidgets::RowSlider', 'val=', val)
    conf.ui.rowSize = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  tab:AddChild(slRows)
  refs.slRows = slRows

  --- @type AceGUISlider
  local slCols = AceGUI:Create('Slider')
  slCols:SetLabel(L['Columns'])
  slCols:SetRelativeWidth(0.5)
  slCols:SetSliderValues(1, DS:GetMaxColSize(), 1)
  slCols:SetValue(conf.ui.colSize)
  slCols:SetCallback('OnValueChanged', function(_, _, val)
    conf.ui.colSize = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  tab:AddChild(slCols)
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
  tab:AddChild(slAlpha)
  refs.slAlpha = slAlpha

  --- @type AceGUISlider
  local slBtnSize = AceGUI:Create('Slider')
  slBtnSize:SetLabel(L['Button Size'])
  slBtnSize:SetRelativeWidth(0.5)
  slBtnSize:SetSliderValues(DS:GetMinBtnSize(), DS:GetMaxBtnSize(), 1)
  slBtnSize:SetValue(conf.ui.button.size)
  slBtnSize:SetCallback('OnValueChanged', function(_, _, val)
    conf.ui.button.size = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  tab:AddChild(slBtnSize)
  refs.slBtnSize = slBtnSize

  return refs
end

--- @param borderDef BorderDef_ABP_2_0
--- @param key string
--- @return boolean
local function dialogFlag(borderDef, key)
  local dlg = borderDef.dialog
  if not dlg or dlg[key] == nil then return true end
  return dlg[key]
end

--- @return table<string, string>, string[]
local function buildThemeList()
  --- @type table<string, string>
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

--- @param tab AceGUITabGroup
--- @param window BarOptionsDialogWindow_ABP_2_0
--- @param conf BarConfig_ABP_2_0
--- @return table
local function AddBackdropTab(tab, window, conf)
  local AceGUI = cns:AceGUI()
  local refs = {}
  local bc = conf.ui.backdrop
  local borderDef = backdrops().BORDER_DEFS[bc.theme] or backdrops().DEFAULT_BACKDROP

  local function RebuildBackdropTab()
    t('RebuildBackdropTab', 'tab=', tab)
    C_Timer.After(0, function()
      tab:ReleaseChildren()
      AddBackdropTab(tab, window, conf)
      tab:DoLayout()
      syncHandleGlow(o.barIndex)
    end)
  end

  local function OnResetTheme()
    bc.theme, bc.bgColor, bc.borderColor, bc.padding, bc.edgeSize = nil, nil, nil, nil, nil
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
    RebuildBackdropTab()
  end

  --- @type AceGUISimpleGroup
  local group = AceGUI:Create('SimpleGroup')
  group:SetLayout('Flow')
  group:SetFullWidth(true)
  tab:AddChild(group)

  --- @type AceGUIDropdown
  local ddTheme = AceGUI:Create('Dropdown')
  ddTheme:SetLabel(L['Theme'])
  SetDropdownLabelFontSize(ddTheme, 12)
  ddTheme:SetRelativeWidth(0.6)
  local themeList, themeOrder = buildThemeList()
  ddTheme:SetList(themeList, themeOrder)
  ddTheme:SetValue(bc.theme or 'stone')
  ddTheme:SetCallback('OnValueChanged', function(_, _, val)
    bc.theme = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
    RebuildBackdropTab()
  end)
  group:AddChild(ddTheme)
  refs.ddTheme = ddTheme

  local ddThemeSp = cns:spacer()
  ddThemeSp:SetRelativeWidth(0.3)
  group:AddChild(ddThemeSp)

  --- @type BarOptionsDialogFrame_ABP_2_0
  local wf = window.frame
  if not wf.resetBtn then
    wf.resetBtn = CreateFrame(
      'Button',
      nil,
      tab.frame,
      'ABP_OptionsUI_ResetButtonTemplate_2_0' --[[@as Template ]]
    )
  end
  local resetBtn = wf.resetBtn
  resetBtn:SetParent(tab.frame)
  resetBtn:SetScript('OnClick', OnResetTheme)
  resetBtn:ClearAllPoints()
  resetBtn:SetPoint('LEFT', ddTheme.frame, 'RIGHT', 1, -7)
  resetBtn:SetFrameLevel(ddTheme.frame:GetFrameLevel() + 1)
  resetBtn:Show()

  if not Str_IsAnyOf(bc.theme, 'none') and dialogFlag(borderDef, 'showBorderColor') then
    --- @type AceGUIColorPicker
    local cpBorderColor = AceGUI:Create('ColorPicker')
    cpBorderColor:SetLabel(L['Border Color'])
    cpBorderColor:SetFullWidth(true)
    cpBorderColor:SetHasAlpha(true)
    cpBorderColor:SetColor(unpack(bc.borderColor or borderDef.borderColor))
    local function OnBorderColorChanged(_, _, r, g, b, a)
      bc.borderColor = { r, g, b, a }
      o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
    end
    cpBorderColor:SetCallback('OnValueChanged', OnBorderColorChanged)
    cpBorderColor:SetCallback('OnValueConfirmed', OnBorderColorChanged)
    tab:AddChild(cpBorderColor)
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
      o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
    end
    cpBgColor:SetCallback('OnValueChanged', OnBgColorChanged)
    cpBgColor:SetCallback('OnValueConfirmed', OnBgColorChanged)
    tab:AddChild(cpBgColor)
    refs.cpBgColor = cpBgColor
  end

  if Str_IsAnyOf(bc.theme, 'none') then
    bc.padding = NONE_THEME_PADDING
  else
    --- @type AceGUISlider
    local slPadding = AceGUI:Create('Slider')
    slPadding:SetLabel(L['Padding'])
    slPadding:SetRelativeWidth(0.5)
    slPadding:SetSliderValues(0, 30, 1)
    slPadding:SetValue(bc.padding or borderDef.padding)
    slPadding:SetCallback('OnValueChanged', function(_, _, val)
      bc.padding = val
      o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
    end)
    tab:AddChild(slPadding)
    refs.slPadding = slPadding
  end

  if not Str_IsAnyOf(bc.theme, 'none') and dialogFlag(borderDef, 'showBorderSize') then
    --- @type AceGUISlider
    local slEdgeSize = AceGUI:Create('Slider')
    slEdgeSize:SetLabel(L['Border Size'])
    slEdgeSize:SetRelativeWidth(0.5)
    local edgeSize = borderDef.edgeSize or {}
    slEdgeSize:SetSliderValues(edgeSize.min or 1, edgeSize.max or 48, 1)
    slEdgeSize:SetValue(bc.edgeSize or edgeSize.default or borderDef.backdrop.edgeSize)
    slEdgeSize:SetCallback('OnValueChanged', function(_, _, val)
      bc.edgeSize = val
      o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
    end)
    tab:AddChild(slEdgeSize)
    refs.slEdgeSize = slEdgeSize
  end

  tab:AddChild(cns:spacer())

  if Str_IsAnyOf(bc.theme, 'none') then
    local df = conf.dragFrame
    local dragAnchor = df and df.anchor or 'TOPLEFT'

    --- @type AceGUIDropdown
    local ddDragAnchor = AceGUI:Create('Dropdown')
    ddDragAnchor:SetLabel(L['Drag Handle Location'])
    SetDropdownLabelFontSize(ddDragAnchor, 12)
    ddDragAnchor:SetRelativeWidth(0.6)
    ddDragAnchor:SetList({
      TOPLEFT = L['Top Left'],
      TOPRIGHT = L['Top Right'],
    }, { 'TOPLEFT', 'TOPRIGHT' })
    ddDragAnchor:SetValue(dragAnchor)
    ddDragAnchor:SetCallback('OnValueChanged', function(_, _, val)
      df.anchor = val
      o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
    end)
    tab:AddChild(ddDragAnchor)
    refs.ddDragAnchor = ddDragAnchor

    local ddDragAnchorSp = cns:spacer()
    ddDragAnchorSp:SetRelativeWidth(0.3)
    tab:AddChild(ddDragAnchorSp)

    --- @type HelpIconFrame
    local dragHelp = CreateHelpIcon(tab.frame, DRAG_HINT)
    dragHelp:SetFrameLevel(ddDragAnchor.frame:GetFrameLevel() + 2)
    dragHelp:ClearAllPoints()
    dragHelp:SetPoint('LEFT', ddDragAnchor.frame, 'RIGHT', 4, -7)
    dragHelp:Show()
    refs.dragHelp = dragHelp

    --- @type AceGUISlider
    local slDragThickness = AceGUI:Create('Slider')
    slDragThickness:SetLabel(L['Thickness'])
    slDragThickness:SetRelativeWidth(0.5)
    slDragThickness:SetSliderValues(4, 20, 1)
    slDragThickness:SetValue(df and df.thickness or 8)
    slDragThickness:SetCallback('OnValueChanged', function(_, _, val)
      df.thickness = val
      o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
    end)
    tab:AddChild(slDragThickness)
    refs.slDragThickness = slDragThickness
  end

  return refs
end

--- @param tab AceGUITabGroup
--- @param window BarOptionsDialogWindow_ABP_2_0
--- @param conf BarConfig_ABP_2_0
--- @return table
local function AddExtraButtonsTab(tab, window, conf)
  local AceGUI = cns:AceGUI()
  local refs = {}
  local wf = window.frame
  local eb = conf.ui.extraButton

  --- @type AceGUICheckBox
  local chkExtraBtn = AceGUI:Create('CheckBox')
  chkExtraBtn:SetLabel(L['Extra Buttons'])
  chkExtraBtn:SetRelativeWidth(0.5)
  chkExtraBtn:SetValue(eb.enabled == true)
  chkExtraBtn:SetCallback('OnValueChanged', function(_, _, val)
    eb.enabled = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  tab:AddChild(chkExtraBtn)
  refs.chkExtraBtn = chkExtraBtn

  if not wf.extraBtnHelp then wf.extraBtnHelp = CreateHelpIcon(wf, L['Extra Buttons Tooltip']) end
  local extraBtnHelp = wf.extraBtnHelp
  extraBtnHelp:SetFrameLevel(chkExtraBtn.frame:GetFrameLevel() + 2)
  extraBtnHelp:ClearAllPoints()
  extraBtnHelp:SetPoint(
    'LEFT',
    chkExtraBtn.text,
    'LEFT',
    chkExtraBtn.text:GetUnboundedStringWidth() + 4,
    0
  )
  extraBtnHelp:Show()
  if wf.enabledHelp then wf.enabledHelp:Hide() end
  refs.extraBtnHelp = extraBtnHelp

  --- @type AceGUICheckBox
  local chkShowEmpty = AceGUI:Create('CheckBox')
  chkShowEmpty:SetLabel(L['Show Empty Buttons'])
  chkShowEmpty:SetFullWidth(true)
  chkShowEmpty:SetValue(eb.showEmptyButtons ~= false)
  chkShowEmpty:SetCallback('OnValueChanged', function(_, _, val)
    eb.showEmptyButtons = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  tab:AddChild(chkShowEmpty)
  refs.chkShowEmpty = chkShowEmpty

  --- @type AceGUIDropdown
  local ddAnchor = AceGUI:Create('Dropdown')
  ddAnchor:SetLabel(L['Anchor'])
  SetDropdownLabelFontSize(ddAnchor, 12)
  ddAnchor:SetRelativeWidth(0.6)
  ddAnchor:SetList({
    TOPLEFT = L['Top Left'],
    TOP = L['Top'],
    TOPRIGHT = L['Top Right'],
    BOTTOMLEFT = L['Bottom Left'],
    BOTTOM = L['Bottom'],
    BOTTOMRIGHT = L['Bottom Right'],
  }, { 'TOPLEFT', 'TOP', 'TOPRIGHT', 'BOTTOMLEFT', 'BOTTOM', 'BOTTOMRIGHT' })
  ddAnchor:SetValue(eb.anchor or 'TOPRIGHT')
  ddAnchor:SetCallback('OnValueChanged', function(_, _, val)
    eb.anchor = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  tab:AddChild(ddAnchor)
  refs.ddAnchor = ddAnchor

  local ddAnchorSp = cns:spacer()
  ddAnchorSp:SetRelativeWidth(0.3)
  tab:AddChild(ddAnchorSp)

  local ddAnchorSp2 = cns:spacer()
  ddAnchorSp2:SetFullWidth(true)
  do
    local f, s, fl = GameFontHighlightSmall:GetFont()
    ddAnchorSp2:SetFont(f, 1, fl)
  end
  tab:AddChild(ddAnchorSp2)

  --- @type AceGUISlider
  local slExtraCols = AceGUI:Create('Slider')
  slExtraCols:SetLabel(L['Button Count'])
  slExtraCols:SetRelativeWidth(0.5)
  slExtraCols:SetSliderValues(1, DS:GetMaxColSize(), 1)
  slExtraCols:SetValue(eb.count or 1)
  slExtraCols:SetCallback('OnValueChanged', function(_, _, val)
    eb.count = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  tab:AddChild(slExtraCols)
  refs.slExtraCols = slExtraCols

  --- @type AceGUISlider
  local slExtraBtnSize = AceGUI:Create('Slider')
  slExtraBtnSize:SetLabel(L['Button Size'])
  slExtraBtnSize:SetRelativeWidth(0.5)
  slExtraBtnSize:SetSliderValues(DS:GetMinExtraBtnSize(), DS:GetMaxExtraBtnSize(), 1)
  slExtraBtnSize:SetValue(eb.size or 30)
  slExtraBtnSize:SetCallback('OnValueChanged', function(_, _, val)
    eb.size = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  tab:AddChild(slExtraBtnSize)
  refs.slExtraBtnSize = slExtraBtnSize

  --- @type AceGUISlider
  local slGap = AceGUI:Create('Slider')
  slGap:SetLabel(L['Gap'])
  slGap:SetRelativeWidth(0.5)
  slGap:SetSliderValues(DS:GetMinExtraBtnGap(), DS:GetMaxExtraBtnGap(), 1)
  slGap:SetValue(eb.gap or 2)
  slGap:SetCallback('OnValueChanged', function(_, _, val)
    eb.gap = val
    o:SendMessage(ns:msg('OnBarOptionsChanged'), o.barIndex)
  end)
  tab:AddChild(slGap)
  refs.slGap = slGap

  if not wf.gapHelp then wf.gapHelp = CreateHelpIcon(wf, L['Gap Tooltip']) end
  local gapHelp = wf.gapHelp
  gapHelp:SetFrameLevel(slGap.frame:GetFrameLevel() + 2)
  gapHelp:ClearAllPoints()
  gapHelp:SetPoint('LEFT', slGap.frame, 'RIGHT', 4, 0)
  gapHelp:Show()
  refs.gapHelp = gapHelp

  return refs
end

--- @param tab AceGUITabGroup
--- @param window BarOptionsDialogWindow_ABP_2_0
--- @param conf BarConfig_ABP_2_0
--- @param selectedTab string|nil
--- @return table @refs to widgets for refresh
local function AddWidgets(window, conf, selectedTab)
  local AceGUI = cns:AceGUI()
  local refs = {}

  --- @type AceGUITabGroup
  local tabGroup = AceGUI:Create('TabGroup')
  tabGroup:SetFullWidth(true)
  tabGroup:SetFullHeight(true)
  tabGroup:SetLayout('Flow')
  tabGroup:SetTabs({
    { text = L['General'], value = TAB_GENERAL },
    { text = L['Backdrop'], value = TAB_BACKDROP },
    { text = L['Extra Buttons'], value = TAB_EXTRA_BTNS },
  })

  tabGroup:SetCallback('OnGroupSelected', function(tg, _, tab)
    tg:ReleaseChildren()
    local wf = window.frame
    if wf.resetBtn then wf.resetBtn:Hide() end
    if wf.charPosHelp then wf.charPosHelp:Hide() end
    if wf.mouseoverHighlightHelp then wf.mouseoverHighlightHelp:Hide() end
    if wf.gapHelp then wf.gapHelp:Hide() end
    if tab == TAB_GENERAL then
      refs.general = AddGeneralTab(tg, window, conf)
    elseif tab == TAB_BACKDROP then
      refs.backdrop = AddBackdropTab(tg, window, conf)
      syncHandleGlow(o.barIndex)
    elseif tab == TAB_EXTRA_BTNS then
      refs.extraButtons = AddExtraButtonsTab(tg, window, conf)
    end
  end)

  window:AddChild(tabGroup)
  refs.tabGroup = tabGroup

  -- Icon buttons float in the title bar, left of the close button
  local wf = window.frame
  if not wf.settingsIconBtn then
    --- @type IconButton|Button
    local settingsIconBtn = CreateFrame(
      'Button',
      nil,
      wf,
      'ABP_OptionsUI_SettingsIconButtonTemplate_2_0' --[[@as Template ]]
    )
    settingsIconBtn:SetScript('OnClick', OnSettingsClicked)
    wf.settingsIconBtn = settingsIconBtn
  end
  local closeBtn = window.closebutton
  local settingsIconBtn = wf.settingsIconBtn
  settingsIconBtn:SetFrameLevel(closeBtn:GetFrameLevel() + 1)
  settingsIconBtn:ClearAllPoints()
  settingsIconBtn:SetPoint('RIGHT', closeBtn, 'LEFT', 0, 0)

  tabGroup:SelectTab(selectedTab or TAB_GENERAL)

  return refs
end

--- @return AceGUIWindow
local function CreateDialog()
  local AceGUI = cns:AceGUI()

  --- @type AceGUIWindow
  local frame = AceGUI:Create('Window')
  local f = frame.frame
  _G[globalVarName] = f
  frame:SetWidth(DIALOG_WIDTH)
  frame:SetHeight(DIALOG_HEIGHT)
  frame:SetLayout('Fill')
  frame:SetCallback('OnClose', function() o:OnFrameClose() end)
  frame:SetCallback('OnShow', function()
    f:SetSize(DIALOG_WIDTH, DIALOG_HEIGHT)
    frame:DoLayout()
  end)

  f:SetResizeBounds(DIALOG_WIDTH, DIALOG_HEIGHT)

  -- dialogbg is the 2nd texture (tooltip bg); AceGUI sets it to 0.75 alpha — override to fully opaque
  local regions = { f:GetRegions() }
  if regions[2] then regions[2]:SetVertexColor(0, 0, 0, 1) end

  tinsert(UISpecialFrames, globalVarName)

  return frame
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- @class BarOptionsDialogFrame_ABP_2_0 : Frame
--- @field enabledHelp HelpIconFrame
--- @field charPosHelp HelpIconFrame
--- @field mouseoverHighlightHelp HelpIconFrame
--- @field extraBtnHelp Frame
--- @field gapHelp HelpIconFrame
--- @field settingsIconBtn Button
--- @field resetBtn Button

ABP_BAR_OPTIONS_DIALOG = nil
--- @class BarOptionsDialogWindow_ABP_2_0 : AceGUIWindow
--- @field frame BarOptionsDialogFrame_ABP_2_0
local dialogWindow
--- @type table
local widgetRefs
local lastEnabledCount

--- @param barIndex number
--- @param selectedTab string|nil
function o:ShowDialog(barIndex, selectedTab)
  if InCombatLockdown() then return end
  self.barIndex = barIndex
  local conf = cns:bar(barIndex)

  if not dialogWindow then
    dialogWindow = CreateDialog()
    dialogWindow.frame:SetClampedToScreen(true)
  end

  -- seed the baseline so the first OnBarOptionsChanged doesn't spuriously rebuild
  lastEnabledCount = 0
  for i = 1, 10 do
    if cns:bar(i).enabled then lastEnabledCount = lastEnabledCount + 1 end
  end

  -- rebuild widgets for the new bar's config
  dialogWindow:ReleaseChildren()
  widgetRefs = AddWidgets(dialogWindow, conf, selectedTab)

  dialogWindow:SetTitle(('%s %s — %s'):format(L['Bar'], barIndex, OPTIONS))
  dialogWindow.frame:ClearAllPoints()
  dialogWindow.frame:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
  syncHandleGlow(barIndex)
  dialogWindow:Show()
  self:RegisterEvent('PLAYER_REGEN_DISABLED')
  self:RegisterMessage(ns:msg('OnBarOptionsChanged'), 'OnBarOptionsChanged')
end

function o:PLAYER_REGEN_DISABLED()
  self:UnregisterEvent('PLAYER_REGEN_DISABLED')
  if dialogWindow then dialogWindow:Hide() end
end

--- Rebuild the General tab only when the enabled bar count changes (bar toggled on/off).
function o:OnBarOptionsChanged()
  if not (dialogWindow and dialogWindow.frame:IsShown()) then return end
  if not (widgetRefs and widgetRefs.tabGroup) then return end
  local count = 0
  for i = 1, DS:GetMaxBarCount() do
    if cns:bar(i).enabled then count = count + 1 end
  end
  if count == lastEnabledCount then return end
  lastEnabledCount = count
  local tg = widgetRefs.tabGroup
  tg:ReleaseChildren()
  widgetRefs.general = AddGeneralTab(tg, dialogWindow, cns:bar(self.barIndex))
  tg:SelectTab(TAB_GENERAL)
end

--- @param barIndex Index
--- @return boolean
function o:IsShownForBar(barIndex)
  return self.barIndex == barIndex and dialogWindow ~= nil and dialogWindow.frame:IsShown()
end

--- @return Frame?
function o:GetFrame() return dialogWindow and dialogWindow.frame end

function o:OnFrameClose()
  stopHandleGlow(self.barIndex)
  self:UnregisterMessage(ns:msg('OnBarOptionsChanged'))
end

--- Invalidate cached frame (call after layout changes, before next ShowDialog)
function o:Reset()
  if not dialogWindow then return end
  dialogWindow:Hide()
  dialogWindow = nil
  widgetRefs = nil
end
