--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)

local cns = ns:cns()
local O = cns.O
local au = O.ActionUtil
local comp, spu, unit = O.Compat, O.SpellUtil, O.UnitUtil

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
--- @return boolean
function o.Btn_ActionRequiresAttackAnim(self)
    local typeVal, id = self:GetActionInfo()
    if not (typeVal and id) then return false end
    if au.IsSpell(typeVal)  then
      return au.SpellRequiresAttackAnim(id)
    end
    return false
end

--- @param self Button_ABP_2_0_X
--- @param callbackFn fun() : void
function o.Btn_PickupAction(self, callbackFn)
  --- The abp_saved_type is saved during PreClick()
  --- so that the button won't fire on pickup action
  local typeVal = self.widget:GetAttributeSuspendedActionType()
  if not typeVal then return end

  if au.IsSpell(typeVal) then
    local spell = self.widget:GetAttributeSpell()
    comp:PickupSpell(spell)
    self:ResetButtonConfig()
    self.widget:ResetButton()
  elseif au.IsItem(typeVal) then
    local itemID = self.widget:GetAttributeItemID()
    comp:PickupItem(itemID)
    self:ResetButtonConfig()
    self.widget:ResetButton()
  end

  if callbackFn then callbackFn() end
end

--- Update the button's checked state
--- @param self Button_ABP_2_0_X
--- @param evt Name @The event name
function o.Btn_UpdateState(self, evt)
  local typeVal, spellID = self:GetActionInfo()
  if not (typeVal and spellID) then return end

  local sp = GetSpellInfo(spellID)
  local isCurrent = au.IsCurrentAction(typeVal, spellID)
  if isCurrent then
    self:SetChecked(true)
  else
    self:SetChecked(false)
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
    local requiresAttackAnim = au.SpellRequiresAttackAnim(btnC.id)
    if requiresAttackAnim and au.IsCurrentSpell(btnC.id) then
      self:EnableAttackingAnimation()
    else
      self:DisableAttackingAnimation()
    end
  end
end
