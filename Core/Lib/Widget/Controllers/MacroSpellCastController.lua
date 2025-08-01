--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns      = select(2, ...)
local O, GC   = ns.O, ns.GC
local api, mcc = O.API, O.MacroControllerCommon

local THROTTLE_INTERVAL_MACRO_UPDATES   = 0.3

local MACRO_UPDATE_TIMEOUT                = 20
local MACRO_UPDATE_COMBAT_RETRY_IN_SEC    = 10
local SPELL_UPDATE_USABLE_BUCKET_INTERVAL = 0.3

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libNameMU = ns.M.MacroSpellCastController
--- @class MacroSpellCastController : ThrottledUpdaterMixin
local L = ns:NewController(libNameMU, O.ThrottledUpdaterMixin); if not L then return end
local p = ns:LC().MACRO:NewLogger(libNameMU)

--- @type MacroSpellCastController | ControllerV2
local o = L

--- @type C_TimerTicker
local unregisterTask
--- @type table
local spellUpdateUsableHandle


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- Automatically called
--- @private
--- @see ModuleV2Mixin#Init
function o:OnAddOnReady()
    self:SetThrottleInterval(THROTTLE_INTERVAL_MACRO_UPDATES)
    self:RegisterMessage(GC.M.OnPlayerSpellCastSucceeded, o.OnPlayerCastSucceeded)
    self:RegisterAddOnMessage(GC.E.PLAYER_TARGET_CHANGED, o.OnTargetChanged)
    self:StartThrottledUpdates()
end

function o.OnPlayerCastSucceeded()
    o:RegisterSpellUpdateUsable()
    o:StartThrottledUpdates()
    o:UnRegisterAfter(MACRO_UPDATE_TIMEOUT)
end

function o.OnSpellUpdateUsable() o:StartThrottledUpdates() end

function o.OnTargetChanged()
    o:StartThrottledUpdates()
    o:UnRegisterAfter(MACRO_UPDATE_TIMEOUT)
end

--- ======================================================
--- Methods
--- ======================================================

--- @see ThrottledUpdaterMixin
--- @param elapsed TimeInMilli
function o:_OnUpdate(elapsed)
    C_Timer.After(0.01, function() local ctrl = self  mcc:UpdateMacros(ctrl) end)
end

function o:RegisterSpellUpdateUsable()
    if spellUpdateUsableHandle then return end
    spellUpdateUsableHandle = o:RegisterBucketAddOnMessage(GC.E.SPELL_UPDATE_USABLE, SPELL_UPDATE_USABLE_BUCKET_INTERVAL, o.OnSpellUpdateUsable)
    p:d(function() return 'Msg Handler Registered. SpellUpdateUsable handle: %s', tostring(spellUpdateUsableHandle) end)
end

--- cancel previous, schedule new, stop updates and cleanup handle
function o:UnRegisterAfter(duration)
    assert(type(duration) == 'number', 'Duration should be a number (in seconds).');
    local previousTask = unregisterTask
    if unregisterTask and not unregisterTask:IsCancelled() then
        unregisterTask:Cancel()
        p:d(function() return 'Unregister task cancelled [%s]',
            tostring(unregisterTask) end)
    end

    local ctrl = self
    unregisterTask = C_Timer.NewTimer(duration, function()
        local function tryUnregister()
            if InCombatLockdown() then
                p:d(function() return 'Retrying unregister task in %ss due to InCombatLockdown()', MACRO_UPDATE_COMBAT_RETRY_IN_SEC end)
                C_Timer.After(MACRO_UPDATE_COMBAT_RETRY_IN_SEC, tryUnregister)
                return
            end
            if not spellUpdateUsableHandle then return end

            ctrl:StopThrottledUpdates()
            ctrl:UnregisterBucket(spellUpdateUsableHandle);
            local prev = spellUpdateUsableHandle
            spellUpdateUsableHandle = nil
            p:d(function() return 'Macro update handler(%s), cleared=[%s]',
                tostring(prev), spellUpdateUsableHandle == nil end)
        end
        tryUnregister()
    end)
    p:d(function()
        if previousTask then
            return 'New unregister task to trigger in %ss.\nNew(%s), Prev(%s), cancelled=[%s]',
                duration, tostring(unregisterTask),
                tostring(previousTask), previousTask:IsCancelled()
        end
        return 'New Unregister task [%s], trigger in %ss.', tostring(unregisterTask), duration
    end)
end

