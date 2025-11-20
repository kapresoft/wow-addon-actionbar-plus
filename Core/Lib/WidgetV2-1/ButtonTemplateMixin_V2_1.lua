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

local seedID = 999

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'ButtonTemplateMixin_V2_1_1'
--- @class ButtonTemplateMixin_V2_1_1
local S = {}
local p = ns:LC().DEFAULT:NewLogger(libName)

local function NextID() seedID = seedID + 1; return seedID end

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]
--- @type ButtonTemplateMixin_V2_1_1
local o = S

--- @param self Frame
function o.OnLoad(self)
    self:SetID(NextID())

    C_Timer.After(1, function()
        p:f1(function() return 'OnLoad: %s', self:GetID() end)
    end)

    self:EnableMouse(true)
    self:SetAttribute("action", self:GetID())
    self.action = self:GetID()
end

--- @param self ButtonTemplateMixin_V2_1_1
function o.OnPostClick(self, button, down)
    p:vv(function() return 'OnPostClick[%s::%s]: button=%s, down=%s', self:GetName(), self:GetID(), button, down  end)
    self:UpdateState(button, down)
end

--- @param self ButtonTemplateMixin_V2_1_1
function o.OnAttributeChanged(self, name, val)
    p:f1(function() return 'OnAttributeChanged[%s]: name=%s, val=%s', self:GetID(), name, val  end)
    self:UpdateAction(name, val)
end

--- @param self ButtonTemplateMixin_V2_1_1
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

ABP_ButtonTemplateMixin_V2_1_1 = o
