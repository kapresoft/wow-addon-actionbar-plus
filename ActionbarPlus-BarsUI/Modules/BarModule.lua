--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'BarModule'
--- @class BarModule
local S = {}; ABPV2_BarModule = S
local p = ns:log(libName)
S.__index = S
S.__type = libName


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local function PropsAndMethods()

    --- @type BarModule
    local o = S
    
    --- @param barFrame ActionBarFrame
    --- @return ActionbarPlusModule
    function o:New(barFrame)
        assert(barFrame, 'Actionbar frame is missing.')
        local w = barFrame.widget
        -- Create the Ace module dynamically
        local name = "ActionbarPlusF" .. w.index .. 'Module'

        --- @class ActionbarPlusModule : AceModuleObj
        --- @field index Index
        --- @field barFrame ActionBarFrame
        local m = ns:a():NewModule(name, "AceEvent-3.0", "AceHook-3.0")
        if not m then return nil end

        --- @type ActionbarPlusModule
        local mod = Mixin(m, self)

        mod.barFrame = barFrame
        mod.index = w.index

        p(('%s created; enabled=%s'):format(m:GetName(), tostring(m:IsEnabled())))

        -- Set Global
        -- example: ActionbarPlusF1Module
        _G[name] = m

        return mod
    end

    function o:SetInitialState()
        local cfg = self:c()
        if cfg.enabled then
            return self:Enable() and p:f1(function() return '[SetInitialState] Enabled; index=%s', self.index end)
        else
            return self:Disable() and p:vv(function() return '[SetInitialState] Disabled; index=%s', self.index end)
        end
    end

    --- @return Profile_Bar
    function o:c()
        -- todo: need the real stuff
        return { enabled=true } end

    function o:OnInitialize()
        p('OnInitialize() called; index=', self.index)
        self:SetInitialState()
    end

    function o:OnEnable()
        p:f1(function() return 'OnEnable() called; index=%s', self.index end)
        return self.barFrame:Show()
    end

    function o:OnDisable()
        p:f1(function() return 'OnDisable() called; index=%s', self.index end)
        return self.barFrame:Hide()
    end

end; PropsAndMethods()
