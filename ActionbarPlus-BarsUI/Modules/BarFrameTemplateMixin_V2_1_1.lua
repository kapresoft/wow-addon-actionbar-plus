--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)

local seedID = 4999

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'BarFrameTemplate_V2_1_1'
--- @class BarFrameTemplate_V2_1_1
local S = {}; ABPV2_BarFrameTemplateMixin_V2_1_1 = S
local p = ns:log(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local function PropsAndMethods()

    --- @type BarFrameTemplate_V2_1_1 | FrameObj
    local o = S
    
    --[[-----------------------------------------------------------------------------
    Mixin Methods
    -------------------------------------------------------------------------------]]
    --- @param self Frame
    function o.OnLoad(self)
        --if not ns:IsV2() then self:UnregisterAllEvents(); self:Hide(); return; end
        self:RegisterForDrag("LeftButton")
    end

    function o.OnDragStart(self) self:StartMoving() end
    function o.OnDragStop(self) self:StopMovingOrSizing() end
    function o.OnSizeChanged(self)
        ABPV2_ApplyBackdrop(self, ABPV2_BACKDROPS.backdrop)
    end

end; PropsAndMethods()

