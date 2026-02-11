--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI
local ns = select(2, ...)
local p = ns:log('BarController')

--[[-------------------------------------------------------------------
Type: ActionbarPlus_BarsUI_BarControllerMixin
---------------------------------------------------------------------]]
--- @alias ActionbarPlus_BarsUI_BarControllerMixin ActionbarPlus_BarsUI_BarControllerMixinImpl|FrameObj
--
--
--- @class ActionbarPlus_BarsUI_BarControllerMixinImpl
ActionbarPlus_BarsUI_BarControllerMixin = {};

--[[-------------------------------------------------------------------
Methods: ActionbarPlus_BarsUI_BarControllerMixin
---------------------------------------------------------------------]]
local function ControllerMethods()
    --- @type ActionbarPlus_BarsUI_BarControllerMixinImpl|ActionbarPlus_BarsUI_BarControllerMixin
    local c = ActionbarPlus_BarsUI_BarControllerMixin

    function c:OnLoad()
        self:RegisterEvent('PLAYER_LOGIN')
        self:RegisterEvent('PLAYER_ENTERING_WORLD')
        self:RegisterEvent('UNIT_SPELLCAST_SENT')
    end
    
    function c:OnEvent(evt, ...)
        C_Timer.After(1, function()
            p('OnEvent:: event=', evt, 'args=', { ... })
        end)

        --[[local arg1, arg2 = ...;
        if ( evt == 'PLAYER_ENTERING_WORLD' ) then
        elseif ( evt == 'UNIT_SPELLCAST_SENT' ) then
            --p('OnEvent:: event=', evt)
            --ActionBarController_UpdateAll();
        end]]
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
