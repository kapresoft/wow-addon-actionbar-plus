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
C_Timer.After(1, function() p("xxx Loaded...") end)

--[[-----------------------------------------------------------------------------
Module::Button_TestData (Methods)
-------------------------------------------------------------------------------]]
--- @type Button_TestData_ABP_2_0
local o = S

local function __GetSpell()
  local data = {}
  if cns:IsMainLine() then
    -- pally
    --tmpBtnSpells = {
    --  [1000] = 'flash of light',
    --  [1001] = 'sense undead',
    --  --[1002] = 'seal of righteousness',
    --  [1002] = 'jewelcrafting',
    --}
    -- druid
  end
  if unit:IsPriest() then
    data = {
      [1000] = 'shadowform',
      [1001] = 'mind blast',
      [1002] = 'mind flay',
    }
  elseif unit:IsDruid() then
    data = {
      [1000] = 'cat form',
      [1001] = 'prowl',
      [1002] = 'barkskin',
    }
  elseif unit:IsRogue() then
    data = {
      [1000] = 'stealth',
      [1001] = 'pick pocket',
      [1002] = 'arcane torrent',
    }
  elseif unit:IsPaladin() then
    data = {
      [1000] = 'holy light(rank 1)',
      [1001] = 'seal of the crusader(rank 1)',
      --[1002] = 'seal of righteousness',
      --[1002] = 'jewelcrafting',
      [1002] = 'arcane torrent',
    }
    if cns:IsMainLine() then
      data = {
        [1000] = 'flash of light',
        [1001] = 'crusader strike',
        [1002] = 'judgment',
        [1003] = 'hammer of justice',
      }
    end
  end
  return data
end

local data = __GetSpell()

--- @param isInitialLogin boolean
---@param btn ABP_Button_2_0_3
function o:AddTestData(isInitialLogin, btn)
  local id = btn:GetID()
  local spellName = data[id]
  if not spellName then return end
  
  -- Setting attribute will call button:UpdateAction()
  btn:SetAttribute('type', 'spell')
  btn:SetAttribute('spell', spellName)
end


