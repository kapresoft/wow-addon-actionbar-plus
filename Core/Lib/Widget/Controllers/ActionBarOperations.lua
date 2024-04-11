--[[-----------------------------------------------------------------------------
ActionBarOperations: The role of this utility is to provide ActionBar operations
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC = ns.O, ns.GC
local MSG = GC.M
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'ActionBarOperations'
--- @class ActionBarOperations
local L = ns:NewController(libName)
local p = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o ActionBarOperations | ControllerV2
local function PropsAndMethods(o)

    --- @return API
    function o:a() return O.API end

    --- @private
    --- @param delay OptionalTimeDelayInMilli
    function o:_ShowActionBars(delay)
        local m = '_ShowActionBars(delay)'
        if delay then assert(type(delay) == 'number',
                m .. ": Delay must be a number in milliseconds. Got-> " .. type(delay)) end
        local timeDelay = delay or 0.2
        p:vv(function() return '%s: called: delay=%s', m, timeDelay end)
        C_Timer.After(timeDelay, function()
            o:fevf(function(fw) fw:ShowGroupIfEnabled() end)
        end)
    end

    --  TODO: Migrate ButtonFrameFactory to this method
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

    --  TODO: Migrate ButtonFrameFactory to this method
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
        o:ForEachSettingsVisibleFrames(function(fw)
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

