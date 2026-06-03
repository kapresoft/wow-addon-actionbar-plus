--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local O = ns.O
local trace_cvar = ns.trace_ui_cvar
local Str_IsBlank = ns:String().IsBlank
local p, t = ns:log('Developer')
local unit, comp, hu = O.UnitUtil, O.Compat, O.HashUtil

--- @class Developer_ABP_2_0 : AceEvent-3.0
local o = ns:NewAceEvent(); Developer_ABP_2_0 = o; dd = o


--- @return Namespace_ABP_BarsUI_2_0
local function bar_ns() return ABP_BARSUI_NS end

function o.OnBarsReady(evt)
  local dlg = ABP_BARSUI_NS.O.QuickKeybindModeDialog
  dlg:Open()
end

function o:disable()
  bar_ns():a():ForEach(function(module)
    module:Disable()
  end)
end

function o:enable()
  bar_ns():a():ForEach(function(module)
    module:Enable()
  end)
end

function o:macroInfo(macroIdentifier) return comp:GetMacroInfo(macroIdentifier) end
function o:hash(str) return hu.string(str) end

--- @param frameIndex Index
--- @param btnIndex Index
--- @return ButtonConfig_ABP_2_0?
function o:btnConf(frameIndex, btnIndex)
  local n = ('ABP_2_0_F%sButton%s'):format(frameIndex, btnIndex)
  --- @type Button_ABP_2_0_X
  local btn = _G[n]
  if not (btn and btn.widget) then return nil end
  return btn.widget:conf()
end

function o:skills()
  for i = 1, GetNumSkillLines() do
    local skillName, isHeader, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank = GetSkillLineInfo(i)
    if not isHeader then
      print(skillName .. ": " .. skillRank .. "/" .. skillMaxRank)
    end
  end
end

--- /dump dd:IsPrimaryProfessionSpell(25230)
function o:IsPrimaryProfessionSpell(spellID)
  local prof1, prof2 = GetProfessions()
  for _, prof in ipairs({prof1, prof2}) do
    if prof then
      local _, _, _, _, _, _, id = GetProfessionInfo(prof)
      if id == spellID then
        return true
      end
    end
  end
  return false
end

--- @param msg string
function o:devMsg(msg)
  UIErrorsFrame:AddMessage('ABP: ' .. msg, 0, 1, 0)
end

--- @param itemInfo ItemName|ItemID|ItemLink
--- @return ItemCooldownInfo?
function o:GetItemCooldown(itemInfo)
  return comp:GetItemCooldown(itemInfo)
end

function o:IsSealActive(spellID)
  if not (spellID and C_UnitAuras and C_UnitAuras.GetBuffDataByIndex) then return false end
  local index = 1
  while true do
    local aura = C_UnitAuras.GetBuffDataByIndex('player', index)
    if not aura then break end
    if aura.spellId == spellID then return true end
    index = index + 1
  end
  return false
end


--[[-----------------------------------------------------------------------------
Register Events
-------------------------------------------------------------------------------]]
o:RegisterMessage('ActionbarPlus-BarsUI::OnBarsReady', o.OnBarsReady)
