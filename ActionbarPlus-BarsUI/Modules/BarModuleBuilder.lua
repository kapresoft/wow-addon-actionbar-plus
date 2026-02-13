--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'BarModuleBuilder'
--- @class BarModuleBuilder_2_0
local S = {}; ABPV2_BarModule = S
local p = ns:log(libName)

--- @alias BarModule_2_0 BarModuleProto_2_0 | AddonModuleObj_3_0_Type2

--[[-------------------------------------------------------------------
BarModuleProto
---------------------------------------------------------------------]]
--- @class BarModuleProto_2_0
--- @field index Index
--- @field barFrame FrameObj
local BarModuleProto_2_0 = {}

local function BarModuleMethods()
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
    
    --- @protected
    function bm:__SetInitialState()
        p('SetInitialState called...')
        if self:c().enabled then self:Enable()
        else self:Disable() end
    end

end; BarModuleMethods()

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local function PropsAndMethods()
    
    --- @type BarModuleBuilder_2_0 | AceModuleLifecycleMixin_3_0
    local o = S
    
    --- @param barFrame ActionBarFrame
    --- @return BarModule_2_0
    function o:New(barFrame)
        assert(barFrame, 'Actionbar frame is missing.')
        local w = barFrame.widget
        -- Create the Ace module dynamically
        --local name = "ActionbarPlusF" .. w.index .. 'Module_2_0'
        local name = ('ActionbarPlusF%sModule_2_0'):format(w.index)
        -- /dump ActionbarPlusF1Module_2_0:Enable()
        -- /dump ActionbarPlusF1Module_2_0:Disable()
        -- /dump ActionbarPlusF1Module_2_0:IsEnabled()
        -- /dump ActionbarPlusF1Module_2_0.enabledState
        --BarModule_2_0
        --- @type BarModule_2_0
        local m = ns:a():NewModule(name, BarModuleProto_2_0)
        m.barFrame = barFrame
        m.index = w.index
        m:__SetInitialState()
        p(('%s created; enabled=%s'):format(m:GetName(), tostring(m:IsEnabled())))
        _G[name] = m
        return m
    end

--[[    function o:OnInitialize()
        p('OnInitialize() called; index=', self.index)
        --self:SetInitialState()
    end

    function o:OnEnable()
        --ABP_BarFactory_2_0
        --print('xx OnEnable() called; index=', self.index)
        --p('xx OnEnable() called; index=', self.index)
        --return self.barFrame:Show()
    end

    function o:OnDisable()
        p:f1(function() return 'OnDisable() called; index=%s', self.index end)
        return self.barFrame:Hide()
    end]]

end; PropsAndMethods()
