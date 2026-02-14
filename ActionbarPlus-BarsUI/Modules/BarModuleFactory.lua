--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'BarModuleFactory'
--- @class BarModuleFactory_2_0
local S = {}; ABP_BarModuleFactory_2_0 = S
local p, f1, f2 = ns:log(libName)

--- @alias BarModule_2_0 BarModuleProto_2_0 | AddonModuleObj_3_0_Type2
--[[-------------------------------------------------------------------
Temporary Config
---------------------------------------------------------------------]]
local barCount = 2

--- @class Profile_Bar_V2
--- @field buttons table<string, Profile_Button>
--- @field widget Profile_Bar_Widget
--- @field anchor Anchor
local Profile_Bar_Config = {
    --- show/hide the actionbar frame
    ["enabled"] = false,
    --- allowed values: {"", "always", "in-combat"}
    ["locked"] = "",
    --- shows the button index
    ["show_button_index"] = true,
    --- shows the keybind text TOP
    ["show_keybind_text"] = true,
    ["widget"] = {
        ["rowSize"] = 1,
        ["colSize"] = 8,
        ["buttonSize"] = 40,
        ["buttonAlpha"] = 0.1,
        ["frame_handle_mouseover"] = false,
        ["frame_handle_alpha"] = 1.0,
        ["show_empty_buttons"] = true
    },
    ["anchor"] = { point="CENTER", relativeTo=nil, relativePoint='CENTER', x=0.0, y=0.0 },
    ["buttons"] = {}
}
--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
--- todo next: move to bars config
local lcfg = { spacing = 6, }
local baseLevel = 1000

local function barName(index) return ('ABP_2_0_F%s'):format(index) end
local function moduleName(index) return ('ABP_2_0_F%sModule'):format(index) end
local function btnName(barIndex, btnIndex)
    return ('ABP_2_0_F%sButton%s'):format(barIndex, btnIndex)
end

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
    function bm:c() return { enabled=true } end
    
    function bm:OnInitialize()
        C_Timer.After(1, function()
            p('OnInitialize() called')
        end)
    end
    
    function bm:OnEnable()
        C_Timer.After(1, function() p('OnEnable() called') end)
        if self.barFrame then self.barFrame:Show() end
    end
    
    function bm:OnDisable()
        p('OnDisable() called')
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
        assert(barFrame, 'Actionbar frame is missing.')
        local w = barFrame.widget
        local name = moduleName(w.index)
        --- @type BarModule_2_0
        local m = ns:a():NewModule(name, BarModuleProto_2_0)
        m.barFrame = barFrame
        m.index = w.index
        m:SetEnabledState(m:c().enabled)

        C_Timer.After(1, function()
            p(('%s created; enabled=%s'):format(m:GetName(), tostring(m:IsEnabled())))
        end)
        _G[name] = m
        return m
    end
    
    --- barFrame should be hidden by default in xml template
    function o:CreateAddonModules()
        p('xx Init() called')
        for i = 1, barCount do
            self:__CreateBarGroup(i, function(barFrame)
                self:New(barFrame)
            end)
        end
    end
    
    --- @private
    --- @param barIndex Index The bar frame index
    --- @param consumerFn BarFactoryConsumerFn
    function o:__CreateBarGroup(barIndex, consumerFn)
        assert(barIndex, 'Index is required.')
        
        local frameName = barName(barIndex)
        if _G[frameName] then
            return consumerFn and consumerFn(_G[frameName])
        end
        
        local cfg = Profile_Bar_Config
        local cols = cfg.widget.colSize
        local rows = cfg.widget.rowSize
        local size = cfg.widget.buttonSize
        local spacing = lcfg.spacing
        
        --- @type ActionBarFrame
        local frame = self:__CreateBarFrame(barIndex, frameName)
        local buttons = self:__CreateButtons(frame, barIndex)
        frame.widget.buttonFrames = buttons
        
        ----------------------------------------------------
        -- resize bar frame based on cols x rows
        ----------------------------------------------------
        local paddingLeft  = 16
        local paddingRight = 16
        local paddingTop   = 16
        local paddingBottom = 16
        
        local totalWidth  = paddingLeft + (size + spacing) * (cols - 1) + size + paddingRight
        local totalHeight = paddingTop + size * rows + spacing * (rows - 1) + paddingBottom
        
        frame:SetSize(totalWidth, totalHeight)
        
        ----------------------------------------------------
        -- layout buttons using cols x rows
        ----------------------------------------------------
        local col, row = 1, 1
        
        for i, btn in ipairs(buttons) do
            btn:SetSize(size, size)
            btn:ClearAllPoints()
            
            -- compute row/col based on index
            local indexInGrid = i - 1
            col = (indexInGrid % cols) + 1
            row = math.floor(indexInGrid / cols) + 1
            
            -- starting offsets
            local startX = 16
            local startY = -paddingTop
            
            -- compute position
            local x = startX + (size + spacing) * (col - 1)
            local y = startY - (size + spacing) * (row - 1)
            
            -- anchor inside the frame
            btn:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
        end
        
        return consumerFn and consumerFn(frame)
    end
    
    --- @private
    --- @param barIndex Index The frame index
    --- @param frameName Name The frame name
    --- @return ActionBarFrame
    --- @param frameName Name
    function o:__CreateBarFrame(barIndex, frameName)
        assert(barIndex and frameName, 'Frame and index missing.')
        --- @alias ABP_BarFrameObj_2_0 ABP_BarFrameObjImpl_2_0 | FrameObj
        --
        --- @class ABP_BarFrameObjImpl_2_0 : ABP_BarFrameMixin_2_0_1
        --- @field widget ABP_BarFrameObjWidget_2_0
        local barFrame = CreateFrame("Frame", frameName, ABP_Parent_2_0, "ABP_BarFrameTemplate_2_0_1")
        --- @type ABP_BarFrameObjImpl_2_0 | ABP_BarFrameObj_2_0
        local f = barFrame
        f:SetParentKey(frameName)
        f:SetFrameLevel(barIndex)
        f2('CreateBarFrame', 'n=' .. frameName .. ' fL=' .. f:GetFrameLevel())
        --- @class ABP_BarFrameObjWidget_2_0
        local __widget = {
            index = barIndex,
            frameStrata = 'MEDIUM',
            frameLevel = 1,
            --- @type ActionBarFrame
            frame = f,
            --- @type FrameHandle
            frameHandle = nil,
            rendered = false,
            --- @type table<number, ButtonUI>
            buttonFrames = {}
        }
        f.widget = __widget
        
        f:Show()
        
        return f
    end
    
    --- @param barIndex Index
    --- @param barFrame ActionBarFrame
    function o:__CreateButtons(barFrame, barIndex)
        --local cfg = P:GetBar(barIndex)
        local cfg = Profile_Bar_Config
        local btnSize = cfg.widget.buttonSize
        local cols = cfg.widget.colSize
        local rows = cfg.widget.rowSize
        local btnCount = rows * cols
        p('xx CreateButtons::btnCount:', btnCount)
        
        local buttons = {}
        for i = 1, btnCount do
            local btnName = btnName(barIndex, i)
            --- @type CheckButton
            local btn = CreateFrame("CheckButton", btnName, barFrame,
                    "ABP_ButtonTemplate_2_0_1")
            btn:SetSize(btnSize, btnSize)
            table.insert(buttons, btn)
        end
        barFrame.buttons = buttons
        return buttons
    end

end; PropsAndMethods()
