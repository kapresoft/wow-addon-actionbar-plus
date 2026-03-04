--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns = ns:cns()
local comp, unit = cns.O.Compat, cns.O.UnitUtil

--[[-----------------------------------------------------------------------------
Module::Button_TestData
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
local libName = 'Button_TestData'
--- @class Button_TestData_ABP_2_0 : AceEvent_3_0
local S = cns:NewAceEvent(); ABP_ButtonTestData = S
local p, pd, t, tf = ns:log(libName)

--[[-----------------------------------------------------------------------------
Module::Button_TestData (Methods)
-------------------------------------------------------------------------------]]
--- @type Button_TestData_ABP_2_0
local o = S

local function GetSpellsForTesting()
  local spells = {
    ['PRIEST'] = {
      [1000] = 'shadowform',
      [1001] = 'mind blast',
      [1002] = 'mind flay',
    },
    ['DRUID'] = {
      [1000] = 'cat form',
      [1001] = 'prowl',
      [1002] = 'barkskin',
    },
    ['ROGUE'] = {
      [1000] = 'stealth',
      [1001] = 'pick pocket',
      [1002] = 'arcane torrent',
    },
    ['PALADIN'] = {
      [1000] = 'judgement',
      [1001] = 'seal of righteousness',
      [1002] = 'seal of the crusader',
      [1003] = 'flash of light(rank 1)',
      [1005] = 'mana tap',
      [1006] = 'arcane torrent',
    }
  }
  if cns:IsMainLine() then
    spells['PALADIN'] = {
      [1000] = 'judgment',
      [1001] = 'flash of light',
      [1002] = 'divine protection',
    }
  end
  
  return spells
end; local testSpells = GetSpellsForTesting()

--- @param btn Button_ABP_2_0_3
function o:AddTestData(btn)
  if not testSpells then return end
  local characterSpells = testSpells[unit:GetPlayerUnitClass()]
  if not characterSpells then return end
  
  local id = btn:GetID()
  local spellName = characterSpells[id]
  if not spellName then return end
  
  local type, id = btn:GetActionInfo()
  if id then return end
  -- Setting attribute will call button:UpdateAction()
  btn:SetAttribute('type', 'spell')
  btn:SetAttribute('spell', spellName)
end


