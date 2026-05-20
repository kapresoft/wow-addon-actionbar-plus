--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns, O = ns:cns()
local comp, au, unit = O.Compat, O.ActionUtil, O.UnitUtil
local druid, rogue, shammy, priest =
      O.DruidUtil, O.RogueUtil, O.ShamanUtil, O.PriestUtil
local attr, atyp = cns:constants()
local Str_IsBlank = cns:String().IsBlank

local C_IsSpellKnown = C_SpellBook.IsSpellKnown
local C_GetItemCount = C_Item.GetItemCount

local BATTLEPET_MACRO_TEMPLATE = [[/summonpet %s]]

--[[-----------------------------------------------------------------------------
Module::ButtonWidgetMixin
-------------------------------------------------------------------------------]]
--- @see BarsUI_Modules_ABP_2_0
local libName = ns.M.ButtonWidgetMixin()
--- @class ButtonWidgetMixin_ABP_2_0
--- @field __suspendAttributeChangeHandler boolean
--- @field button Button_ABP_2_0_X
--- @field index Index The button index
--- @field barIndex Index The owner frame index
--- @field itemSpellID SpellID @Used for items with spellIDs
local S = {}; ns:Register(libName, S)
--
--- @class ButtonWidget_ABP_2_0 : ButtonWidgetMixin_ABP_2_0
--
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Module::ButtonWidgetMixin (Methods)
-------------------------------------------------------------------------------]]
local o = S

--- @param btn Button_ABP_2_0_X
--- @param btnIndex Index
--- @param parentFrameIndex Index
function o:Init(btn, btnIndex, parentFrameIndex)
  self.button = btn
  self.index = btnIndex
  self.barIndex = parentFrameIndex
end

function o:OnAttributeChanged(name, val)
  if self.__suspendAttributeChangeHandler then return end
  self:UpdateAction(name, val)
end

--- If type is invalid (blank or nil) then return quickly
--- Clear Icon When: type=spell|item|etc and val is invalid (blank or nil)
--- @see ApplyButtonConfig()
--- @param name Name
--- @param val string
function o:UpdateAction(name, val)
  if not au.IsSupportedAction(name) then return end
  if Str_IsBlank(val) then self.button.icon:SetTexture(nil); return end
  self.button:Update()
end

function o:UpdateCount()
  local btn = self.button
  local countText = btn.Count
  if not countText then return end

  local typeVal, id = self:GetActionInfo()
  if not id then countText:SetText(''); return end

  local count = ''
  if au.IsItem(typeVal) then
    au.IfItem(id, function(itemInfo)
      -- includeBank=false, includeUses=true (captures charges), includeReagentBank=false
      local n = C_GetItemCount(id, false, true, false) or 0
      if n > 1 then count = n end
    end)
  elseif au.IsSpell(typeVal) then
    au.IfSpellCharges(id, function(spId, spc)
      local current, max = spc.currentCharges, spc.maxCharges
      if current and max and max > 1 and current > 0 then count = current end
    end)
  end
  countText:SetText(count)
end

--- @return boolean
function o:IsEmpty() return Str_IsBlank(self:GetAttribute(attr.type)) end

--- Has a valid action
--- @return boolean @If hasAction
--- @return string? @If {hasAction} is true -- the action type; 'spell', 'item', etc..
--- @return ActionValue? @The {hasAction} is true -- the ; spellID, itemID, etc
function o:HasAction()
  local actionType = self:GetAttribute(attr.type)
  if not actionType then return false end
  --- @type ActionValue
  local val = self:GetActionAttributeTypeValue(actionType)
  return type(val) ~= nil, actionType, val
end

--- @param callbackFn fun(typeVal:string, value:ActionValue) : void
--- @param callbackElseFn fun(typeVal:string, value:ActionValue) : void
function o:IfAction(callbackFn, callbackElseFn)
  assert(type(callbackFn) == 'function', 'IfAction(callbackFn): {callbackFn} should be a function')
  local hasAction, typ, val = self:HasAction()
  if hasAction then
    callbackFn(typ, val)
  elseif type(callbackElseFn) == 'function' then
    callbackElseFnFn(typ, val)
  end
end

--- Loads/Applies saved button config to secure
--- attributes and resets visuals if config is invalid.
function o:LoadAction()
  local btn = self.button
  btn:SetButtonStateNormal()

  --- @type ButtonConfig_ABP_2_0
  local bc = btn:GetButtonConfig()
  if not (bc and bc.type and bc.id) then self:ResetButton(); return end
  if au.IsSpell(bc.type) then
    -- mainline mounts are also spells
    if type(bc.id) == 'number' then
      local known, nextKnownSp = au.IsSpellKnown(bc.id)
      if not known then
        if nextKnownSp then bc.id = nextKnownSp.spellID
        else bc.id = nil end
      end
    end
    if bc.id then self:SetActionSpell(bc.id) end
  elseif au.IsItem(bc.type) then
     self:SetActionItem(bc.id)
  elseif au.IsBattlePet(bc.type) then
    self:SetActionBattlePet(bc.id)
  end
end

--- Converts cursor drag state into button config
--- and applies secure attributes.
--- @param cursor Cursor_ABP_2_0
function o:SaveAction(cursor)
  if not cursor then return end
  --- @type ButtonConfig_ABP_2_0
  local c = self:conf()
  c.type = cursor.type

  if cursor:IsSpell() then
    au.IfSpell(cursor:GetSpellID(), function(spell)
      self:SetActionSpell(spell.spellID)
      c.id = spell.spellID
    end)
  elseif cursor:IsItem() then
    au.IfItem(cursor:GetItemID(), function(itemInfo)
      self:SetActionItem(itemInfo.id)
      c.id = itemInfo.id
    end)
  elseif cursor:IsMount() then
    comp:IfMount(cursor:GetMountID(), function(mount)
      c.type = atyp.spell
      c.id = mount.spellID
      self:SetActionSpell(c.id)
    end)
  elseif cursor:IsBattlePet() then
    c.id = cursor.battlePetID
    self:SetActionBattlePet(c.id)
  end

  self.button:UpdateState('SetActionFromCursor')
  self.button:UpdateFlash()
  self.button:UpdateAnimation()
  self.button:UpdateUsable()
end

function o:ResetButton()
  self.itemSpellID = nil
  self:__ResetAttributes()
  self:__ResetVisuals()
end

--- @private
--- Reset button UI to original empty state
function o:__ResetVisuals()
  local btn = self.button
  -- Clear icon
  if btn.icon then
    btn.icon:SetTexture(nil)
    btn:SetIconNormalVertex()
  end
  
  -- Clear cooldown
  if btn.cooldown then
    btn.cooldown:Clear()
  end
  
  -- Clear checked state
  btn:SetChecked(false)
  btn:SetButtonStateNormal()
  
  btn.widget:DisableFlashAnimation()

  -- Remove any desaturation
  if btn.icon then btn.icon:SetDesaturated(false) end

  btn.Count:SetText('')
end

--- @private
function o:__ResetAttributes()
  self.__suspendAttributeChangeHandler = true
  pcall(self.__ClearActionAttributes, self)
  self.__suspendAttributeChangeHandler = false
end

--- @private
function o:__ClearActionAttributes()
  for _, attrib in pairs(atyp) do self:SetAttribute(attrib, nil) end
  for _, attrib in pairs(attr) do self:SetAttribute(attrib, nil) end
end

--- @return string?, ActionValue? @The type (e.g. spell, item) and resolved typeID (spellID/itemID)
function o:GetActionInfoCustom()
  local typ = self:GetAttributeTypeCustom()
  if not typ then return nil end

  --- @type ActionValue
  local val = self:GetActionAttributeTypeValue(typ)
  if not val then return nil end

  if au.IsBattlePet(typ) then
    return typ, val
  end

  return nil
end

--- Returns info for a known spell.  An unknown spell will return nil values.
--- @return string?, ActionValue? @The type (e.g. spell, item) and resolved typeID (spellID/itemID)
function o:GetActionInfo()
  local typ = self:GetAttributeType()
  if not typ then return nil end

  local val = self:GetActionAttributeTypeValue(typ)
  if not val then return nil end

  if type(val) == "number" then return typ, val end

  if type(val) == "string" then
    if au.IsSpell(typ) then
      local sp = comp:GetSpellInfo(val)
      if not sp then return nil end
      return typ, sp.spellID
    elseif au.IsItem(typ) then
      local itemID = self:GetAttributeItemID()
      return typ, itemID
    elseif au.IsMacro(typ) then
      local c_actionType, c_val = self:GetActionInfoCustom()
      if c_actionType and c_val then
        return c_actionType, c_val
      else
        error(self.button:GetName() .. ':: GetActionInfo(): macro support not implemented')
      end
    end
  end

  return nil
end

--- #### NOTES:
--- - Druid prowl is a normal spell
--- - Shaman Ghost Wolf form is not a real form, but it does honor GetShapeshiftForm() when active.
--- - Rogue stealth, warrior stance, pally blessings, etc.. are treated as forms in MoPs+
--- @return TextureIcon?
function o:GetActionTexture()
  local btn = self.button

  local typ, val = self:GetActionInfo()
  if not val then return nil end

  local iconID, shouldDim = nil, false
  if au.IsSpell(typ) then
    local isShapeshiftSpell, active, activeIcon = unit:IsShapeShiftSpell(val)
    if druid:IsProwl(val) and unit:IsStealthActive() then
      iconID = unit:GetStealthedIcon()
    elseif isShapeshiftSpell and active then
      iconID, shouldDim = self:GetShapeshiftSpellActionTexture(val, active, activeIcon)
    else
      local info = comp:GetSpellInfo(val)
      if info then iconID = info.iconID end
    end
  elseif au.IsItem(typ) then
    au.IfItem(self:GetAttributeItemID(), function(itemInfo)
      iconID = itemInfo.icon
    end)
  elseif au.IsBattlePet(typ) then
    local petID = self:GetAttributeTypeValueCustom()
    comp:IfPet(petID, function(pet)
      iconID = pet.icon
    end)
  end

  if shouldDim then btn:DimIcon()
  else btn:SetIconNormalVertex()
  end

  return iconID
end

--- @param spellID SpellID
--- @param shapeshiftSpellActive boolean
--- @param activeIcon Icon
--- @return Icon, boolean @Icon and whether it should be dimmed
function o:GetShapeshiftSpellActionTexture(spellID, shapeshiftSpellActive, activeIcon)
  local formOrStealthActive = isShapeshiftSpell == true
  local iconID, shouldDim = activeIcon, false

  if unit:IsStealthActive()
      and (druid:IsProwl(spellID) or rogue:IsStealth(spellID)) then
    -- Druid and Rogue use the same stealth icon
    shouldDim, iconID = true, unit:GetStealthedIcon()
  elseif shapeshiftSpellActive then
    if unit:IsPriest() then
      iconID = priest:GetActiveShapeshiftFormIcon()
    else
      -- in MoP, rogue stealth is a shapeshift form
      -- druid and rogues have the same shapeshift form active icon
      iconID = unit:GetActiveShapeshiftFormIcon()
    end
  end

  return iconID, shouldDim
end

--- @param callbackFn fun(icon:Icon):void
function o:IfActionTexture(callbackFn)
  local icon = self:GetActionTexture()
  if not icon then return end
  callbackFn(icon)
end

function o:ClearAttributeType() self:SetAttribute(attr.type, nil) end
--- @return string
function o:GetAttributeType() return self.button:GetAttribute(attr.type) end

--- @return string
function o:GetAttributeTypeCustom() return self.button:GetAttribute(attr.abp_type) end
--- @return string|number?
function o:GetAttributeTypeValueCustom()
  local typ = self:GetAttributeTypeCustom()
  if not typ then return end; return self:GetAttribute(typ)
end

--- Temporarily suspends the button's secure action.
---
--- The current `type` attribute is saved to a global ABP attribute and then
--- cleared from the button. Clearing `type` prevents the SecureActionButton
--- from executing its action while we perform drag, pickup, or cursor swap
--- operations.
---
--- This is called from PreClick() and drag handlers before manipulating the
--- cursor or replacing the button's action.
function o:SuspendAction()
  local typ = self:GetAttributeType()
  if not typ then return end

  cns:SetGlobalAttribute(attr.suspended_type, typ)
  local val = cns:GetGlobalAttribute(attr.suspended_type)
  self:ClearAttributeType()
end

--- Returns the action type temporarily suspended during drag/cursor operations.
--- This value is saved when SuspendAction() clears the button's `type`
--- so the button does not execute its secure action while we perform
--- pickup / swap logic. Used by PreClick/PostClick and drag handlers.
--- @return string?
function o:GetAttributeSuspendedActionType()
  return cns:GetGlobalAttribute(attr.suspended_type)
end

--- Clears the globally stored suspended action type.
--- This value is set by SuspendAction() during PreClick/drag so the button's
--- `type` attribute can be temporarily removed without losing the original
--- action. Once the swap/apply operation is complete, this value must be
--- cleared to avoid leaking stale drag state across buttons.
function o:ClearAttributeSuspendedActionType()
  cns:ClearGlobalAttribute(attr.suspended_type)
end

--- @return ItemID?
function o:GetAttributeItemID()
  return au.GetAttributeItemID(self:GetAttribute(atyp.item))
end

--- @return SpellName|SpellID
function o:GetAttributeSpell() return self:GetAttribute(atyp.spell) end

--- @return PetGUID?
function o:GetAttributeBattlePetID()
  return self:GetAttribute(atyp.battlepet) --[[@as PetGUID]]
end

function o:MatchesSpellID(spellID)
  local _, id = self:GetActionInfo()
  return spellID == id or spellID == self.itemSpellID
end

function o:GetDebugName()
  return ('%s(Widget):: index=%s frameIndex=%s')
      :format(self.button:GetName(), self.index, self.barIndex)
end

--- @param spellID SpellID
function o:SetActionSpell(spellID)
  if LE_EXPANSION_LEVEL_CURRENT >= LE_EXPANSION_MISTS_OF_PANDARIA then
    return self:SetActionSpellByName(spellID)
  end
  self:SetAttribute(attr.type, atyp.spell)
  local isShapeShiftSpell = unit:IsShapeShiftSpell(spellID)
  if isShapeShiftSpell or au.IsTalentSpell(spellID) then
    au.IfSpell(spellID, function(spell)
      self:SetAttribute(atyp.spell, spell.name)
    end)
  else
    self:SetAttribute(atyp.spell, spellID)
  end
end

--- BattlePet is a custom action implementation that uses `/summonpet {petGUID}`
--- @param battlePetID PetGUID
function o:SetActionBattlePet(battlePetID)
  assert(type(battlePetID) == 'string', 'SetActionBattlePet(battlePetID): {battlePetID} should be a GUID:String')

  local macroText = BATTLEPET_MACRO_TEMPLATE:format(battlePetID)
  local typ = atyp.battlepet
  self:SetAttribute(attr.abp_type, typ)
  self:SetAttribute(typ, battlePetID)
  self:SetAttribute(attr.type, atyp.macro)
  self:SetAttribute(atyp.macrotext, macroText)
end

--- MoP-specific spell attribute setter. In MoP, spells have no ranks, so spell names are
  --- unambiguous and can always be used safely. Some spells (e.g. Mind Flay, spellID 15407)
  --- fail to fire when set by ID because the deprecated IsSpellKnown() returns false for them,
  --- which is what the secure button system uses internally to resolve spells. Setting by name
  --- bypasses this and works reliably for all MoP spells.
--- @param spellID SpellID
function o:SetActionSpellByName(spellID)
  au.IfSpell(spellID, function(spell)
    self:SetAttribute(attr.type, atyp.spell)
    self:SetAttribute(atyp.spell, spell.name)
  end)
end

--- @param itemID ItemID
function o:SetActionItem(itemID)
  self:SetAttribute(attr.type, atyp.item)
  self:SetAttribute(atyp.item, ('%s:%s'):format(atyp.item, itemID))
  self.itemSpellID = comp:GetItemSpell(itemID)
end

--- @param mountInfo MountInfo
function o:SetActionMountRetail(mountInfo)
  self:SetActionSpellByName(mountInfo.spellID)
end

--- @return boolean
function o:IsDragAllowed()
  return not Settings.GetValue('lockActionBars')
                or IsModifiedClick('PICKUPACTION')
end

function o:IsAutoAttacking()
  local typeVal, id = self:GetActionInfo()
  return au.IsAutoAttackInProgress(id)
end

--[[-------------------------------------------------------------------
Delegate Functions
---------------------------------------------------------------------]]
--- @return ButtonConfig_ABP_2_0
function o:conf() return self.button:GetButtonConfig() end

--- @see Frame#GetAttribute
--- @param attributeName string
--- @return string value
function o:GetAttribute(attributeName) return self.button:GetAttribute(attributeName) end

--- @see Frame#GetAttribute
--- @param actionType string
--- @return ActionValue
function o:GetActionAttributeTypeValue(actionType)
  --- @type ActionValue
  local val = self:GetAttribute(actionType)
  -- macro type value can either be attribute 'macro' or 'macrotext'
  if not val and actionType == atyp.macro then
    val = self:GetAttribute(atyp.macrotext)
  end
  return val
end


--- @see Frame#SetAttribute(attributeName, value)
--- @param attributeName string
--- @param value any
function o:SetAttribute(attributeName, value) self.button:SetAttribute(attributeName, value) end

--- @return boolean
function o:RequiresShootAnimation()
  local typeVal, id = self:GetActionInfo()
  if not (typeVal and id) then return false end
  return au.IsSpell(typeVal) and au.IsShootingInProgress(id)
end

--- @return boolean
function o:RequiresAttackAnimation()
  local typeVal, id = self:GetActionInfo()
  if not (typeVal and id) then return false end
  return au.IsSpell(typeVal) and au.IsAutoAttackInProgress(id)
end

function o:ShowOverlayGlow()
  local btn = self.button
  if ActionButtonSpellAlertManager then
    ActionButtonSpellAlertManager:ShowAlert(btn)
  elseif ActionButton_ShowOverlayGlow then
    ActionButton_ShowOverlayGlow(btn)
  end
end

function o:HideOverlayGlow()
  local btn = self.button
  if ActionButtonSpellAlertManager then
    ActionButtonSpellAlertManager:HideAlert(btn)
  elseif ActionButton_HideOverlayGlow then
    ActionButton_HideOverlayGlow(btn)
  end
end

function o:EnableFlashAnimation()
  C_Timer.After(0.3, function() self.button.SpellHighlightAnim:Play() end)
end

function o:DisableFlashAnimation()
  if not self.button.SpellHighlightAnim:IsPlaying() then return end
  self.button.SpellHighlightAnim:Stop()
end

function o:RestoreAction()
  local at = self:GetAttributeSuspendedActionType()
  if not at then return end
  self:SetAttribute(attr.type, at)
  self:ClearAttributeSuspendedActionType()
end

--- @private
--- @param checkFn fun(typeVal:string):boolean
--- @return boolean
function o:__IsAT(checkFn)
  local typeVal, id = self:GetActionInfo()
  if not (typeVal and id) then return false end
  return checkFn(typeVal)
end

--- @return boolean
function o:IsShootSpell()
  return self:__IsAT(function(typ)
    return au.IsSpell(typ) and au.IsShootSpell(self:GetActionInfo())
  end)
end

--- @param callbackFn fun(petID:PetGUID)
--- @return Chain_ABP_2_0
function o:IfBattlePet(callbackFn)
  local typ, id = self:GetActionInfo()
  local match = id and au.IsBattlePet(typ)
  if match then callbackFn(id) end
  return cns:Chain(match)
end

--- @return boolean
function o:IsSpell() return self:__IsAT(au.IsSpell) end
--- @return boolean
function o:IsItem() return self:__IsAT(au.IsItem) end
--- @return boolean
function o:IsMount() return self:__IsAT(au.IsMount) end
--- @return boolean
function o:IsBattlePet()
  --return self:__IsAT(au.IsBattlePet)
  return self:GetAttribute(attr.abp_type) == atyp.battlepet
end


