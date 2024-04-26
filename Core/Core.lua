--[[-----------------------------------------------------------------------------
Type: CoreNamespace
-------------------------------------------------------------------------------]]
--- @class CoreNamespace : Kapresoft_Base_Namespace
--- @field gameVersion GameVersion
--- @field GC GlobalConstants
local ns
--- @type string
local addon

addon, ns = ...; ns.addon = addon

--- @type GlobalObjects
local O = ns.O or {}; ns.O = O

-- global print/logger ('c')
function ns.print(...)
    if ns.chatFrame then return ns.chatFrame:log(...) end
    print(...)
end; c = ns.print

---@param module Name
function ns.logp(module, ...)
    if ns.chatFrame then return ns.chatFrame:logp(module,...) end
    print(module, ...)
end;

--- @see AceLibraryMixin.lua
--- @param o CoreNamespace
local function CoreNamespaceMixin(o)

    local KO = ns.Kapresoft_LibUtil.Objects
    local AceMixin = KO.NamespaceAceLibraryMixin
    o.AceEvent = AceMixin.AceEvent
    o.AceHook = AceMixin.AceHook
    o.AceBucket = AceMixin.AceBucket

    --- @return Kapresoft_LibUtil
    function o:K() return ns.Kapresoft_LibUtil end

    --- @return Kapresoft_LibUtil_Objects
    function o:KO() return KO end

    --- @return Kapresoft_LibUtil_AceLibraryObjects
    function o:AceLibrary() return KO.AceLibrary.O end

    --- @return Kapresoft_LibUtil_Assert
    function o:Assert() return KO.Assert end

    --- @return Kapresoft_LibUtil_ColorUtil
    function o:ColorUtil() return KO.ColorUtil end

    --- @return Kapresoft_LibUtil_Safecall
    function o:Safecall() return KO.Safecall end

    --- @return Kapresoft_LibUtil_String
    function o:String() return KO.String end

    --- @return Kapresoft_LibUtil_Table
    function o:Table() return KO.Table end

    --- @return Kapresoft_LibUtil_TimeUtil
    function o:TimeUtil() return KO.TimeUtil end

end; CoreNamespaceMixin(ns)

--[[-----------------------------------------------------------------------------
Type: DebugSettingsFlag
-------------------------------------------------------------------------------]]
--- @class DebugSettingsFlag
--- @see DeveloperSetup
local flag = {
    developer = false,
    --- Enables debugging
    logConsole = false,
    --- Enable Event Tracing on the log console
    eventTrace = false,
}

--[[-----------------------------------------------------------------------------
Type: DebugSettings
--- Make sure to match this structure in GlobalDeveloper (which is not packaged in releases)
-------------------------------------------------------------------------------]]

--- @return DebugSettings
local function debug()
    --- @class DebugSettings
    local o = {
        flag = flag,
        --- The name is case-insensitive
        chatFrameName = '<name of the chat-frame-tab>'
    }
    function o:IsDeveloper() return self.flag.developer == true  end
    return o;
end

ns.debug = debug()
