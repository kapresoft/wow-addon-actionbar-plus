--- @type string
local addon
--- @type Namespace | Kapresoft_Base_Namespace
local kns
addon, kns = ...

--[[-----------------------------------------------------------------------------
Type: DebugSettingsFlag
-------------------------------------------------------------------------------]]
--- @class DebugSettingsFlag
--- @field debugging OptionalFlag
--- @field eventTrace OptionalFlag
--- @see GlobalDeveloper
local flag = {
    developer = false,
    debugging = false,
    eventTrace = false,
}

--[[-----------------------------------------------------------------------------
Type: DebugSettings
-------------------------------------------------------------------------------]]
--- Make sure to match this structure in GlobalDeveloper (which is not packaged in releases)
--- @class DebugSettings
--- @field flag DebugSettingsFlag
--- @see GlobalDeveloper
kns.debug = {
    flag = flag
}
