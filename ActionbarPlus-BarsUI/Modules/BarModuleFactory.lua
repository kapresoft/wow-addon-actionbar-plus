--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local BO = ns.O
local bac, bd = BO.BarAnchorController, BO.Backdrops
local gridLayout = BO.GridLayout

local cns, O = ns:cns()
local unit, au = O.UnitUtil, O.ActionUtil
local DatabaseSchema = O.DatabaseSchema
local attr, atyp = cns:constants()
local Tbl_IsEmpty = cns:Table().IsEmpty

local VISIBILITY_DEFAULTS = '[vehicleui][petbattle][possessbar][overridebar]hide; show'

--- GridLayout is BarsUI's static built-in default; any other layout key is
--- looked up from Core's layout registry, populated by plugin addons
--- (e.g. ActionbarPlus-ArcLayout) at their own load time.
--- @param ui BarUIConfig_ABP_2_0
--- @return BarLayout_ABP_2_0
local function ResolveLayout(ui)
  local key = ui.layout or 'grid'
  if key == 'grid' then return gridLayout end
  return cns:GetLayout(key) or gridLayout
end

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
--- @return OptionsUI_Modules_ABP_2_0
local function OptionsO() return cns:OptionsNS().O end

--- Returns true if BarOptionsDialog is open for this bar index,
--- so the drag handle glow is preserved while the dialog is visible.
--- @param barIndex Index
--- @return boolean
local function IsBarDialogShownForBar(barIndex)
  if not cns:OptionsUI() then return false end
  return OptionsO().BarOptionsDialog:IsShownForBar(barIndex)
end
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

--- @param barIndex Index
local function OnSettingsPanelShown(barIndex) S:ApplyBarEnabledState(barIndex) end

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

    local borderDef = bd.BORDER_DEFS[theme] or bd.DEFAULT_BACKDROP
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
      local conf = self:conf()
      local dragFrame = conf.dragFrame or {}
      local dragAnchor = dragFrame.anchor or 'TOPLEFT'
      local thickness = dragFrame.thickness or 8
      local layout = ResolveLayout(conf.ui)
      layout:ApplyDragHandle(self.frame, dragAnchor, thickness)
      self:GetOrCreateDragHandle():Show()
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
      self.dragHandle:SetClampedToScreen(true)
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
    self.barFrame:Show()
    BarFrame_EnableVisibilityDriver(self.barFrame)
    self:ForEach(function(btn) btn:Update() end)
    self:ForEachExtraButton(function(btn) btn:Update() end)
    BarModule_EnableEditModeCallback(self)
  end

  --- @NotCombatSafe
  function bm:OnDisable()
    if InCombatLockdown() then return end
    BarFrame_DisableVisibilityDriver(self.barFrame)
    self.barFrame:Hide()
    local eventsFrame = ActionEventsFrame_ABP_2_0
    local function unregister(btn)
      if btn.eventsRegistered then
        eventsFrame:UnregisterFrame(btn)
        btn.eventsRegistered = nil
      end
    end
    self:ForEach(unregister)
    self:ForEachExtraButton(unregister)
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
  if SettingsPanel then
    -- hide bars when SettingsPanel opens (covers Edit Mode → Actionbar Settings transition)
    hooksecurefunc(SettingsPanel, 'Show', function()
      for i = 1, DatabaseSchema:GetMaxBarCount() do
        OnSettingsPanelShown(i)
      end
    end)
  end
end

--- @param ui BarUIConfig_ABP_2_0
--- @return BarLayout_ABP_2_0
function o:ResolveLayout(ui) return ResolveLayout(ui) end

--- @param frame BarFrame_ABP_2_0
--- @param barConf BarConfig_ABP_2_0
function o:ApplyLayout(frame, barConf)
  local ui = barConf.ui
  local layout = ResolveLayout(ui)
  layout:Apply(frame, ui)
  frame:SetAlpha(ui.alpha)
  if layout:SupportsBackdrop() then
    frame.widget:ApplyBackdrop()
  else
    frame:SetBackdrop(nil)
    frame.widget:ApplyDragHandle(true)
  end
  layout:ApplyExtraButtons(frame)
  -- theme 'none' (or a layout without backdrop support) has no visible border/background
  -- to interact with, so the bar frame itself is always click-through in that case.
  -- Otherwise, keep it mouse-enabled for right-click/tooltip on the border/background,
  -- regardless of showEmptyButtons.
  local bc = ui.backdrop
  local hasVisibleBackdrop = layout:SupportsBackdrop() and bc and bc.theme ~= 'none'
  frame:EnableMouse(hasVisibleBackdrop == true)
  -- When the bar frame is click-through, the drag handle is the only grab target and
  -- the (often larger, e.g. Arc) frame itself is never dragged directly -- clamping it
  -- to the screen in that state only blocks the handle-driven drag for no benefit.
  frame:SetClampedToScreen(hasVisibleBackdrop == true)
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
  local layout = ResolveLayout(ui)
  local needed = layout:GetButtonCount(ui)
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
      -- hide and clear stale extra buttons so ApplyExtraButtons rebuilds from the new profile
      local w = self:GetBarWidget(i)
      if w and w.extraButtons then
        for _, btn in ipairs(w.extraButtons) do btn:Hide() end
        w.extraButtons = nil
      end
      self:RebuildLayout(i)
      local frame = _G[barName(i)]
      if frame then bac.ApplyAnchor(frame) end
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
  bac.ApplyAnchor(f)
  f:Show()

  return f
end

--- @param barConf BarConfig_ABP_2_0 The frame index
--- @param barIndex Index
--- @param barFrame BarFrame_ABP_2_0
--- @return table<number, Button_ABP_2_0_X>
function o:CreateButtons(barConf, barFrame, barIndex)
  local ui = barConf.ui
  local layout = ResolveLayout(ui)
  local grid = ui.layoutConfig.grid
  local btnCount = math.max(grid.colSize * grid.rowSize, layout:GetButtonCount(ui))

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

