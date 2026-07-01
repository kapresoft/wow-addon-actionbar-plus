--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)

local cns = ns:cns()
local unit, au = cns.O.UnitUtil, cns.O.ActionUtil
local DatabaseSchema = cns.O.DatabaseSchema
local backdrops = ns.O.Backdrops
local attr, atyp = cns:constants()
local Tbl_IsEmpty = cns:Table().IsEmpty

--- Returns true if BarOptionsDialog is open for this bar index,
--- so the drag handle glow is preserved while the dialog is visible.
--- @param barIndex Index
--- @return boolean
local function IsBarDialogShownForBar(barIndex)
  if not cns:OptionsUI() then return false end
  local O = cns:OptionsNS().O
  return O.BarOptionsDialog:IsShownForBar(barIndex)
end

local VISIBILITY_DEFAULTS = '[vehicleui][petbattle][possessbar][overridebar]hide; show'

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @see Namespace_ABP_BarsUI_2_0
--- @type string
local libName = ns.M.BarModuleFactory()
--- @class BarModuleFactory_ABP_2_0 : AceAddon-Module-Lifecycle-3-0
local S = {}; ns:Register(libName, S)
local p, t = ns:log(libName)

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
local function barName(index) return ('ABP_2_0_F%s'):format(index) end
local function moduleName(index) return ('ABP_2_0_F%sModule'):format(index) end
--- ABP_2_0_F1Button1, ABP_2_0_F1Button2, etc...
--- @return string, string Button name and button parent key
local function ButtonName(barIndex, btnIndex)
  local parentKey = ('Button%s'):format(btnIndex)
  return ('ABP_2_0_F%s%s'):format(barIndex, parentKey), parentKey
end

--- @param name string
--- @param parent Frame
--- @param encodedID number
--- @return Button_ABP_2_0_X
local function CreateButton(name, parent, encodedID)
  return CreateFrame("CheckButton", name, parent, ns.buttonTemplate, encodedID)
end

--- @param self BarFrame_ABP_2_0
local function BarFrame_EnableVisibilityDriver(self)
  RegisterStateDriver(self, "visibility", VISIBILITY_DEFAULTS)
end

--- @param self BarFrame_ABP_2_0
local function BarFrame_DisableVisibilityDriver(self)
  UnregisterStateDriver(self, "visibility")
end

--- @param self BarModuleProto_ABP_2_0
local function BarModule_EnableEditModeCallback(self)
  if not (EventRegistry and EventRegistry.RegisterCallback) then return end
  EventRegistry:RegisterCallback("EditMode.Enter", self.OnEditModeEnter, self)
  EventRegistry:RegisterCallback("EditMode.Exit",  self.OnEditModeExit,  self)
end

--- @param self BarModuleProto_ABP_2_0
local function BarModule_DisableEditModeCallback(self)
  if not (EventRegistry and EventRegistry.UnregisterCallback) then return end
  EventRegistry:UnregisterCallback("EditMode.Enter", self)
  EventRegistry:UnregisterCallback("EditMode.Exit", self)
end

--[[-------------------------------------------------------------------
Mixin: BarFrameObjWidgetMixin_2_0
---------------------------------------------------------------------]]
--- @class BarFrameWidgetMixin_ABP_2_0
--- @field index Index
--- @field frame BarFrame_ABP_2_0
--- @field buttons Button_ABP_2_0_X[]
--- @field module BarModule_2_0
--- @field dragHandle ABP_BarDragHandle_2_0
local BarFrameObjWidgetMixin = {}

--- @class BarFrameWidget_ABP_2_0 : BarFrameWidgetMixin_ABP_2_0

local function BarFrameWidgetMethods()
  
  local wm = BarFrameObjWidgetMixin
  
  ---@param frame BarFrame_ABP_2_0
  function wm:Init(frame, index)
    assert(type(frame) == 'table' and strlower(frame:GetObjectType()) == 'frame',
            'BarFrameWidget::Init(frame, index):: Param frame is expected to be a Frame.')
    assert(type(index) == 'number')
    self.frame = frame
    self.index = index
  end

  --- @return BarConfig_ABP_2_0
  function wm:conf() return cns:bar(self.index) end
  
  function wm:ApplyBackdrop()
    local conf = self:conf()
    if not conf then return end
    local bc = conf.ui and conf.ui.backdrop
    if not bc then return end
    local theme = bc.theme
    self:ApplyDragHandle(theme == 'none')
    if theme == 'none' then self.frame:SetBackdrop(nil); return end

    local borderDef = backdrops.BORDER_DEFS[theme] or backdrops.DEFAULT_BACKDROP
    -- effective edge size: user override > theme's intended slider default > static backdrop.edgeSize
    local edgeSize = bc.edgeSize or (borderDef.edgeSize and borderDef.edgeSize.default) or borderDef.backdrop.edgeSize
    local baseEdge = borderDef.backdrop.edgeSize
    if edgeSize ~= baseEdge then
      local backdropInfo = CopyTable(borderDef.backdrop)
      local baseInsets = borderDef.backdrop.insets
      backdropInfo.edgeSize = edgeSize
      if baseEdge and baseEdge > 0 and baseInsets then
        -- scale insets with edgeSize so the background keeps meeting the border
        -- cleanly as the effective size diverges from the theme's tuned default
        local ratio = edgeSize / baseEdge
        backdropInfo.insets = {
          left   = baseInsets.left   * ratio,
          right  = baseInsets.right  * ratio,
          top    = baseInsets.top    * ratio,
          bottom = baseInsets.bottom * ratio,
        }
      end
      self.frame:SetBackdrop(backdropInfo)
    else
      self.frame:SetBackdrop(borderDef.backdrop)
    end

    local bgColor = bc.bgColor or borderDef.bgColor
    local borderColor = bc.borderColor or borderDef.borderColor

    self.frame:SetBackdropColor(unpack(bgColor))
    self.frame:SetBackdropBorderColor(unpack(borderColor))
  end

  --- Marks the drag handle eligible.
  --- Only relevant when the backdrop theme is 'none' since there's no border to grab.
  --- Normally horizontal above button 1; when extra buttons occupy TOPLEFT or TOPRIGHT,
  --- switches to a vertical strip on the opposite side to avoid overlap.
  --- @param enabled boolean
  function wm:ApplyDragHandle(enabled)
    self.dragHandleEnabled = enabled
    if enabled then
      local handle = self:GetOrCreateDragHandle()
      local btn1 = self.buttons and self.buttons[1]
      if btn1 then
        handle:ClearAllPoints()
        local conf       = self:conf()
        local dragFrame  = conf.dragFrame or {}
        local dragAnchor = dragFrame.anchor or 'TOPLEFT'
        local thickness  = dragFrame.thickness or 8
        local btnSize    = btn1:GetHeight()
        local heightPad = 6
        if dragAnchor == 'TOPRIGHT' then
          local cols = conf.ui.colSize or 1
          local lastBtn1 = self.buttons[cols]
          handle:SetHeight(btnSize - heightPad)
          handle:SetWidth(thickness)
          handle:SetPoint('LEFT', lastBtn1, 'RIGHT', 3, 0)
          handle:SetPoint('CENTER', lastBtn1, 'CENTER', thickness, 0)
        else
          handle:SetHeight(btnSize - heightPad)
          handle:SetWidth(thickness)
          handle:SetPoint('RIGHT', btn1, 'LEFT', -3, 0)
          handle:SetPoint('CENTER', btn1, 'CENTER', -thickness, 0)
        end
      end
      handle:Show()
    elseif self.dragHandle then
      self.dragHandle:Hide()
    end
  end

  --- @return ABP_BarDragHandle_2_0 @lazily creates the handle on first use
  function wm:GetOrCreateDragHandle()
    if not self.dragHandle then
      --- @class ABP_BarDragHandle_2_0 : BarDragHandleMixin_ABP_2_0
      --- @field barFrame Frame
      local handle = CreateFrame('Frame', nil, self.frame, 'ABP_BarDragHandleTemplate_2_0' --[[@as Template ]])
      handle.barFrame = self.frame
      handle.tex:Hide()
      self.dragHandle = handle
    end
    return self.dragHandle
  end

  function wm:ShowDragHandle()
    if not self.dragHandleEnabled then return end
    self:GetOrCreateDragHandle().tex:Show()
  end

  function wm:HideDragHandle()
    if IsBarDialogShownForBar(self.index) then return end
    if self.dragHandle and self.dragHandle.__dragging then return end
    if self.dragHandle then self.dragHandle.tex:Hide() end
  end

  --- Pulses the drag handle so it's findable while BarBackdropDialog is open
  --- (theme 'none' has no visible border to draw the eye to the handle otherwise).
  function wm:StartHandleGlow()
    if not self.dragHandleEnabled then return end
    local handle = self:GetOrCreateDragHandle()
    handle.tex:Show()
    handle.glow:Play()
  end

  function wm:StopHandleGlow()
    if not self.dragHandle then return end
    if IsBarDialogShownForBar(self.index) then return end
    self.dragHandle.glow:Stop()
    self.dragHandle.tex:SetAlpha(1)
    if not self.dragHandle:IsMouseOver() then self.dragHandle.tex:Hide() end
  end
  
  --- Applies the extra button row config — creates buttons lazily, repositions/resizes each call.
  --- Buttons are laid out as a single horizontal row outside the bar frame edge.
  function wm:ApplyExtraButton()
    local eb = self:conf().ui.extraButton
    if not eb or not eb.enabled then
      if self.extraButtons then
        for _, btn in ipairs(self.extraButtons) do btn:Hide() end
      end
      return
    end

    local anchor  = eb.anchor  or 'TOPRIGHT'
    local size    = eb.size    or 30
    local cols    = eb.colSize or 1
    self.extraButtons = self.extraButtons or {}

    -- create any missing buttons
    for i = 1, cols do
      if not self.extraButtons[i] then
        local encodedID = au.encodeBarID(self.index, 900 + i)
        local btnName = ('ABP_2_0_F%sExtraBtn%s'):format(self.index, i)
        local btn = CreateButton(btnName, self.frame, encodedID)
        btn:SetClampedToScreen(true)
        btn.widget.isExtraButton = true
        self.extraButtons[i] = btn
      end
    end

    -- hide any buttons beyond the current colSize
    for i = cols + 1, #self.extraButtons do
      self.extraButtons[i]:Hide()
    end

    local isTop   = anchor == 'TOP' or anchor == 'TOPLEFT' or anchor == 'TOPRIGHT'
    local isLeft  = anchor == 'TOPLEFT'  or anchor == 'BOTTOMLEFT'
    local isRight = anchor == 'TOPRIGHT' or anchor == 'BOTTOMRIGHT'
    local offY    = isTop and size or -size
    local spacing = 2
    local mainCols = self:conf().ui.colSize or 1
    local mainRows = self:conf().ui.rowSize or 1
    -- for TOP*: last button of row 1; for BOTTOM*: last button of the last row
    local lastBtnTop    = self.buttons and self.buttons[mainCols]
    local lastBtnBottom = self.buttons and self.buttons[mainCols * mainRows]
    local lastBtn1 = isTop and lastBtnTop or lastBtnBottom
    -- for BOTTOM* left anchor: first button of the last row
    local firstBtnBottom = self.buttons and self.buttons[mainCols * (mainRows - 1) + 1]

    -- use backdrop padding as the Y gap so the extra row clears the border cleanly
    local ui = self:conf().ui
    local borderDef = backdrops.BORDER_DEFS[ui.backdrop.theme] or backdrops.DEFAULT_BACKDROP
    local pad = ui.backdrop.theme == 'none'
                and 2
                or (ui.backdrop.padding or borderDef.padding or 0) + 8
    local gap = isTop and pad or -pad

    local showEmpty = eb.showEmptyButtons ~= false
    for i = 1, cols do
      local btn = self.extraButtons[i]
      btn:SetSize(size, size)
      btn:ClearAllPoints()
      btn:Show()
      if btn.widget then btn.widget:UpdateEmptyState(showEmpty) end
    end

    -- relative point on the grid button to attach to (top edge for TOP*, bottom edge for BOTTOM*)
    local gridRelPoint = isTop and 'TOPLEFT' or 'BOTTOMLEFT'
    local gridRelPointR = isTop and 'TOPRIGHT' or 'BOTTOMRIGHT'
    -- point on the extra button that meets the grid button edge
    local extraRelPoint = isTop and 'BOTTOMLEFT' or 'TOPLEFT'
    local extraRelPointR = isTop and 'BOTTOMRIGHT' or 'TOPRIGHT'

    local firstBtn = isTop and (self.buttons and self.buttons[1]) or firstBtnBottom
    if isLeft and firstBtn then
      self.extraButtons[1]:SetPoint(extraRelPoint, firstBtn, gridRelPoint, 1, gap)
      for i = 2, cols do
        self.extraButtons[i]:SetPoint('LEFT', self.extraButtons[i - 1], 'RIGHT', spacing, 0)
      end
    elseif isRight and lastBtn1 then
      self.extraButtons[cols]:SetPoint(extraRelPointR, lastBtn1, gridRelPointR, 0, gap)
      for i = cols - 1, 1, -1 do
        self.extraButtons[i]:SetPoint('RIGHT', self.extraButtons[i + 1], 'LEFT', -spacing, 0)
      end
    else
      -- TOP / BOTTOM: center on bar frame, chain rightward
      -- anchor is center-top/bottom of both frame and button, so offset by half totalW minus half button width
      local totalW = cols * size + (cols - 1) * spacing
      self.extraButtons[1]:SetPoint(anchor, self.frame, anchor, -(totalW / 2) + (size / 2), offY)
      for i = 2, cols do
        self.extraButtons[i]:SetPoint('LEFT', self.extraButtons[i - 1], 'RIGHT', spacing, 0)
      end
    end
  end

  --- @return Index
  function wm:GetIndex() return self.index end

  --- @return BarFrame_ABP_2_0
  function wm:GetFrame() return self.frame end

  function wm:GetDebugName()
    return ('%s(Widget):: index=%s')
            :format(self.frame:GetName(), self.index)
  end

end; BarFrameWidgetMethods()

--[[-------------------------------------------------------------------
BarModuleProto
---------------------------------------------------------------------]]
--- @class BarModuleProto_ABP_2_0
--- @field index Index
--- @field barFrame BarFrame_ABP_2_0
local BarModuleProto_2_0 = {}

local function BarModuleProtoMethods()
  
  local bm = BarModuleProto_2_0
  
  --- @return BarConfig_ABP_2_0?
  function bm:c() return cns:bar(self.index) end
  
  function bm:OnInitialize()
    --t('OnInitialize')
  end
  
  --- @NotCombatSafe
  function bm:OnEnable()
    if InCombatLockdown() then return end
    if self.barFrame then
      self.barFrame:Show()
      BarFrame_EnableVisibilityDriver(self.barFrame)
    end
    BarModule_EnableEditModeCallback(self)
  end

  --- @NotCombatSafe
  function bm:OnDisable()
    if InCombatLockdown() then return end
    if self.barFrame then
      BarFrame_DisableVisibilityDriver(self.barFrame)
      self.barFrame:Hide()
    end
    BarModule_DisableEditModeCallback(self)
  end

  --- @NotCombatSafe
  function bm:OnEditModeEnter()
    if InCombatLockdown() then return end
    BarFrame_DisableVisibilityDriver(self.barFrame)
    self.barFrame:Hide()
  end
  
  -- No need to call barFrame:Hide() here because
  -- the visibility values will be evaluated.
  function bm:OnEditModeExit()
    if InCombatLockdown() then return end
    BarFrame_EnableVisibilityDriver(self.barFrame)
  end
  
  function bm:ACTIVE_TALENT_GROUP_CHANGED(event, ...)
    local currentIndex, prevIndex = ...
    local activeIndex = unit:GetActiveSpecGroupIndex()
    t('ACTIVE_TALENT_GROUP_CHANGED::' .. event, 'from=', prevIndex, 'to=', currentIndex, 'activeIndex[detected]=', activeIndex)

    self.pendingSpecUpdate = true
  end
  
  function bm:SPELLS_CHANGED(event, ...)
    if not self.pendingSpecUpdate then return end
    self.pendingSpecUpdate = false
    if InCombatLockdown() then return end

    local activeIndex = unit:GetActiveSpecGroupIndex()
    t('SPELLS_CHANGED', 'evt=', event, 'activeIndex[detected]=', activeIndex)
    self:ForEach(function(btn) btn.widget:LoadAction() end)
    self:ForEachExtraButton(function(btn) btn.widget:LoadAction() end)
  end

  --- @param callbackFn fun(btn: Button_ABP_2_0_X)
  function bm:ForEach(callbackFn)
    for _, btn in ipairs(self.barFrame.widget.buttons) do
      --- @type Button_ABP_2_0_X
      local b = btn
      callbackFn(b)
    end
  end

  --- @param callbackFn fun(btn: Button_ABP_2_0_X)
  --- @param includeHidden boolean|nil
  function bm:ForEachExtraButton(callbackFn, includeHidden)
    local extraButtons = self.barFrame.widget.extraButtons
    if not extraButtons then return end
    for _, btn in ipairs(extraButtons) do
      if includeHidden or btn:IsShown() then
        callbackFn(btn --[[@as Button_ABP_2_0_X]])
      end
    end
  end

  --- @param callbackFn fun(btn: Button_ABP_2_0_X, w: ButtonWidget_ABP_2_0, conf:ButtonConfig_ABP_2_0)
  function bm:ForEachNonEmpty(callbackFn)
    for _, btn in ipairs(self.barFrame.widget.buttons) do
      --- @type Button_ABP_2_0_X
      local b = btn
      local conf = b.widget:conf()
      if not b.widget:IsEmpty() and conf then callbackFn(b, b.widget, conf) end
    end
  end

  --- @param callbackFn fun(btn: Button_ABP_2_0_X, w: ButtonWidget_ABP_2_0, conf:MacroButtonConfig_ABP_2_0)
  function bm:ForEachMacro(callbackFn)
    self:ForEachNonEmpty(function(btn, w, conf)
      if au.IsMacro(conf.type) then callbackFn(btn, w, conf) end
    end)
  end

end; BarModuleProtoMethods()

--[[-----------------------------------------------------------------------------
Methods: BarModuleFactory

Dump:
-- /dump ABP_2_0_F1Module:Enable()
-- /dump ABP_2_0_F1Module:Disable()
-- /dump ABP_2_0_F1Module:IsEnabled()
-- /dump ABP_2_0_F1Module.enabledState
-------------------------------------------------------------------------------]]
local o = S

--- Create the Ace module dynamically
--- @param barFrame BarFrame_ABP_2_0
--- @return BarModule_2_0
function o:New(barFrame)
  assert(type(barFrame) == 'table', 'New(barFrame):: {barFrame} should be a frame.')

  local core = ns:a()
  local w = barFrame.widget --[[@as BarFrameWidget_ABP_2_0 ]]
  local name = moduleName(w.index)

  --- @type BarModule_2_0
  local existingModule = core:GetModule(name, true)
  if existingModule then return existingModule end

  --- @class BarModule_2_0 : BarModuleProto_ABP_2_0, AceAddon, AceConsole-3.0, AceEvent-3.0, AceBucket-3.0, AceHook-3.0
  local m = core:NewModule(name, BarModuleProto_2_0)
  m.barFrame = barFrame
  m.index = w.index
  w.module = m

  self:ApplyBarEnabledState(w.index)
  _G[name] = m

  m:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
  m:RegisterBucketEvent('SPELLS_CHANGED', 0.2)
  return m
end

--- @param barIndex Index
--- @param callbackFn fun(m:BarModule_2_0):void
function o:IfBar(barIndex, callbackFn)
  local frame = _G[barName(barIndex)]
  local m = frame and frame.widget and frame.widget.module
  if m then callbackFn(m) end
end

--- @param barIndex Index
--- @return BarFrameWidget_ABP_2_0?
function o:GetBarWidget(barIndex)
  local frame = _G[barName(barIndex)]
  return frame and frame.widget
end

--- Directly drives the bar's show/hide logic instead of going through Ace3's
--- Enable()/Disable(), since modules created via NewModule are queued for
--- Ace3's init process and may not have settled their internal enabled
--- status yet, causing Disable() to silently no-op right after creation.
--- @param barIndex Index
function o:ApplyBarEnabledState(barIndex)
  if InCombatLockdown() then return end
  self:IfBar(barIndex, function(m)
    local enabled = m:c().enabled
    m:SetEnabledState(enabled)
    if enabled then m:OnEnable() else m:OnDisable() end
  end)
end

local barCount = cns:a():p().barCount or 1
--- barFrame should be hidden by default in xml template
function o:CreateAddonModules()
  for i = 1, barCount do
    self:CreateBarGroup(i, function(barFrame) self:New(barFrame) end)
  end
end

--- @param frame BarFrame_ABP_2_0
--- @param ui BarUIConfig_ABP_2_0
local function ApplyGridLayout(frame, ui)
  local cols = ui.colSize
  local rows = ui.rowSize
  local size = ui.button.size
  local spacing = ui.button.spacing
  local borderDef = backdrops.BORDER_DEFS[ui.backdrop.theme] or backdrops.DEFAULT_BACKDROP
  local pad = ui.backdrop.padding or borderDef.padding
  local BASE_UI_PADDING = borderDef.basePadding or 8

  local padLeft   = pad + BASE_UI_PADDING
  local padRight  = pad + BASE_UI_PADDING
  local padTop    = pad + BASE_UI_PADDING
  local padBottom = pad + BASE_UI_PADDING + (borderDef.borderPadBottom or 0)

  local totalWidth  = padLeft + size*cols + spacing.horizontal*(cols - 1) + padRight
  local totalHeight = padTop  + size*rows + spacing.vertical*(rows - 1)   + padBottom
  frame:SetSize(totalWidth, totalHeight)

  local hotKeyFontSize = math.max(8, math.floor(size * 16 / 40))
  local hotKeyOffsetX  = math.floor(size * 5 / 40)
  local hotKeyOffsetY  = math.floor(size * 7 / 40)
  local startX = math.floor(padLeft + 0.5)
  local startY = -math.floor(padTop + 0.5)
  local visible = cols * rows

  for i, _btn in ipairs(frame.widget.buttons) do
    --- @type Button_ABP_2_0_X
    local btn = _btn

    btn:ClearAllPoints()
    if i <= visible then
      btn:SetSize(size, size)
      btn.HotKey:SetFont(btn.HotKey:GetFont(), hotKeyFontSize, 'OUTLINE')
      btn.HotKey:ClearAllPoints()
      btn.HotKey:SetPoint('TOPRIGHT', btn, 'TOPRIGHT', -hotKeyOffsetX, -hotKeyOffsetY)
      local idx = i - 1
      local c = (idx % cols) + 1
      local r = math.floor(idx / cols) + 1
      local x = startX + (size + spacing.horizontal) * (c - 1)
      local y = startY - (size + spacing.vertical)   * (r - 1)
      btn:SetPoint('TOPLEFT', frame, 'TOPLEFT', x, y)
      btn:Show()
      btn.widget:UpdateEmptyState(ui.showEmptyButtons)
    else
      btn:Hide()
    end
  end
end

--- @param frame BarFrame_ABP_2_0
--- @param barConf BarConfig_ABP_2_0
function o:ApplyLayout(frame, barConf)
  local ui = barConf.ui
  local layout = ui.layout or 'grid' -- todo: add layout to database
  if layout == 'grid' then ApplyGridLayout(frame, ui) end
  frame:SetAlpha(ui.alpha)
  frame.widget:ApplyBackdrop()
  frame.widget:ApplyExtraButton()
  -- empty buttons are individually click-through (UpdateEmptyState); when none are
  -- shown, the bar frame itself must also stop catching clicks in the gaps behind them.
  -- Exception: a visible backdrop (theme ~= 'none') needs the bar frame mouse-enabled
  -- for right-click/tooltip on its own border/background, even with no empty buttons.
  local bc = barConf.ui.backdrop
  local hasVisibleBackdrop = bc and bc.theme ~= 'none'
  frame:EnableMouse(ui.showEmptyButtons == true or hasVisibleBackdrop == true)
end

--- Re-layout an existing bar in place from the current config.
--- Named WoW frames cannot be destroyed and recreated, so this mutates in place.
--- Creates any additional buttons if rows/cols increased beyond what was originally built.
--- @param barIndex Index
function o:RebuildLayout(barIndex)
  if InCombatLockdown() then return end
  local frame = _G[barName(barIndex)]
  if not frame then return end

  local barConf = cns:a():bar(barIndex)
  local ui = barConf.ui
  local needed = ui.colSize * ui.rowSize
  local buttons = frame.widget.buttons

  for i = #buttons + 1, needed do
    local encodedID = au.encodeBarID(barIndex, i)
    local btnName, btnKey = ButtonName(barIndex, i)
    local btn = CreateButton(btnName, frame, encodedID)
    btn:SetParentKey(btnKey)
    table.insert(buttons, btn)
  end

  self:ApplyLayout(frame, barConf)
end

--- Reload every bar/button from the current profile — call after a profile
--- switch/copy/reset, since AceDB swaps the underlying saved-vars table and
--- buttons/layout must re-read it from scratch.
--- @NotCombatSafe
function o:ReloadAll()
  if InCombatLockdown() then return end
  for i = 1, DatabaseSchema:GetMaxBarCount() do
    local barConf = cns:a():bar(i)
    if barConf then
      self:CreateBarGroup(i, function(barFrame) self:New(barFrame) end)
      self:ApplyBarEnabledState(i)
      -- hide and clear stale extra buttons so ApplyExtraButton rebuilds from the new profile
      local w = self:GetBarWidget(i)
      if w and w.extraButtons then
        for _, btn in ipairs(w.extraButtons) do btn:Hide() end
        w.extraButtons = nil
      end
      self:RebuildLayout(i)
      self:IfBar(i, function(m)
        m:ForEach(function(btn) btn.widget:LoadAction() end)
        m:ForEachExtraButton(function(btn) btn.widget:LoadAction() end)
      end)
    end
  end
end

--- @private
--- @param barIndex Index The bar frame index
--- @param consumerFn BarFactoryConsumerFn
function o:CreateBarGroup(barIndex, consumerFn)
  assert(type(barIndex) == 'number', 'CreateBarGroup(barIndex):: {barIndex} should be a number')

  local frameName = barName(barIndex)
  -- if the frame is already created, return that frame instance
  if _G[frameName] then return consumerFn and consumerFn(_G[frameName]) end

  local barConf = cns:a():bar(barIndex)
  local ui = barConf.ui

  local cols = ui.colSize
  local rows = ui.rowSize
  local size = ui.button.size
  local spacing = ui.button.spacing

  --- @type BarFrame_ABP_2_0
  local frame = self:CreateBarFrame(barConf, barIndex, frameName)
  local buttons = self:CreateButtons(barConf, frame, barIndex)
  frame.widget.buttons = buttons

  self:ApplyLayout(frame, barConf)

  return consumerFn and consumerFn(frame)
end

--- Bar name: ABP_2_0_F{INDEX}, i.e. ABP_2_0_F1, ABP_2_0_F2, ...
--- @param barConf ButtonConfig_ABP_2_0 The frame index
--- @param barIndex Index The frame index
--- @param frameName Name The frame name
--- @return BarFrame_ABP_2_0
function o:CreateBarFrame(barConf, barIndex, frameName)
  assert(type(barIndex) == 'number', '__CreateBarFrame(barConf, barIndex, frameName) {barIndex} should be a number')
  assert(type(frameName) == 'string', '__CreateBarFrame(barConf, barIndex, frameName): {frameName} should be a string')

  --- @class BarFrame_ABP_2_0 : Frame, BackdropTemplate, BarFrameMixin_ABP_2_0_1
  local barFrame = CreateFrame("Frame", frameName, ABP_Parent_2_0, "ABP_BarFrameTemplate_2_0_1" --[[@as Template ]])
  local f = barFrame
  f:SetParentKey(frameName)
  f:SetFrameLevel(DatabaseSchema:GetMaxBarCount() - barIndex)
  f.widget = CreateAndInitFromMixin(BarFrameObjWidgetMixin, f, barIndex) --[[@as BarFrameWidget_ABP_2_0]]

  -- TODO: Can have user-preference override
  --RegisterStateDriver(barFrame, 'visibility', VISIBILITY_DEFAULTS)
  BarFrame_EnableVisibilityDriver(barFrame)

  --barFrame:SetAttribute("_onstate-abp-state", [[
  --  print('xx barFrame: newState=', newstate)
  --  self:SetAttribute("abp_state", newstate)
  --]])
  ns.O.BarAnchorController.ApplyAnchor(f, barIndex)
  f:Show()

  return f
end

--- @param barConf BarConfig_ABP_2_0 The frame index
--- @param barIndex Index
--- @param barFrame BarFrame_ABP_2_0
--- @return table<number, Button_ABP_2_0_X>
function o:CreateButtons(barConf, barFrame, barIndex)
  local ui = barConf.ui
  local cols, rows = ui.colSize, ui.rowSize
  local btnCount = rows * cols

  --- @type table<number, Button_ABP_2_0_X>
  local buttons = {}
  for i = 1, btnCount do
    -- Encode: barIndex in tens place, btnIndex fills the rest
    local encodedID = au.encodeBarID(barIndex, i)
    local btnName, btnKey = ButtonName(barIndex, i)
    local btn = CreateButton(btnName, barFrame, encodedID)
    btn:SetParentKey(btnKey)
    table.insert(buttons, btn)
  end

  return buttons
end

