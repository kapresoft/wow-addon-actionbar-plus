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
local function Btn_WrapScript_OnReceiveDrag(self)
    local handler = self:GetParent().handler
    handler:WrapScript(self, "OnReceiveDrag", [[
        print('xx OnReceiveDrag')
        local cursorType, a1, a2, a3 = ...
        if cursorType ~= "spell" then return end
        local spellID = a3 or a1
        if not spellID then return end
        local oldSpellID = self:GetAttribute("spell2_id")
        print('OnReceiveDrag::Args type=', cursorType, 'spID=', spellID, 'oldSP=', oldSpellID)
        
        self:SetAttribute("spell2_id", spellID)
        self:SetAttribute("spell2", spellID)
        self:SetAttribute("type2", "spell")
        
        if oldSpellID then
            return 'clear', 'spell', oldSpellID
        else
            return 'clear'
        end
    ]])
end


--- @param self ABP_Button_2_0_1_1
local function Btn_WrapScript_OnDragStart(self)
    local handler = self:GetParent().handler
    handler:WrapScript(self, "OnDragStart", [[
        local spellID = self:GetAttribute("spell2_id")
        if not spellID then return end
        print('xxr OnDragStart: spID=', spellID)

        -- Clear this button's action
        self:SetAttribute("spell2_id", nil)
        self:SetAttribute("spell2", nil)
        self:SetAttribute("type2", nil)
        return 'clear', 'spell', spellID
    ]])
end

--- @param self ABP_Button_2_0_1_1
local function Btn_WrapScript_OnClick(self)
    local handler = self:GetParent().handler
        handler:WrapScript(self, "OnClick", [[
            -- parameters are: self, button, down
            if down then return end  -- only act on mouse up
            print('xx OnClick... btn=', button, 'kind=', kind)
            local kind, a1, a2, a3 = GetCursorInfo()
            if kind ~= "spell" then return end
            -- perform drop logic
            return false
        ]])
end

function o:OnLoad()
    self:SetID(NextID())
    
    --self:SetAttribute("action", self:GetID())
    self.action = self:GetID()
    self:EnableMouse(true)
    self:GetNormalTexture():SetDrawLayer("BACKGROUND", 0)
    
    --self:SetAttribute("checkselfcast", true);
    --self:SetAttribute("checkfocuscast", true);
    --self:SetAttribute("checkmouseovercast", true);
    self:RegisterForDrag("LeftButton", "RightButton");
    self:RegisterForClicks("AnyDown", "AnyUp");
    
    Btn_WrapScript_OnDragStart(self)
    Btn_WrapScript_OnReceiveDrag(self)
    
    if self:GetID() == 1000 then
        self:InitButton1000()
    elseif self:GetID() == 1001 then
        self:InitButton1001()
    end
end

function o:XXXOnReceiveDrag(...)
    p('OnReceiveDrag... args=', {...})
end

function o:InitButton1000()
    local GetSpellInfo = GetSpellInfo or C_Spell.GetSpellInfo
    --/dump GetSpellInfo('mend pet') 136
    --/dump GetSpellInfo("Hunter's Mark") 1130
    --/dump GetSpellInfo('Aspect of the iron hawk') -- 109260
    --/dump GetSpellInfo('Aspect of the pack') -- 13159
    local c = ns:cns().O.Compat
    local holyLight = c:GetSpellInfo('holy light(rank 1)')
    self:SetAttribute('ABP_2_0_spellName1', holyLight.name)
    --self:SetAttribute('ABP_2_0_spellName2', arcaneInt)
    self.icon:SetTexture(holyLight.iconID)
    self:SetAttribute("type1", nil)        -- Left click does nothing
    self:SetAttribute('type2', 'spell')
    self:SetAttribute('spell2', holyLight.name)
    self:SetAttribute('spell2_id', holyLight.spellID)
    self:SetAttribute('spell2_icon', holyLight.icon)
end

function o:InitButton1001()
    local spName = 'seal of the crusader'
    local sp = c:GetSpellInfo(spName)
    self.icon:SetTexture(sp.iconID)
    self:SetAttribute("type1", nil) -- Left click does nothing
    self:SetAttribute('type2', 'spell')
    self:SetAttribute('spell2', sp.name)
    self:SetAttribute('spell2_id', sp.spellID)
    self:SetAttribute('spell2_icon', sp.icon)
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

