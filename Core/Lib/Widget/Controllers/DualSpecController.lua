--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC = ns.O, ns.GC
local MSG, E, Compat = GC.M, GC.E, O.Compat
local BF, AL = O.ButtonFactory, ns:AceLocale()
local talentsSwitchMsgFmt = AL['Talents Switch Success Message Format']

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'DualSpecController'
--- @class DualSpecController
local L = ns:NewController(libName)
local p = ns:CreateDefaultLogger(libName)
local ps = ns:LC().TALENT:NewLogger(libName)
--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- If the player is currently using a non-primary spec,
--- set the spec2_init flag here to indicate the primary spec buttons
--- will no longer be copied to the other specs on initial switch.
--- Sets the 'Spec 2 Initialized' flag
local function updateSpec2Init()
    if ns.db.profile.spec2_init == 1 or Compat:IsPrimarySpec() then return end
    ns.db.profile.spec2_init = 1
    ps:f3(function()
        return "Profile spec2_init=%s", ns.db.profile.spec2_init
    end)
end

--- @NotCombatSafe
local function initButtonsSafe()
    if InCombatLockdown() then return end

    local handler = function(error)
        p:e(function() return 'Unexpected error: %s', error end)
    end
    local ok = xpcall(function() BF:Init() end, handler)
    if ok then updateSpec2Init() end
    return ok
end
--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o DualSpecController | ControllerV2
local function PropsAndMethods(o)

    --- Automatically called
    --- @see ModuleV2Mixin#Init
    --- @private
    function o:OnAddOnInitialized()
        self:RegisterMessageCallbacks()
        updateSpec2Init()
    end

    --- @private
    function o:RegisterMessageCallbacks()
        if ns:IsRetail() then
            return self:RegisterAddOnMessage(E.ACTIVE_PLAYER_SPECIALIZATION_CHANGED, o.OnActivePlayerSpecChanged)
        end

        local msg = E.ACTIVE_TALENT_GROUP_CHANGED
        if ns:IsMoP() then msg = E.PLAYER_SPECIALIZATION_CHANGED end
        self:RegisterAddOnMessage(msg, o.OnActiveTalentGroupChanged)
    end

    -- pre-retail: ACTIVE_TALENT_GROUP_CHANGED
    -- retail: ACTIVE_PLAYER_SPECIALIZATION_CHANGED
    function o.OnActiveTalentGroupChanged(msg, source, newGroup, previousGroup)
        ps:vv(function()
            local specName = AL['Primary']
            if Compat:IsSecondarySpec() then specName = AL['Secondary'] end
            return talentsSwitchMsgFmt, specName
        end)
        initButtonsSafe()
    end

    function o.OnActivePlayerSpecChanged(msg, source)
        local specIndex = Compat:GetSpecializationID()
        if specIndex then
            local specID, specName = Compat:GetSpecializationInfo(specIndex)
            ps:vv(function()
                return talentsSwitchMsgFmt, specName
            end)
        end
        initButtonsSafe()
    end

end; PropsAndMethods(L)

