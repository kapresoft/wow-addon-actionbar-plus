--[[-----------------------------------------------------------------------------
@see BarFrame.xml
@see also Blizzard_FrameXML/Classic/SecureTemplates.xml#SecureActionButtonTemplate

Enable by:
<Script file="Button_2_0_3.lua"/>
<CheckButton name="ABP_ButtonTemplate_2_0_3"
             inherits="SecureActionButtonTemplate, ABP_ButtonTemplate_2_0"
             mixin="ButtonMixin_ABP_2_0_3" virtual="true">
    <Scripts>
        <OnLoad method="OnLoad"/>
    </Scripts>
</CheckButton>
-------------------------------------------------------------------------------]]

local IsModifiedClick = IsModifiedClick

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
ns.buttonTemplate = 'ABP_ButtonTemplate_2_0_3'
--- @type Namespace_ABP_2_0 - Core Namespace
local cns = ns:cns()
local O = cns.O
local C = O.Constants
local au = O.ActionUtil
local attr, atyp = C.AttributeNames, C.SupportedActionTypes
local comp, spu, unit = O.Compat, O.SpellUtil, O.UnitUtil
local dru, priest = O.DruidUtil, O.PriestUtil
local Str_IsAnyOf, Str_IsBlank = cns.Str_IsAnyOf, cns.Str_IsBlank
local Tbl_IsEmpty = cns.O.Table.IsEmpty

--- @type Color
local rankColor = GRAY_FONT_COLOR or CreateColor(0.502, 0.502, 0.502, 1.000)


local seedID = 1000
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @alias Button_ABP_2_0_3 ButtonMixin_ABP_2_0_3 | ButtonConfigAccessor_ABP_2_0 | SecureCheckButtonObj | AceEvent_3_0
--- @alias Button_ABP_2_0_X Button_ABP_2_0_3 @Use this externally so we don't have to rename if we use a different button
--
local libName = 'ButtonMixin_ABP_2_0_3'
--- @class ButtonMixin_ABP_2_0_3
--- @field NormalTexture TextureObj
--- @field HighlightTexture TextureObj
--- @field PushedTexture TextureObj
--- @field CheckedTexture TextureObj
--- @field ClearFlash fun():void
--- @field icon TextureObj
--- @field cooldown CooldownObj
--- @field eventsRegistered boolean
--- @field widget ButtonWidget_ABP_2_0
--- @field GetParent fun(self:ButtonMixin_ABP_2_0_3) : BarFrameObj_ABP_2_0
local S = cns:NewAceEvent(); ButtonMixin_ABP_2_0_3 = S
local p, pd, t, tf = ns:log(libName)


--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
local function NextSeedID()
  local current = seedID;
  seedID = seedID + 1;
  return current
end

--- @return boolean
local function IsActionbarLockedByUser() return Settings.GetValue("lockActionBars") end

--- @param down boolean
--- @return boolean
local function Btn_ActionShouldFire(down)
  if IsActionbarLockedByUser() then return down == true end
  return down ~= true
end

--- @param self Button_ABP_2_0_3
local function Btn_PickupAction(self)
  --- The abp_saved_type is saved during PreClick()
  --- so that the button won't fire on pickup action
  local typeVal = self.widget:GetAttributeSavedType()
  if not typeVal then return end
  if au.IsSpell(typeVal) then
    local spell = self.widget:GetAttributeSpell()
    comp:PickupSpell(spell)
  end
  self.widget:ClearAttributeType()
  self.widget:ClearAttributeSavedType()
  self.widget:ClearAttributeSpell()
end

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]
--- @type ButtonMixin_ABP_2_0_3 | Button_ABP_2_0_3 | ButtonState_ABP_2_0 | ButtonConfigAccessor_ABP_2_0
local o = S

-- /dump SetCVar('ActionButtonUseKeyDown', 1)
function o:OnLoad()
  self:SetID(NextSeedID())
  
  Mixin(self, ns.O.ButtonStateMixin, ns.O.ButtonConfigAccessorMixin)
  self:EnableMouse(true)
  self:GetNormalTexture():SetDrawLayer("BACKGROUND", 0)
  self.icon:AddMaskTexture(self.IconMask)
  
  self:SetAttribute("checkselfcast", true);
  self:SetAttribute("checkfocuscast", true);
  self:SetAttribute("checkmouseovercast", true);
  
  self:RegisterForDrag("LeftButton", "RightButton");
  self:RegisterForClicks('AnyDown', 'AnyUp');
  
  WorldEventsFrame_ABP_2_0:RegisterFrame(self)
  
  local traceChecked = false
  if traceChecked then
    if not self.__SetCheckedWrapped then
      self.__SetCheckedWrapped = true
      local orig = self.SetChecked
      self.SetChecked = function(btn, val)
        tf('Checked', val, "SetCheckedWrapped:: Button:", btn:GetName(), 'debugstack=', debugstack(2, 5, 5))
        --tf(debugstack(2, 5, 5))
        return orig(btn, val)
      end
    end
  end
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
    self:UpdateState()
  elseif evt == 'ACTIONBAR_UPDATE_STATE' then
    self:UpdateState()
    self:RepairRetailPushedState()
  elseif evt == 'UPDATE_SHAPESHIFT_FORM' or evt == 'UPDATE_STEALTH' then
    self:UpdateTexture()
  elseif evt == 'UNIT_SPELLCAST_STOP' or evt == 'UNIT_SPELLCAST_SUCCEEDED' then
    self:UpdateTexture()
  elseif evt == 'LOSS_OF_CONTROL_UPDATE' then
    self:UpdateCooldown()
  elseif evt == 'SPELL_UPDATE_COOLDOWN' or evt == 'LOSS_OF_CONTROL_ADDED' then
    --if unit:IsPriest() and unit:IsShapeShifted() then return end
    self:UpdateCooldown()
  elseif evt == 'UNIT_AURA' then
    --self:UpdateStealthSpells()
  end
  
end

--- Retail fix for stuck PUSHED state after toggle.
function o:RepairRetailPushedState()
  if cns:IsRetail() then
    self:SetButtonStateNormal()
  end
end

--- Events coming here are matching spellcast events
---@param spellID SpellID The matching spell ID
function o:OnPlayerMatchingSpellcastEvent(evt, spellID)
  --self:t('OnPlayerMatchingSpellcastEvent', 'evt=', evt, 'called...')
  if evt == 'UNIT_SPELLCAST_START' then
  end
  self:UpdateState()
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
end

--- @param button ButtonName
--- @param down ButtonDown
function o:PreClick(button, down)
  if InCombatLockdown() then return false end
  
  -- fires on 'up' if not locked by user
  if not IsActionbarLockedByUser() then
    return
  end
  
  if Btn_ActionShouldFire(down) and self:IsDragAllowed() then
    self.widget:DisableAttributeType()
  end
  
  --local _type, spellID = self:GetActionInfo()
  --if not _type then return end
  --
  --local current = C_IsCurrentSpell(spellID) or C_IsAutoRepeatSpell(spellID);
  --if current then self:SetChecked(true) end
  --tf('PreClick', 'current=', current)
end

--- @param button ButtonName
--- @param down ButtonDown
function o:PostClick(button, down)
  if InCombatLockdown() then return false end
  if down == true then return end
  self:UpdateState()
end

function o:OnEnter()
  self.widget:ClearAttributeSavedType()
  
  local type, id = self:GetActionInfo()
  if not id then return end
  --todo: GameTooltip owner will be user configurable
  --GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
  GameTooltip:ClearAllPoints()
  GameTooltip:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -10, 70)
  
  --- @type FontStringObj
  local right = _G["GameTooltipTextRight1"]
  
  if type == atyp.spell then
    GameTooltip:SetSpellByID(id)
    local rank = spu:GetHighestSpellRank(id)
    if right and rank then
      right:SetText(rank);
      right:SetTextColor(rankColor:GetRGBA())
      right:Show()
    end
    GameTooltip:Show()
  end
end

function o:OnLeave()
  GameTooltip:Hide()
  self.widget:RestoreAttributeType()
end

--- @param button ButtonName
function o:OnDragStart(button)
  p('OnDragStart...')
  if InCombatLockdown() then return false end
  if not self:IsDragAllowed() then return end
  
  Btn_PickupAction(self)
  self:UpdateState()
  self:UpdateCooldown()
  self:UpdateFlash()
  
  self:SetChecked(false)
  self:ClearButtonConf()
end

function o:OnDragStop()
  p('OnDragStop...')
  -- todo: review if these are needed
  self.widget:RestoreAttributeType()
end

--function o:__btnConfOrNew()
--  local barIndex, btnIndex = self.widget.barIndex, self.widget.index
--  local barConf = cns:a():bar(barIndex)
--  return cns:a():buttonOrNew(barConf, btnIndex)
--end

function o:OnReceiveDrag()
  if InCombatLockdown() then return end
  local cursor = cns:cursor()
  if not cursor.isValid then return end
  
  --- @type ButtonConfig_ABP_2_0
  local btnC = self:GetButtonConfig(true)
  --self:p('OnReceiveDrag', 'btnC=', btnC)
  
  if cursor.type == 'spell' then
    cursor:IfSpell(function(spell)
      self:__SetSpell(spell.spellID)
      btnC.type = atyp.spell
      btnC.id = spell.spellID
      local _sp = ('%s(%s)'):format(spell.name, spell.spellID)
      self:p('OnReceiveDrag:: spell=', _sp, 'btnC=', btnC)
    end)
  end
  
  ClearCursor()
  self:UpdateState()
  self:UpdateFlash()
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
    
    --self:UpdateState()
    --self:UpdateUsable()
    --self:UpdateProfessionQuality()
    --self:UpdateTypeOverlay()
    --ActionButton_UpdateCooldown(self)
    self:UpdateCooldown()
    self:UpdateFlash()
    --self:UpdateHighlightMark()
    --self:UpdateSpellHighlightMark()
  else
    if ( self.eventsRegistered ) then
      eventsFrame:UnregisterFrame(self);
      self.eventsRegistered = nil;
    end
    --self:ClearFlash()
    --self:SetChecked(false);
    --self:ClearProfessionQuality();
    --self:ClearTypeOverlay();
  end
  
  self.__updating = false
end

--- If type is invalid (blank or nil) then return quickly
--- Clear Icon When: type=spell|item|etc and val is invalid (blank or nil)
function o:UpdateAction(name, val)
  if name == attr.type and Str_IsBlank(val) then return end
  
  if not Str_IsAnyOf(name, atyp.spell, atyp.item) then return end
  if Str_IsBlank(val) then self.icon:SetTexture(nil); return end
  
  -- if name == 'abp_clear' then
  if name == atyp.spell then
    local info = comp:GetSpellInfo(val)
    local _sp = ('%s(%s)'):format(tostring(info.name), tostring(info.spellID))
    self:t('UpdateAction','spell=', _sp, 'attr-name=', name)
    if not (info and info.iconID) then return end
    self.icon:SetTexture(info.iconID)
  elseif name == atyp.item then
    self:t('UpdateAction','item=', val, 'attr-name=', name)
  end
  
  self:Update()
end

--- [Doc::GetShapeshiftFormInfo](https://warcraft.wiki.gg/wiki/API_GetShapeshiftFormInfo)
--- @return TextureIcon
function o:GetActionTexture()
  local _type, id = self:GetActionInfo()
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
  if _type == atyp.spell then
    if unit:IsStealthActive() then
      if druid:IsProwl(id) then
        self:DimIcon()
        return unit:GetStealthedIcon()
      end
    elseif priest:IsShadowFormSpell(id) and priest:IsShapeShifted() then
      return priest:GetShadowFormActiveIcon()
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
function o:UpdateCooldown()
  --self:p('UpdateCooldown():: called...')
  local cd = self.cooldown
  if not cd then return end
  
  if not self:HasAction() then cd:Clear(); return end
  
  local _type, id = self:GetActionInfo()
  if not id then cd:Clear(); return end
  
  local start, duration, enable, modRate = 0, 0, 0, 1
  
  if au.IsSpell(_type) then
    -- The shadowform spell triggers a cooldown if we don't do this (weird behavior)
    if cns:IsTBC()
            and priest:IsPriest()
            and priest:IsShapeShifted()
            and priest:IsShadowFormSpell(id) then return end
    au.IfSpellCooldown(id, function(info)
      start = info.startTime or 0
      duration = info.duration or 0
      modRate = info.modRate
    end)
  elseif au.IsItem(_type) then
    start, duration, enable = GetItemCooldown(id)
  else
    cd:Clear()
    return
  end
  if not start or not duration then cd:Clear(); return end
  --cd.currentCooldownType = COOLDOWN_TYPE_NORMAL
  cd:SetCooldown(start, duration, modRate or 1)
end

--- @return string|nil, number|nil The type (e.g. spell, item) and resolved typeID (spellID/itemID)
function o:GetActionInfo()
  local aType = self:GetAttribute(attr.type)
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
  local type = self:GetAttribute(attr.type)
  if not type then return false end
  local id = self:GetAttribute(type)
  return id ~= nil
end

--- @param spell SpellIdentifier
function o:__SetSpell(spell)
  local sp = comp:GetSpellInfo(spell)
  if not sp then return end
  self:SetAttribute(attr.type, atyp.spell)
  self:SetAttribute(atyp.spell, sp.spellID)
  self.icon:SetTexture(sp.iconID)
  self:Update()
end

function o:t(prefix, ...)
  local a = { ... }; tf(self:pid(prefix), unpack(a))
end
function o:p(prefix, ...)
  local a = { ... }; p(self:pid(prefix), unpack(a))
end
function o:pd(prefix, ...)
  local a = { ... }; pd(self:pid(prefix), unpack(a))
end
function o:pid(prefix) return ("%s(%s)::"):format(prefix, self:GetName()) end

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

function o:IsDragAllowed()
  return not Settings.GetValue('lockActionBars') or IsModifiedClick('PICKUPACTION')
end

function o:SetButtonStateNormal() self:SetButtonState('NORMAL') end
function o:SetButtonStatePushed() self:SetButtonState('PUSHED') end
function o:SetButtonStateDisabled() self:SetButtonState('DISABLED') end


