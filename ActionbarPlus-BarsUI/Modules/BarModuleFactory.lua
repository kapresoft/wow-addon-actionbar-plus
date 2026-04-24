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

local VISIBILITY_DEFAULTS = '[vehicleui][petbattle]hide; show'

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

--- @param self BarFrameObj_ABP_2_0
local function BarFrame_EnableVisibilityDriver(self)
  RegisterStateDriver(self, "visibility", VISIBILITY_DEFAULTS)
end

--- @param self BarFrameObj_ABP_2_0
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
--- @class BarFrameObjWidgetMixin_ABP_2_0
--- @field index Index
--- @field frame BarFrameObj_ABP_2_0
--- @field buttons table<number, Button_ABP_2_0_X>
local BarFrameObjWidgetMixin = {}

local function BarFrameWidgetMethods()
  
  --- @type BarFrameObjWidgetMixin_ABP_2_0
  local wm = BarFrameObjWidgetMixin
  
  ---@param frame BarFrameObj_ABP_2_0
  function wm:Init(frame, index)
    assert(type(frame) == 'table' and strlower(frame:GetObjectType()) == 'frame',
            'BarFrameObjWidgetMixin::Init(frame, index):: Param frame is expected to be a Frame.')
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
  
  --- @return BarFrameObj_ABP_2_0
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
--- @field barFrame BarFrameObj_ABP_2_0
local BarModuleProto_2_0 = {}

local function BarModuleProtoMethods()
  
  local bm = BarModuleProto_2_0
  
  --- @return BarConfig_ABP_2_0?
  function bm:c() return cns:bar(self.index) end
  
  function bm:OnInitialize()
    --pd('OnInitialize:: called')
  end
  
  function bm:OnEnable()
    t('BarModuleProto', 'OnEnable')
    if self.barFrame then
      self.barFrame:Show()
      BarFrame_EnableVisibilityDriver(self.barFrame)
    end
    BarModule_EnableEditModeCallback(self)
  end

  function bm:OnDisable()
    t('BarModuleProto', 'OnDisable')
    if self.barFrame then
      BarFrame_DisableVisibilityDriver(self.barFrame)
      self.barFrame:Hide()
    end
    BarModule_DisableEditModeCallback(self)
  end

  function bm:OnEditModeEnter()
    BarFrame_DisableVisibilityDriver(self.barFrame)
    self.barFrame:Hide()
  end
  
  -- No need to call barFrame:Hide() here because
  -- the visibility values will be evaluated.
  function bm:OnEditModeExit()
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
    
    local w = self.barFrame.widget
    for i, btn in ipairs(w.buttons) do
      btn.widget:ApplyButtonConfig()
    end
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
--- @param barFrame ActionBarFrame
--- @return BarModule_2_0
function o:New(barFrame)
  assert(type(barFrame) == 'table', 'New(barFrame):: {barFrame} should be a frame.')

  local core = ns:a()
  local w = barFrame.widget
  local name = moduleName(w.index)

  --- @type BarModule_2_0
  local existingModule = core:GetModule(name, true)
  if existingModule then return existingModule end

  --- @class BarModule_2_0 : BarModuleProto_ABP_2_0, AceConsole-3.0, AceEvent-3.0, AceBucket-3.0, AceHook-3.0
  local m = core:NewModule(name, BarModuleProto_2_0)
  m.barFrame = barFrame
  m.index = w.index

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
    self:__CreateBarGroup(i, function(barFrame) self:New(barFrame) end)
  end
end

--- @private
--- @param barIndex Index The bar frame index
--- @param consumerFn BarFactoryConsumerFn
function o:__CreateBarGroup(barIndex, consumerFn)
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

  --- @type BarFrameObj_ABP_2_0
  local frame = self:__CreateBarFrame(barConf, barIndex, frameName)
  local buttons = self:__CreateButtons(barConf, frame, barIndex)
  frame.widget.buttons = buttons

  ----------------------------------------------------
  -- resize bar frame based on cols x rows
  ----------------------------------------------------
  local pad = ui.padding
  local BASE_UI_PADDING = 12

  local padLeft   = pad.left   + BASE_UI_PADDING
  local padRight  = pad.right  + BASE_UI_PADDING
  local padTop    = pad.top    + BASE_UI_PADDING
  local padBottom = pad.bottom + BASE_UI_PADDING

  local totalWidth = padLeft + size*cols + spacing.horizontal*(cols - 1) + padRight
  local totalHeight = padTop + size*rows + spacing.vertical*(rows - 1) + padBottom

  frame:SetSize(totalWidth, totalHeight)

  ----------------------------------------------------
  -- layout buttons using cols x rows
  ----------------------------------------------------
  local col, row = 1, 1
  local startX = math.floor(padLeft + 0.5)
  local startY = -math.floor(padTop + 0.5)

  for i, btn in ipairs(buttons) do
    btn:SetSize(size, size)
    btn:ClearAllPoints()

    -- compute row/col based on index
    local indexInGrid = i - 1
    col = (indexInGrid % cols) + 1
    row = math.floor(indexInGrid / cols) + 1

    -- starting offsets
    --local startX = pad.left
    --local startY = -pad.top

    -- compute position
    local x = startX + (size + spacing.horizontal) * (col - 1)
    local y = startY - (size + spacing.vertical) * (row - 1)

    -- anchor inside the frame
    btn:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
  end

  return consumerFn and consumerFn(frame)
end

--- Bar name: ABP_2_0_F{INDEX}, i.e. ABP_2_0_F1, ABP_2_0_F2, ...
--- @param barConf ButtonConfig_ABP_2_0 The frame index
--- @param barIndex Index The frame index
--- @param frameName Name The frame name
--- @return BarFrameObj_ABP_2_0
function o:__CreateBarFrame(barConf, barIndex, frameName)
  assert(type(barIndex) == 'number', '__CreateBarFrame(barConf, barIndex, frameName) {barIndex} should be a number')
  assert(type(frameName) == 'string', '__CreateBarFrame(barConf, barIndex, frameName): {frameName} should be a string')

  --- @type Template
  local template = "ABP_BarFrameTemplate_2_0_1"

  --- @class BarFrameObj_ABP_2_0 : Frame, BackdropTemplate, BarFrameMixin_ABP_2_0_1
  --- @field widget BarFrameObjWidget_ABP_2_0
  local barFrame = CreateFrame("Frame", frameName, ABP_Parent_2_0, template)
  local f = barFrame
  f:SetParentKey(frameName)
  f:SetFrameLevel(barIndex)

  --- @class BarFrameObjWidget_ABP_2_0 : BarFrameObjWidgetMixin_ABP_2_0
  f.widget = CreateAndInitFromMixin(BarFrameObjWidgetMixin, f, barIndex)

  -- TODO: Can have user-preference override
  --RegisterStateDriver(barFrame, 'visibility', VISIBILITY_DEFAULTS)
  BarFrame_EnableVisibilityDriver(barFrame)

  --barFrame:SetAttribute("_onstate-abp-state", [[
  --  print('xx barFrame: newState=', newstate)
  --  self:SetAttribute("abp_state", newstate)
  --]])

  f:Show()

  return f
end

--- @param barConf BarConfig_ABP_2_0 The frame index
--- @param barIndex Index
--- @param barFrame BarFrameObj_ABP_2_0
--- @return table<number, Button_ABP_2_0_X>
function o:__CreateButtons(barConf, barFrame, barIndex)
  local ui = barConf.ui
  local cols, rows = ui.colSize, ui.rowSize
  local btnCount = rows * cols

  --- @type table<number, Button_ABP_2_0_X>
  local buttons = {}
  for i = 1, btnCount do
    local btnName, btnKey = ButtonName(barIndex, i)
    --- @type Button_ABP_2_0_X
    local btn = CreateFrame("CheckButton", btnName, barFrame, ns.buttonTemplate)
    btn:SetParentKey(btnKey)
    btn:AfterLoad(i, barIndex)
    table.insert(buttons, btn)
  end

  return buttons
end

