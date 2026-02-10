--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI
local ns = select(2, ...)
local p = ns:cns():log()

--[[-------------------------------------------------------------------
Type: ActionbarPlus_BarsUI_BarController
---------------------------------------------------------------------]]
--- @alias ActionbarPlus_BarsUI_BarController ActionbarPlus_BarsUI_BarControllerImpl|FrameObj
--
--
--- @class ActionbarPlus_BarsUI_BarControllerImpl
ActionbarPlus_BarsUI_BarController = {};

--[[-------------------------------------------------------------------
Methods: ActionbarPlus_BarsUI_BarController
---------------------------------------------------------------------]]
local function ControllerMethods()
    --- @type ActionbarPlus_BarsUI_BarControllerImpl|ActionbarPlus_BarsUI_BarController
    local c = ActionbarPlus_BarsUI_BarController

    function c:OnLoad()
    
    end
    
end; ControllerMethods()

--[[-----------------------------------------------------------------------------
Global Functions
-------------------------------------------------------------------------------]]
---@param frame _Frame
--[[
function ns.xml:BarController_OnLoad(frame)
    --for i, v in pairs(children) do
    --
    --end
    frame:RegisterEvent(E.PLAYER_ENTERING_WORLD)
end

function ns.xml:BarController_OnEvent(self, event, ...)
    local arg1, arg2 = ...;
    if ( event == E.PLAYER_ENTERING_WORLD ) then
        --p:log('event: %s', event)
        --ActionBarController_UpdateAll();
    end
end
]]
