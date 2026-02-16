--[[-----------------------------------------------------------------------------
@see ActionBarPlusButtonTemplate.xml
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
--- @type Compat_ABP_2_0
local c = ns:cns().O.Compat

local seedID = 999

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @alias ABP_Button_2_0_1_1 ABP_ButtonMixin_2_0_1_1 | SecureCheckButtonObj |
--
--
local libName = 'ABP_ButtonMixin_2_0_1_1'
--- @class ABP_ButtonMixin_2_0_1_1
--- @field icon TextureObj
--- @field GetParent fun(self:ABP_ButtonMixin_2_0_1_1) : ABP_BarFrameObj_2_0
local S = {}; ABP_ButtonMixin_2_0_1_1 = S
local p = ns:log(libName)

local function NextID() seedID = seedID + 1; return seedID end

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]
--- @type ABP_ButtonMixin_2_0_1_1 | ABP_Button_2_0_1_1
local o = S

--- @param self ABP_Button_2_0_1_1
local function Btn_WrapScript(self)
    local handler = self:GetParent().handler
    handler:WrapScript(self, "OnReceiveDrag", [[
        local cursorType, spellID = ...
        local oldSpellID = self:GetAttribute("spell2_id")
        print('xxr OnReceiveDrag: GetCursorInfo=', cursorType, 'spID=', spellID, 'oldSP=', oldSpellID)
        -- assign dropped spell
        self:SetAttribute("spell2_id", spellID)
        self:SetAttribute("spell2", spellID)
        self:SetAttribute("type2", "spell")
        
        if oldSpellID then
            return "clear", "spell", oldSpellID
        else
            return "clear"
        end
    ]])
end

function o:OnLoad()
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
    --self:RegisterForClicks("AnyUp", "LeftButtonUp", "RightButtonUp");
    
    --local header = CreateFrame("Frame", nil, UIParent, "SecureHandlerBaseTemplate")
    --self:SetParent(header)
    
    if self:GetID() == 1000 then
        self:InitButton1000()
    elseif self:GetID() == 1001 then
        self:InitButton1001()
    end
    if self:GetID() <= 1001 then return end
    
    Btn_WrapScript(self)
    
end

function o:InitButton1000()
    local handler = self:GetParent().handler
    
    --self:SetScript('OnDragStart', function(btn)
    --    local spid = btn:GetAttribute('spell2_id')
    --    p('xx ondragstart:', spid)
    --    PickupSpell(spid)
    --end)
    -- Wrap drag securely
    
    handler:WrapScript(self, "OnDragStart", [[
        print('xx OnDragStart...btnId=', self:GetID())
        return "spell", self:GetAttribute("spell2_id")
    ]])
    -- Same as
    --SecureHandlerWrapScript(self, "OnDragStart", header, [[
    --    print('xx OnDragStart...btnId=', self:GetID())
    --    return "spell", self:GetAttribute("spell2_id")
    --]])
    ---@param btn ABP_Button_2_0_1_1
    self:SetScript('OnDragStop', function(btn)
        p('xx OnDragStop: btnId=', btn:GetID())
    end)
    
    
    ------
    --print('header:', header)
    --print('proxy:', proxy)
    --SecureHandlerSetFrameRef(self, "proxy", proxy)
    
    local GetSpellInfo = GetSpellInfo or C_Spell.GetSpellInfo
    --/dump GetSpellInfo('mend pet') 136
    --/dump GetSpellInfo("Hunter's Mark") 1130
    --/dump GetSpellInfo('Aspect of the iron hawk') -- 109260
    --/dump GetSpellInfo('Aspect of the pack') -- 13159
    local c = ns:cns().O.Compat
    local holyLight = c:GetSpellInfo('holy light(rank 1)')
    local arcaneInt = GetSpellInfo('arcane intellect(rank 1)')
    local conjureWater = GetSpellInfo('conjure water')
    local mendPet = GetSpellInfo(136)
    local ironHawk = GetSpellInfo(109260)
    local huntersMark = GetSpellInfo(1130)
    if ns:cns():IsMainLine() then
        mendPet = mendPet.name
        huntersMark = huntersMark.name
    end
    p('mendPet:', mendPet)
    self:SetAttribute('ABP_2_0_spellName1', holyLight.name)
    --self:SetAttribute('ABP_2_0_spellName2', arcaneInt)
    self.icon:SetTexture(holyLight.iconID)
    self:SetAttribute("type1", nil)        -- Left click does nothing
    self:SetAttribute('type2', 'spell')
    self:SetAttribute('spell2', holyLight.name)
    self:SetAttribute('spell2_id', holyLight.spellID)
    self:SetAttribute('spell2_icon', holyLight.icon)
    
    --handler:WrapScript(self, "OnReceiveDrag", [[
    --    local cursorType, spellID = ...
    --    local oldSpellID = self:GetAttribute("spell2_id")
    --    print('xx OnReceiveDrag: GetCursorInfo=', cursorType, 'spID=', spellID, 'oldSP=', oldSpellID)
    --    return "spell", oldSpellID
    --]])
    Btn_WrapScript(self)
    
end

function o:InitButton1001()
    local handler = self:GetParent().handler
    
    local spName = 'seal of the crusader'
    local sp = c:GetSpellInfo(spName)
    
    handler:WrapScript(self, "OnDragStart", [[
        print('xx OnDragStart...btnId=', self:GetID())
        return "spell", self:GetAttribute("spell2_id")
    ]])
    ---@param btn ABP_Button_2_0_1_1
    self:SetScript('OnDragStop', function(btn)
        p('xx OnDragStop: btnId=', btn:GetID())
    end)
    
    self.icon:SetTexture(sp.iconID)
    self:SetAttribute("type1", nil) -- Left click does nothing
    self:SetAttribute('type2', 'spell')
    self:SetAttribute('spell2', sp.name)
    self:SetAttribute('spell2_id', sp.spellID)
    self:SetAttribute('spell2_icon', sp.icon)
    
    --handler:WrapScript(self, "OnReceiveDrag", [[
    --    local cursorType, spellID = ...
    --    local oldSpellID = self:GetAttribute("spell2_id")
    --    print('xx OnReceiveDrag: GetCursorInfo=', cursorType, 'spID=', spellID, 'oldSP=', oldSpellID)
    --    return "spell", oldSpellID
    --]])
    Btn_WrapScript(self)
    
end

function o:OnPostClick(button, down)
    --p(('OnPostClick[%s::%s]: button=%s, down=%s'):format(self:GetName(), self:GetID(), button, tostring(down)))
    self:UpdateState(button, down)
end

function o:OnAttributeChanged(name, val)
    --p(('OnAttributeChanged[%s]: name=%s, val=%s'):format(self:GetID(), tostring(name), tostring(val)))
    self:UpdateAction(name, val)
end

function o:OnEvent(event, ...)
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
    --p('UpdateAction:: called...')
    -- empty for now
    if name ~= "spell2_id" then return end
    if not val then
        self.icon:SetTexture(nil)
        return
    end
    
    local info = c:GetSpellInfo(val)
    if not info and not info.iconID then return end
    
    -- Retail vs Classic safe
    self.icon:SetTexture(info.iconID)
end

