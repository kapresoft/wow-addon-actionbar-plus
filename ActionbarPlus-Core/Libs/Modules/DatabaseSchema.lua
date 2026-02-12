--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
Module::DatabaseSchema
-------------------------------------------------------------------------------]]
--- @see Modules_ABP_2_0
local libName = ns.M.DatabaseSchema()
--- @class DatabaseSchema_ABP_2_0
local S = {}; ns:Register(libName, S)
local p = ns:log(libName)

--[[-----------------------------------------------------------------------------
Module::DatabaseSchema (Methods)
-------------------------------------------------------------------------------]]
--- @type DatabaseSchema_ABP_2_0
local o = S


--[[-------------------------------------------------------------------
Default Database
---------------------------------------------------------------------]]
--- @class Config_ABP_2_0 : AceDBObjectObj
--- @field global GlobalConfig_ABP_2_0
--- @field profile ProfileConfig_ABP_2_0
--
--- @class DefaultConfig_ABP_2_0 : Config_ABP_2_0
--
--- @class GlobalConfig_ABP_2_0
local GlobalProfile = {
  schemaVersion = 1
}
--- @class ProfileConfig_ABP_2_0
local Profile = {

}

--- @return DefaultConfig_ABP_2_0
function o:GetDefaultDatabase()
  return { global = GlobalProfile, profile = Profile, }
end


