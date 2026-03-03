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
local comp = cns.O.Compat
local unit, dru = cns.O.UnitUtil, cns.O.DruidUtil
local Str_IsAnyOf = cns.Str_IsAnyOf

--- @type ABP_ButtonStateMixin_2_0_3
local buttonState = ns.__ButtonState;
ns.__ButtonState = nil

local seedID = 1000
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @alias ABP_Button_2_0_3 ABP_ButtonMixin_2_0_3 | SecureCheckButtonObj | AceEvent_3_0
--- @alias ABP_Button_2_X ABP_Button_2_0_3 @Use this externally so we don't have to rename if we use a different button
--
--
--- @class ABP_ButtonMixin_IconFrame_2_0_3
--- @field icon TextureObj
--
local libName = 'ABP_ButtonMixin_2_0_3'
--- @class ABP_ButtonMixin_2_0_3
--- @field __name Name The debug name
--- @field icon TextureObj
--- @field cooldown CooldownObj
--- @field eventsRegistered boolean
--- @field GetParent fun(self:ABP_ButtonMixin_2_0_3) : ABP_BarFrameObj_2_0
local S = cns:NewAceEvent();
ABP_ButtonMixin_2_0_3 = S
local p, pd, t, tf = ns:log(libName)

local spellType, itemType, equipmentsetType = 'spell', 'item', 'equipmentset'

local actionType = 'type'
local player = 'player'

local c = {
  type = 'type',
  saved_type = 'abp_saved_type',
}

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
local function Btn_PickupAction(self)
  local type = self:GetAttributeType()
  if self:IsSpellType() then
    local spell = self:GetAttributeSpell()
    self:ClearAttributeType()
    self:ClearAttributeSpell()
    comp:PickupSpell(spell)
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
  self.__name = ('%s:%s'):format(self:GetName(), self:GetID())
  
  self:EnableMouse(true)
  self:GetNormalTexture():SetDrawLayer("BACKGROUND", 0)
  self.icon:AddMaskTexture(self.IconMask)
  
  self:SetAttribute("checkselfcast", true);
  self:SetAttribute("checkfocuscast", true);
  self:SetAttribute("checkmouseovercast", true);
  
  self:RegisterForDrag("LeftButton", "RightButton");
  self:RegisterForClicks('AnyDown', 'AnyUp');
  --self:RegisterMessage('ABP_2_0::PLAYER_ENTERING_WORLD', 'OnInit')
  --Btn_RegisterCallbacks(self)
  
  --local function RegisterWorldEventsFrame()
  --
  --end
  
  WorldEventsFrame_ABP_2_0:RegisterFrame(self)
end

--- Still needs to be wired
--- @see BarFrame.xml#ButtonUpdateFrame_ABP_2_0
--- @see ButtonUpdateFrame_ABP_2_0#OnUpdate()
--- @param elapsed number
function o:OnUpdate(elapsed)
  self:p('xxx OnUpdate')
  -- tbd
end

--- Handles spellcast lifecycle events routed from ActionEventsFrame_ABP_2_0.
--- Unchecks the button when the active spell cast finishes.
---
--- @param evt string Blizzard event name
--- @param ... any Event payload (unit, castGUID, spellID, etc.)
function o:OnEvent(evt, ...)
  if evt == 'PLAYER_ENTERING_WORLD' then
    local isInitialLogin, isReloadingUi = ...
    self:OnInit(evt, isInitialLogin, isReloadingUi)
    self:UpdateTexture()
  elseif evt == 'UPDATE_SHAPESHIFT_FORM' or evt == 'UPDATE_STEALTH' then
    self:UpdateTexture()
  elseif evt == 'UNIT_SPELLCAST_STOP' or evt == 'UNIT_SPELLCAST_SUCCEEDED' then
    self:SetChecked(false)
  elseif evt == 'LOSS_OF_CONTROL_UPDATE' then
    self:UpdateCooldown()
  elseif evt == 'SPELL_UPDATE_COOLDOWN'
          or evt == 'SPELL_UPDATE_COOLDOWN'
          or evt == 'LOSS_OF_CONTROL_ADDED' then
    self:UpdateCooldown()
    --self:p('OnEvent', 'evt=', evt)
  elseif evt == 'UNIT_AURA' then
    --self:UpdateStealthSpells()
  end
end

-- /dump GetShapeshiftFormInfo(1)
-- /dump GetSpellTexture('shadowform')
-- /dump GetSpellInfo('shadowform'), active=136200
--- Add temporary spells for testing
function o:OnInit(evt, isInitialLogin, isReloadingUi)
  --self:pd('OnInit', 'isInitialLogin=', isInitialLogin, 'isReloadingUi=', isReloadingUi)
  
  --/dump SetCVar('ActionButtonUseKeyDown', 1)
  --/dump GetCVarBool('ActionButtonUseKeyDown')
  if not GetCVarBool('ActionButtonUseKeyDown') then
    SetCVar('ActionButtonUseKeyDown', 1)
    p('ActionButtonUseKeyDown=', GetCVarBool('ActionButtonUseKeyDown'))
  end
  if InCombatLockdown() then return end
  
  ABP_ButtonTestData:AddTestData(isInitialLogin, self)
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
  self:UpdateState()
  self:UpdateCooldown()
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
      self:__SetSpell(spell.spellID)
      --local btnc = ABP_Core_2_0:c(self:GetIndex())
    end)
  end
  
  ClearCursor()
  self:UpdateState()
  -- Btn_UpdateFlash(self)
end

function o:OnAttributeChanged(name, val)
  --p(('OnAttributeChanged[%s]: name=%s, val=%s'):format(self:GetID(), tostring(name), tostring(val)))
  self:UpdateAction(name, val)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function o:Update()
  if self.__updating then return end
  self.__updating = true
  --if self.__updating then self:pd('Update', 'updating=', self.__updating) end
  --p('Update(): called...')
  
  local eventsFrame = ActionEventsFrame_ABP_2_0
  local icon = self.icon
  local buttonCooldown = self.cooldown;
  
  icon:SetDesaturated(false)
  
  local type, id = self:GetActionInfo()
  if self:HasAction() then
    if ( not self.eventsRegistered ) then
      eventsFrame:RegisterFrame(self);
      self.eventsRegistered = true;
    end
    self:UpdateTexture()
    
    self:UpdateState()
    --self:UpdateUsable()
    --self:UpdateProfessionQuality()
    --self:UpdateTypeOverlay()
    --ActionButton_UpdateCooldown(self)
    self:UpdateCooldown()
    --self:UpdateFlash()
    --self:UpdateHighlightMark()
    --self:UpdateSpellHighlightMark()
  else
    if ( self.eventsRegistered ) then
      eventsFrame:UnregisterFrame(self);
      self.eventsRegistered = nil;
    end
    --self:ClearFlash()
    self:SetChecked(false);
    --self:ClearProfessionQuality();
    --self:ClearTypeOverlay();
  end
  
  self.__updating = false
end

function o:UpdateAction(name, val)
  if not val then self.icon:SetTexture(nil); return end
  if not Str_IsAnyOf(name, t.spell, t.item) then return end

  if name == t.spell then
    local info = comp:GetSpellInfo(val)
    tf('UpdateAction:: spell=', val, 'info=', info)
    if not (info and info.iconID) then return end
    ClearCursor()
    -- Retail vs Classic safe
    self.icon:SetTexture(info.iconID)
  elseif name == t.item then
    p('UpdateAction():: item needs implementation.')
  end
  
  self:Update()
end

--- [Doc::GetShapeshiftFormInfo](https://warcraft.wiki.gg/wiki/API_GetShapeshiftFormInfo)
--- @return TextureIcon
function o:GetActionTexture()
  local type, id = self:GetActionInfo()
  if not id then return end
  -- todo next: move prowl logic from UpdateStealthSpells()
  
  -- todo add rogue, priest, shammy
  -- Prowl active override
  --if type == t.spell and dru:IsDruidClass() and dru:IsProwl(id) then
  --  if dru:IsStealthActive() then
  --    self:DimIcon()
  --    return unit:GetStealthedIcon()
  --  end
  --  self:SetIconNormalVertex()
  --end
  local druid = cns.O.DruidUtil
  --self:pd('GetActionTexture', 'Unit=', unit:GetUnitClass())
  if type == t.spell then
    if unit:IsStealthActive() then
      if druid:IsProwl(id) then
        self:DimIcon()
        return unit:GetStealthedIcon()
      end
    end
    self:SetIconNormalVertex()
  end
  
  local icon
  if unit:CanShapeShift() then
    unit:IfShapeShifted(function(data)
      if data.active and id == data.spellID then
        icon = data.shapeshiftIcon
      end
    end)
  end
  if icon then return icon end
  
  comp:IfSpell(id, function(spell)
    icon = spell.iconID
    --self:p('GetActionTexture', 'sp=', spell.name)
  end)
  return icon
end

--[[-------------------------------------------------------------------
Convenience Methods
---------------------------------------------------------------------]]
function o:GetAttributeType() return self:GetAttribute(c.type) end
function o:GetAttributeSpell() return self:GetAttribute(t.spell) end
function o:ClearAttributeType() self:SetAttribute(c.type, nil) end
function o:ClearAttributeSpell() self:SetAttribute(t.spell, nil) end
function o:DisableAttributeType()
  if not self:GetAttributeSavedType() then
    self:SetAttribute(c.saved_type, self:GetAttributeType())
  end
  self:ClearAttributeType()
end
function o:GetAttributeSavedType() return self:GetAttribute(c.saved_type) end
function o:ClearAttributeSavedType()
  if not self:GetAttributeSavedType() then return end
  self:SetAttribute(c.saved_type, nil)
end
function o:RestoreAttributeType()
  if not self:GetAttributeSavedType() then return end
  self:SetAttribute(c.type, self:GetAttribute(c.saved_type))
  self:SetAttribute(c.saved_type, nil)
end

function o:IsSpellType()
  return self:GetAttributeType() == t.spell
          or self:GetAttributeSavedType() == t.spell
end

function o:MatchesActiveButtonSpellID(spellID)
  if (not spellID) then return false end
  
  local type, id = self:GetActionInfo()
  if type == "item" then
    p('MatchesActiveButtonSpellID():: needs implementation...')
  end
  return id == spellID;
end

function o:UpdateCooldown()
  --self:p('UpdateCooldown():: called...')
  local cd = self.cooldown
  if not cd then return end
  
  if not self:HasAction() then cd:Clear(); return end
  
  local actionType, id = self:GetActionInfo()
  if not id then return end
  if not actionType or not id then cd:Clear(); return end
  
  local name = ''
  local start, duration, enable, modRate = 0, 0, 0, 1
  
  if actionType == t.spell then
    name = comp:GetSpellName(id)
    local info = comp:GetSpellCooldown(id)
    --self:p('UpdateCD', 'name=', name, 'info=', tostring(info))
    if info then
      start = info.startTime or 0
      duration = info.duration or 0
      modRate = info.modRate
    end
  elseif actionType == t.item then
    start, duration, enable = GetItemCooldown(id)
  else
    cd:Clear()
    return
  end
  if not start or not duration then cd:Clear(); return end
  
  --local _enable=false
  --local ok, _valEnable = pcall(function() return enable == true end)
  --if ok then _enable = _valEnable end
  --self:p('UpdateCD', 'name=', name, 'ok=', ok, 'isEnabledVal=', _enable)
  -- not sure if we need currentCooldownType
  cd.currentCooldownType = COOLDOWN_TYPE_NORMAL
  --CooldownFrame_Set(cd, start, duration, _enable, false, modRate or 1)
  cd:SetCooldown(start, duration, modRate or 1)
end

--- @return string|nil, number|nil The type (e.g. spell, item) and resolved typeID (spellID/itemID)
function o:GetActionInfo()
  local aType = self:GetAttribute(actionType)
  if not aType then return nil end
  
  --- @type number|string|nil
  local val = self:GetAttribute(aType)
  if not val then return nil end
  
  if type(val) == "number" then return aType, val end
  
  if type(val) == "string" then
    local sp = comp:GetSpellInfo(val)
    if not sp then return nil end
    return aType, sp.spellID
  end
  
  return nil
end

--- @return boolean
function o:HasAction()
  local type = self:GetAttribute(actionType)
  if not type then return false end
  local id = self:GetAttribute(type)
  return id ~= nil
end

--- Update the button's checked state
function o:UpdateState()
  --p('UpdateState():: called...')
  local type, id = self:GetActionInfo()
  if not type or not id then return end local checked = false
  
  local current = false
  if type == t.spell then
    current = C_IsCurrentSpell(id)
    --p('btn=', self:GetID(), 'current=', current, 'spellID=', actionID)
    checked = current or C_IsAutoRepeatSpell(id);
  end
  
  local name = '';
  if type == t.spell then
    local sp = comp:GetSpellInfo(id)
    if sp then name = '[' .. sp.name .. ']' end
  end
  
  --p(('%s[%s]:: type=%s action=%s%s current=%s checked=%s')
  --        :format('UpdateSt', self:GetID(), type, id, name,
  --        tostring(current), tostring(checked)))
  self:SetChecked(checked)
end


--- @param spell SpellIdentifier
function o:__SetSpell(spell)
  local sp = comp:GetSpellInfo(spell)
  if not sp then return end
  self:SetAttribute(c.type, t.spell)
  self:SetAttribute(t.spell, sp.spellID)
  self.icon:SetTexture(sp.iconID)
  self:Update()
end

function o:p(prefix, ...)
  local a = { ... }; p(self:pid(prefix), unpack(a))
end
function o:pd(prefix, ...)
  local a = { ... }; pd(self:pid(prefix), unpack(a))
end
function o:pid(prefix) return ("%s(%s)::"):format(prefix, self.__name) end

--- @param r RGBColor
--- @param g RGBColor
--- @param b RGBColor
function o:SetIconVertex(r, g, b) self.icon:SetVertexColor(r, g, b) end
function o:SetIconNormalVertex() self:SetIconVertex(1, 1, 1) end
function o:DimIcon() self:SetIconVertex(0.5, 0.5, 0.5) end

---@param callbackFn fun(icon:Icon):void
function o:IfActionTexture(callbackFn)
  local icon = self:GetActionTexture()
  if not icon then return end
  callbackFn(icon)
end

function o:UpdateTexture()
  self:IfActionTexture(function(icon) self.icon:SetTexture(icon) end)
end
