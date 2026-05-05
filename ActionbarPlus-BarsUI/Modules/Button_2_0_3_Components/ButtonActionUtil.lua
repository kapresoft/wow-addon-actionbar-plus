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
local libName = 'ButtonActionUtil'
--- @class ButtonActionUtil_ABP_2_0
local o = ns:NewLib(libName)
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]
--- @return boolean
function o.IsActionbarLockedByUser() return Settings.GetValue("lockActionBars") end

--- @param down boolean
--- @return boolean
function o.Btn_ActionShouldFire(down)
  if o.IsActionbarLockedByUser() then return down == true end
  return down ~= true
end

--- @param self Button_ABP_2_0_3
--- @return boolean
function o.Btn_ActionRequiresAttackAnim(self)
    local typeVal, id = self:GetActionInfo()
    if not (typeVal and id) then return false end
    if au.IsSpell(typeVal)  then
      return au.SpellRequiresAttackAnim(id)
    end
    return false
end

--- @param self Button_ABP_2_0_3
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
  end

  if callbackFn then callbackFn() end
end
