--[[-----------------------------------------------------------------------------
BaseLibraryObject
-------------------------------------------------------------------------------]]
--- @class BaseLibraryObject
local BaseLibraryObject = {
    --- @type fun(self:BaseLibraryObject) : string
    GetModuleName = {},
    --- @type fun(self:BaseLibraryObject) : string, string The major and minor version
    GetVersionUnpacked = {},
    --- @type fun(self:BaseLibraryObject) : table<string, string>  With keys "major" and "minor"; major:string, minor:string
    GetVersion = {},
    --- @type fun(self:BaseLibraryObject) : Logger
    GetLogger = {},
    --- @type table
    mt = { __tostring = function() end },
}

--[[-----------------------------------------------------------------------------
BaseLibraryObject_WithAceEvent
-------------------------------------------------------------------------------]]

--- @class BaseLibraryObject_WithAceEvent : AceEvent
local BaseLibraryObject_WithAceEvent = {
    --- @param self BaseLibraryObject_WithAceEvent
    GetModuleName = function(self)  end,
    --- @type fun(self:BaseLibraryObject_WithAceEvent) : string, string The major and minor version
    GetVersionUnpacked = {},
    --- @type fun(self:BaseLibraryObject_WithAceEvent) : table<string, string>  With keys "major" and "minor"; major:string, minor:string
    GetVersion = {},
    --- @type fun(self:BaseLibraryObject_WithAceEvent) : LoggerTemplate
    GetLogger = {},
    --- @type table
    mt = { __tostring = function() end },
}

--[[-----------------------------------------------------------------------------
BaseLibraryObject_Initialized
-------------------------------------------------------------------------------]]
--- @class BaseLibraryObject_Initialized : BaseLibraryObject
local BaseLibraryObject_Initialized = {}
--- @type ActionbarPlus
BaseLibraryObject_Initialized.addon = {}
--- @type Profile_Config
BaseLibraryObject_Initialized.profile = {}

--[[-----------------------------------------------------------------------------
BaseLibraryObject_Initialized_WithAceEvent
-------------------------------------------------------------------------------]]
--- @class BaseLibraryObject_Initialized_WithAceEvent : BaseLibraryObject_WithAceEvent
local BaseLibraryObject_Initialized_WithAceEvent = {}
--- @type ActionbarPlus
BaseLibraryObject_Initialized_WithAceEvent.addon = {}
--- @type Profile_Config
BaseLibraryObject_Initialized_WithAceEvent.profile = {}


--[[-----------------------------------------------------------------------------
LoggerTemplate
-------------------------------------------------------------------------------]]
--- @class LoggerTemplate
--- @deprecated Use Logger
local LoggerTemplate = {
    --- @type fun(self:LoggerTemplate, format:string, ...)
    log = {}
}

--- @class Logger
local Logger = {
    --- @type fun(self:Logger, format:string, ...)
    log = {}
}


