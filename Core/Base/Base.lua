--- @type string
local addon
--- @type Namespace | Kapresoft_Base_Namespace
local kns
addon, kns = ...

--[[-----------------------------------------------------------------------------
Type: DebugSettings
-------------------------------------------------------------------------------]]
--- Make sure to match this structure in GlobalDeveloper (which is not packaged in releases)
--- @class DebugSettings
--- @field flag DebugSettingsFlag
kns.debug = {
    flag = {
        debugging = false,
        eventTrace = false,
    }
}
