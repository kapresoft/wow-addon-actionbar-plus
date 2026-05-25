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
local String = cns:String()
local Str_IsBlank, Str_IsAnyOf = String.IsBlank, String.IsAnyOf

local C_IsSpellKnown = C_SpellBook.IsSpellKnown
local C_GetItemCount = C_Item.GetItemCount

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

  --- @type ActionType?, boolean?
  local typ, isCustom = self:GetActionType()
  if not typ then countText:SetText(''); return end

  local count = ''

  if not isCustom then
    local val = self:GetActionValueByType(typ)
    if au.IsItem(typ) then
      val = self:GetAttributeItemID()
      au.IfItem(val, function(itemInfo)
        -- includeBank=false, includeUses=true (captures charges), includeReagentBank=false
        local n = C_GetItemCount(itemInfo.id, false, true, false) or 0
        if n > 1 then count = n end
      end)
    elseif au.IsSpell(typ) then
      au.IfSpellCharges(val, function(spId, spc)
        local current, max = spc.currentCharges, spc.maxCharges
        if current and max and max > 1 and current > 0 then count = current end
      end)
    end
  end

  countText:SetText(count)
end

--- @return boolean
function o:IsEmpty() return Str_IsBlank(self:GetAttribute(attr.type)) end

--- @param callbackFn fun(typ:ActionType, val:ActionValue, isCustom:boolean) : void
--- @return Chain_ABP_2_0
function o:IfHasAction(callbackFn)
  assert(type(callbackFn) == 'function', 'IfHasAction(callbackFn): {callbackFn} should be a function')
  local typ, val, isCustom = self:GetActionInfo()
  local typValMatched = (typ ~= nil and val ~= nil)
  if typValMatched then callbackFn(typ, val, isCustom == true) end
  return cns:Chain(typValMatched)
end

--- @param callbackFn fun(typ:ActionType, val:ActionValue) : void
--- @return Chain_ABP_2_0
function o:IfCustomAction(callbackFn)
  assert(type(callbackFn) == 'function', 'IfCustomAction(callbackFn): {callbackFn} should be a function')
  local typ, val, isCustom = self:GetActionInfo()
  local typValMatched = (typ ~= nil and val ~= nil)
  local matched = typValMatched and isCustom == true
  if matched then callbackFn(typ, val) end
  -- regular action
  return cns:Chain(typValMatched, typ, val)
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
  elseif au.IsMount(bc.type) then
    btn.Btn_SetActionMount(btn, bc.id)
  elseif au.IsBattlePet(bc.type) then
    btn.Btn_SetActionBattlePet(btn, bc.id)
  elseif au.IsEquipmentSet(bc.type) then
    btn.Btn_SetActionEquipmentSet(btn, bc.id)
  end
end

--- Converts cursor drag state into button config
--- and applies secure attributes.
--- @param cursor Cursor_ABP_2_0
function o:SaveAction(cursor)
  if not cursor then return end

  local btn = self.button
  --- @type ButtonConfig_ABP_2_0
  local bc = self:conf()
  bc.type = cursor.type

  if cursor:IsSpell() then
    au.IfSpell(cursor.spellID, function(spell)
      self:SetActionSpell(spell.spellID)
      bc.id = spell.spellID
    end)
  elseif cursor:IsItem() then
    au.IfItem(cursor.itemID, function(itemInfo)
      self:SetActionItem(itemInfo.id)
      bc.id = itemInfo.id
    end)
  elseif cursor:IsMount() then
  elseif cursor:IsMount() then
    bc.type = atyp.mount
    bc.id = cursor.mountID
    btn.Btn_SetActionMount(btn, bc.id)
  elseif cursor:IsBattlePet() then
    bc.id = cursor.battlePetID
    btn.Btn_SetActionBattlePet(btn, bc.id)
  elseif cursor:IsEquipmentSet() then
    bc.id = cursor.equipmentSetID
    btn.Btn_SetActionEquipmentSet(btn, bc.id)
  end

  btn:UpdateState('SetActionFromCursor')
  btn:UpdateFlash()
  btn:UpdateAnimation()
  btn:UpdateUsable()
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
  pcall(self.ClearActionAttributes, self)
  self.__suspendAttributeChangeHandler = false
end

function o:ClearActionAttributes()
  self.button:ClearAttributes()
end

--- @return ActionType?   @The blizzard standard type, i.e. equipmentset
--- @return ActionValue?  @The action value, i.e. (spellID, equipmentSetID, etc)
function o:GetActionInfoCustom()
  local typ = self:GetAttribute(attr.abp_type)
  if not typ then return nil end

  --- @type ActionValue
  local val = self:GetAttribute(typ)
  if not val then return nil end

  return self:__GetNormalizedType(typ), val
end

--- @return ActionType? boolean?  @The ActionType, either the attribute 'type' or 'abp_type'
--- @return boolean?              @Returns true if the actionType is a custom action-type
function o:GetActionType()
  local typ = self:__GetAttributeTypeCustomNormalized()
  if typ then return typ, true end
  return self:GetAttributeType()
end

--- Returns info for a known spell.  An unknown spell will return nil values.
--- @return ActionType?
--- @return ActionValue?
--- @return boolean?
function o:GetActionInfo()
  -- todo next: Cleanup GetActionInfo() or remove?

  --- @type ActionType, ActionValue
  local typ, val = self:GetActionInfoCustom()
  if typ and val then return typ, val, true end

  typ = self:GetAttributeType()
  if not typ then return nil end

  val = self:GetActionValueByType(typ)
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
    --tbd elseif au.IsMacro(typ) then
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

  --- @type ActionType?, boolean?
  local typ, isCustom = self:GetActionType()
  if not typ then return nil end

  local iconID, shouldDim = nil, false

  if not isCustom then
    --- @type ActionValue
    local val = self:GetActionValueByType(typ)
    if au.IsSpell(typ) then
      comp:IfSpell(val, function(sp)
        local spid = sp.spellID
        local isShapeshiftSpell, active, activeIcon = unit:IsShapeShiftSpell(spid)
        if druid:IsProwl(spid) and unit:IsStealthActive() then
          iconID = unit:GetStealthedIcon()
        elseif isShapeshiftSpell and active then
          iconID, shouldDim = self:GetShapeshiftSpellActionTexture(spid, active, activeIcon)
        else
          local info = comp:GetSpellInfo(spid)
          if info then iconID = info.iconID end
        end
      end)
    elseif au.IsItem(typ) then
      au.IfItem(self:GetAttributeItemID(), function(itemInfo)
        iconID = itemInfo.icon
      end)
    end
  else
    --- @type ActionValue
    local val = self:GetActionValueCustom()
    if au.IsMount(typ) then
      comp:IfMount(val, function(mount)
          iconID = mount.icon
      end)
    elseif au.IsBattlePet(typ) then
      comp:IfPet(val, function(pet)
        iconID = pet.icon
      end)
    elseif au.IsEquipmentSet(typ) then
      local es = comp:GetEquipmentSet(val)
      iconID = es and es.iconID
    end
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

--- @return ActionTypeName
function o:GetAttributeType() return self:GetAttribute(attr.type) end

--- Returns the normalized custom action type; strips abp prefix e.g. abp_equipmentset → equipmentset
--- @private
--- @return string? @The custom action type without the 'abp_' prefix, e.g. 'equipmentset'; a normalized value
function o:__GetAttributeTypeCustomNormalized()
  return self:__GetNormalizedType(self:GetAttribute(attr.abp_type))
end

--- @param abp_type ActionTypeName
--- @return ActionType?             @The custom action type without the 'abp_' prefix, e.g. 'equipmentset'
function o:__GetNormalizedType(abp_type)
  if not abp_type then return nil end
  return abp_type:sub(1, 4) == 'abp_' and abp_type:sub(5) or abp_type
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
  self:ClearAttributeType()
end

--- Returns the action type temporarily suspended during drag/cursor operations.
--- This value is saved when SuspendAction() clears the button's `type`
--- so the button does not execute its secure action while we perform
--- pickup / swap logic. Used by PreClick/PostClick and drag handlers.
--- @return ActionType? @The suspended action type
--- @return boolean?    @Returns true if the {ActionType} is a custom action type
function o:GetAttributeSuspendedActionType()
  return cns:GetGlobalAttribute(attr.suspended_type),
      not Str_IsBlank(self:__GetAttributeTypeCustomNormalized())
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

--- Used for setting attributes with values in one method
--- ```
--- btn:SetAttribute('type', 'spell')
--- btn:SetAttribute('spell', <spellID>)
--- ```
--- @param typ ActionTypeName
--- @param val ActionValue? @Can be a nil
function o:SetActionAttribute(typ, val)
  local _type = type(typ)
  assert(_type == 'string', 'SetActionAttribute(typ, value): {typ} should be a string; spell, item, etc. ')

  self:SetAttribute(attr.type, typ)
  self:SetAttribute(typ, val)
end

--- @param typ ActionType? @Can be a nil
--- @param val ActionValue? @Can be a nil
function o:SetActionAttributeCustom(typ, val)
  assert(type(typ) == 'string', 'SetActionAttributeCustom(typ, val): {typ} should be a string; spell, item, etc. ')

  local typ_custom = 'abp_' .. typ
  self:SetAttribute(attr.abp_type, typ_custom)
  self:SetAttribute(typ_custom, val)
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

--[[-------------------------------------------------------------------
Delegate Functions
---------------------------------------------------------------------]]
--- @return ButtonConfig_ABP_2_0
function o:conf() return self.button:GetButtonConfig() end

--- @see Frame#GetAttribute
--- @param attributeName string
--- @return string value
function o:GetAttribute(attributeName) return self.button:GetAttribute(attributeName) end

--- Use this method for standard blizzard action attributes
--- @see Frame#GetAttribute
--- @param actionType string
--- @return ActionValue? @The blizzard action value
function o:GetActionValueByType(actionType)
  assert(type(actionType) == 'string', 'GetActionAttributeTypeValue(actionType): {actionType} should be a string')
  --- @type ActionValue
  local val = self:GetAttribute(actionType)
  -- macro type value can either be attribute 'macro' or 'macrotext'
  if not val and actionType == atyp.macro then
    val = self:GetAttribute(atyp.macrotext)
  end
  return val
end

--- Use this method for custom action attributes
--- @return ActionValue?
function o:GetActionValueCustom()
  local abp_type = self:GetAttribute(attr.abp_type)
  return abp_type and self:GetAttribute(abp_type)
end

--- @see Frame#SetAttribute(attributeName, value)
--- @param attributeName string
--- @param value any
function o:SetAttribute(attributeName, value) self.button:SetAttribute(attributeName, value) end

--- @return boolean
function o:RequiresShootAnimation()
  local typ, val = self:GetActionInfo()
  if not (typ and val) then return false end
  return au.IsSpell(typ) and au.IsShootingInProgress(val)
end

--- @return boolean
function o:RequiresAttackAnimation()
  local typ, val = self:GetActionInfo()
  if not (typ and val) then return false end
  return au.IsSpell(typ) and au.IsAutoAttackInProgress(val)
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

--- Is Action Type Check
--- @private
--- @param checkFn fun(typ:ActionType, val:ActionValue):boolean
--- @return boolean
function o:__IsAT(checkFn)
  local typ, val = self:GetActionInfo()
  if not (typ and val) then return false end
  return checkFn(typ, val)
end

--- @return boolean
function o:IsShootSpell()
  return self:__IsAT(function(typ, val)
    return au.IsSpell(typ) and au.IsShootSpell(val)
  end)
end

--- @param callbackFn fun(petID:PetGUID)
--- @return Chain_ABP_2_0
function o:IfBattlePet(callbackFn)
  local typ, val = self:GetActionInfo()
  local match = val and au.IsBattlePet(typ)
  if match then callbackFn(val) end
  return cns:Chain(match)
end

--- @return boolean
function o:IsSpell() return self:__IsAT(au.IsSpell) end
--- @return boolean
function o:IsItem() return self:__IsAT(au.IsItem) end
--- @return boolean
function o:IsMount() return self:__IsAT(au.IsMount) end
--- @return boolean
function o:IsBattlePet() return self:__IsAT(au.IsBattlePet) end
--- @return boolean
function o:IsEquipmentSet() return self:__IsAT(au.IsEquipmentSet) end

--@debug@
--- DEBUG ONLY
--- Returns a snapshot of non-nil secure attributes as an array of 'key="value"' strings.
function o:a()
  local snap = {}
  for _, key in pairs(attr) do
    snap[key] = self.button:GetAttribute(key)
  end
  for _, key in pairs(atyp) do
    snap[key] = self.button:GetAttribute(key)
    local abpKey = 'abp_' .. key
    snap[abpKey] = self.button:GetAttribute(abpKey)
  end
  return snap
end
--@end-debug@
