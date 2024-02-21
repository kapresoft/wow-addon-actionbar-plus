--[[-----------------------------------------------------------------------------
Alias Functions
-------------------------------------------------------------------------------]]
--- @alias FrameHandlerFunction fun(fw:FrameWidget) : void | "function(fw) print(fw:GetName()) end"
--- @alias ButtonPredicateFunction fun(bw:ButtonUIWidget) : boolean | "function(bw) print(bw:GetName()) end"
--- @alias ButtonHandlerFunction fun(bw:ButtonUIWidget) : void | "function(bw) print(bw:GetName()) end"

--[[-----------------------------------------------------------------------------
BaseLibraryObject
-------------------------------------------------------------------------------]]
local function BaseLibraryObject_Def()
    --- @class BaseLibraryObject
    local o = {}
    --- @type table
    o.mt = { __tostring = function() end }

    --- @type Logger
    o.logger = {}

    --- @return string
    function o:GetModuleName() end
    --- @return string, string The major and minor version
    function o:GetVersionUnpacked() end
    --- @type fun(self:BaseLibraryObject) : table<string, string>  With keys "major" and "minor"; major:string, minor:string
    --- @return table<string, string>
    function o:GetVersion() end
    --- @return Logger
    function o:GetLogger() end
end

--[[-----------------------------------------------------------------------------
BaseLibraryObject_WithAceEvent
-------------------------------------------------------------------------------]]
local function BaseLibraryObject_WithAceEvent_Def()
    --- @class BaseLibraryObject_WithAceEvent : AceEvent
    local o = {}
    --- @type table
    o.mt = { __tostring = function() end }

    --- @return string
    function o:GetModuleName() end
    --- @return string, string The major and minor version
    function o:GetVersionUnpacked() end
    --- @type fun(self:BaseLibraryObject) : table<string, string>  With keys "major" and "minor"; major:string, minor:string
    --- @return table<string, string>
    function o:GetVersion() end
    --- @return Logger
    function o:GetLogger() end
end

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
