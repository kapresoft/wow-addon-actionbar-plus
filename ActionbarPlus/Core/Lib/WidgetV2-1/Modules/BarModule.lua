--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M = ns.O, ns.GC, ns.M
local P = O.Profile

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return BarModule, Kapresoft_CategoryLogger
local function CreateLib()
    local libName = M.BarModule
    --- @class BarModule : BaseLibraryObject
    local newLib = ns:NewLib(libName); if not newLib then return nil end
    local logger = ns:CreateDefaultLogger(libName)
    return newLib, logger
end; local L, p = CreateLib(); if not L then return end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o BarModule | ActionbarPlusModule
local function PropsAndMethods(o)

    --- @return ActionbarPlusModule
    --- @param barFrame ActionBarFrame
    function o:New(barFrame)
        assert(barFrame, 'Actionbar frame is missing.')
        local w = barFrame.widget
        -- Create the Ace module dynamically
        local name = "ActionbarPlusF" .. w.index .. 'Module'

        --- @class ActionbarPlusModule : AceModule
        --- @field index Index
        --- @field barFrame ActionBarFrame
        local m = ns:a():NewModule(name, "AceEvent-3.0", "AceHook-3.0")
        if not m then return nil end

        --- @type ActionbarPlusModule
        local mod = ns:K():Mixin(m, o)

        mod.barFrame = barFrame
        mod.index = w.index

        p:f1(function() return '%s created; enabled=%s', m:GetName(), m:IsEnabled() end)

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
    function o:c() return P:GetBar(self.index) end

    function o:OnInitialize()
        p:f1(function() return 'OnInitialize() called; index=%s', self.index end)
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

end; PropsAndMethods(L)
