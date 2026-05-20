--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)

local cns = ns:cns()
local O = cns.O
local au = O.ActionUtil
local comp, spu, unit =
      O.Compat, O.SpellUtil, O.UnitUtil
local druid, rogue, shammy, priest =
      O.DruidUtil, O.RogueUtil, O.ShamanUtil, O.PriestUtil

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
--- @param callbackFn fun() : void
function o.Btn_PickupAction(self, callbackFn)
  --- The abp_saved_type is saved during PreClick()
  --- so that the button won't fire on pickup action
  local typeVal = self.widget:GetAttributeSuspendedActionType()
  if not typeVal then return end

  local pickedUp = false

  if au.IsSpell(typeVal) then
    local spell = self.widget:GetAttributeSpell()
    o.Btn_PickupSpellOrMount(self, spell)
    pickedUp = true
  elseif au.IsItem(typeVal) then
    local itemID = self.widget:GetAttributeItemID()
    comp:PickupItem(itemID)
    pickedUp = true
  elseif au.IsMacro(typeVal) then
    local c_actionType, c_val = self.widget:GetActionInfoCustom()
    if c_actionType and c_val then
      -- battlepet has macro/macrotext attributes
      comp:PickupBattlePet(c_val)
    else
      -- pickup macro
      error(self.button:GetName() .. ':: GetActionInfo(): macro support not implemented')
    end
    pickedUp = true
  end
  if pickedUp then o.Btn_ResetAll(self) end
  if callbackFn then callbackFn() end
end

--- @param self Button_ABP_2_0_X
--- @param spell SpellIdentifier
function o.Btn_PickupSpellOrMount(self, spell)
  comp:IfMountSpell(spell, function(mount)
    comp:PickupMount(mount.mountID)
  end).OrElse(function ()
    comp:PickupSpell(spell)
  end)
end

--- Update the button's checked state
--- @param self Button_ABP_2_0_X
--- @param evt Name @The event name
function o.Btn_UpdateState(self, evt)
  local typ, val = self:GetActionInfo()
  if not (typ and val) then return end

  local isCurrent = au.IsCurrentAction(typ, val)
  self:SetChecked(isCurrent == true)
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
