--- @type string
local addon
--- @type BaseNamespace
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
    --- Enables debugging
    debugging = false,
    --- Enables the log console
    logConsole = false,
    --- Enable Event Tracing on the log console
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
    flag = flag,
    --- The name is case-insensitive
    chatFrameName = '<name of the chat-frame-tab>',
}
