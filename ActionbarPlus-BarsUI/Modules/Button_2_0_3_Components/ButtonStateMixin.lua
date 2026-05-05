--[[-------------------------------------------------------------------
Blizzard Vars
---------------------------------------------------------------------]]
local C_IsAutoRepeatSpell = C_Spell and C_Spell.IsAutoRepeatSpell or IsAutoRepeatSpell
local C_IsCurrentSpell = C_Spell and C_Spell.IsCurrentSpell or IsCurrentSpell

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns = ns:cns()
local comp, au = cns.O.Compat, cns.O.ActionUtil
local type, spell = 'type', 'spell'

local attr, atyp = cns:constants()

--[[-----------------------------------------------------------------------------
Module::ButtonStateMixin
-------------------------------------------------------------------------------]]
--- @see BarsUI_Modules_ABP_2_0
local libName = ns.M.ButtonStateMixin()

--- @class ButtonStateMixin_ABP_2_0 : CheckButton
--- @field __castingSpellID SpellID Keeps track of the current spell
--- @field __updateState_IsInstantCast boolean Used in UpdateState() to keep track of instantly casted spells
--- @field __instantCastSpellID SpellID
local S = {}; ns:Register(libName, S)

--
--- @class ButtonState_ABP_2_0 : ButtonStateMixin_ABP_2_0
--

local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Module::ButtonStateMixin (Methods)
-------------------------------------------------------------------------------]]
local o = S

--- Update the button's checked state
--- @param self ButtonMixin_ABP_2_0_3
local function Btn_UpdateState(self, evt)
  local typeVal, spellID = self:GetActionInfo()
  if not (typeVal and spellID) then return end

  local sp = GetSpellInfo(spellID)
  local isCurrent = au.IsCurrentAction(typeVal, spellID)
  if isCurrent then
    --t('Btn_UpdateState', 'evt=', evt, 'isCurrent=', isCurrent, 'spell=', sp)
    self:SetChecked(true)
  else
    self:SetChecked(false)
  end

end

--- @param self ButtonMixin_ABP_2_0_3
local function Btn_UpdateFlash(self)
  -- tbd
end

--- @param self ButtonMixin_ABP_2_0_3
local function Btn_UpdateAnimation(self)
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

--- Update the button's checked state
function o:UpdateState(evt) Btn_UpdateState(self, evt) end
function o:UpdateAnimation() Btn_UpdateAnimation(self) end
function o:UpdateFlash() Btn_UpdateFlash(self) end

function o:ClearFlash()
  --p('ClearFlash:: called...')
end

--- @param show boolean
function o:OnTradeSkill(show)
  --p(('%s[%s]:: show=%s'):format('OnTradeSkill', self:GetID(), tostring(show)))
end

