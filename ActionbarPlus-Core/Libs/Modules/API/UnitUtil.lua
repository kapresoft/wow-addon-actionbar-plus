--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, M, comp = ns.O, ns.M, ns.O.Compat
local UnitClasses = ns.O.APIConstants.UnitClasses
local tinsert, tconcat = table.insert, table.concat

--- For all stealth
local STEALTHED_ICON = 136047

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
--- @type string
local libName = M.UnitUtil()
--- @class UnitUtil_ABP_2_0 : BaseLibraryObject
--- @field protected CLASS_ID UnitClass This is an interface field and must be defined by the specific unit
local S = {}; ns:Register(libName, S)
S.__index = S
S.__type = libName

local p, pd, t, tf = ns:log(libName)

--- Checks if the first argument matches any of the subsequent arguments.
--- @param toMatch number The value to match against the varargs.
--- @vararg string SpellInfoShort The list of values to check for a match.
--- @return boolean True if `toMatch` is found in the varargs, false otherwise.
local function IsAnyOfBuff(toMatch, ...)
  for i = 1, select('#', ...) do
    --- @type SpellInfoShort
    local val = select(i, ...)
    local spellID = val and val.id
    if toMatch == spellID then return true end
  end
  return false
end


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@type UnitUtil_ABP_2_0
local o = S

o.C = { UnitClasses = UnitClasses }

o.ADDON_TEXTURES_DIR_FORMAT = 'interface/addons/actionbarplus/Core/Assets/Textures/%s'
o.stealthedIcon = o.ADDON_TEXTURES_DIR_FORMAT:format('spell_nature_invisibilty_active')

--- @overload fun(unitClass:UnitClass) : UnitUtil_ABP_2_0
--- @param unitClass UnitClass
--- @return UnitUtil_ABP_2_0
function o:New(obj, unitClass)
  local _obj, _class = obj, unitClass
  if type(obj) == 'string' and _class == nil then
    _class = obj
    _obj = {}
  end
  assert(type(_class) == 'string', 'Param UnitClass must be one of @UnitClass')
  _obj.CLASS_ID = strupper(_class)
  assert(self.C.UnitClasses[_obj.CLASS_ID], ('UnitUtil:New(UNIT_CLASS):: Invalid UNIT_CLASS: "%s"'):format(tostring(_class)))
  return setmetatable(_obj, self)
end

--- Use New() instead if a unit class is extending this mixin instead
function o:Embed(obj) return self:New(obj) end
--- @return UnitClass
function o:ClassID() return self.CLASS_ID end

--- Class names are not locale-specific (The second return value of UnitClass())
---Example:
--- @param optionalUnit string
--- @see Blizzard_UnitId
--- @return UnitClass, UnitClassID One of DRUID, ROGUE, PRIEST, etc... returned with the ID
function o:GetUnitClass(optionalUnit) return UnitClassBase(optionalUnit or 'player') end

--- @return UnitClassType
function o:GetUnitClassX(optionalUnit)
  local name = self:GetUnitClass(optionalUnit)
  return UnitClasses[name]
end

--- @see UnitClasses
--- @return string, number One of DRUID, ROGUE, PRIEST, etc...
function o:GetPlayerUnitClass() return self:GetUnitClass() end

--- /dump select(2, UnitClass('player'))
---Example:
---```
---local playerClass = 'DRUID'
---local isValidClass = IsPlayerClassAnyOf('DRUID','ROGUE', 'PRIEST')
---assertThat(isValidClass).IsTrue()
---```
--- @param ... any list of class enum names.
--- @return boolean
function o:IsPlayerClassAnyOf(...)
  local unitClass = self:GetUnitClass()
  return unitClass and ns.Str_IsAnyOfCaseInsensitive(unitClass, ...)
end

--- @vararg any list of Unit Class IDs
--- @return Boolean
function o:IsPlayerClassAnyOfID(...)
  local _, _, unitClassID = UnitClassNames('player')
  if not unitClassID then return false end
  local args = { ... }
  -- Fix for Midnight
  local ok, result = pcall(function() return ns.Nbr_IsAnyOf(unitClassID, unpack(args)) end)
  return (ok and result) or false
end

--- Notes:
--- - `PriestUnitMixin:IsUs()` returns true if player is a priest, otherwise false
--- - `PriestUnitMixin:IsUs('PRIEST')` returns true if player is a priest, otherwise false
--- - `DruidUnitMixin:IsUs()`, then returns true if player is a druid, otherwise false
--- - `DruidUnitMixin:IsUs('DRUID')`, then returns true if player is a druid, otherwise false
--- Don't call `UnitMixin:IsUs()` directly.
---
--- Uses Interface field: CLASS_ID
--- @see UnitClass
--- @param unitClass UnitClass|nil Optional unit class. If passed, unitClass is checked against the player class.
function o:IsUs(unitClass)
  local pClass = self:GetPlayerUnitClass()
  if type(unitClass) == 'string' then return pClass == unitClass end
  assert(self.CLASS_ID, 'CLASS_ID is missing')
  return self.CLASS_ID == pClass
end

function o:IsDruid() return self:IsUs(UnitClasses.DRUID()) end
function o:IsPriest() return self:IsUs(UnitClasses.PRIEST()) end
function o:IsPaladin() return self:IsUs(UnitClasses.PALADIN()) end
function o:IsRogue() return self:IsUs(UnitClasses.ROGUE()) end

--- @return Boolean
function o:IsStealthActive() return IsStealthed and IsStealthed() end
--- @return Boolean
function o:CanShapeShift() return GetNumShapeshiftForms and GetNumShapeshiftForms() > 0 end
--- @return boolean
function o:IsShapeShifted() return self:GetShapeshiftForm() > 0 end
--- @return Icon
function o:GetStealthedIcon() return STEALTHED_ICON end
--- @return Index|0 The form index if any; 0 if not shapeshifted
function o:GetShapeshiftForm() return GetShapeshiftForm and GetShapeshiftForm() end
--shapeshiftIcon, active, castable, spellID

--- @return boolean
---@param callbackFn fun(data:ShapeshiftFormData):void
function o:IfShapeShifted(callbackFn)
  local index = self:GetShapeshiftForm()
  if index == 0 then return end
  local data = comp:GetShapeshiftFormInfo(index)
  if not data then return end
  callbackFn(data)
end

--- Inefficient. Use #IsBuffActive
function o:HasBuff(spellID)
  for i = 1, 40 do
    if spellID == comp:GetBuffSpellID(i) then return true end
  end
  return false
end

--- @alias UnitBuffFilterFunction fun(spellID:SpellID) : void

function o:GeTrackedShapeshiftSpells()
  return O.ShamanUnitMixin.GHOST_WOLF_SPELL_ID,
        O.PriestUnitMixin.SHADOW_FORM_SPELL_ID,
        O.PriestUnitUtil_2_0.SHADOW_FORM_SPELL_ID_RETAIL
end

function o:UpdateShapeshiftBuffs()
  --- Wrap in pcall for Midnight Fix
  pcall(function()
    self:UpdateBuffs(function(spellID)
      return ns.Nbr_IsAnyOf(spellID, self:GeTrackedShapeshiftSpells());
    end)
  end)
end

--- TODO: Move to API
---@param spellID SpellID
function o:IsOwnSpell(spellID) return comp:IsOwnSpell(spellID) end

--- @param filterFn UnitBuffFilterFunction | "function(spellID)  end"
function o:UpdateBuffs(filterFn)
  self:ClearBuffs()
  for i = 1, 40 do
    local spellID = comp:GetBuffSpellID(i)
    if spellID then
      if filterFn(spellID) and self:IsOwnSpell(spellID) then
        local name = comp:GetSpellName(spellID)
        p:t(function() return "Own spell: id=%s name=%s", spellID, tostring(name) end)
        --- @type SpellInfoShort
        local spellInfo = { id = spellID, name = name }
        table.insert(ns.playerBuffs, spellInfo)
      end
    end
  end
end

---@param spellID SpellID
function o:IsBuffActive(spellID)
  if ns.Tbl_IsEmpty(ns.playerBuffs) then return false end
  return IsAnyOfBuff(spellID, unpack(ns.playerBuffs))
end

local function NewTalentInfo()
  --- @class TalentInfo_ABP_2_0
  local info = {
    --- @type table<number, Name>
    names       = {},
    --- @type table<Name, number>
    points      = {},
    --- @type string
    spec        = nil,
    talentIndex = -1,
    --- @type string
    icon        = nil,
  }
  return info
end

--- @class TalentTabInfoMixin_ABP_2_0
local TalentTabInfoMixin = {}
--- @param name Name
--- @param icon TextureIDOrPath
--- @param pointsSpent Number
--- @return TalentTabInfo_ABP_2_0
function TalentTabInfoMixin:New(name, icon, pointsSpent)
  --- @class TalentTabInfo_ABP_2_0
  local info = { name = name, icon = icon, pointsSpent = pointsSpent }
  return info
end

--- @return TalentInfo_ABP_2_0
function o:GetTalentInfo()
  if ns:IsRetail() then return self:GetTalentInfoRetail() end
  if not GetNumTalentTabs then return nil end
  return self:GetTalentInfoPreRetail()
end

--- @param tabIndex Index
local function GetTalentTabInfoPreCataclysm(tabIndex)
  local name, icon, pointsSpent = GetTalentTabInfo(tabIndex)
  return TalentTabInfoMixin:New(name, icon, pointsSpent)
end

--- @param tabIndex Index
local function GetTalentTabInfo_Cataclysm(tabIndex)
  local id, name, talentDesc, icon, pointsSpent = GetTalentTabInfo(tabIndex)
  return TalentTabInfoMixin:New(name, icon, pointsSpent)
end

--- @private
--- @return TalentInfo_ABP_2_0
function o:GetTalentInfoPreRetail()
  local totalPoints = 0
  --- @type TalentInfo_ABP_2_0
  local info = NewTalentInfo()
  function info:summary()
    local s = {}
    for name, points in pairs(self.points) do
      points = points or 0
      tinsert(s, name .. ': ' .. tostring(points))
    end
    return tconcat(s, ', ')
  end
  --- @param callbackFn fun(name:string, points:number) | "function(name, points) end"
  function info:ForEachTalent(callbackFn)
    for name, points in pairs(self.points) do
      points = points or 0
      callbackFn(name, points)
    end
  end
  
  local max = 0
  
  -- skip MoP for now (uses GetNumSpecGroups)
  if GetNumSpecGroups then
    local specIndex = comp:GetSpecializationID()
    if specIndex then
      local specId, specName = comp:GetSpecializationInfo(specIndex)
      info.spec = specName
    end
    return info
  end
  
  -- /dump GetTalentTabInfo(1)
  for i = 1, GetNumTalentTabs() do
    --- @type TalentTabInfo_ABP_2_0
    local tabInfo
    if ns:IsCataclysm() then tabInfo = GetTalentTabInfo_Cataclysm(i)
    else tabInfo = GetTalentTabInfoPreCataclysm(i) end
    
    if tabInfo then
      table.insert(info.names, tabInfo.name)
      info.points[tabInfo.name] = tabInfo.pointsSpent
      if tabInfo.pointsSpent > max then
        info.spec = tabInfo.name
        info.talentIndex = i
        info.icon = ('|T%s:18:18:0:0|t'):format(tabInfo.icon)
        max = tabInfo.pointsSpent
      end
      totalPoints = totalPoints + tabInfo.pointsSpent
    end
  end
  return info
end

--- @private
--- @return TalentInfo_ABP_2_0
function o:GetTalentInfoRetail()
  --- @type TalentInfo_ABP_2_0
  local info = NewTalentInfo()
  function info:summary() return nil end
  
  --- @param callbackFn fun(name:string, points:number) | "function(name, points) end"
  function info:ForEachTalent(callbackFn) end
  
  local specIndex = GetSpecialization();
  if not specIndex then return nil end
  local _, spec = GetSpecializationInfo(specIndex);
  info.spec = spec
  return info
end

