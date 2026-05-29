--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)

local cns = ns:cns()
local O = cns.O
local attr, atyp = cns:constants()
local au = O.ActionUtil
local comp, spu, unit, hu = O.Compat, O.SpellUtil, O.UnitUtil, O.HashUtil

local BATTLEPET_MACRO_TEMPLATE = [[/summonpet %s]]
local EQUIPMENT_SET_TEMPLATE = [[/equipset %s]] -- %s is the name without quotes

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'ButtonHandlerMixin'
--- @class ButtonHandlerMixin_ABP_2_0
local o = ns:NewLib(libName)
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]
--- @return boolean
function o.IsActionbarLockedByUser() return Settings.GetValue("lockActionBars") end

--- @param self Button_ABP_2_0_X
--- @param down boolean
--- @return boolean
function o.Btn_ActionShouldFire(self, down)
  if o.IsActionbarLockedByUser() then return down == true end
  return down ~= true
end

--- @param self Button_ABP_2_0_X
function o.Btn_ResetAll(self)
  self:ResetButtonConfig()
  self.widget:ResetButton()
end

--- @param self Button_ABP_2_0_X
function o.Btn_UpdateUsable(self)
  self.widget:IfHasAction(function(typ, val, isCustom)
    local icon = self.icon

    --- @type boolean, boolean
    local isUsable, notEnoughMana = au.IsUsableAction(typ, val, isCustom)

    if isUsable then
      self:SetIconNormalVertex()
    elseif notEnoughMana then
      icon:SetVertexColor(0.5, 0.5, 1.0)
    else
      icon:SetVertexColor(0.4, 0.4, 0.4);
    end
  end)
end

--- @param self Button_ABP_2_0_X
--- @param typ ActionType
--- @param isCustom boolean
--- @param callbackFn fun() : void
function o.Btn_DispatchPickupAction(self, typ, isCustom, callbackFn)
  if not typ then return end

  --- @type ActionValue
  local val

  if not isCustom then
    val = self.widget:GetActionValueByType(typ)
    if au.IsSpell(typ) then
      comp:PickupSpell(val)
    elseif au.IsItem(typ) then
      comp:PickupItem(val)
    elseif au.IsMacro(typ) then
      comp:PickupMacro(val)
    end
  else
    typ, val = self.widget:GetActionInfoCustom()
    if au.IsMount(typ) then
      comp:PickupMount(val)
    elseif au.IsBattlePet(typ) then
      comp:PickupBattlePet(val)
    elseif au.IsEquipmentSet(typ) then
      comp:PickupEquipmentSet(val)
    end
  end

  self:IfHasCursor(function(cursor) o.Btn_ResetAll(self) end)
  if callbackFn then callbackFn() end
end

--- @param self Button_ABP_2_0_X
--- @param callbackFn fun() : void
function o.Btn_PickupAction(self, callbackFn)
  --- @type ActionType, boolean
  local typ, isCustom = self.widget:GetAttributeSuspendedActionType()
  o.Btn_DispatchPickupAction(self, typ, isCustom, callbackFn)
end

--- @see Button_ABP_2_0_3.OnReceiveDrag
--- @param self Button_ABP_2_0_X
function o.Btn_PickupExistingAction(self)
  --- @type ActionType, boolean?
  local typ, isCustom = self.widget:GetActionType()
  o.Btn_DispatchPickupAction(self, typ, isCustom)
end

--- Update the button's checked state
--- @param self Button_ABP_2_0_X
--- @param evt Name @The event name
function o.Btn_UpdateState(self, evt)
  self.widget:IfHasAction(function(typ, val, isCustom)
    local isCurrent = au.IsCurrentAction(typ, val)
    self:SetChecked(isCurrent == true)
  end)
end

--- Update the macro button texture repeatedly to catch castsequence icon changes
--- @param self Button_ABP_2_0_X
--- @param evt Name             @The event name
--- @param tickerCount? number  @The number of iterations (optional)
function o.Btn_UpdateTextureMacro(self, evt, tickerCount)
  local count = 0
  local loopCount = tickerCount or 8
  C_Timer.NewTicker(0.1, function(ticker)
      count = count + 1
      self:UpdateTexture()
      if count >= loopCount then ticker:Cancel() end
  end)
end

--- @param self Button_ABP_2_0_X
function o.Btn_OnEnterGameTooltip(self)

  local typ, val, isCustom = self.widget:GetActionInfo()
  if not (typ and val) then return end

  --todo: GameTooltip owner will be user configurable
  GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
  GameTooltip:ClearAllPoints()
  GameTooltip:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -10, 70)
  o.Btn_OnGameTooltip(self, typ, val, isCustom)
end

--- @param self Button_ABP_2_0_X
--- @param typ ActionType
--- @param val ActionValue
--- @param isCustom? boolean
function o.Btn_OnGameTooltip(self, typ, val, isCustom)

  --- @type FontStringObj
  local right = _G["GameTooltipTextRight1"]

  if not isCustom then
    if au.IsSpell(typ) then
      comp:IfSpell(val, function(spell)
        local spid = spell.spellID
        GameTooltip:SetSpellByID(spid)
        local rank = spu:GetHighestSpellRank(spid)
        if right and rank then
          right:SetText(rank);
          right:SetTextColor(rankColor:GetRGBA())
          right:Show()
        end
        GameTooltip:Show()
      end)
    elseif au.IsItem(typ) then
      --- @type number|string @The val param can be 'item:<itemID>', itemID, itemName
      local itemVal= au.ExtractItemID(val) or val
      comp:IfItem(itemVal, function(item)
        GameTooltip:SetInventoryItemByID(item.id)
      end)
    elseif au.IsMacro(typ) then
      comp:IfMacro(val, function(name, icon, body)
        local mSpellID, mItemID = au.GetMacroAction(name)
        if mSpellID then
          o.Btn_OnGameTooltip(self, atyp.spell, mSpellID)
        elseif mItemID then
          o.Btn_OnGameTooltip(self, atyp.item, mItemID)
        end
      end)
    end
  else
    if au.IsMount(typ) then
      comp:IfMount(val, function(mount)  -- val as MountID
        GameTooltip:SetMountBySpellID(mount.spellID)
      end)
    elseif au.IsBattlePet(typ) then
      GameTooltip:SetCompanionPet(val) -- val as petGUID
    end
  end
end

--- @param self Button_ABP_2_0_X
function o.Btn_UpdateFlash(self)
  -- tbd
end

--- @param self Button_ABP_2_0_X
function o.Btn_UpdateAnimation(self)
  --- @type ButtonConfig_ABP_2_0
  local btnC = self.widget:conf()
  if not btnC then return end

  if au.IsSpell(btnC.type) then

    if au.IsAutoAttackInProgress(btnC.id) then
      self:EnableFlashAnimation()
    else
      self:DisableFlashAnimation()
    end
  end
end

--- @param self Button_ABP_2_0_X
--- @param macroIdentifier MacroIdentifier
function o.Btn_SetActionMacro(self, macroIdentifier)
  local w, typ = self.widget, atyp.macro
  comp:IfMacro(macroIdentifier, function(name, icon, body)
    w:SetActionAttribute(typ, name)
  end).OrElse(function()
    local conf = w:conf() --[[@as MacroButtonConfig_ABP_2_0]]
    -- try and find macro by body hash
    comp:IfMacroByBodyHash(conf.hash, function(name, icon, body)
        conf.id = name
        w:SetActionAttribute(typ, name)
        self:UpdateTexture()
    end).OrElse(function()
      o.Btn_ResetAll(self)
    end)
  end)
end

--- BattlePet is a custom action implementation that uses `/summonpet {petGUID}`
--- @param self Button_ABP_2_0_X
--- @param battlePetID PetGUID
function o.Btn_SetActionBattlePet(self, battlePetID)
  assert(type(battlePetID) == 'string', 'Btn_SetActionBattlePet(self, battlePetID): {battlePetID} should be a GUID:String')

  local macroText = BATTLEPET_MACRO_TEMPLATE:format(battlePetID)
  local typ = atyp.battlepet
  local w = self.widget
  w:SetActionAttributeCustom(typ, battlePetID)
  w:SetAttribute(attr.type, atyp.macro)
  w:SetAttribute(atyp.macrotext, macroText)
end

--- EquipmentSet is a custom action
--- @param self Button_ABP_2_0_X
--- @param equipmentSetID EquipmentSetID
function o.Btn_SetActionEquipmentSet(self, equipmentSetID)
  local eqSet = comp:GetEquipmentSet(equipmentSetID)
  assert(eqSet, 'Failed to retrieve EquipmentSet(id): ' .. tostring(equipmentSetID))

  local equipName = eqSet.name
  local macroText = EQUIPMENT_SET_TEMPLATE:format(equipName)
  local w = self.widget
  w:SetActionAttributeCustom(atyp.equipmentset, equipmentSetID)
  w:SetAttribute(attr.type, atyp.macro)
  w:SetAttribute(atyp.macrotext, macroText)
end

--- Mount is a a custom action
--- @param self Button_ABP_2_0_X
--- @param mountID MountID
function o.Btn_SetActionMount(self, mountID)
  comp:IfMount(mountID, function(mount)
    local w = self.widget
    w:SetActionAttributeCustom(atyp.mount, mount.mountID)
    w:SetAttribute(attr.type, atyp.spell)
    if LE_EXPANSION_LEVEL_CURRENT >= LE_EXPANSION_MISTS_OF_PANDARIA then
      w:SetActionSpellByName(mount.spellID)
      return
    end
    w:SetAttribute(atyp.spell, mount.spellID)
  end)
end

