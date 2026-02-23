--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns = ns:cns()
local c = cns.O.Compat

local p, pd, t, tf = ns:log('ButtonState')

local C_IsAutoRepeatSpell = C_Spell and C_Spell.IsAutoRepeatSpell or IsAutoRepeatSpell
local C_IsCurrentSpell = C_Spell and C_Spell.IsCurrentSpell or IsCurrentSpell

ns.__ButtonState = {}
local type, spell = 'type', 'spell'

--- @class ABP_ButtonStateMixin_2_0_3
local o = ns.__ButtonState

function o.Btn_IsDragAllowed()
  return not Settings.GetValue("lockActionBars") or IsModifiedClick("PICKUPACTION")
end

--- Update the button's checked state
--- @param self ABP_Button_2_0_3
function o.Btn_UpdateState(self)
  local type = self:GetAttribute('type'); if not type then return end
  --p('type=', type)
  local actionID = self:GetAttribute(type)
  --p('actionID=', actionID);
  if not actionID then return end local checked = false

  local current = false
  if type == spell then
    current = C_IsCurrentSpell(actionID)
    --p('btn=', self:GetID(), 'current=', current, 'spellID=', actionID)
    checked = current or C_IsAutoRepeatSpell(actionID);
  end
  local name = '';
  if type == 'spell' then
    local sp = c:GetSpellInfo(actionID)
    if sp then name = '[' .. sp.name .. ']' end
  end
  p(('%s[%s]:: type=%s action=%s%s current=%s checked=%s')
          :format('UpdateSt', self:GetID(), type, actionID, name,
            tostring(current), tostring(checked)))
  self:SetChecked(checked)
end

--- @param spellID SpellIdentifier
--- @param callbackFn fun(spell:SpellInfo)
local function IfSpell(spellID, callbackFn)
  if not spellID then return end
  local sp = c:GetSpellInfo(spellID)
  return sp and callbackFn(sp)
end

--- @param self ABP_Button_2_0_3
--- @param event string | "'UNIT_SPELLCAST_START'", | "'UNIT_SPELLCAST_STOP'" | "'etc...'"
function o.Btn_OnSpellCast(self, event, unitTarget, ...)
  if unitTarget ~= "player" then return end
  local type = self:GetAttribute('type')
  if type ~= spell then return end
  --p(('%s[%s]:: evt=%s'):format('OnSpellCast', self:GetID(), event))
  
  local spellID = self:GetAttribute(spell)
  if not spellID then return end local checked = false
  
  local current = C_IsCurrentSpell(spellID) or C_IsAutoRepeatSpell(spellID);
  
  local spellDesc = tostring(spellID);
  if type == 'spell' then
    IfSpell(spellID, function(sp)
      spellDesc = spellDesc .. '[' .. sp.name .. ']'
    end)
  end
  if event == 'UNIT_SPELLCAST_STOP' or event == 'UNIT_SPELLCAST_SUCCEEDED' then
    current = C_IsCurrentSpell(spellID)
    local m = ('OnSpellCast[%s] %s::'):format(self:GetID(), event)
    local _, evtSpellID = ...
    p(m, 'evtSpellID=', evtSpellID, 'spell=', spellDesc, 'current=', current)
    if evtSpellID == spellID then
      self:SetChecked(false)
    end
  end
end

--- @param self ABP_Button_2_0_3
function o.Btn_UpdateFlash(self)

end

--- @param self ABP_Button_2_0_3
---@param show boolean
function o.Btn_OnTradeSkill(self, show)
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
