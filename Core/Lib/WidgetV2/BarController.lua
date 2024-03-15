--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, E, LibStub = ns.O, ns.GC, ns.M, ns.GC.E, ns.LibStub

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = M.BarController or 'BarController'
--- @class BarController : BaseLibraryObject
local L = LibStub:NewLibrary(libName); if not L then return end
local p = ns:CreateDefaultLogger(libName)

-- Add to Modules.lua
-- BarController = 'BarController',
--
-- @type BarController
-- BarController = {},

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o BarController
local function PropsAndMethods(o)

end; PropsAndMethods(L)


--[[-----------------------------------------------------------------------------
Global Functions
-------------------------------------------------------------------------------]]
---@param frame _Frame
function ABP_BarController_OnLoad(frame)
    --p:log('OnLoad:: called...')
    --for i, v in pairs(children) do
    --
    --end
    frame:RegisterEvent(E.PLAYER_ENTERING_WORLD)
end

function ABP_BarController_OnEvent(self, event, ...)
    local arg1, arg2 = ...;
    if ( event == E.PLAYER_ENTERING_WORLD ) then
        --p:log('event: %s', event)
        --ActionBarController_UpdateAll();
    end
end
