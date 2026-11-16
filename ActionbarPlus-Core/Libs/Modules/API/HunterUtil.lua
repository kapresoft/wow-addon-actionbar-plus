--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local UnitUtil = ns.O.UnitUtil
local C_GetSpellName = C_Spell.GetSpellName
local C_GetAuraDataBySpellName = C_UnitAuras.GetAuraDataBySpellName
-- Forever only; the other clients read the aura instead
local C_IsActiveSpell = C_Spell.IsActiveSpell

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
--- @type string
local libName = ns.M.HunterUtil()
--- @class HunterUtil_ABP_2_0 : UnitUtil_ABP_2_0
local o = UnitUtil:New('HUNTER'); ns:Register(libName, o)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
-- Base rank of each toggled aspect; ranks share its name
o.ASPECT_SPELL_IDS = {
  5118, -- Cheetah
  13159, -- Pack
  13161, -- Beast
  13163, -- Monkey
  13165, -- Hawk
  20043, -- Wild
  34074, -- Viper
  61846, -- Dragonhawk
  82661, -- Fox
  109260, -- Iron Hawk
  415423, -- Viper (Season of Discovery)
}

-- Retail aspects are cooldowns and share these names
local tracksAspects = o:IsUs() and (ns:IsForever() or ns:IsMistsOrEarlier())

--- @type table<Name, boolean>
local aspectNames
--- @type (Name|false)? @false if none is active; nil until first read
local activeAspect

--- @return table<Name, boolean>
local function AspectNames()
  if aspectNames then return aspectNames end
  aspectNames = {}
  for _, spellID in ipairs(o.ASPECT_SPELL_IDS) do
    local name = C_GetSpellName(spellID)
    if name then aspectNames[name] = true end
  end
  return aspectNames
end

-- PLAYER: other hunters' Pack and Wild don't count
--- @return Name|false @false if no aspect is active
local function FindActiveAspect()
  for name in pairs(AspectNames()) do
    if C_GetAuraDataBySpellName('player', name, 'HELPFUL|PLAYER') then return name end
  end
  return false
end

--- @param spellID SpellID
--- @return Name? @nil if the spell isn't a tracked aspect
local function AspectName(spellID)
  if not tracksAspects then return nil end
  local name = C_GetSpellName(spellID)
  if name and AspectNames()[name] then return name end
  return nil
end

local function OnEvent()
  -- Forever: a secret can't be compared, so always signal
  if not C_IsActiveSpell then
    local aspect = FindActiveAspect()
    if aspect == activeAspect then return end
    activeAspect = aspect
  end
  ns:a():SendMessage(ns:msg('OnAspectChanged'))
end

if tracksAspects then
  local frame = CreateFrame('Frame')
  frame:RegisterEvent('PLAYER_ENTERING_WORLD')
  frame:RegisterUnitEvent('UNIT_AURA', 'player')
  frame:SetScript('OnEvent', OnEvent)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @return boolean
function o:TracksAspects() return tracksAspects end

--- @param spellID SpellID
--- @return boolean
function o:IsAspect(spellID) return AspectName(spellID) ~= nil end

--- @param spellID SpellID
--- @return boolean @Secret in Forever combat; never test it
function o:IsAspectActive(spellID)
  if C_IsActiveSpell then return C_IsActiveSpell(spellID) end
  if activeAspect == nil then activeAspect = FindActiveAspect() end
  return activeAspect == AspectName(spellID)
end
