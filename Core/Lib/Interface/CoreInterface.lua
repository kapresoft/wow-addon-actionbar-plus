--[[-----------------------------------------------------------------------------
BaseLibraryObject
-------------------------------------------------------------------------------]]
--- @class BaseLibraryObject
local BaseLibraryObject = {
    --- @type table
    mt = { __tostring = function() end },
}
--- @return LoggerTemplate
function BaseLibraryObject:GetLogger()  end
--[[-----------------------------------------------------------------------------
BaseLibraryObject_WithAceEvent
-------------------------------------------------------------------------------]]

--- @class BaseLibraryObject_WithAceEvent : AceEvent
local BaseLibraryObject_WithAceEvent = {
    --- @type table
    mt = { __tostring = function() end },
}
--- @return LoggerTemplate
function BaseLibraryObject_WithAceEvent:GetLogger()  end

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
