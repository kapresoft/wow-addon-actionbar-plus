--[[-----------------------------------------------------------------------------
VERSION:: Bump MINOR_VERSION whenever a change occurs
-- 1: initial version

DEPENDENCIES:
  - LibStub, Kapresoft-String-2-0
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'Kapresoft-AddonUtil-2-0', 1

--- @class Kapresoft-AddonUtil-2-0
local S = LibStub:NewLibrary(MAJOR, MINOR); if not S then return end
local mt = { __tostring = function() return MAJOR .. '.' .. LibStub.minors[MAJOR] end }
setmetatable(S, mt)

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local EnableAddOn, DisableAddOn = EnableAddOn or C_AddOns.EnableAddOn, DisableAddOn or C_AddOns.DisableAddOn
local C_AddOns_GetAddOnEnableState = C_AddOns.GetAddOnEnableState
local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
local GetAddOnInfo = GetAddOnInfo or C_AddOns.GetAddOnInfo
local LoadAddOn = LoadAddOn or C_AddOns.LoadAddOn
local IsAddOnLoaded = IsAddOnLoaded or C_AddOns.IsAddOnLoaded

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local String, sformat = nil, string.format

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local NAME_REQUIRED_MSG = "AddonUtil::%s: Expected an addon index:number or name:string but was=%s"

--- @return Kapresoft-String-2-0
local function Str()
  if not String then String = LibStub('Kapresoft-String-2-0') end
  return String
end

--- @param indexOrName IndexOrName The AddOn Index or Name
--- @param methodName Name
local function assertIndexOrName(methodName, indexOrName)
  assert(type(indexOrName) == 'string' or type(indexOrName) == 'number',
    sformat(NAME_REQUIRED_MSG, methodName, tostring(indexOrName)))
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param indexOrName IndexOrName
--- @return Enabled
function S:IsAddOnEnabled(indexOrName)
  assert(type(indexOrName) ~= 'nil', 'IsAddOnEnabled(indexOrName): Addon Index or Name is required.')

  local charName = UnitName("player")
  local intVal = -1
  if C_AddOns_GetAddOnEnableState then
    intVal = C_AddOns_GetAddOnEnableState(indexOrName, charName)
  elseif GetAddOnEnableState then
    intVal = GetAddOnEnableState(charName, indexOrName)
  end
  return intVal == 2
end

--- @param name Name The addOn name
--- @param charName Name|nil The character name. Defaults to current
function S:EnableAddOnForCharacter(name, charName)
  assert(type(name) == 'string', 'EnableAddOnForCharacter(name,charName):: name should be a string')

  charName = charName or UnitName("player")
  EnableAddOn(name, charName)
end

--- @param indexOrName IndexOrName The index from 1 to GetNumAddOns() or The name of the addon (as in TOC/folder filename), case insensitive.
--- @return AddOnInfo
function S:GetAddOnInfo(indexOrName)
  assertIndexOrName('GetAddOnInfo()', indexOrName)
  local EqualsIgnoreCase = Str().EqualsIgnoreCase
  local name, title, notes, loadable, reason, security = GetAddOnInfo(indexOrName)
  local index
  if type(indexOrName) == 'number' then index = indexOrName end

  --- @type AddOnInfo
  local info = {
    name = name,
    title = title,
    loadable = loadable,
    notes = notes,
    reason = reason,
    security = security,
    index = index
  }
  function info:IsMissing()
    return EqualsIgnoreCase(self.reason, 'MISSING')
  end

  return info
end

--- @param name Name
--- @param callbackFn fun(loadSuccess:boolean, info:AddOnInfo, errorMsg:string) | "function(loadSuccess, info, errorMsg) print('success:', loadSuccess) end"
function S:LoadOnDemand(name, callbackFn)
  assert(type(name) == 'string', 'LoadOnDemand(name):: name should be a string')

  local info = self:GetAddOnInfo(name)
  if not self:IsAddOnEnabled(name) then
    self:EnableAddOnForCharacter(name)
    if not self:IsAddOnEnabled(name) then
      local infoText = ('reason=%s, loadable=%s'):format( tostring(info.reason), tostring(info.loadable))
      return callbackFn(false, info, ('Failed to Enable Addon: %s info=%s'):format( name, infoText))
    end
  end
  if not IsAddOnLoaded(name) then LoadAddOn(name); end
  local loaded = select(2, IsAddOnLoaded(name))
  callbackFn(loaded, info, nil)
end

--- Retrieves the dependencies for a specified addon, compatible with both Retail and Classic WoW.
--- @param addon AddOnName The name or index of the addon to check.
--- @return table dependencies A table of dependency names for the addon, or an empty table if none are found.
function S:GetAddOnDependencies(addon)
  local dependencies = {}

  if C_AddOns and C_AddOns.GetAddOnDependencies then
    -- Retail version: returns dependencies as multiple return values
    for _, dependency in ipairs({ C_AddOns.GetAddOnDependencies(addon) }) do
      table.insert(dependencies, dependency)
    end
    return dependencies
  elseif GetAddOnDependencies then
    -- Classic version: requires index-based fetching
    local depIndex = 1
    while true do
      local dependency = GetAddOnDependencies(addon, depIndex)
      if not dependency then break end
      table.insert(dependencies, dependency)
      depIndex = depIndex + 1
    end
  end

  return dependencies
end
