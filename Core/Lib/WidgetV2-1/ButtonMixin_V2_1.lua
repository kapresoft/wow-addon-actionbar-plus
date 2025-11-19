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
--- @type ButtonMixin_V2_1
local o = S

--- @param self ButtonMixin_V2_1
function o.OnLoad(self)
    C_Timer.After(1, function()
        p:vv(function() return 'OnLoad: %s', self:GetID() end)
    end)

    self:EnableMouse(true)
    self:SetAttribute("action", self:GetID())
    self.action = self:GetID()
end

--- @param self ButtonMixin_V2_1
function o.OnPostClick(self, button, down)
    p:vv(function() return 'OnPostClick[%s::%s]: button=%s, down=%s', self:GetName(), self:GetID(), button, down  end)
    self:UpdateState(button, down)
end

--- @param self ButtonMixin_V2_1
function o.OnAttributeChanged(self, name, val)
    p:vv(function() return 'OnAttributeChanged[%s]: name=%s, val=%s', self:GetID(), name, val  end)
    self:UpdateAction(name, val)
end

--- @param self ButtonMixin_V2_1
function o.OnEvent(self, event, ...)
    local args = { ... }
    p:vv(function() return 'OnEvent[%s::%s]: name=%s, val=%s', self:GetName(), self:GetID(), event, args end)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function o:UpdateState(button, down)
    self:SetChecked(false)
end

function o:UpdateAction(name, val)
    -- empty for now
end



ABP_ButtonMixin_V2_1 = o
