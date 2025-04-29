--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC = ns.O, ns.GC
local MSG, E = GC.M, GC.E
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'DualSpecController'
--- @class DualSpecController
local L = ns:NewController(libName)
local p = ns:CreateDefaultLogger(libName)
p:v(function() return "Loaded: %s", libName end)
local ps = ns:LC().TALENT:NewLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o DualSpecController | ControllerV2
local function PropsAndMethods(o)

    --- Automatically called
    --- @see ModuleV2Mixin#Init
    --- @private
    function o:OnAddOnReady()
        p:vv('OnAddOnReady called...')
        self:RegisterMessageCallbacks()
    end

    function o.OnActiveTalentGroupChanged(msg, source, newGroup, previousGroup)
        ps:vv(function()
            return 'OnActiveTalentGroupChanged called new=%s prev=%s', newGroup, previousGroup
        end)

        -- TODO: Create a new storage with index 2 if newGroup = 2
        -- if btn[2] is empty and btn[1] has an action, then copy btn[1] to btn[2:newGroup]
        -- See ButtonFactory.lua
        -- Call ButtonFactory#Init() again?
    end

    --- @private
    function o:RegisterMessageCallbacks()
        self:RegisterAddOnMessage(E.ACTIVE_TALENT_GROUP_CHANGED, o.OnActiveTalentGroupChanged)
    end

end; PropsAndMethods(L)

