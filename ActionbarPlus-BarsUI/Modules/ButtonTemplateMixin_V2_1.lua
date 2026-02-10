--[[-----------------------------------------------------------------------------
@see ActionBarPlusButtonTemplate.xml
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI
local ns = select(2, ...)

local seedID = 999

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'ButtonTemplateMixin_V2_1_1'
--- @class ButtonTemplateMixin_V2_1_1
local S = {}
local p = ns:log(libName)

local function NextID() seedID = seedID + 1; return seedID end

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]
--- @type ButtonTemplateMixin_V2_1_1
local o = S

--- @param self Frame
function o.OnLoad(self)
    self:SetID(NextID())

    self:SetAttribute("action", self:GetID())
    self.action = self:GetID()
    self:EnableMouse(true)
    self:GetNormalTexture():SetDrawLayer("BACKGROUND", 0)

    --self:SetAttribute("checkselfcast", true);
    --self:SetAttribute("checkfocuscast", true);
    --self:SetAttribute("checkmouseovercast", true);
    self:RegisterForDrag("LeftButton", "RightButton");
    self:RegisterForClicks("AnyDown", "LeftButtonDown", "RightButtonDown");
end

--- @param self ButtonTemplateMixin_V2_1_1
function o.OnPostClick(self, button, down)
    p(('OnPostClick[%s::%s]: button=%s, down=%s'):format(self:GetName(), self:GetID(), button, tostring(down)))
    self:UpdateState(button, down)
end

--- @param self ButtonTemplateMixin_V2_1_1
function o.OnAttributeChanged(self, name, val)
    p(('OnAttributeChanged[%s]: name=%s, val=%s'):format(self:GetID(), name, val))
    self:UpdateAction(name, val)
end

--- @param self ButtonTemplateMixin_V2_1_1
function o.OnEvent(self, event, ...)
    local args = { ... }
    p(('OnEvent[%s::%s]: name=%s, val=%s'):format(self:GetName(), self:GetID(), event, args))
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param button ButtonName
function o:UpdateState(button, down)
    self:SetChecked(false)
end

function o:UpdateAction(name, val)
    p('UpdateAction:: called...')
    -- empty for now
end

ABP_ButtonTemplateMixin_V2_1_1 = o
