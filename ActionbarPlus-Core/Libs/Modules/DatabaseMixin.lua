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
--- @alias Database_ABP_2_0 DatabaseMixin_ABP_2_0
--
--
local libName = ns.M.DatabaseMixin()
--- @class DatabaseMixinImpl_ABP_2_0
local S = ns:Register(libName, {})
local p = ns:log(libName)

--- @type DatabaseMixinImpl_ABP_2_0 | DatabaseMixin_ABP_2_0
local o = S

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function o:OnNewProfile(evt, db, profileKey) p('OnNewProfile called...') end
function o:OnProfileChanged(evt, db, profileKey) p('OnProfileChanged called...') end
function o:OnProfileDeleted(evt, db, profileKey) p('OnProfileDeleted called...key=' .. profileKey) end
function o:OnProfileCopied() p('OnProfileCopied called...') end
function o:OnProfileReset() p('OnProfileReset called...') end

--ns:db().RegisterCallback(o, "OnNewProfile", "OnNewProfile")
--ns:db().RegisterCallback(o, "OnProfileChanged", "OnProfileChanged")
--ns:db().RegisterCallback(o, "OnProfileCopied", "OnProfileCopied")
--ns:db().RegisterCallback(o, "OnProfileReset", "OnProfileReset")
--ns:db().RegisterCallback(o, "OnProfileDeleted", "OnProfileDeleted")

--- @param addon ABP_Core_2_0_Impl
function o:InitDb(addon)
    
    local db = AceDB:New(ns.DB_NAME)
    ns:RegisterDB(db)
    
    --C_Timer.After(1, function()
    --    p('xx db keys:', db.keys)
    --end)
    
    Mixin(addon, self)
    --self:InitDbDefaults()
end

--[[-----------------------------------------------------------------------------
Library Methods
-------------------------------------------------------------------------------]]
----- @type DatabaseMixinImpl_ABP_2_0
--local LIB = S


--[[-----------------------------------------------------------------------------
Instance Methods
-------------------------------------------------------------------------------]]
--- @type AceDbInitializer
--local o = S

--[[--- Called by CreateAndInitFromMixin(..) Automatically
--- @param addon AddonSuite
function o:Init(addon)
    assert(addon, "AddonSuite is required")
    self.addon = addon
    self.addon.db = AceDB:New(GC.C.DB_NAME)
    self.addon.dbInit = self
    ns:SetAddOnFn(function() return self.addon.db end)
end]]

--[[--- @return AceDB
function o:GetDB() return self.addon.db end]]

--function o:InitDb()
--    p( 'Initialize called...')
--    AddonCallbackMethods(self.addon)
--    self:InitDbDefaults()
--end

--function o:InitDbDefaults()
--    ns:db():RegisterDefaults(ns.DefaultAddOnDatabase)
--    ns:db().profile.enable = true
--    p:i(function() return 'Profile: %s', ns:db():GetCurrentProfile() end)
--end
