--[[-----------------------------------------------------------------------------
Type: AceDbInitializer
-------------------------------------------------------------------------------]]
--- @class AceDbInitializer

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local AceDB = ns.O.AceDB
local DatabaseSchema, unit = ns.O.DatabaseSchema, ns.O.UnitUtil

local DB_VERSION = 1

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @alias DatabaseMixin_ABP_2_0 DatabaseMixin_ABP_2_0 | AceDB_3_0
--- @alias Database_ABP_2_0 DatabaseMixin_ABP_2_0 | ABP_Core_2_0
--
--
local libName = ns.M.DatabaseMixin()
--- @class DatabaseMixin_ABP_2_0
local S = ns:Register(libName, {})
local p, pd, t, tf = ns:log(libName)

--- @type DatabaseMixin_ABP_2_0 | Database_ABP_2_0
local o = S


--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
--- @param self DatabaseMixin_ABP_2_0
--- @param db AceDBObject_3_0
local function DatabaseMixin_RegisterCallbacks(self, db)
    db.RegisterCallback(self, "OnNewProfile", "OnNewProfile")
    db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    db.RegisterCallback(self, "OnProfileCopied", "OnProfileCopied")
    db.RegisterCallback(self, "OnProfileReset", "OnProfileReset")
    db.RegisterCallback(self, "OnProfileDeleted", "OnProfileDeleted")
end
--- @param self DatabaseMixin_ABP_2_0|Database_ABP_2_0
--- @param db DatabaseObj_ABP_2_0
local function DatabaseMixin_InitDBDefaults(self, db)
    db:RegisterDefaults(DatabaseSchema:GetDefaultDatabase())
    pd(('Current Profile: %s'):format(db:GetCurrentProfile()))
    --pd('Schema: version=', db.global.schemaVersion , 'global=', db.global, 'profile=', db.profile)
    --p('Schema: keys=', db.keys)
end

--- @param self DatabaseMixin_ABP_2_0|Database_ABP_2_0
--- @param db DatabaseObj_ABP_2_0
local function DatabaseMixin_EnsureSchemaUpToDate(self, db)
    local current = db.global.schemaVersion
    if current < DB_VERSION then
        self:RunMigrations(current)
        db.global.schemaVersion = DB_VERSION
    end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function o:OnNewProfile(evt, db, profileKey) p('OnNewProfile called...') end
function o:OnProfileChanged(evt, db, profileKey) p('OnProfileChanged called...') end
function o:OnProfileDeleted(evt, db, profileKey) p('OnProfileDeleted called...key=' .. profileKey) end
function o:OnProfileCopied() p('OnProfileCopied called...') end
function o:OnProfileReset() p('OnProfileReset called...') end

--- @param addon ABP_Core_2_0
function o:InitDb(addon)
  Mixin(addon, o)
  --- @type DatabaseObj_ABP_2_0
  local db = AceDB:New(ns.DB_NAME);
  DatabaseMixin_InitDBDefaults(addon, db)
  --DatabaseMixin_EnsureSchemaUpToDate(addon, db)
  DatabaseMixin_RegisterCallbacks(addon, db)
  
  ns:RegisterDB(db)
end

-- Empty for now; an example of a migration strategy
function o:RunMigrations(fromVersion)
  if fromVersion < 1 then
    --self:MigrateToV1()
  end
  
  if fromVersion < 2 then
    --self:MigrateToV2()
  end
end

--[[-------------------------------------------------------------------
Methods
---------------------------------------------------------------------]]
--- @return GlobalData_ABP_2_0
function o:g() return ns:db().global end

--- @return ProfileData_ABP_2_0
function o:p() return ns:db().profile end

--- @param barIndex number
--- @param btnIndex number
--- @return ButtonData_ABP_2_0|nil
function o:c(barIndex, btnIndex)
  assert(type(barIndex) == "number", "c(): barIndex must be number")
  assert(type(btnIndex) == "number", "c(): btnIndex must be number")
  
  local profile = self:p()
  local bars = profile.bars
  assert(type(bars) == "table", "c(): profile.bars missing")
  
  local bar = bars[barIndex]
  assert(type(bar) == "table", "c(): invalid barIndex " .. barIndex)
  
  local buttons = bar.buttons
  assert(type(buttons) == "table", "c(): bar.buttons missing")
  
  local btnSpecs = buttons[btnIndex]
  assert(type(btnSpecs) == "table", "c(): invalid btnIndex " .. btnIndex)

  return btnSpecs[unit:GetActiveSpecGroupIndex()]
end
