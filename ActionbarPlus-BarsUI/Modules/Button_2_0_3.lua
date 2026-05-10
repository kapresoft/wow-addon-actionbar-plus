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

local cns, O = ns:cns(), ns:cns().O
local C, au = O.Constants, O.ActionUtil
local attr, atyp = C.AttributeNames, C.SupportedActionTypes
local comp, spu, unit = O.Compat, O.SpellUtil, O.UnitUtil
local dru, priest = O.DruidUtil, O.PriestUtil
local Tbl_IsEmpty = cns:Table().IsEmpty
local Str_IsAnyOf = cns:String().IsAnyOf

--- @type Color
local rankColor = GRAY_FONT_COLOR or CreateColor(0.502, 0.502, 0.502, 1.000)


local seedID = 1000
--[[-----------------------------------------------------------------------------
New Instance
@see ButtonState_ABP_2_0, ButtonConfigAccessor_ABP_2_0
-------------------------------------------------------------------------------]]
--- @class Button_ABP_2_0_3 : ButtonMixin_ABP_2_0_3
--- @alias Button_ABP_2_0_X Button_ABP_2_0_3 @Use this externally so we don't have to rename if we use a different button
--
local libName = 'Button_2_0_3'

--- @class ButtonMixin_ABP_2_0_3 : ButtonHandlerMixin_ABP_2_0, ButtonConfigAccessor_ABP_2_0, SecureActionButtonTemplate, CheckButton, AceEvent-3.0
--- @field NormalTexture TextureObj
--- @field HighlightTexture TextureObj
--- @field PushedTexture TextureObj
--- @field CheckedTexture TextureObj
--- @field SpellHighlightAnim AnimationGroup
--- @field icon TextureObj
--- @field cooldown CooldownObj
--- @field eventsRegistered boolean
--- @field widget ButtonWidget_ABP_2_0
--- @field GetParent fun(self:ButtonMixin_ABP_2_0_3) : BarFrameObj_ABP_2_0
local o = Mixin(cns:NewAceEvent(), ns.O.ButtonHandlerMixin, ns.O.ButtonConfigAccessorMixin)
ButtonMixin_ABP_2_0_3 = o

local p, t = ns:log(libName)

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
local function NextSeedID()
  local current = seedID;
  seedID = seedID + 1;
  return current
end

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]
-- /dump SetCVar('ActionButtonUseKeyDown', 1)
function o:OnLoad()

  local encodedID = self:GetID()
  assert(type(encodedID) == 'number', 'encodedID is invalid: ' .. tostring(encodedID))

  local barIndex, btnIndex = au.decodeBarID(encodedID)

  self:SetID(encodedID)

  --- @type ButtonWidget_ABP_2_0
  self.widget = CreateFromMixins(ns.O.ButtonWidgetMixin)
  self.widget:Init(self, btnIndex, barIndex)

  self:EnableMouse(true)
  self:GetNormalTexture():SetDrawLayer("BACKGROUND", 0)
  self:GetPushedTexture():SetVertexColor(0.3, 0.4, 0.8, 1)
  self.icon:AddMaskTexture(self.IconMask)
  
  self:RegisterForDrag("LeftButton")
  self:AnyDown()

  -- retail only (not supported in ABPV2)
  -- self:SetAttribute("down", true)
  self:SetAttribute('checkselfcast', true)
  self:SetAttribute('checkfocuscast', true)
  self:SetAttribute('checkmouseovercast', true)

  WorldEventsFrame_ABP_2_0:RegisterFrame(self)

  --- @param btn Button_ABP_2_0_X
  self:SetScript('OnAttributeChanged', function(btn, ...) btn:OnAttributeChanged(...) end)
  self.widget:ApplyButtonConfig()

  local traceChecked = false
  if traceChecked then
    if not self.__SetCheckedWrapped then
      self.__SetCheckedWrapped = true
      local orig = self.SetChecked
      self.SetChecked = function(btn, val)
        t('Checked', val, "SetCheckedWrapped:: Button:", btn:GetName(), 'debugstack=', debugstack(2, 5, 5))
        --tf(debugstack(2, 5, 5))
        return orig(btn, val)
      end
    end
  end
end

--- Still needs to be wired: TBD
--- @see BarFrame.xml#ButtonUpdateFrame_ABP_2_0
--- @see ButtonUpdateFrame_ABP_2_0#OnUpdate()
--- @param elapsed number
function o:OnUpdate(elapsed)
  t('OnUpdate') -- tbd
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
    self:UpdateState(evt)
    self:UpdateUsable()
  elseif evt == 'SPELL_UPDATE_USABLE' then
    self:UpdateUsable()
  elseif evt == 'PLAYER_LEAVE_COMBAT' then
    self:UpdateState(evt)
    self:DisableAttackingAnimation()
  elseif evt == 'PLAYER_TARGET_SET_ATTACKING' then
    if o.Btn_ActionRequiresAttackAnim(self) then
      self:SetChecked(true)
      self:EnableAttackingAnimation()
      return
    end
    self:UpdateState(evt)
  elseif evt == 'ACTIONBAR_UPDATE_STATE' then
    self:RepairRetailPushedState()
    self:UpdateState('OnEvent') -- this deselects Cooking, First Aid, Prof Talents
  elseif Str_IsAnyOf(evt, 'UPDATE_SHAPESHIFT_FORM', 'UPDATE_STEALTH') then
    self:UpdateTexture()
    self:UpdateState('OnEvent')
  elseif evt == 'LOSS_OF_CONTROL_UPDATE' then
    self:UpdateCooldown()
  elseif Str_IsAnyOf(evt, 'SPELL_UPDATE_COOLDOWN', 'LOSS_OF_CONTROL_ADDED') then
    self:UpdateCooldown()
  elseif Str_IsAnyOf(evt, 'TRADE_SKILL_SHOW', 'TRADE_SKILL_CLOSE')  then
    self:UpdateState('OnEvent')
  --elseif evt == 'UNIT_AURA' then
  --  self:UpdateStealthSpells()
  elseif evt == 'BAG_UPDATE_COOLDOWN' then
    --t('OnEvent', 'evt=', evt)
    self:UpdateCooldown()
    self:UpdateUsable()
  elseif evt == 'BAG_UPDATE_DELAYED' then
    self:UpdateUsable()
  end
  
end

--- Note: checked state is only used for non-instant spells
--- Normal cast:
--  1. UNIT_SPELLCAST_SENT — client sends cast request to server (instant cast)
--  2. UNIT_SPELLCAST_START — cast bar begins (non-instant cast)
--  3. UNIT_SPELLCAST_STOP — cast bar ends (fires regardless of outcome)
--  4. UNIT_SPELLCAST_SUCCEEDED or UNIT_SPELLCAST_FAILED — spell completed successfully or failed
--- Events coming here are matching spellcast events
---@param spellID SpellIdentifier The matching spell ID
function o:OnPlayerMatchingSpellcastEvent(evt, spellID)
  -- todo: in classic-era, older rank spells are non castable
  local sp = comp:GetSpellName(spellID)
  if evt == 'UNIT_SPELLCAST_SENT' then
      self:SetChecked(true)
  elseif evt == 'UNIT_SPELLCAST_START' then
    self:SetChecked(true)
  elseif evt == 'UNIT_SPELLCAST_STOP'
      or evt == 'UNIT_SPELLCAST_SUCCEEDED'
      or evt == 'UNIT_SPELLCAST_INTERRUPTED'
      or 'UNIT_SPELLCAST_FAILED' then
    self:SetChecked(false)
    self:UpdateTexture()
  end
end
--- Retail fix for stuck PUSHED state after toggle.
function o:RepairRetailPushedState()
  if cns:IsRetail() then
    self:SetButtonStateNormal()
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
  end
end

--- @param button ButtonName
--- @param down ButtonDown
function o:PreClick(button, down)
  if InCombatLockdown() then return false end
  self:PreClickAction(button, down)
end

--- Responds on up
--- @param button ButtonName
--- @param down ButtonDown
function o:PostClick(button, down)
  if InCombatLockdown()
    or not (down and o.IsActionbarLockedByUser()) then
      return
  end
  self:PostClickAction(button, down)
end

--- Only process mouse down events here
--- @param button ButtonName
--- @param down ButtonDown
function o:PreClickAction(button, down)
  if self.widget:IsEmpty() then self:SetChecked(false); return end
  -- Prepare for a potential drag operation.
  -- When the user begins dragging the button, the secure `type` attribute
  -- must be temporarily suspended so the button does not execute its
  -- action while the drag / pickup transaction is in progress.
  if o.Btn_ActionShouldFire(self, down) and self:IsDragAllowed() then
    self:SetChecked(false)
    self.widget:SuspendAction()
    return
  end

  -- ########################################
  -- Cursor swap case (no drag event):
  -- The user clicked the button while the cursor already holds an action.
  -- This performs a chain swap:
  --   cursor action → button
  --   button action → cursor
  -- ########################################
  local cursor = cns:cursor()

  -- clicks on a button with a valid cursor
  -- on mouse 'down', suspend the current action if there is a valid cursor
  if cursor.isValid then
    self.widget:SuspendAction(); return
  end
end

function o:OnClick() end

--- Only process down events here due to AnyDown() being set
--- @param button ButtonName
--- @param down ButtonDown
function o:PostClickAction(button, down)
  self:UpdateState('PostClick')

  -- return if nothing on cursor
  local cursor = cns:cursor()
  if not cursor.isValid then return end

  ClearCursor()

  local suspendedType, actionID = self:GetSuspendedActionInfo()
  if suspendedType then
    if suspendedType == atyp.spell then
      comp:PickupSpell(actionID)
    elseif suspendedType == atyp.item then
      comp:PickupItem(self.widget:GetAttributeItemID())
    elseif suspendedType == atyp.macro then
      --  todo: handle macro
    end
  end

  self.widget:ClearAttributeSuspendedActionType()
  self.widget:ApplyCursorAction(cursor)
end

function o:OnEnter()
  local type, id = self:GetActionInfo()
  if not id then return end
  --todo: GameTooltip owner will be user configurable
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

function o:OnLeave() GameTooltip:Hide() end

--- @param button ButtonName
function o:OnDragStart(button)
  if InCombatLockdown() then return false end
  if not self:IsDragAllowed() then return end

  o.Btn_PickupAction(self, function()
    self:UpdateState('OnDragStart')
    self:UpdateCooldown()
    self:UpdateFlash()
    self:SetChecked(false)
  end)
  
end

function o:OnDragStop() end

function o:OnReceiveDrag()
  if InCombatLockdown() then return end
  local cursor = cns:cursor()
  if not cursor.isValid then return end
  ClearCursor()
  self.widget:ClearAttributeSuspendedActionType()
  
  -- check if button already has action
  local existingType, existingID = self:GetActionInfo()
  -- pickup existing action (this places it on cursor)
  if au.IsSpell(existingType) then
    comp:PickupSpell(existingID)
  elseif au.IsItem(existingType) then
    comp:PickupItem(self.widget:GetAttributeItemID())
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
  local buttonCooldown = self.cooldown
  
  icon:SetDesaturated(false)
  
  local type, id = self:GetActionInfo()
  if self.widget:HasAction() then
    if ( not self.eventsRegistered ) then
      eventsFrame:RegisterFrame(self)
      self.eventsRegistered = true
    end
    self:UpdateTexture()
    --self:UpdateState()
    self:UpdateUsable()
    --self:UpdateProfessionQuality()
    --self:UpdateTypeOverlay()
    --ActionButton_UpdateCooldown(self)
    self:UpdateCooldown()
    self:UpdateFlash()
    --self:UpdateHighlightMark()
    --self:UpdateSpellHighlightMark()
  else
    if ( self.eventsRegistered ) then
      eventsFrame:UnregisterFrame(self)
      self.eventsRegistered = nil
    end
    --self:ClearFlash()
    --self:SetChecked(false);
    --self:ClearProfessionQuality();
    --self:ClearTypeOverlay();
  end
  
  self.__updating = false
end

--- [Doc::GetShapeshiftFormInfo](https://warcraft.wiki.gg/wiki/API_GetShapeshiftFormInfo)
--- @return TextureIcon?
function o:GetActionTexture()
  local typeVal, id = self:GetActionInfo()
  --t('GetActionTexture', 'typeVal=', typeVal, 'id=', id)

  if not id then return nil end
  if au.IsMount(typeVal) then return end

  local druid, rogue, shammy = cns.O.DruidUtil, cns.O.RogueUtil, cns.O.ShamanUtil
  local iconID
  if au.IsSpell(typeVal) then
    if unit:CanShapeShift() then
      local formOrStealthActive = false
      -- some shapeshifts have
      -- different icons when active
      if unit:IsStealthActive()
          and (druid:IsProwl(id) or rogue:IsStealth(id)) then
        -- Druid and Rogue use the same stealth icon
        formOrStealthActive = true
        iconID = unit:GetStealthedIcon()
      elseif priest:IsShadowFormSpell(id) and priest:IsShapeShifted() then
        formOrStealthActive = true
        iconID = priest:GetShadowFormActiveIcon()
      elseif shammy:IsGhostWolfSpell(id) and shammy:IsInGhostWolfForm() then
        iconID = shammy:GetFormActiveIcon()
      end
      if formOrStealthActive then
        self:DimIcon()
      else
        self:SetIconNormalVertex()
      end
    end
    if not iconID then
      local info = comp:GetSpellInfo(id)
      if info and info.iconID then iconID = info.iconID end
    end
  elseif au.IsItem(typeVal) then
    au.IfItem(self.widget:GetAttributeItemID(), function(itemInfo)
        iconID = itemInfo.icon
    end)
  end
  return iconID
end

--[[-------------------------------------------------------------------
Convenience Methods
---------------------------------------------------------------------]]
function o:UpdateUsable()
  local icon = self.icon
  local typeVal, actionID = self:GetActionInfo()
  if typeVal == nil then return end

  local isUsable, notEnoughMana = au.IsUsableAction(typeVal, actionID)
  if isUsable then
    self:SetIconNormalVertex()
  elseif notEnoughMana then
    icon:SetVertexColor(0.5, 0.5, 1.0)
  else
    icon:SetVertexColor(0.4, 0.4, 0.4);
  end
end

function o:UpdateCooldown()
  local cd = self.cooldown
  if not cd then return end
  
  if not self.widget:HasAction() then cd:Clear(); return end
  
  local typeVal, id = self:GetActionInfo()
  if not id then cd:Clear(); return end
  
  local start, duration, enabled, modRate = 0, 0, false, 1
  
  if au.IsSpell(typeVal) then
    -- The shadowform spell triggers a cooldown if we don't do this (weird behavior)
    if cns:IsTBC()
            and priest:IsPriest()
            and priest:IsShapeShifted()
            and priest:IsShadowFormSpell(id) then return end
    au.IfSpellCooldown(id, function(info)
      start = info.startTime or 0
      duration = info.duration or 0
      enabled = info.isEnabled == true
      modRate = info.modRate
    end)
  elseif au.IsItem(typeVal) then
    -- todo next: ItemCooldown
    au.IfItemCooldown(id, function(info)
      start, duration, enabled = info.startTime, info.duration, info.isEnabled == true
    end)
  end

  if enabled == true and duration > 0 then
    cd:SetCooldown(start, duration, modRate or 1)
    return
  end
  cd:Clear()
end

--- Returns info for a known spell.  An unknown spell will return nil values.
--- @return string?, ActionID? @The type (e.g. spell, item) and resolved typeID (spellID/itemID)
function o:GetActionInfo()
  local actionType = self:GetAttribute(attr.type)
  if not actionType then return nil, nil end
  
  --- @type ActionID
  local val = self:GetAttribute(actionType)
  if not val then return nil, nil end
  
  if type(val) == "number" then return actionType, val end

  if type(val) == "string" then
    if au.IsSpell(actionType) then
      local sp = comp:GetSpellInfo(val)
      if not sp then return nil, nil end
      return actionType, sp.spellID
    elseif au.IsItem(actionType) then
      local itemID = self.widget:GetAttributeItemID()
      return actionType, itemID
    elseif au.IsMacro(actionType) then
      error(self:GetName() .. ':: GetActionInfo(): macro support not implemented')
    end
  end
  
  return nil, nil
end

--- @return string|nil, number|nil The suspended action type (e.g. spell, item) and the suspended action type value (spellID/itemID). If one is nil, both are nil.
function o:GetSuspendedActionInfo()
  local actionType = self.widget:GetAttributeSuspendedActionType()
  if not actionType then return nil, nil end
  
  local id = self:GetAttribute(actionType)
  if not id then return nil, nil end
  
  return actionType, id
end
--- @param r number
--- @param g number
--- @param b number
function o:SetIconVertex(r, g, b) self.icon:SetVertexColor(r, g, b) end
function o:SetIconNormalVertex() self:SetIconVertex(1, 1, 1) end
function o:DimIcon() self:SetIconVertex(0.5, 0.5, 0.5) end

---@param callbackFn fun(icon:Icon):void
function o:IfActionTexture(callbackFn)
  local icon = self:GetActionTexture()
  if not icon then return end
  callbackFn(icon)
end

function o:UpdateState(evt) o.Btn_UpdateState(self, evt) end
function o:UpdateAnimation() o.Btn_UpdateAnimation(self) end
function o:UpdateFlash() o.Btn_UpdateFlash(self) end
function o:ClearFlash()
  -- tbd
end

function o:UpdateTexture()
  self:IfActionTexture(function(icon) self.icon:SetTexture(icon) end)
end

function o:IsDragAllowed()
  return not Settings.GetValue('lockActionBars') or IsModifiedClick('PICKUPACTION')
end

function o:AnyDown() self:RegisterForClicks('AnyDown') end
function o:Any() self:RegisterForClicks('AnyDown', 'AnyUp') end
function o:SetButtonStateNormal() self:SetButtonState('NORMAL') end
function o:SetButtonStatePushed() self:SetButtonState('PUSHED') end
function o:SetButtonStateDisabled() self:SetButtonState('DISABLED') end

function o:EnableAttackingAnimation()
  if self.SpellHighlightAnim:IsPlaying() then return end
  self.SpellHighlightAnim:Play()
end

function o:DisableAttackingAnimation()
  if not self.SpellHighlightAnim:IsPlaying() then return end
  self.SpellHighlightAnim:Stop()
  self.SpellHighlightTexture:Hide()
end
