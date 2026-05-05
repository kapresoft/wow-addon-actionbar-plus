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

--- @class ButtonMixin_ABP_2_0_3 : ButtonState_ABP_2_0, ButtonConfigAccessor_ABP_2_0, SecureActionButtonTemplate, CheckButton, AceEvent-3.0
--- @field NormalTexture TextureObj
--- @field HighlightTexture TextureObj
--- @field PushedTexture TextureObj
--- @field CheckedTexture TextureObj
--- @field SpellHighlightAnim AnimationGroup
--- @field ClearFlash fun():void
--- @field icon TextureObj
--- @field cooldown CooldownObj
--- @field eventsRegistered boolean
--- @field widget ButtonWidget_ABP_2_0
--- @field GetParent fun(self:ButtonMixin_ABP_2_0_3) : BarFrameObj_ABP_2_0
local o = cns:NewAceEvent(); ButtonMixin_ABP_2_0_3 = o

local p, t = ns:log(libName)

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
    self:ResetButtonConfig()
    self.widget:ResetButton()
  end

  if callbackFn then callbackFn() end
end

--- Spells:
--- Attack (6603)
--- @param self Button_ABP_2_0_3
--- @return boolean
local function Btn_ActionRequiresAttackAnim(self)
    local typeVal, spellID = self:GetActionInfo()
    if not (typeVal and spellID) then return false end
    return spellID == 6603
end

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]

-- /dump SetCVar('ActionButtonUseKeyDown', 1)
function o:OnLoad()
  self:SetID(NextSeedID())

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
end

--- @private
--- @param barIndex Index
--- @param btnIndex Index
function o:AfterLoad(btnIndex, barIndex)
  --- @type ButtonWidget_ABP_2_0
  self.widget = CreateFromMixins(ns.O.ButtonWidgetMixin)
  self.widget:Init(self, btnIndex, barIndex)
  Mixin(self, ns.O.ButtonStateMixin, ns.O.ButtonConfigAccessorMixin)

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
  elseif evt == 'PLAYER_LEAVE_COMBAT' then
    self:UpdateState(evt)
    self:DisableAttackingAnimation()
  elseif evt == 'PLAYER_TARGET_SET_ATTACKING' then
    if Btn_ActionRequiresAttackAnim(self) then
      self:SetChecked(true)
      self:EnableAttackingAnimation()
      return
    end
    self:UpdateState(evt)
  elseif evt == 'ACTIONBAR_UPDATE_STATE' then
    self:RepairRetailPushedState()
    self:UpdateState('OnEvent') -- this deselects Cooking, First Aid, Prof Talents
  elseif evt == 'UPDATE_SHAPESHIFT_FORM' or evt == 'UPDATE_STEALTH' then
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

--- Note: checked state is only used for non-instant spells
--- Normal cast:
--  1. UNIT_SPELLCAST_SENT — client sends cast request to server (instant cast)
--  2. UNIT_SPELLCAST_START — cast bar begins (non-instant cast)
--  3. UNIT_SPELLCAST_STOP — cast bar ends (fires regardless of outcome)
--  4. UNIT_SPELLCAST_SUCCEEDED or UNIT_SPELLCAST_FAILED — spell completed successfully or failed
--- Events coming here are matching spellcast events
---@param spellID SpellID The matching spell ID
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
  if InCombatLockdown() then return end
  self:PostClickAction(button, down)
end

--- Only process mouse down events here
--- @param button ButtonName
--- @param down ButtonDown
function o:PreClickAction(button, down)
  if not down or not IsActionbarLockedByUser() then return end
  -- Prepare for a potential drag operation.
  -- When the user begins dragging the button, the secure `type` attribute
  -- must be temporarily suspended so the button does not execute its
  -- action while the drag / pickup transaction is in progress.
  if Btn_ActionShouldFire(down) and self:IsDragAllowed() then
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
      --  todo: handle item
    elseif suspendedType == atyp.macro then
      --  todo: handle macro
    end
  end

  self.widget:ClearAttributeSuspendedActionType()
  self.widget:ApplyCursorAction(cursor)
  self:UpdateState('PostClick')
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

function o:OnLeave() GameTooltip:Hide() end

--- @param button ButtonName
function o:OnDragStart(button)
  if InCombatLockdown() then return false end
  if not self:IsDragAllowed() then return end
  
  Btn_PickupAction(self, function()
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
  if existingType == atyp.spell then
    --t('Drag', 'ORcvDrag', 'existingType=', existingType, 'existingID=', existingID)
    comp:PickupSpell(existingID)
    self.widget:ApplyCursorAction(cursor)
    return
  end
  
  self.widget:ApplyCursorAction(cursor)
  self:UpdateState('OnReceiveDrag')
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
  local _type, id = self:GetActionInfo()
  if not id then return nil end
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
  end)
  return icon
end

--[[-------------------------------------------------------------------
Convenience Methods
---------------------------------------------------------------------]]
function o:UpdateCooldown()
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
    start, duration, enable = c:GetItemCooldown(id)
  else
    cd:Clear()
    return
  end
  if not start or not duration then cd:Clear(); return end
  --cd.currentCooldownType = COOLDOWN_TYPE_NORMAL
  cd:SetCooldown(start, duration, modRate or 1)
end

--- Returns info for a known spell.  An unknown spell will return nil values.
--- @return string|nil, number|nil The type (e.g. spell, item) and resolved typeID (spellID/itemID)
function o:GetActionInfo()
  local actionType = self:GetAttribute(attr.type)
  if not actionType then return nil, nil end
  
  --- @type number|string|nil
  local val = self:GetAttribute(actionType)
  if not val then return nil, nil end
  
  if type(val) == "number" then return actionType, val end
  
  if type(val) == "string" then
    if actionType == atyp.spell then
      local sp = comp:GetSpellInfo(val)
      if not sp then return nil, nil end
      return actionType, sp.spellID
    elseif actionType == atyp.item then
      error(self:GetName() .. ':: GetActionInfo(): item support not implemented')
    elseif actionType == atyp.macrotext then
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

