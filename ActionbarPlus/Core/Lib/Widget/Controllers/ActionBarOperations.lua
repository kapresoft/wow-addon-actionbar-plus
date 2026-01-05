--[[-----------------------------------------------------------------------------
ActionBarOperations: The role of this utility is to provide ActionBar operations
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFrame = CreateFrame

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC = ns.O, ns.GC
local PI, MSG = O.ProfileInitializer, GC.M

local tinsert = table.insert
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'ActionBarOperations'
--- @class _ActionBarOperations
local L = ns:NewController(libName)
local p = ns:CreateDefaultLogger(libName)
--- @alias ActionBarOperations _ActionBarOperations | ControllerV2

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o _ActionBarOperations | ControllerV2
local function PropsAndMethods(o)

    o.BASE_FRAME_NAME = 'ActionbarPlusF'

    --- @return API
    function o:a() return O.API end

    --- @return number
    function o:GetActionbarFrameCount() return PI.ActionbarCount end

    --- @param frameIndex Index
    function o:GetFrameName(frameIndex)
        assert(frameIndex and frameIndex > 0, "frameIndex should be > 0 on GC:GetFrameName(frameIndex)")
        return o.BASE_FRAME_NAME .. frameIndex
    end

    --- @param frameIndex Index
    --- @return ActionBarFrame
    function o:GetFrameByIndex(frameIndex)
        assert(type(frameIndex) == 'number', 'Expected frameIndex to be a number but got ' .. type(frameIndex))
        --- @type ActionBarFrame
        local f = _G[self:GetFrameName(frameIndex)]
        return f and f.GetName and f
    end

    --- @param frameIndex Index
    --- @return ActionBarFrameWidget
    function o:GetFrameWidgetByIndex(frameIndex)
        local f = self:GetFrameByIndex(frameIndex)
        return f and f.widget
    end

    --- The parent ActionbarPlus Frame which will eventually
    --- be the type `ActionbarPlusFrame`
    --- @param frameIndex number
    --- @return Frame
    function o:CreateBarFrame(frameIndex)
        local frameName = self:GetFrameName(frameIndex)
        return CreateFrame('Frame', frameName, nil, GC.C.FRAME_TEMPLATE)
    end

    --- @return table<number, ActionBarFrame>
    function o:GetAllBarFrames()
        local barFrames = {}
        for i=1, self:GetActionbarFrameCount() do
            local f = self:GetFrameByIndex(i)
            if f and f.widget then tinsert(barFrames, f) end
        end
        return barFrames
    end

    --- @return table<number, ActionBarFrame>
    function o:GetVisibleBarFrames()
        local barFrames = {}
        for i=1, self:GetActionbarFrameCount() do
            local f = self:GetFrameByIndex(i)
            if f and f.widget and f.widget.IsShownInConfig and f.widget:IsShownInConfig() then
                tinsert(barFrames, f)
            end
        end
        return barFrames
    end

    --- @return table<number, ActionBarFrame>
    function o:GetUsableBarFrames()
        local barFrames = {}
        for i=1, self:GetActionbarFrameCount() do
            local f = self:GetFrameWidgetByIndex(i)
            if f and f.widget
                    and f.widget:IsShownInConfig()
                    and f.widget:HasEmptyButtons() ~= true then
                tinsert(barFrames, f)
            end
        end
        return barFrames
    end

    --- @private
    --- @param delay OptionalTimeDelayInMilli
    function o:_ShowActionBars(delay)
        local m = '_ShowActionBars(delay)'
        if delay then assert(type(delay) == 'number',
                m .. ": Delay must be a number in milliseconds. Got-> " .. type(delay)) end
        local timeDelay = delay or 0.2
        p:f3(function() return '%s: called: delay=%s', m, timeDelay end)
        C_Timer.After(timeDelay, function()
            o:fevf(function(fw) fw:ShowGroupIfEnabled() end)
        end)
    end

    --  TODO: Migrate ActionBarFrameBuilder to this method
    --- @param delay OptionalTimeDelayInMilli
    function o:ShowActionBars(delay)
        local m = 'ShowActionBars(delay)'
        if not InCombatLockdown() then
            p:f3(m .. ' called: in-combat=false')
            return self:_ShowActionBars(delay)
        end

        -- When in combat, set a callbackfn when the player goes out of combat
        self:RegisterMessage(MSG.OnPlayerLeaveCombat, function(evt, source, ...)
            p:f3(m .. ': player left combat')
            self:_ShowActionBars(delay)
            self:UnregisterMessage(MSG.OnPlayerLeaveCombat)
            p:f3(m .. ': msg[OnPlayerLeaveCombat] unregistered')
        end)
        p:f3(m .. ' After combat handler registered')
    end

    --  TODO: Migrate ActionBarFrameBuilder to this method
    --- @param delay OptionalTimeDelayInMilli
    function o:HideActionBars(delay)
        local timeDelay = delay or 0.2
        p:f3(function() return 'HideActionBars() called: delay=%s', timeDelay end)
        C_Timer.After(timeDelay, function()
            o:fevf(function(fw) fw:HideGroup() end)
        end)
    end

    --- Lock Actionbar Settings. Hides the Frame Handle on Combat State
    --- This is a protected function
    --- @param lockState boolean true will lock, else unlock
    function o:SetActionBarsLockState(lockState)
        if InCombatLockdown() then return end
        local m = 'SetActionBarsLockState()'
        self:ForEachVisibleFrame(function(fw)
            if not fw:IsLockedInCombat() then return end
            if lockState == true then
                p:f3(function() return '%s: state=%s', m, fw:GetName() end)
                fw:SetCombatLockState()
            else
                p:f3(function() return '%s: state=%s', m, fw:GetName() end)
                fw:SetCombatUnlockState()
            end
        end)
    end

end; PropsAndMethods(L)

