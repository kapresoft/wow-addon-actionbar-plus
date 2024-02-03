--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub
local E = GC.E

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = M.BarController or 'BarController'
--- @class BarController : BaseLibraryObject
local L = LibStub:NewLibrary(libName); if not L then return end
local p = L:GetLogger()

-- Add to Modules.lua
--BarController = 'BarController',
--
----- @type BarController
--BarController = {},

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
