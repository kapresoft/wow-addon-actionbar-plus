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
--- @alias ABP_Button_2_0_1_1 ABP_ButtonMixin_2_0_1_1 | SecureCheckButtonObj | AceEvent_3_0
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

--- we need SecureHandlerBaseTemplate for prev (previous) frame
--- @type SecureHandlerBaseTemplateObj
local prev = CreateFrame('Frame',  nil, UIParent, "SecureHandlerBaseTemplate")

--- Signature (implicit vars): self,button,kind,value
--- kind: spell, item, equipment
--- value(spell) ~ SpellBook?
--- @see FrameXML/SecureHandlers.lua#Wrapped_Drag
--- @param self ABP_Button_2_0_1_1
local function Btn_WrapScript_OnReceiveDrag(self)
    local handler = self:GetParent().handler
    SecureHandlerSetFrameRef(self, "prev", prev)
    handler:WrapScript(self, "OnReceiveDrag", [[
        local prev = self:GetFrameRef('prev')
        
        -- GetCursorInfo() return values
        cursorType, a1, a2, a3 = ...
        local spellID = a1
        if cursorType ~= "spell" and type(spellID) ~= 'number' then return end
        --print('Kind=', kind, 'spellID(arg1)=', spellID, 'args:: 1=', a1, '2=', a2, '3=', a3)
        
        local oldSpellID = self:GetAttribute("spell2_id")
        --print('OnReceiveDrag::Args type=', cursorType, 'spID=', spellID, 'oldSP=', oldSpellID)
        
        local prevSpellID = self:GetAttribute("spell2_id")
        local prevSpell = self:GetAttribute("spell2")
        local prevType = self:GetAttribute("type2")
        if prevSpellID then
            print('OnReceiveDrag::Prev type=', prevType, 'spid=', prevSpell)
            prev:SetAttribute("type2", prevType)
            prev:SetAttribute("spell2", prevSpell)
            prev:SetAttribute("spell2_id", prevSpellID)
        else
            prev:SetAttribute("type2", nil)
            prev:SetAttribute("spell2", nil)
            prev:SetAttribute("spell2_id", nil)
        end
        
        self:SetAttribute("spell2_id", spellID)
        self:SetAttribute("spell2", spellID)
        self:SetAttribute("type2", cursorType)
        prev:SetAttribute('abp_isDropComplete', true)
        
        print('OnReceiveDrag:: attr set:: t=', cursorType, 'spid=', spellID)
        if prevSpellID then
            return 'clear', 'spell', prevSpellID
        else
            return 'clear'
        end
    ]])
end

--- @param self ABP_Button_2_0_1_1
local function Btn_WrapScript_PreClick(self)
    local handler = self:GetParent().handler
    SecureHandlerSetFrameRef(self, "prev", prev)
    handler:WrapScript(self, "PreClick", [[
        local shiftDown = self:GetAttribute("state-ABP_SHIFT")
        local mouseBtnClicked = GetMouseButtonClicked()
        local children = self:GetChildren()
        print('Modifier key:', shiftDown, 'IsModifiedClick("PICKUPACTION")=', IsModifiedClick("PICKUPACTION"), 'mouseBtnClicked=', mouseBtnClicked, 'children=', children)
        
        for k, v in pairs(_G) do print("var:", k, type(v)) end
        
        if down then return end
        
        
        local prev = self:GetFrameRef('prev')
        local isDropComplete = prev:GetAttribute('abp_isDropComplete') == true
        local type = prev:GetAttribute("type2")
        local sp = prev:GetAttribute("spell2")
        local spid = prev:GetAttribute("spell2_id")
        print('PreClick:: isDropComplete=', isDropComplete)
        if isDropComplete ~= true then return end
        
        if spid then
            print('PreClick:: previous spell found; type2=', type, 'spid=', spid, 'sp=', sp)
            self:SetAttribute("spell2_id", spid)
            self:SetAttribute("spell2", sp)
            self:SetAttribute("type2", type)
        end
        prev:SetAttribute("type2", nil)
        prev:SetAttribute("spell2", nil)
        prev:SetAttribute("spell2_id", nil)
    ]])
end

--- @param self ABP_Button_2_0_1_1
local function Btn_WrapScript_OnDragStart(self)
    local handler = self:GetParent().handler
    handler:WrapScript(self, "OnDragStart", [[
        local spellID = self:GetAttribute("spell2_id")
        if not spellID then return end
        -- Clear this button's action
        self:SetAttribute("spell2_id", nil)
        self:SetAttribute("spell2", nil)
        self:SetAttribute("type2", nil)
        return 'clear', 'spell', spellID
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
    
    RegisterStateDriver(self, "ABP_SHIFT", "[mod:shift] shift; [mod:ctrl] ctrl; [mod:alt] alt; none")
    Btn_WrapScript_OnDragStart(self)
    Btn_WrapScript_OnReceiveDrag(self)
    Btn_WrapScript_PreClick(self)
    
    
    
    --ns:cns():NewAceEvent(self)
    --self:RegisterEvent('CURSOR_CHANGED', 'OnCursorChanged')
    
    -- TODO: Hook to event with SPELLS_CHANGED
    C_Timer.After(0.01, function()
        if self:GetID() == 1000 then
            self:InitButton1000()
        elseif self:GetID() == 1001 then
            self:InitButton1001()
        end
    end)
end

function o:OnDragStop()
    p('xx OnDragStop...')
end
function o:OnCursorChanged()
    --local kind = GetCursorInfo()
    --if kind then return end
    --prev:SetAttribute("abp_type2", nil)
    --prev:SetAttribute("abp_spell2", nil)
    --prev:SetAttribute("abp_spell2_id", nil)
    --print('OnCursorChanged: kind=', kind)
end

function o:InitButton1000()
    local GetSpellInfo = GetSpellInfo or C_Spell.GetSpellInfo
    --/dump GetSpellInfo('mend pet') 136
    --/dump GetSpellInfo("Hunter's Mark") 1130
    --/dump GetSpellInfo('Aspect of the iron hawk') -- 109260
    --/dump GetSpellInfo('Aspect of the pack') -- 13159
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

function o:PostClick(button, down)
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
    --p('UpdateAction:: attr name=', name, 'val=', val)
    if name ~= "spell2_id" then return end
    if not val then
        self.icon:SetTexture(nil)
        return
    end
    
    local info = c:GetSpellInfo(val)
    if not info and not info.iconID then return end
    ClearCursor()
    -- Retail vs Classic safe
    self.icon:SetTexture(info.iconID)
    
    local kind = GetCursorInfo()
    if not kind then return end
    ClearCursor()
end

