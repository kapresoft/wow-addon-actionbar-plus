--[[-----------------------------------------------------------------------------
@see ActionBarPlusButtonTemplate.xml
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local K, O, GC = ns:K(), ns.O, ns.GC
local MSG = GC.M
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'ButtonMixin_V2_1'
--- @class ButtonMixin_V2_1
local S = {}
local p = ns:LC().DEFAULT:NewLogger(libName)

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]
--- @type ButtonMixin_V2_1 | CheckButton
local o = S

function o:OnLoad()
    C_Timer.After(1, function()
        p:vv(function() return 'OnLoad: %s', self:GetID() end)
    end)

    self:EnableMouse(true)
    self:SetAttribute("action", self:GetID())
    self.action = self:GetID()
end; ABP_ButtonMixin_V2_1 = o
