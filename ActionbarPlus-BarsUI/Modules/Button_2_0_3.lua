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
@see ButtonState_ABP_2_0, ButtonConfigAccessor_ABP_2_0
-------------------------------------------------------------------------------]]
--- @alias Button_ABP_2_0_3 ButtonMixin_ABP_2_0_3 | ButtonState_ABP_2_0 | ButtonConfigAccessor_ABP_2_0 | SecureCheckButtonObj | AceEvent_3_0
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
--- @param callbackFn fun() : void
local function Btn_PickupAction(self, callbackFn)
  --- The abp_saved_type is saved during PreClick()
  --- so that the button won't fire on pickup action
  local typeVal = self.widget:GetAttributeSuspendedActionType()
  if not typeVal then return end
  
  if au.IsSpell(typeVal) then
    local spell = self.widget:GetAttributeSpell()
    comp:PickupSpell(spell)
    self:ClearButtonConf()
    self.widget:ResetButton()
  end

  if callbackFn then callbackFn() end
end

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]
--- @type ButtonMixin_ABP_2_0_3 | Button_ABP_2_0_3
local o = S

-- /dump SetCVar('ActionButtonUseKeyDown', 1)
function o:OnLoad()
  self:SetID(NextSeedID())
  
  --@do-not-package@
  function self:__logID() return self:GetName() end
  DeveloperSetup_ABP_2_0.ButtonLogMixin(self, p, pd, t, tf)
  --@end-do-not-package@
  
  self:EnableMouse(true)
  self:GetNormalTexture():SetDrawLayer("BACKGROUND", 0)
  self.icon:AddMaskTexture(self.IconMask)
  
  self:RegisterForDrag("LeftButton");
  self:RegisterForClicks('AnyDown', 'AnyUp');
  
  WorldEventsFrame_ABP_2_0:RegisterFrame(self)
end

--- @private
--- @param barIndex Index
--- @param btnIndex Index
function o:AfterLoad(btnIndex, barIndex)
  self.widget = CreateFromMixins(ns.O.ButtonWidgetMixin)
  self.widget:Init(self, btnIndex, barIndex)
  Mixin(self, ns.O.ButtonStateMixin, ns.O.ButtonConfigAccessorMixin)

  self:SetAttribute("checkselfcast", true);
  self:SetAttribute("checkfocuscast", true);
  self:SetAttribute("checkmouseovercast", true);
  
  self.widget:ApplyButtonConfig()
  
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
  if not IsActionbarLockedByUser() then return end
  
  -- Prepare for a potential drag operation.
  -- When the user begins dragging the button, the secure `type` attribute
  -- must be temporarily suspended so the button does not execute its
  -- action while the drag / pickup transaction is in progress.
  if Btn_ActionShouldFire(down) and self:IsDragAllowed() then
    self.widget:SuspendAction(); return
  end
 
  -- on mouse 'up', return
  if not down then return end
  
  -- ########################################
  -- Cursor swap case (no drag event)::
  -- The user clicked the button while the cursor already holds an action.
  -- This performs a chain swap:
  --   cursor action → button
  --   button action → cursor
  -- ########################################
  local cursor = cns:cursor(); if not cursor.isValid then return end
  
  -- on mouse 'down', suspend the current action
  self.widget:SuspendAction()
  local suspendedType, actionID = self:GetSuspendedActionInfo()
  if not suspendedType then return end
  
  -- on mouse 'down'
  local sp = comp:__debug_SpellInfo(actionID)
  t('DND', 'PreClick', 'suspended=', sp, 'type=', suspendedType, 'on-mouse-down=', true)
end

--- @param button ButtonName
--- @param down ButtonDown
function o:PostClick(button, down)
  if InCombatLockdown() then return false end
  if down == true then return end
  
  local cursor = cns:cursor()
  if not cursor.isValid then return end
  
  ClearCursor()
  
  local suspendedType, actionID = self:GetSuspendedActionInfo()
  if suspendedType == atyp.spell then
    comp:PickupSpell(actionID)
    local sp = comp:__debug_SpellInfo(actionID)
    t('DND', 'PostClick', 'picked-up=', sp, 'suspended-type=', suspendedType,
            'on-mouse-up=', down ~= true)
    self.widget:ClearAttributeSuspendedActionType()
    self.widget:ApplyCursorAction(cursor)
  else
    self.widget:ApplyCursorAction(cursor)
  end
  self:UpdateState()
end

function o:OnEnter()
  --self.widget:ClearAttributeSavedType()
  
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
  --self.widget:RestoreAttributeType()
end

--- @param button ButtonName
function o:OnDragStart(button)
  if InCombatLockdown() then return false end
  if not self:IsDragAllowed() then return end
  
  Btn_PickupAction(self, function()
    self:UpdateState()
    self:UpdateCooldown()
    self:UpdateFlash()
    self:SetChecked(false)
  end)
  
end

function o:OnDragStop()
  p('OnDragStop...')
  -- todo: review if these are needed
  --self.widget:RestoreAttributeType()
end

function o:OnReceiveDrag()
  if InCombatLockdown() then return end
  local cursor = cns:cursor()
  if not cursor.isValid then return end
  ClearCursor()
  self.widget:ClearAttributeSuspendedActionType()
  
  -- check if button already has action
  local existingType, existingID = self:GetActionInfo()
  -- pickup existing action (this places it on cursor)
  if existingType == atyp.spell then
    --t('Drag', 'ORcvDrag', 'existingType=', existingType, 'existingID=', existingID)
    comp:PickupSpell(existingID)
    self.widget:ApplyCursorAction(cursor)
    return
  end
  
  self.widget:ApplyCursorAction(cursor)
end

function o:OnAttributeChanged(name, val)
  self.widget:OnAttributeChanged(name, val)
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
  if self.widget:HasAction() then
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
  
  if not self.widget:HasAction() then cd:Clear(); return end
  
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

--- @return string|nil, number|nil The suspended action type (e.g. spell, item) and the suspended action type value (spellID/itemID). If one is nil, both are nil.
function o:GetSuspendedActionInfo()
  local actionType = self.widget:GetAttributeSuspendedActionType()
  if not actionType then return nil, nil end
  
  local id = self:GetAttribute(actionType)
  if not id then return end
  
  return actionType, id
end

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


