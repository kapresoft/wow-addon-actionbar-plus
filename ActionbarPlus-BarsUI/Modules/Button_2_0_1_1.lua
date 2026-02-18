--[[-----------------------------------------------------------------------------
@see BarFrame.xml
@see also ActionBarPlusButtonTemplate.xml

Enable by:
<Script file="Button_2_0_1_1.lua"/>
<CheckButton name="ABP_ButtonTemplate_2_0_1_1"
             inherits="SecureActionButtonTemplate, ABP_ButtonTemplate_2_0"
             mixin="ABP_ButtonMixin_2_0_1_1" virtual="true">
    <Scripts>
        <OnLoad method="OnLoad"/>
        <PostClick method="PostClick"/>
        <OnDragStop method="OnDragStop"/>
        <OnAttributeChanged method="OnAttributeChanged"/>
    </Scripts>
</CheckButton>
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
ns.buttonTemplate = 'ABP_ButtonTemplate_2_0_1_1'

--- @type Compat_ABP_2_0
local c = ns:cns().O.Compat

local seedID = 999

-- attributes are converted to lower case
local SPELL_ID_ATTR = 'abp_2_0_spellid'
local SPELL_ID_TX_ATTR = 'abp_2_0_tx_spellid'

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
local S = ns:cns():NewAceEvent(); ABP_ButtonMixin_2_0_1_1 = S

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
prev:SetAttribute('abp_2_0_spellid_name', SPELL_ID_ATTR)
prev:SetAttribute('abp_2_0_tx_spellid_name', SPELL_ID_TX_ATTR)

--- @param self ABP_Button_2_0_1_1
local function Btn_WrapScript_OnDragStart(self)
    local handler = self:GetParent().handler
    handler:WrapScript(self, "OnDragStart", [[
        --print('OnDragS...')
        local modifiedClick = IsModifiedClick("PICKUPACTION")
        if not modifiedClick then return end
        print('OnDragS:: xx modifiedClick=', modifiedClick)

        local spellID = self:GetAttribute("spell")
        if modifiedClick then
            spellID = self:GetAttribute('abp_drag_spellid')
        end
        print('OnDragS:: modifiedClick=', modifiedClick, 'spellID=', spellID)
        if not spellID then return 'clear' end

        -- Clear this button's action
        self:SetAttribute("type", nil)
        self:SetAttribute("spell", nil)
        self:SetAttribute("abp_2_0_spellid", nil)
        return 'clear', 'spell', spellID
    ]])
end

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
        if not spellID then return 'clear' end
        self:SetAttribute('abp_2_0_start_drag_spell', nil)
        
        --if cursorType ~= "spell" and type(spellID) ~= 'number' then return end
        --print('ORDrag:: spid=', spellID)
        --local prevSpellID = self:GetAttribute("abp_2_0_spellid")
        --local prevSpell = self:GetAttribute("spell")
        --local prevType = self:GetAttribute("type")
        
        -- overwrite B immediately
        self:SetAttribute("type", "spell")
        self:SetAttribute("spell", spellID)
        
        print('ORDrag:: spid=', spellID)
        return 'clear'
        --self:SetAttribute("abp_2_0_spellid", spellID)
        --prev:SetAttribute("abp_2_0_tx_spellid", prevSpell)
        --print('abp_2_0_tx_spellid:', prevSpell)
        --if prevSpellID then
        --    return 'clear', 'spell', prevSpellID
        --else
        --    return 'clear'
        --end
    ]])
end

--- @param self ABP_Button_2_0_1_1
local function Btn_WrapScript_PreClick(self)
    local handler = self:GetParent().handler
    SecureHandlerSetFrameRef(self, "prev", prev)
    handler:WrapScript(self, "PreClick", [[
        if not down then
            self:SetAttribute('abp_2_0_start_drag_spell', nil)
            return
        end
        local modifiedClick = IsModifiedClick("PICKUPACTION")
        local current = self:GetAttribute("spell")
        if not modifiedClick then return end

        print('PreClick:: xx no op, spell=', current)
        self:SetAttribute("abp_drag_spellid", current)
        self:SetAttribute("abp_2_0_start_drag_spell", current)
        --self:SetAttribute("spell", nil)
    ]])
end

--- @param self ABP_Button_2_0_1_1
local function Btn_WrapScript_PreClickXXXOLD(self)
    local handler = self:GetParent().handler
    SecureHandlerSetFrameRef(self, "prev", prev)
    handler:WrapScript(self, "PreClick", [[
        --if not down then return end
        --local modifiedClick = IsModifiedClick("PICKUPACTION")
        --local current = self:GetAttribute("spell")
        --
        --if down and modifiedClick then
        --    print('PreClick:: xx no op, spell=', current)
        --    self:SetAttribute("abp_drag_spellid", current)
        --    self:SetAttribute("abp_2_0_start_dragging", true)
        --    self:SetAttribute("spell", nil)
        --    return false
        --end
        --
        --local prev = self:GetFrameRef("prev")
        ----local spellIDAttr = self:GetAttribute('abp_2_0_spellid_name')
        ----print('PreClick:: spellIDAttr=', spellIDAttr)
        --local txSpell = prev:GetAttribute("abp_2_0_tx_spellid")
        --
        ---- no transaction
        --if not txSpell then return end
        --
        --print('PreClick:: current=', current, 'txSpell=', txSpell)
        ---- Always consume the transaction on first ABP click
        --prev:SetAttribute("abp_2_0_tx_spellid", nil)
        --
        --if not current then
        --    -- empty target → place
        --    self:SetAttribute("type", "spell")
        --    self:SetAttribute("spell", txSpell)
        --    self:SetAttribute("abp_2_0_spellid", txSpell)
        --    self:SetAttribute("abp_2_0_not_current", true)
        --    print('xx not current:: txSpell=', txSpell)
        --else
        --    -- occupied target → swap
        --    self:SetAttribute("type", "spell")
        --    self:SetAttribute("spell", current)
        --    self:SetAttribute("abp_2_0_spellid", nil)
        --
        --    -- continue transaction internally
        --    prev:SetAttribute("abp_2_0_tx_spellid", current)
        --    print('xx current')
        --end
    ]])
end

--- @param self ABP_Button_2_0_1_1
local function Btn_WrapScript_OnClick(self)
    local handler = self:GetParent().handler
    SecureHandlerSetFrameRef(self, "prev", prev)
    handler:WrapScript(self, "OnClick", [[
        --print('OnC: down=', down)
        if not down then
            self:SetAttribute('abp_2_0_start_drag_spell', nil)
            return
        end
        
        if self:GetAttribute("abp_2_0_start_drag_spell") then
            print('OnC: abp_2_0_start_drag_spell')
            return false
        end
        
    ]])
end

local function Btn_WrapScript_OnClickXXXOLD(self)
    local handler = self:GetParent().handler
    SecureHandlerSetFrameRef(self, "prev", prev)
    handler:WrapScript(self, "OnClick", [[
        if not down then return end
        
        --if self:GetAttribute("abp_2_0_start_dragging") then
        --    return false
        --end
        
        --local type = self:GetAttribute("type")
        --local spell = self:GetAttribute("spell")
        --local modifiedClick = IsModifiedClick("PICKUPACTION")
        --print('OnClick:: modifiedClick=', modifiedClick, 'down=', down, 'spell=', spell)
        --
        ----if not modifiedClick then
        --    --local txSpellId = self:GetAttribute('abp_2_0_tx_spellid')
        --    --print('OnClick:: txSpellId=', txSpellId)
        --    local notCurrent = self:GetAttribute('abp_2_0_not_current')
        --    if notCurrent then
        --        print('OnClick:: not current.')
        --        --self:SetAttribute("spell", txSpellId)
        --        self:SetAttribute('abp_2_0_not_current', nil)
        --        return false
        --    end
        --end
        
        --local prev = self:GetFrameRef('prev')
        --print('OnClick::xx  type=', type, 'spell=', spell)
        --
        --if modifiedClick then
        --    --print('OnClick::in-down  type=', type, 'spell=', spell)
        --    self:SetAttribute("type", nil)
        --    self:SetAttribute("spell", nil)
        --    prev:SetAttribute("abp_onclick_type", type)
        --    prev:SetAttribute("abp_onclick_spellid", spell)
        --    self:SetAttribute("abp_drag_type", type)
        --    self:SetAttribute("abp_drag_spellid", spell)
        --
        --    --print('OnClick::after-down  type=', type, 'spell=', spell)
        --    return false
        --end
        --
        --if not spell then
        --    type = prev:GetAttribute('abp_onclick_type')
        --    spell = prev:GetAttribute('abp_onclick_spellid')
        --end
        --print('OnClick(up):: type=', type, 'spell=', spell)
        --self:SetAttribute("type", type)
        --self:SetAttribute("spell", spell)
        --self:SetAttribute("abp_drag_type", nil)
        --self:SetAttribute("abp_drag_spellid", nil)
        
    ]])
end

--- @param self ABP_Button_2_0_1_1
local function Btn_WrapScript_PostClick(self)
    local handler = self:GetParent().handler
    SecureHandlerSetFrameRef(self, "prev", prev)
    handler:WrapScript(self, "PostClick", [[
        print('PostC:: called...down=', down)
        local prev = self:GetFrameRef("prev")
        --prev:SetAttribute("abp_2_0_tx_spellid", nil)
    ]])
end



-- /dump SetCVar('ActionButtonUseKeyDown', 1)
function o:OnLoad()
    self:SetID(NextID())
    
    --self:SetAttribute("action", self:GetID())
    self.action = self:GetID()
    self:EnableMouse(true)
    self:GetNormalTexture():SetDrawLayer("BACKGROUND", 0)
    
    self:SetAttribute("checkselfcast", true);
    self:SetAttribute("checkfocuscast", true);
    self:SetAttribute("checkmouseovercast", true);
    
    self:RegisterForDrag("LeftButton", "RightButton");
    self:RegisterForClicks('AnyDown', 'AnyUp');
    
    self:RegisterMessage('ABP_2_0::SPELLS_CHANGED', 'OnSpellsChanged')
    
    RegisterStateDriver(self, "abp_shift", "[mod:shift] shift; [mod:ctrl] ctrl; [mod:alt] alt; none")
    Btn_WrapScript_OnDragStart(self)
    Btn_WrapScript_OnReceiveDrag(self)
    Btn_WrapScript_PreClick(self)
    Btn_WrapScript_OnClick(self)
    --Btn_WrapScript_PostClick(self)
    
    
    
end

function o:OnSpellsChanged()
    C_Timer.After(0.2, function()
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

--- @param self ABP_Button_2_0_1_1
--- @param spell SpellIdentifier
local function Btn_SetSpell(self, spell)
    local sp = c:GetSpellInfo(spell)
    if not sp then return end
    
    self.icon:SetTexture(sp.iconID)
    self:SetAttribute('type', 'spell')
    self:SetAttribute('spell', sp.spellID)
    self:SetAttribute(SPELL_ID_ATTR, sp.spellID)
    self:SetAttribute(SPELL_ID_TX_ATTR, sp.name)
end

--/dump GetSpellInfo('mend pet') 136
--/dump GetSpellInfo("Hunter's Mark") 1130
--/dump GetSpellInfo('Aspect of the iron hawk') -- 109260
--/dump GetSpellInfo('Aspect of the pack') -- 13159
function o:InitButton1000()
    local spName = 'holy light(rank 1)'
    if ns:cns():IsMainLine() then spName = 'flash of light' end
    Btn_SetSpell(self, spName)
end

function o:InitButton1001()
    local spName = 'seal of the crusader'
    if ns:cns():IsMainLine() then spName = 'Judgment' end
    Btn_SetSpell(self, spName)
end

function o:PostClick(button, down)
    --p(('OnPostClick[%s::%s]: button=%s, down=%s'):format(self:GetName(), self:GetID(), button, tostring(down)))
    self:UpdateState(button, down)
end

function o:OnAttributeChanged(name, val)
    --p(('OnAttributeChanged[%s]: name=%s, val=%s'):format(self:GetID(), tostring(name), tostring(val)))
    self:UpdateAction(name, val)
end

--function o:OnEvent(event, ...)
--    local args = { ... }
--    p(('OnEvent[%s::%s]: name=%s, val=%s'):format(self:GetName(), self:GetID(), event, pf(args)))
--end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param button ButtonName
function o:UpdateState(button, down)
    self:SetChecked(false)
end

function o:UpdateAction(name, val)
    --p('UpdateAction:: attr name=', name, 'val=', val)
    --if name ~= SPELL_ID_ATTR then return end
    if name ~= 'spell' then return end
    if not val then
        self.icon:SetTexture(nil)
        return
    end
    
    local info = c:GetSpellInfo(val)
    if not info and not info.iconID then return end
    ClearCursor()
    -- Retail vs Classic safe
    self.icon:SetTexture(info.iconID)
end

