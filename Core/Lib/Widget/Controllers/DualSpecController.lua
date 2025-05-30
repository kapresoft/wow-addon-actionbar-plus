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
-- TODO next:: only copy primary spec action buttons if spec2_init ~= 1
--- Sets the 'Spec 2 Initialized' flag
local function updateSpec2Init()
    if ns.db.profile.spec2_init == 1 or Compat:IsPrimarySpec() then return end
    ns.db.profile.spec2_init = 1
    ps:f3(function()
        return "Profile spec2_init=%s", ns.db.profile.spec2_init
    end)
end
local function initButtonsSafe()
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
        initButtonsSafe()
    end

    --- @private
    function o:RegisterMessageCallbacks()
        self:RegisterAddOnMessage(E.ACTIVE_TALENT_GROUP_CHANGED, o.OnActiveTalentGroupChanged)

        -- retail only
        if not ns:IsRetail() then return end
        self:RegisterAddOnMessage(E.ACTIVE_PLAYER_SPECIALIZATION_CHANGED, o.OnActivePlayerSpecChanged)
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
        local specIndex = GetSpecialization()
        if specIndex then
            local specID, specName = GetSpecializationInfo(specIndex)
            ps:vv(function()
                return talentsSwitchMsgFmt, specName
            end)
        end
        initButtonsSafe()
    end

end; PropsAndMethods(L)

