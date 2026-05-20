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

local MODIFIER_STATE_CHANGED = 'MODIFIER_STATE_CHANGED'
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

--- @class ButtonMixin_ABP_2_0_3 : ButtonHandlerMixin_ABP_2_0, ButtonConfigAccessor_ABP_2_0, AceEvent-3.0, SecureActionButtonTemplate, CheckButton
--- @field NormalTexture Texture
--- @field HighlightTexture Texture
--- @field PushedTexture Texture
--- @field CheckedTexture Texture
--- @field SpellHighlightAnim AnimationGroup
--- @field Count FontString
--- @field icon Texture
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
  self.widget:LoadAction()

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
  --t('OnUpdate') -- tbd
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
    if isInitialLogin or isReloadingUi then
      self.widget:IfBattlePet(function (petID)
        C_Timer.After(1, function ()
          self:UpdateTexture()
          self:UpdateState(evt)
        end)
      end)
    end
  elseif evt == 'COMPANION_UPDATE' then
    self:UpdateState('OnEvent')
  elseif evt == MODIFIER_STATE_CHANGED then
    t('OnEvent', 'evt=', evt, 'args=', fmt({...}))
  elseif evt == 'SPELL_UPDATE_USABLE' then
    self:UpdateUsable()
  elseif evt == 'SPELL_UPDATE_CHARGES' then
    self:UpdateCount()
  elseif evt == 'PLAYER_LEAVE_COMBAT' then
    -- note: PLAYER_LEAVE_COMBAT gets fired when the player stops
    -- attacking (even when player is in combat)
    self:UpdateState(evt)
    self:DisableFlashAnimation()
  elseif evt == 'START_AUTOREPEAT_SPELL' then
    --t('START_AUTOREPEAT_SPELL', 'attributeSpell=', self.widget:GetAttributeSpell())
    if self.widget:RequiresShootAnimation() then
      self:SetChecked(true)
      self:EnableFlashAnimation()
    end
  elseif evt == 'STOP_AUTOREPEAT_SPELL' then
    if self.widget:IsShootSpell() then
      self:SetChecked(false)
      self:DisableFlashAnimation()
    end
  elseif Str_IsAnyOf(evt, 'PLAYER_TARGET_SET_ATTACKING', 'PLAYER_ENTER_COMBAT') then
    if self.widget:RequiresAttackAnimation() then
      self:SetChecked(true)
      self:EnableFlashAnimation()
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
  elseif evt == 'SPELL_ACTIVATION_OVERLAY_GLOW_SHOW' then
    local spellID = ...
    if self:MatchesSpellID(spellID) then self.widget:ShowOverlayGlow() end
  elseif evt == 'SPELL_ACTIVATION_OVERLAY_GLOW_HIDE' then
    local spellID = ...
    if self:MatchesSpellID(spellID) then self.widget:HideOverlayGlow() end
  elseif evt == 'BAG_UPDATE_COOLDOWN' then
    self:UpdateCooldown()
    self:UpdateUsable()
  elseif evt == 'BAG_UPDATE_DELAYED' then
    self:UpdateUsable()
    self:UpdateCount()
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
 --t('OnPlayerMatchingSpellcastEvent', 'evt=', evt, 'spellID=', spellID, sp)
  if evt == 'UNIT_SPELLCAST_SENT' then
      self:SetChecked(true)
  elseif evt == 'UNIT_SPELLCAST_START' then
    self:UpdateState()
  elseif evt == 'UNIT_SPELLCAST_STOP'
      or evt == 'UNIT_SPELLCAST_SUCCEEDED'
      or evt == 'UNIT_SPELLCAST_INTERRUPTED'
      or evt == 'UNIT_SPELLCAST_FAILED' then
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
  self:UpdateUsable()
  if InCombatLockdown()
    or not (down and o.IsActionbarLockedByUser()) then
      return
  end
  self:PostClickAction(button, down)
end

--- For restoring suspended actions
function o:OnModifierStateChanged(evt, keyPressed, isDown)
  self:UnregisterEvent(MODIFIER_STATE_CHANGED)
  if InCombatLockdown() then return end
  self.widget:RestoreAction()
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
  if o.Btn_ActionShouldFire(self, down) and self.widget:IsDragAllowed() then
    self:SetChecked(false)
    self.widget:SuspendAction()
    self:RegisterEvent(MODIFIER_STATE_CHANGED, 'OnModifierStateChanged')
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

  -- On mouse 'down' with a valid cursor, suspend the current action
  -- to prevent it from firing during a drag-drop operation.
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

  local suspendedType = self:GetSuspendedActionInfo()
  if suspendedType then
    -- Chain-clicking between buttons with a valid cursor; not a drag event.
    -- Clicking on button with an action
    o.Btn_PickupAction(self)
  end
  self.widget:ClearAttributeSuspendedActionType()
  self.widget:SaveAction(cursor)
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
  if au.IsSpell(type) then
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
  self:UnregisterEvent(MODIFIER_STATE_CHANGED)
  if InCombatLockdown() then return false end
  if not self.widget:IsDragAllowed() then return end

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
    o.Btn_PickupSpellOrMount(self, existingID)
  elseif au.IsItem(existingType) then
    comp:PickupItem(self.widget:GetAttributeItemID())
  elseif au.IsBattlePet(existingType) then
    comp:PickupBattlePet(self.widget:GetAttributeBattlePetID())
  end
  
  self.widget:SaveAction(cursor)
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
    self:UpdateCount()
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

--[[-------------------------------------------------------------------
Convenience Methods
---------------------------------------------------------------------]]
function o:UpdateUsable()
  local icon = self.icon
  local typ, val = self:GetActionInfo()
  if typ == nil then return end

  local isUsable, notEnoughMana = au.IsUsableAction(typ, val)
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

  local ok = pcall(function()
    -- retail: duration is 'secret' and will throw error
    if enabled == true and duration > 0 then
      cd:SetCooldown(start, duration, modRate or 1)
    else
      cd:Clear()
    end
  end)
  if not ok then cd:Clear() end
end

--- @see ButtonWidget_ABP_2_0.GetActionInfo()
--- @return string?, ActionValue? @The type (e.g. spell, item) and resolved typeID (spellID/itemID)
function o:GetActionInfo() return self.widget:GetActionInfo() end

--- @return string?, ActionValue? @The suspended action type (e.g. spell, item) and the suspended action type value (spellID/itemID). If one is nil, both are nil.
function o:GetSuspendedActionInfo()
  local typ = self.widget:GetAttributeSuspendedActionType()
  if not typ then return nil, nil end

  local val = self.widget:GetActionAttributeTypeValue(typ)
  if not val then return nil end
  
  return typ, val
end

--- @param r number
--- @param g number
--- @param b number
function o:SetIconVertex(r, g, b) self.icon:SetVertexColor(r, g, b) end
function o:SetIconNormalVertex() self:SetIconVertex(1, 1, 1) end
function o:DimIcon() self:SetIconVertex(0.5, 0.5, 0.5) end
function o:UpdateState(evt) o.Btn_UpdateState(self, evt) end
function o:UpdateAnimation() o.Btn_UpdateAnimation(self) end
function o:UpdateFlash() o.Btn_UpdateFlash(self) end
function o:UpdateCount() self.widget:UpdateCount() end

function o:UpdateTexture()
  self.widget:IfActionTexture(function(icon) self.icon:SetTexture(icon) end)
end

function o:EnableFlashAnimation() self.widget:EnableFlashAnimation() end
function o:DisableFlashAnimation() self.widget:DisableFlashAnimation() end
function o:AnyDown() self:RegisterForClicks('AnyDown') end
function o:Any() self:RegisterForClicks('AnyDown', 'AnyUp') end
function o:SetButtonStateNormal() self:SetButtonState('NORMAL') end
function o:SetButtonStatePushed() self:SetButtonState('PUSHED') end
function o:SetButtonStateDisabled() self:SetButtonState('DISABLED') end
function o:MatchesSpellID(spellID) return self.widget:MatchesSpellID(spellID) end
