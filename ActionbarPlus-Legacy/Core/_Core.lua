local ENABLE_V2 = false

--[[-----------------------------------------------------------------------------
Type: CoreNamespace
-------------------------------------------------------------------------------]]
--- @type CoreNamespace
local ns = select(2, ...)

local K = ns.Kapresoft_LibUtil
K:MixinWithDefExc(ns, K.Objects.CoreNamespaceMixin, K.Objects.NamespaceAceLibraryMixin)

--- @type string
--- @deprecated Deprecated. Use ns.addon
ns.name = ns.addon
ns.addonLogName   = 'ABP'

--- Used in XML files to hook frame events: OnLoad and OnEvent
--- Example: <OnLoad>ABP_XML:[TypeName]_OnLoad(self)</OnLoad>
ns.xml = {}
ABP_XML = ns.xml

--- @type GlobalObjects
local O = ns.O or {}; ns.O = O

--- @type Kapresoft_LibUtil_ColorDefinition
ns.consoleColors = {
    primary   = '2db9fb',
    secondary = 'fbeb2d',
    tertiary  = 'ffffff',
}
ns.ch = ns:NewConsoleHelper(ns.consoleColors)

--- @class AddOnFeatures
local features = { enableV2 = ENABLE_V2, }
ns.features = features

--- @return boolean
function ns:IsV2() return ns.features.enableV2 == true end

--[[-----------------------------------------------------------------------------
Type: DebugSettingsFlag
-------------------------------------------------------------------------------]]
--- @class DebugSettingsFlag
--- @see DeveloperSetup
local flag = {
    --- Enables debugging
    developer = false,
    --- Enables the DebugChatFrame log console
    enableLogConsole = false,
    --- Enable selection of chat frame tab
    selectLogConsoleTab = true,
    --- Enable Event Tracing on the log console
    eventTrace = false,
}

--[[-----------------------------------------------------------------------------
Type: DebugSettings
--- Make sure to match this structure in GlobalDeveloper (which is not packaged in releases)
-------------------------------------------------------------------------------]]
--- @class DebugSettings
local debug = {
    flag = flag
}; ns.debug = debug

--[[-----------------------------------------------------------------------------
Namespace Methods
-------------------------------------------------------------------------------]]
--- @return boolean
function ns:IsDev() return ns.debug.flag.developer == true end
