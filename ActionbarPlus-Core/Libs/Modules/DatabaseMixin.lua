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

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @alias DatabaseMixin_ABP_2_0 DatabaseMixinImpl_ABP_2_0 | AceDB
--- @alias Database_ABP_2_0 DatabaseMixin_ABP_2_0 | ABP_Core_2_0
--
--
local libName = ns.M.DatabaseMixin()
--- @class DatabaseMixinImpl_ABP_2_0
local S = ns:Register(libName, {})
local p = ns:log(libName)

--- @type DatabaseMixinImpl_ABP_2_0 | Database_ABP_2_0
local o = S

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
--- @param self DatabaseMixinImpl_ABP_2_0|Database_ABP_2_0
--- @param db AceDBObjectObj
local function DatabaseMixin_RegisterCallbacks(self, db)
    db.RegisterCallback(self, "OnNewProfile", "OnNewProfile")
    db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    db.RegisterCallback(self, "OnProfileCopied", "OnProfileCopied")
    db.RegisterCallback(self, "OnProfileReset", "OnProfileReset")
    db.RegisterCallback(self, "OnProfileDeleted", "OnProfileDeleted")
end
--- @param self DatabaseMixinImpl_ABP_2_0|Database_ABP_2_0
--- @param db AceDBObjectObj
local function DatabaseMixin_InitDBDefaults(self, db)
    --todo next: setup default db
    --db:RegisterDefaults(ns.DefaultAddOnDatabase)
    db.profile.enable = true
    p(('Current Profile: %s'):format(ns:db():GetCurrentProfile()))
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
    local db = AceDB:New(ns.DB_NAME); ns:RegisterDB(db)
    DatabaseMixin_RegisterCallbacks(addon, db)
    DatabaseMixin_InitDBDefaults(addon, db)
end
