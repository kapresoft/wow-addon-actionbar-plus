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

--- @type GlobalObjects
local O = ns.O or {}; ns.O = O

--- @type Kapresoft_LibUtil_ColorDefinition
local consoleColors = {
    primary   = '2db9fb',
    secondary = 'fbeb2d',
    tertiary  = 'ffffff',
}; ns.consoleColors = consoleColors

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

--- @return DebugSettings
local function debug()
    --- @class DebugSettings
    local o = {
        flag = flag,
    }
    --- @return boolean
    function o:IsDeveloper() return self.flag.developer == true  end
    --- @return boolean
    function o:IsEnableLogConsole()
        return self:IsDeveloper() and self.flag.enableLogConsole == true
    end
    function o:IsSelectLogConsoleTab()
        return self:IsEnableLogConsole() and self.flag.selectLogConsoleTab
    end
    return o;
end

ns.debug = debug()
