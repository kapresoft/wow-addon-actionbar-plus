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

local RegisterFrameForEvents, RegisterFrameForUnitEvents = FrameUtil.RegisterFrameForEvents, FrameUtil.RegisterFrameForUnitEvents
local C_IsAutoRepeatSpell = C_Spell and C_Spell.IsAutoRepeatSpell or IsAutoRepeatSpell
local C_IsCurrentSpell = C_Spell and C_Spell.IsCurrentSpell or IsCurrentSpell

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
ns.buttonTemplate = 'ABP_ButtonTemplate_2_0_3'
--- @type Namespace_ABP_2_0 - Core Namespace
local cns = ns:cns()
--- @type Compat_ABP_2_0
local c = cns.O.Compat
--- @type ABP_ButtonStateMixin_2_0_3
local buttonState = ns.__ButtonState;
ns.__ButtonState = nil

local seedID = 1000
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
local S = cns:NewAceEvent();
ABP_ButtonMixin_2_0_3 = S
local p, pd, t, tf = ns:log(libName)

local spellType, itemType, equipmentsetType = 'spell', 'item', 'equipmentset'

local type = 'type'
local player = 'player'

--- Supported Types
local t = {
  spell        = 'spell',
  item         = 'item',
  macro        = 'macro',
  mount        = 'mount',
  companion    = 'companion',
  battlepet    = 'battlepet',
  petaction    = 'petaction',
  equipmentset = 'equipmentset',
}

local Btn_UpdateState = buttonState.Btn_UpdateState
local Btn_OnSpellCast = buttonState.Btn_OnSpellCast
local Btn_OnTradeSkill = buttonState.Btn_OnTradeSkill
local Btn_IsDragAllowed = buttonState.Btn_IsDragAllowed
local Btn_UpdateFlash = buttonState.Btn_UpdateFlash
--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
local function NextSeedID()
  local current = seedID;
  seedID = seedID + 1;
  return current
end

--- @param unitTarget UnitID
local function IsPlayer(unitTarget) return player == unitTarget end

--- @return boolean
local function IsActionbarLockedByUser() return Settings.GetValue("lockActionBars") end

--- @param down boolean
--- @return boolean
local function ShouldFire(down)
  if IsActionbarLockedByUser() then return down == true end
  return down ~= true
end

--- @param self ABP_Button_2_0_3
--- @param spell SpellIdentifier
local function Btn_SetSpell(self, spell)
  local sp = c:GetSpellInfo(spell)
  if not sp then return end
  self:SetAttribute('type', 'spell')
  self:SetAttribute('spell', sp.spellID)
  self.icon:SetTexture(sp.iconID)
  --self:SetAttribute(type, t.spell)
  --self:SetAttribute(t.spell, sp.spellID)end
end

--- @param self ABP_Button_2_0_3
local function Btn_PickupAction(self)
  local type = self:GetAttributeType()
  if self:IsSpellType() then
    local spell = self:GetAttributeSpell()
    self:ClearAttributeType()
    self:ClearAttributeSpell()
    c:PickupSpell(spell)
  end
end

--- @param self ABP_Button_2_0_3
local function Btn_RegisterCallbacks(self)
  --self:RegisterEvent('MODIFIER_STATE_CHANGED')
  --self:RegisterEvent("CVAR_UPDATE")
  local h = function(...) Btn_OnSpellCast(self, ...) end
  self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED', h)
  self:RegisterEvent('UNIT_SPELLCAST_SENT', h)
  self:RegisterEvent('UNIT_SPELLCAST_START', h)
  self:RegisterEvent('UNIT_SPELLCAST_STOP', h)
  self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED', h)
  self:RegisterEvent('UNIT_SPELLCAST_FAILED_QUIET', h)
  
  self:RegisterEvent('TRADE_SKILL_SHOW', function() Btn_OnTradeSkill(self, true)  end)
  self:RegisterEvent('TRADE_SKILL_CLOSE', function() Btn_OnTradeSkill(self, false)  end)
  
  -- also potential: CURRENT_SPELL_CAST_CHANGED
  
  --self:RegisterEvent('CURRENT_SPELL_CAST_CHANGED', function(evt)
  --  local spid = self:GetAttribute('spell')
  --  local current = false
  --  local name
  --  if spid then
  --    local sp = c:GetSpellInfo(spid)
  --    if sp then name = sp.name end
  --    current = C_IsCurrentSpell(spid)
  --  end
  --  self:SetChecked(current)
  --  p('xx id=', self:GetID(),'evt=', evt, 'spell=', spid, 'name=', name, 'current=', current, 'is-checked:', self:GetChecked())
  --end)
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
  self:RegisterMessage('ABP_2_0::PLAYER_ENTERING_WORLD', 'OnInit')
  
  --Btn_RegisterCallbacks(self)
  
  --- @type ButtonEventsFrame_ABP_2_0
  local ABP_2_0_ButtonEventsFrame = ABP_2_0_ButtonEventsFrame
  ABP_2_0_ButtonEventsFrame:RegisterFrame(self)
end

---@param evt Name The event name
function o:OnEvent(evt, ...)
  p(('xx OnEvent[%s]...'):format(tostring(evt)))
end

-- /dump GetShapeshiftFormInfo(1)
-- /dump GetSpellTexture('shadowform')
-- /dump GetSpellInfo('shadowform'), active=136200
--- Add temporary spells for testing
function o:OnInit(evt, isInitialLogin, isReloadingUi)
  --pd('OnInit():: isInitialLogin=', isInitialLogin, 'isReloadingUi=', isReloadingUi)
  
  --/dump SetCVar('ActionButtonUseKeyDown', 1)
  --/dump GetCVarBool('ActionButtonUseKeyDown')
  if not GetCVarBool('ActionButtonUseKeyDown') then
    SetCVar('ActionButtonUseKeyDown', 1)
    p('ActionButtonUseKeyDown=', GetCVarBool('ActionButtonUseKeyDown'))
  end
  
  -- /dump C_Spell.GetSpellInfo('flash of light')
  local tmpBtnSpells = {
    [1000] = 'holy light(rank 1)',
    [1001] = 'seal of the crusader(rank 1)',
    --[1002] = 'seal of righteousness',
    [1002] = 'jewelcrafting',
  }
  if cns:IsMainLine() then
    tmpBtnSpells = {
      [1000] = 'flash of light',
      [1001] = 'sense undead',
      --[1002] = 'seal of righteousness',
      [1002] = 'jewelcrafting',
    }
  end
  
  if InCombatLockdown() then return end
  
  local id = self:GetID()
  local spell = tmpBtnSpells[id]
  if not spell then return end
  
  if isInitialLogin then
    self:RegisterEvent('SPELLS_CHANGED', function(evt)
      Btn_SetSpell(self, spell)
      pd('OnInit():: spell=', spell)
    end)
  else
    Btn_SetSpell(self, spell)
  end
  
  Btn_UpdateState(self)
end


--- @param button ButtonName
--- @param down ButtonDown
function o:PreClick(button, down)
  if InCombatLockdown() then return false end
  
  -- fires on 'up' if not locked by user
  if not IsActionbarLockedByUser() then
    return
  end
  
  if ShouldFire(down) and Btn_IsDragAllowed() then
    self:DisableAttributeType()
  end
end

--- @param button ButtonName
--- @param down ButtonDown
function o:PostClick(button, down)
  if InCombatLockdown() then return false end
  --p('PostC:: down=', down, 'GetButtonState()=', self:GetButtonState())
  
  --if not down then self:RestoreAttributeType() end
  Btn_UpdateState(self)
  -- todo move to ButtonStates#Btn_OnSpellCast
end

function o:OnEnter() self:ClearAttributeSavedType() end
function o:OnLeave()
  --p('xx OnLeave')
  self:RestoreAttributeType()
end

--- @param button ButtonName
function o:OnDragStart(button)
  p('OnDragStart...')
  if InCombatLockdown() then return false end
  if not Btn_IsDragAllowed() then return end
  Btn_PickupAction(self)
  Btn_UpdateState(self)
  Btn_UpdateFlash(self)
  self:SetChecked(false)
end

function o:OnDragStop()
  p('OnDragStop...')
  self:RestoreAttributeType()
end

function o:OnReceiveDrag()
  if InCombatLockdown() then return end
  local cursor = cns:cursor()
  if not cursor.isValid then return end
  
  if cursor.type == 'spell' then
    cursor:IfSpell(function(spell)
      p('OnReceiveDrag:: spell=', spell)
      Btn_SetSpell(self, spell.spellID)
    end)
  end
  
  ClearCursor()
  Btn_UpdateState(self)
  Btn_UpdateFlash(self)
end

function o:OnAttributeChanged(name, val)
  --p(('OnAttributeChanged[%s]: name=%s, val=%s'):format(self:GetID(), tostring(name), tostring(val)))
  self:UpdateAction(name, val)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
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
function o:ClearAttributeSavedType()
  if not self:GetAttributeSavedType() then return end
  self:SetAttribute(saved_type, nil)
end
function o:RestoreAttributeType()
  if not self:GetAttributeSavedType() then return end
  self:SetAttribute(type, self:GetAttribute(saved_type))
  self:SetAttribute(saved_type, nil)
end

function o:IsSpellType()
  return self:GetAttributeType() == spell
          or self:GetAttributeSavedType() == spell
end
