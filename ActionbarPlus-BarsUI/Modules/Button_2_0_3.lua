--[[-----------------------------------------------------------------------------
@see BarFrame.xml
@see also Blizzard_FrameXML/Classic/SecureTemplates.xml#SecureActionButtonTemplate

Enable by:
<Script file="Button_2_0_3.lua"/>
<CheckButton name="ABP_ButtonTemplate_2_0_3"
             inherits="SecureActionButtonTemplate, ABP_ButtonTemplate_2_0"
             mixin="ABP_ButtonMixin_2_0_3" virtual="true">
    <Scripts>
        <OnLoad method="OnLoad"/>
    </Scripts>
</CheckButton>
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
ns.buttonTemplate = 'ABP_ButtonTemplate_2_0_3'

--- @type Compat_ABP_2_0
local c = ns:cns().O.Compat

local seedID = 1000

-- attributes are converted to lower case
local SPELL_ID_ATTR = 'abp_2_0_spellid'
local SPELL_ID_TX_ATTR = 'abp_2_0_tx_spellid'

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @alias ABP_Button_2_0_3 ABP_ButtonMixin_2_0_3 | SecureCheckButtonObj | AceEvent_3_0
--
--
local libName = 'ABP_ButtonMixin_2_0_3'
--- @class ABP_ButtonMixin_2_0_3
--- @field __name Name The debug name
--- @field icon TextureObj
--- @field GetParent fun(self:ABP_ButtonMixin_2_0_3) : ABP_BarFrameObj_2_0
local S = ns:cns():NewAceEvent(); ABP_ButtonMixin_2_0_3 = S
local p, pd, t, tf = ns:log(libName)

local function NextSeedID() local current = seedID; seedID = seedID + 1; return current end
--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
local function Btn_IsDragAllowed()
    return not Settings.GetValue("lockActionBars") or IsModifiedClick("PICKUPACTION")
end

--- @param self ABP_Button_2_0_3
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

--- @param self ABP_Button_2_0_3
local function Btn_PickupAction(self)
    local type = self:GetAttributeType()
    if self:IsSpellType() then
        local spell = self:GetAttributeSpell()
        p('xx type spell:', spell)
        self:ClearAttributeType()
        self:ClearAttributeSpell()
        c:PickupSpell(spell)
    end
end

--- Update btn checked state
--- @param self ABP_Button_2_0_3
local function Btn_UpdateState(self)
    self:SetChecked(false)
end

--- @param self ABP_Button_2_0_3
local function Btn_UpdateFlash(self)

end

--- @param self ABP_Button_2_0_3
--- @param button ButtonName
local function Btn_OnDragStart(self, button)
    p('Btn_OnDragStart:', self.__name, 'btn:', button)
    if not Btn_IsDragAllowed() then return end
    Btn_PickupAction(self)
    Btn_UpdateState(self)
    Btn_UpdateFlash(self)
end

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]
--- @type ABP_ButtonMixin_2_0_3 | ABP_Button_2_0_3
local o = S


-- /dump SetCVar('ActionButtonUseKeyDown', 1)
function o:OnLoad()
    self:SetID(NextSeedID())
    self.__name = ('%s:%s)'):format(self:GetName(), self:GetID())
    
    self:EnableMouse(true)
    self:GetNormalTexture():SetDrawLayer("BACKGROUND", 0)
    
    self:SetAttribute("checkselfcast", true);
    self:SetAttribute("checkfocuscast", true);
    self:SetAttribute("checkmouseovercast", true);
    
    self:RegisterForDrag("LeftButton", "RightButton");
    self:RegisterForClicks('AnyDown', 'AnyUp');
    self:SetScript("OnDragStart", Btn_OnDragStart)
    
    self:RegisterMessage('ABP_2_0::SPELLS_CHANGED', 'OnSpellsChanged')
    --self:RegisterEvent('MODIFIER_STATE_CHANGED')
    --self:RegisterEvent("CVAR_UPDATE")
end

--- @param event '"CVAR_UPDATE"'
--- @param cvarName string
--- @param value string
function o:CVAR_UPDATE(event, cvarName, value)
    p(("CVAR_UPDATE cvar=%s value=%s"):format(cvarName, value))
    if cvarName ~= "ActionButtonUseKeyDown" then return end
    
    -- value is "1" or "0"
    local useKeyDown = value == "1"
    
    p(("ActionButtonUseKeyDown value=%s, changed=%s"):format(value, tostring(useKeyDown)))
    
    --if useKeyDown then
    --    self:RegisterForClicks("AnyDown")
    --else
    --    self:RegisterForClicks("AnyUp")
    --end
end

--- @param event '"MODIFIER_STATE_CHANGED"'
--- @param key string "LALT" | "RALT" | "LSHIFT" | "RSHIFT" | "LCTRL" | "RCTRL"
--- @param state number @Values are 1 = pressed, 0 = released
function o:MODIFIER_STATE_CHANGED(event, key, state)
    p(('MSC... key=%s, state=%s'):format(key, state))
    local varn = 'ActionButtonUseKeyDown'
    if state == 1 and Btn_IsDragAllowed() then
        -- /dump GetCVar('ActionButtonUseKeyDown')
        -- /dump SetCVar('ActionButtonUseKeyDown', 0)
        --p('MSC:: drag allowed... state=', state, 'key=', key)
        self:RegisterForClicks('AnyUp');
        --SetCVar(varn, 0)
        p('MSC:: state=1 cvar updated; useKeyD=', GetCVarBool(varn))
    elseif state == 0 then
        self:RegisterForClicks('AnyDown');
--        SetCVar(varn, 1)
        p('MSC:: state=0 cvar updated; useKeyD=', GetCVarBool(varn))
    end
end

--- @param button ButtonName
--- @param down ButtonDown
function o:PreClick(button, down)
    --p(('PreClick[%s]: button=%s, down=%s'):format(self.__name, button, tostring(down)))
    if down == true and Btn_IsDragAllowed() then
        -- prevent spell from firing
        p('PreClick...type disabled')
        self:DisableAttributeType()
    else
        p('PreClick...type restored')
        self:RestoreAttributeType()
    end
    
    self:UpdateState(button, down)
end

function o:PostClick(button, down)
    --p(('PostClick[%s]: button=%s, down=%s'):format(self.__name, button, tostring(down)))
    self:UpdateState(button, down)
end

--- Add temporary spells for testing
function o:OnSpellsChanged()
    local tmpBtnSpells = {
        [1000] = 'holy light(rank 1)',
        [1001] = 'seal of the crusader',
        --[1002] = 'seal of righteousness',
        [1002] = 'jewelcrafting',
    }
    local id = self:GetID()
    local spell = tmpBtnSpells[id]
    if not spell then return end
    
    Btn_SetSpell(self, spell)
end

function o:OnDragStop()
    p('xx OnDragStop...')
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

--[[-------------------------------------------------------------------
Convenience Methods
---------------------------------------------------------------------]]
local type = 'type'
local saved_type = 'abp_saved_type'
local spell = 'spell'
function o:GetAttributeType() return self:GetAttribute(type) end
function o:GetAttributeSpell() return self:GetAttribute(spell) end
function o:ClearAttributeType() self:SetAttribute(type, nil) end
function o:ClearAttributeSpell() self:SetAttribute(spell, nil) end
function o:DisableAttributeType()
    if not self:GetAttributeSavedType() then
        self:SetAttribute(saved_type, self:GetAttributeType())
    end
    self:ClearAttributeType()
end
function o:GetAttributeSavedType() return self:GetAttribute(saved_type) end
function o:RestoreAttributeType()
    if not self:GetAttributeSavedType() then return end
    self:SetAttribute(type, self:GetAttribute(saved_type))
end

function o:IsSpellType()
    return self:GetAttributeType() == spell
            or self:GetAttributeSavedType() == spell
end
