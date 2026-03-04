--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns = ns:cns()
local tbl_IsEmpty = cns.O.Table.IsEmpty

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @see Namespace_ABP_BarsUI_2_0
--- @type string
local libName = ns.M.BarModuleFactory()
--- @class BarModuleFactory_2_0
local S = {}; ns:Register(libName, S)
local p, pd, t, tf = ns:log(libName)

--- @alias BarModule_2_0 BarModuleProto_2_0 | AddonModuleObj_3_0_Type2
--[[-------------------------------------------------------------------
Temporary Config
---------------------------------------------------------------------]]
local barCount = 1
--- todo next: move to bars config
local lcfg = { spacing = 6, }

--- @class Profile_Bar_V2
--- @field buttons table<string, Profile_Button>
--- @field widget Profile_Bar_Widget
--- @field anchor Anchor
local Profile_Bar_Config = {
  --- show/hide the actionbar frame
  ["enabled"]           = false,
  --- allowed values: {"", "always", "in-combat"}
  ["locked"]            = "",
  --- shows the button index
  ["show_button_index"] = true,
  --- shows the keybind text TOP
  ["show_keybind_text"] = true,
  ["widget"]            = {
    ["rowSize"]                = 1,
    ["colSize"]                = 4,
    ["buttonSize"]             = 40,
    ["buttonAlpha"]            = 0.1,
    ["frame_handle_mouseover"] = false,
    ["frame_handle_alpha"]     = 1.0,
    ["show_empty_buttons"]     = true
  },
  ["anchor"]            = { point = "CENTER", relativeTo = nil, relativePoint = 'CENTER', x = 0.0, y = 0.0 },
  ["buttons"]           = {}
}
--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
local function barName(index) return ('ABP_2_0_F%s'):format(index) end
local function moduleName(index) return ('ABP_2_0_F%sModule'):format(index) end
--- ABP_2_0_F1Button1, ABP_2_0_F1Button2, etc...
--- @return string, string Button name and button parent key
local function btnName(barIndex, btnIndex)
  local parentKey = ('Button%s'):format(btnIndex)
  return ('ABP_2_0_F%s%s'):format(barIndex, parentKey), parentKey
end
--[[-------------------------------------------------------------------
Mixin: BarFrameObjWidgetMixin_2_0
---------------------------------------------------------------------]]
--- @class BarFrameObjWidgetMixin_2_0
--- @field index Index
--- @field frame ABP_BarFrameObj_ABP_2_0
--- @field buttons table<number, Button_ABP_2_0_X>
local BarFrameObjWidgetMixin = {}

local function BarFrameWidgetMethods()
  
  --- @type BarFrameObjWidgetMixin_2_0
  local wm = BarFrameObjWidgetMixin
  
  ---@param frame ABP_BarFrameObj_ABP_2_0
  function wm:Init(frame, index)
    assert(type(frame) == 'table' and strlower(frame:GetObjectType()) == 'frame',
            'BarFrameObjWidgetMixin::Init(frame, index):: Param frame is expected to be a Frame.')
    assert(type(index) == 'number')
    self.frame = frame
    self.index = index
  end
  
  --- @return Index
  function wm:GetIndex() return self.index end
  
  --- @return ABP_BarFrameObj_ABP_2_0
  function wm:GetFrame() return self.frame end
  
  function wm:GetDebugName()
    return ('%s(Widget):: index=%s')
            :format(self.frame:GetName(), self.index)
  end


end; BarFrameWidgetMethods()

--[[-------------------------------------------------------------------
Mixin: BarFrameObjWidgetMixin_2_0
---------------------------------------------------------------------]]
--- @alias ButtonWidget_ABP_2_0 ButtonWidgetMixin_ABP_2_0
--
--- @class ButtonWidgetMixin_ABP_2_0
--- @field button Button_ABP_2_0_X
--- @field index Index The button index
--- @field barIndex Index The owner frame index
local ButtonWidgetMixin = {}
local function ButtonWidgetMixinMethods()
  
  --- @type ButtonWidgetMixin_ABP_2_0
  local bw = ButtonWidgetMixin
  
  --- @param btn Button_ABP_2_0_X
  --- @param btnIndex Index
  --- @param parentFrameIndex Index
  function bw:Init(btn, btnIndex, parentFrameIndex)
    self.button = btn
    self.index = btnIndex
    self.barIndex = parentFrameIndex
  end
  function bw:GetDebugName()
    return ('%s(Widget):: index=%s frameIndex=%s')
            :format(self.button:GetName(), self.index, self.barIndex)
  end
end; ButtonWidgetMixinMethods()

--[[-------------------------------------------------------------------
BarModuleProto
---------------------------------------------------------------------]]
--- @class BarModuleProto_2_0
--- @field index Index
--- @field barFrame FrameObj
local BarModuleProto_2_0 = {}

local function BarModuleProtoMethods()
  --- @type BarModuleProto_2_0|BarModule_2_0
  local bm = BarModuleProto_2_0
  
  -- todo: replace with real config
  --- @return Profile_Bar
  function bm:c() return { enabled = true } end
  
  function bm:OnInitialize()
    --pd('OnInitialize:: called')
  end
  
  function bm:OnEnable()
    --pd('OnEnable:: called')
    if self.barFrame then self.barFrame:Show() end
  end
  
  function bm:OnDisable()
    --p('OnDisable:: called')
    if self.barFrame then self.barFrame:Hide() end
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
local function PropsAndMethods()
  
  --- @type BarModuleFactory_2_0 | AceModuleLifecycleMixin_3_0
  local o = S
  
  --- Create the Ace module dynamically
  --- @param barFrame ActionBarFrame
  --- @return BarModule_2_0
  function o:New(barFrame)
    assert(barFrame, 'New(barFrame):: barFrame is missing.')
    local core = ns:a()
    local w = barFrame.widget
    local name = moduleName(w.index)
    
    --- @type BarModule_2_0
    local m = core:GetModule(name, true)
    if m then return m end
    
    m = core:NewModule(name, BarModuleProto_2_0)
    m.barFrame = barFrame
    m.index = w.index
    pd('New:: enabled=', m:c().enabled)
    if m:c().enabled then m:Enable()
    else m:Disable() end
    
    pd(('New:: %s created; enabled=%s'):format(m:GetName(), tostring(m:IsEnabled())))
    _G[name] = m
    return m
  end
  
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
    assert(barIndex, 'CreateBarGroup(barIndex):: Index is required.')
    
    local frameName = barName(barIndex)
    -- if the frame is already created, return that frame instance
    if _G[frameName] then return consumerFn and consumerFn(_G[frameName]) end
    
    --local barConf = cns:bars(barIndex)
    local barConf = cns:a():bar(barIndex)
    local ui = barConf.ui
    
    local cols = ui.colSize
    local rows = ui.rowSize
    local size = ui.button.size
    --local spacing = lcfg.spacing
    local spacing = ui.button.spacing
    
    --- @type ABP_BarFrameObj_ABP_2_0
    local frame = self:__CreateBarFrame(barConf, barIndex, frameName)
    local buttons = self:__CreateButtons(barConf, frame, barIndex)
    frame.widget.buttons = buttons
    
    ----------------------------------------------------
    -- resize bar frame based on cols x rows
    ----------------------------------------------------
    local paddingLeft = 16
    local paddingRight = 16
    local paddingTop = 16
    local paddingBottom = 16
    --local pad = ui.padding
    --
    --local totalWidth = pad.left + (size + spacing.horizontal) * (cols - 1) + size + pad.right
    --local totalHeight = pad.top + size * rows + spacing.vertical * (rows - 1) + pad.bottom
    
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
  --- @return ABP_BarFrameObj_ABP_2_0
  function o:__CreateBarFrame(barConf, barIndex, frameName)
    assert(barIndex and frameName, 'Frame and index missing.')
    --- @alias ABP_BarFrameObj_ABP_2_0 ABP_BarFrameObjImpl_ABP_2_0 | FrameObj
    --
    --- @class ABP_BarFrameObjImpl_ABP_2_0 : BarFrameMixin_ABP_2_0_1
    --- @field widget ABP_BarFrameObjWidget_2_0
    local barFrame = CreateFrame("Frame", frameName, ABP_Parent_2_0, "ABP_BarFrameTemplate_2_0_1")
    
    --- @type ABP_BarFrameObjImpl_ABP_2_0 | ABP_BarFrameObj_ABP_2_0
    local f = barFrame
    f:SetParentKey(frameName)
    f:SetFrameLevel(barIndex)
    
    --- @class ABP_BarFrameObjWidget_2_0 : BarFrameObjWidgetMixin_2_0
    f.widget = CreateAndInitFromMixin(BarFrameObjWidgetMixin, f, barIndex)
    f:Show()
    
    return f
  end
  
  --- @param barConf BarConfig_ABP_2_0 The frame index
  --- @param barIndex Index
  --- @param barFrame ABP_BarFrameObj_ABP_2_0
  --- @return table<number, Button_ABP_2_0_X>
  function o:__CreateButtons(barConf, barFrame, barIndex)
    local ui = barConf.ui
    local cols, rows = ui.colSize, ui.rowSize
    local btnCount = rows * cols
    
    --- @type table<number, Button_ABP_2_0_X>
    local buttons = {}
    for i = 1, btnCount do
      local btnName, btnKey = btnName(barIndex, i)
      --- @type Button_ABP_2_0_X
      local btn = CreateFrame("CheckButton", btnName, barFrame, ns.buttonTemplate)
      btn:SetParentKey(btnKey)
      btn.widget = CreateAndInitFromMixin(ButtonWidgetMixin, btn, i, barIndex)
      local bc = btn:GetButtonConfig()
      if not tbl_IsEmpty(bc) then
        pd('CreateButtons:: button=', btnName, 'bc=', fmt(bc))
        if bc.type and bc.id then
          btn:SetAttribute('type', bc.type)
          btn:SetAttribute(bc.type, bc.id)
        end
      else
        --ABP_ButtonTestData:AddTestData(btn)
      end
      
      table.insert(buttons, btn)
    end
    
    return buttons
  end

end;
PropsAndMethods()
