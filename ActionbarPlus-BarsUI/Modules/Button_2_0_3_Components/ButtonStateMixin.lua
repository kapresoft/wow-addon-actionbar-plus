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
--- @class ButtonStateMixin_ABP_2_0
local S = {}; ns:Register(libName, S)
--
--- @alias ButtonState_ABP_2_0 ButtonStateMixin_ABP_2_0
--
local p, pd, t, tf = ns:log(libName)

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
--- @param typeVal string
--- @return boolean
local function ActionType_IsSpell(typeVal) return typeVal == atyp.spell end

--[[-----------------------------------------------------------------------------
Module::ButtonStateMixin (Methods)
-------------------------------------------------------------------------------]]
--- @type ButtonStateMixin_ABP_2_0 | ButtonState_ABP_2_0 | Button_ABP_2_0_3
local o = S


--- Update the button's checked state
function o:UpdateState()
  --p('UpdateState():: called...')
  local _type, id = self:GetActionInfo()
  if not _type or not id then return end
  
  if self.__castingSpellID and self.__castingSpellID == id then
    self:SetChecked(true)
    return
  end
  
  local checked = false
  local current = false
  if _type == attr.spell then
    current = C_IsCurrentSpell(id) or C_IsAutoRepeatSpell(id);
  end
  --self:t('Checked', 'UpdateState:: spellID=', id, 'current=', tostring(current), 'checked=', tostring(checked))
  self:SetChecked(current)
end

--- @param event string | "'UNIT_SPELLCAST_START'", | "'UNIT_SPELLCAST_STOP'" | "'etc...'"
function o:OnSpellCast(event, unitTarget, ...)
  if unitTarget ~= "player" then return end
  --self:t('OnSpellCast', 'evt=', event)
  local actionType, spellID = self:GetActionInfo()
  if not au.IsSpell(actionType) then return end
  
  if not spellID then return end
  
  local checked = false
  local current = C_IsCurrentSpell(spellID) or C_IsAutoRepeatSpell(spellID);
  
  local spellDesc = tostring(spellID);
  if au.IsSpell(actionType) then
    comp:IfSpell(spellID, function(sp)
      spellDesc = spellDesc .. '[' .. sp.name .. ']'
    end)
  end
  if event == 'UNIT_SPELLCAST_START' then
    local _, evtSpellID = ...
    if evtSpellID == spellID then
      self.__castingSpellID = evtSpellID
      self:SetChecked(true)
    end
  end
  
  if event == 'UNIT_SPELLCAST_STOP'
          or event == 'UNIT_SPELLCAST_INTERRUPTED'
          or event == 'UNIT_SPELLCAST_SUCCEEDED' then
    current = C_IsCurrentSpell(spellID)
    local _, evtSpellID = ...
    if self.__castingSpellID and self.__castingSpellID == evtSpellID then
      self.__castingSpellID = nil
      self:UpdateState()
    end
  end
end

function o:UpdateFlash()
  p('UpdateFlash:: called...')
end

function o:ClearFlash()
  p('ClearFlash:: called...')
end

--- @param show boolean
function o:OnTradeSkill(show)
  p(('%s[%s]:: show=%s'):format('OnTradeSkill', self:GetID(), tostring(show)))
end

--[[

----- @param event '"CVAR_UPDATE"'
----- @param cvarName string
----- @param value string
--function o:CVAR_UPDATE(event, cvarName, value)
--  p(("CVAR_UPDATE cvar=%s value=%s"):format(cvarName, value))
--  if cvarName ~= "ActionButtonUseKeyDown" then return end
--
--  -- value is "1" or "0"
--  local useKeyDown = value == "1"
--
--  p(("ActionButtonUseKeyDown value=%s, changed=%s"):format(value, tostring(useKeyDown)))
--
--  --if useKeyDown then
--  --    self:RegisterForClicks("AnyDown")
--  --else
--  --    self:RegisterForClicks("AnyUp")
--  --end
--end
--
----- @param event '"MODIFIER_STATE_CHANGED"'
----- @param key string "LALT" | "RALT" | "LSHIFT" | "RSHIFT" | "LCTRL" | "RCTRL"
----- @param state number @Values are 1 = pressed, 0 = released
--function o:MODIFIER_STATE_CHANGED(event, key, state)
--  p(('MSC... key=%s, state=%s'):format(key, state))
--  local varn = 'ActionButtonUseKeyDown'
--  if state == 1 and Btn_IsDragAllowed() then
--    -- /dump GetCVar('ActionButtonUseKeyDown')
--    -- /dump SetCVar('ActionButtonUseKeyDown', 0)
--    --p('MSC:: drag allowed... state=', state, 'key=', key)
--    self:RegisterForClicks('AnyUp');
--    --SetCVar(varn, 0)
--    p('MSC:: state=1 cvar updated; useKeyD=', GetCVarBool(varn))
--  elseif state == 0 then
--    self:RegisterForClicks('AnyDown');
--    --        SetCVar(varn, 1)
--    p('MSC:: state=0 cvar updated; useKeyD=', GetCVarBool(varn))
--  end
--end
]]


