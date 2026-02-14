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
    end

    function o:OnDragStart()
        self._originalLevel = self:GetFrameLevel()
        self:SetFrameLevel(self._originalLevel + 100)
        self:StartMoving()
    end
    function o:OnDragStop()
        self:StopMovingOrSizing()
        if self._originalLevel then
            self:SetFrameLevel(self._originalLevel)
            self._originalLevel = nil
        end
    end
    function o:OnSizeChanged()
        ns.O.Backdrops:ApplyDefaultBackdrop(self)
    end

end; PropsAndMethods()
