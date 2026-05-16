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
--- @return number? @The {hasAction} is true -- the ActionID; spellID, itemID, etc
function o:HasAction()
  local actionType = self:GetAttribute(attr.type)
  if not actionType then return false end
  --- @type number
  local id = self:GetAttribute(actionType)
  return type(id) ~= nil, actionType, id
end

--- @param callbackFn fun(typeVal:string, id:ActionID) : void
--- @param callbackElseFn fun(typeVal:string, id:ActionID) : void
function o:IfAction(callbackFn, callbackElseFn)
  assert(type(callbackFn) == 'function', 'IfAction(callbackFn): {callbackFn} should be a function')
  local hasAction, typeVal, id = self.widget:HasAction()
  if hasAction then
    callbackFn(typeVal, id)
  elseif type(callbackElseFn) == 'function' then
    callbackElseFnFn(typeVal, id)
  end
end

--- Applies saved button config to secure
--- attributes and resets visuals if config is invalid.
function o:ApplyButtonConfig()
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
  end
end

--- Converts cursor drag state into button config
--- and applies secure attributes.
--- @param cursor Cursor_ABP_2_0
function o:SetActionFromCursor(cursor)
  if not cursor then return end
  --- @type ButtonConfig_ABP_2_0
  local btnC = self:conf()
  btnC.type = cursor.type

  if cursor:IsSpell() then
    au.IfSpell(cursor:GetSpellID(), function(spell)
      self:SetActionSpell(spell.spellID)
      btnC.id = spell.spellID
    end)
  elseif cursor:IsItem() then
    au.IfItem(cursor:GetItemID(), function(itemInfo)
      self:SetActionItem(itemInfo.id)
      btnC.id = itemInfo.id
    end)
  elseif cursor:IsMount() then
    local mountID = cursor:GetMountID()
    comp:IfMount(mountID, function(mount)
      btnC.type = atyp.spell
      btnC.id = mount.spellID
      self:SetActionSpell(btnC.id)
    end)
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
  self:SetAttribute(attr.type, nil)
  self:ClearAttributeSuspendedActionType()
  for _, typeAttribute in ipairs(atyp) do
    self:SetAttribute(typeAttribute, nil)
  end
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
      local itemID = self:GetAttributeItemID()
      return actionType, itemID
    elseif au.IsMacro(actionType) then
      error(self.button:GetName() .. ':: GetActionInfo(): macro support not implemented')
    end
  end

  return nil, nil
end

--- #### NOTES:
--- - Druid prowl is a normal spell
--- - Shaman Ghost Wolf form is not a real form, but it does honor GetShapeshiftForm() when active.
--- - Rogue stealth, warrior stance, pally blessings, etc.. are treated as forms in MoPs+
--- @return TextureIcon?
function o:GetActionTexture()
  local btn = self.button
  local typeVal, id = self:GetActionInfo()
  if not id then return nil end
  if au.IsMount(typeVal) then return end

  local iconID, shouldDim = nil, false
  if au.IsSpell(typeVal) then
    local isShapeshiftSpell, active, activeIcon = unit:IsShapeShiftSpell(id)
    if druid:IsProwl(id) and unit:IsStealthActive() then
      iconID = unit:GetStealthedIcon()
    elseif isShapeshiftSpell and active then
      iconID, shouldDim = self:GetShapeshiftSpellActionTexture(id, active, activeIcon)
    else
      local info = comp:GetSpellInfo(id)
      if info then iconID = info.iconID end
    end
  elseif au.IsItem(typeVal) then
    au.IfItem(self:GetAttributeItemID(), function(itemInfo)
      iconID = itemInfo.icon
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
function o:GetAttributeType() return self.button:GetAttribute(attr.type) end

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
  local at = self:GetAttributeType()
  if not at then return end
  cns:SetGlobalAttribute(attr.suspended_type, self:GetAttributeType())
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

function o:GetAttributeItemID() return au.GetAttributeItemID(self:GetAttribute('item')) end

--- Clears the globally stored suspended action type.
--- This value is set by SuspendAction() during PreClick/drag so the button's
--- `type` attribute can be temporarily removed without losing the original
--- action. Once the swap/apply operation is complete, this value must be
--- cleared to avoid leaking stale drag state across buttons.
function o:ClearAttributeSuspendedActionType()
  cns:ClearGlobalAttribute(attr.suspended_type)
end

--function o:RestoreAttributeType()
--  if not self:GetAttributeDraggedType() then return end
--  self:SetAttribute(attr.type, self:GetAttribute(attr.saved_type))
--  self:SetAttribute(attr.saved_type, nil)
--end

function o:GetAttributeSpell() return self:GetAttribute(atyp.spell) end

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

--- @see Frame#SetAttribute(attributeName, value)
--- @param attributeName string
--- @param value any
function o:SetAttribute(attributeName, value) self.button:SetAttribute(attributeName, value) end

--- @return boolean
function o:IsShootSpell()
  local typeVal, id = self:GetActionInfo()
  if not (typeVal and id) then return false end
  return au.IsSpell(typeVal) and au.IsShootSpell(id)
end

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
