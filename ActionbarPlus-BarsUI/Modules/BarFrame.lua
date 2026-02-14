--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)

local seedID = 4999

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--
--
local libName = 'ABP_BarFrameMixin_2_0_1'
--- @class ABP_BarFrameMixin_2_0_1 : Frame
--- @field _originalLevel number
local S = {}; ABP_BarFrameMixin_2_0_1 = S
local p, f1, f2 = ns:log(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local function PropsAndMethods()

    --- @type ABP_BarFrameMixin_2_0_1 | ABP_BarFrameObj_2_0
    local o = S
    
    --[[-----------------------------------------------------------------------------
    Mixin Methods
    -------------------------------------------------------------------------------]]
    function o:OnLoad()
        --if not ns:IsV2() then self:UnregisterAllEvents(); self:Hide(); return; end
        self:RegisterForDrag("LeftButton")
        f2('onload', 'frameLevel=', self:GetFrameLevel())
    end

    function o:OnDragStart()
        self._originalLevel = self:GetFrameLevel()
        f2('OnDragStart', '(b4) barFrameIndex=' .. self.widget.index,
                'parentFL=' .. self:GetParent():GetFrameLevel(),
                'fLvl=', self:GetFrameLevel(), 'strat='.. self:GetFrameStrata())
        self:SetFrameLevel(self._originalLevel + 100)
        self:StartMoving()
        f2('OnDragStart', 'dragging... f=', self:GetName(), 'flOrig=', self._originalLevel, 'fL=', self:GetFrameLevel())
    end
    function o:OnDragStop()
        self:StopMovingOrSizing()
        f2('OnDragStop', '(b4) f=', self:GetName(), 'fl=', self:GetFrameLevel(), 'flOrig=', self._originalLevel)
        if self._originalLevel then
            self:SetFrameLevel(self._originalLevel)
            self._originalLevel = nil
        end
        f2('OnDragStop', 'f=', self:GetName(), 'fl=', self:GetFrameLevel())
    end
    function o:OnSizeChanged()
        ABPV2_ApplyBackdrop(self, ABPV2_BACKDROPS.backdrop)
    end

end; PropsAndMethods()
