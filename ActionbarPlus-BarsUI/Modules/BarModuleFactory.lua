--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)

local cns = ns:cns()
local unit, au = cns.O.UnitUtil, cns.O.ActionUtil
local backdrops = ns.O.Backdrops
local attr, atyp = cns:constants()
local Tbl_IsEmpty = cns:Table().IsEmpty

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
local BarFrameObjWidgetMixin = {}

--- @class BarFrameWidget_ABP_2_0 : BarFrameWidgetMixin_ABP_2_0

local function BarFrameWidgetMethods()
  
  --- @type BarFrameWidgetMixin_ABP_2_0
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
    local conf = self:conf().ui.border
    assert(conf, "BarFrameWidget:ApplyBackdrop(): ui.border config missing")    local theme = conf and conf.theme

    if theme == 'none' then self.frame:SetBackdrop(nil); return end
    
    local borderDef = backdrops.BORDER_DEFS[theme] or backdrops.DEFAULT_BACKDROP
    self.frame:SetBackdrop(borderDef.backdrop)
    
    local bgColor = conf.bgColor or borderDef.bgColor
    local borderColor = conf.borderColor or borderDef.borderColor
    
    self.frame:SetBackdropColor(unpack(bgColor))
    self.frame:SetBackdropBorderColor(unpack(borderColor))
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
  end

  --- @param callbackFn fun(btn: Button_ABP_2_0_X)
  function bm:ForEach(callbackFn)
    for _, btn in ipairs(self.barFrame.widget.buttons) do
      --- @type Button_ABP_2_0_X
      local b = btn
      callbackFn(b)
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
  local w = barFrame.widget
  local name = moduleName(w.index)

  --- @type BarModule_2_0
  local existingModule = core:GetModule(name, true)
  if existingModule then return existingModule end

  --- @class BarModule_2_0 : BarModuleProto_ABP_2_0, AceAddon, AceConsole-3.0, AceEvent-3.0, AceBucket-3.0, AceHook-3.0
  local m = core:NewModule(name, BarModuleProto_2_0)
  m.barFrame = barFrame
  m.index = w.index
  w.module = m

  if m:c().enabled then m:Enable()
  else m:Disable() end
  _G[name] = m

  m:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
  --m:RegisterEvent('SPELLS_CHANGED', 'SPELLS_CHANGED')
  m:RegisterBucketEvent('SPELLS_CHANGED', 0.2)
  return m
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
  local pad = ui.padding
  local BASE_UI_PADDING = 12

  local padLeft   = pad.left   + BASE_UI_PADDING
  local padRight  = pad.right  + BASE_UI_PADDING
  local padTop    = pad.top    + BASE_UI_PADDING
  local padBottom = pad.bottom + BASE_UI_PADDING

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
    local btn = CreateFrame("CheckButton", btnName, frame, ns.buttonTemplate, encodedID)
    btn:SetParentKey(btnKey)
    table.insert(buttons, btn)
  end

  self:ApplyLayout(frame, barConf)
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

  --- @type Template
  local template = "ABP_BarFrameTemplate_2_0_1"

  --- @class BarFrame_ABP_2_0 : Frame, BackdropTemplate, BarFrameMixin_ABP_2_0_1
  local barFrame = CreateFrame("Frame", frameName, ABP_Parent_2_0, template)
  local f = barFrame
  f:SetParentKey(frameName)
  f:SetFrameLevel(barCount - barIndex)
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
    --- @type Button_ABP_2_0_X
    local btn = CreateFrame("CheckButton", btnName, barFrame, ns.buttonTemplate, encodedID)
    btn:SetParentKey(btnKey)
    table.insert(buttons, btn)
  end

  return buttons
end

