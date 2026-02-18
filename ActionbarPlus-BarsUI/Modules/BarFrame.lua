--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)

local seedID = 4999

--[[-----------------------------------------------------------------------------
New Instance
BarFrame (secure)
    └── Handler (protected, hidden)
-------------------------------------------------------------------------------]]
--
--
local libName = 'ABP_BarFrameMixin_2_0_1'
--- @class ABP_BarFrameMixin_2_0_1 : Frame
--- @field _originalLevel number
local S = {}; ABP_BarFrameMixin_2_0_1 = S
local p, pd, t, tf = ns:log(libName)

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
        
        --self:SetScript("OnUpdate", function(frame)
        --    frame:SetScript("OnUpdate", nil)
        --    frame:InitSecure()
        --end)
    end
    
    function o:InitSecure()
        p('xx InitSecure')
        local header = self.Handler
        local proxy  = self.SecureProxy
        proxy:SetAttribute("type", "spell")
        --proxy:SetScript('OnClick', function()
        --    p('xx proxy clicked...')
        --    self:SetAttribute("spell", 'holy light')
        --end)
        SecureHandlerSetFrameRef(header, "proxy", proxy)
        
        SecureHandlerWrapScript(
                header,
                "OnAttributeChanged",
                header,
                [[
                    local proxy = self:GetFrameRef("proxy")
                    local spellName = self:GetAttribute("spell_abp")
                    if proxy and spellName then
                        proxy:SetAttribute("spell", spellName)
                    print('xx proxy=', proxy, 'spellN=', spellName, 'CastSpellByName=', CastSpellByName)
                    
                    end
                    return true, "ok"
                ]]
        )
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
