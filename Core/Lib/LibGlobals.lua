-- log levels, 10, 20, (+10), 100
if type(ABP_PLUS_DB) ~= "table" then ABP_PLUS_DB = {} end
if type(ABP_LOG_LEVEL) ~= "number" then ABP_LOG_LEVEL = 1 end
if type(ABP_DEBUG_MODE) ~= "boolean" then ABP_DEBUG_MODE = false end
--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format, unpack = string.format, unpack

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetAddOnMetadata = GetAddOnMetadata

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]

-- ## Start Here ---
local LibStub, Core = __K_Core:LibPack()
local M = Core.M
-- ABP_LOG_LEVEL is also in use here
local ABP_PLUS_DB_NAME = 'ABP_PLUS_DB'
local addonName, versionFormat, logPrefix = Core:GetAddonInfo()

---Only put string constants here (non-UI contants)
---@class LibGlobalConstants
local C = {

    ABP_KEYBIND_FORMAT = '\n|cfd03c2fcKeybind ::|r |cfd5a5a5a%s|r',
    ALT = 'ALT',
    ANCHOR_TOPLEFT = 'ANCHOR_TOPLEFT',
    ARTWORK_DRAW_LAYER = 'ARTWORK',
    BOTTOMLEFT = 'BOTTOMLEFT',
    BOTTOMRIGHT = 'BOTTOMRIGHT',
    CLAMPTOBLACKADDITIVE = 'CLAMPTOBLACKADDITIVE',
    CONFIRM_RELOAD_UI = 'CONFIRM_RELOAD_UI',
    CTRL = 'CTRL',
    HIGHLIGHT_DRAW_LAYER = 'HIGHLIGHT',
    PICKUPACTION = 'PICKUPACTION',
    SECURE_ACTION_BUTTON_TEMPLATE = 'SecureActionButtonTemplate',
    SHIFT = 'SHIFT',
    TOPLEFT = 'TOPLEFT',

}

---@class LibGlobals
local _L = {
    -- use whole number if no longer in beta
    name = addonName,
    addonName = addonName,
    version = GetAddOnMetadata(addonName, 'Version'),
    versionText = GetAddOnMetadata(addonName, 'X-Github-Project-Version'),
    dbName = ABP_PLUS_DB_NAME,
    versionFormat = versionFormat,
    logPrefix = logPrefix,
    C = C,
    M = M,
    ---@deprecated Use 'M'
    Module = M,
    mt = {
        __tostring = function() return addonName .. "::LibGlobals" end,
        __call = function (_, ...)
            --local libNames = {...}
            --print("G|libNames:", pformat(libNames))
            return __K_Core:Lib(...)
        end
    }
}
setmetatable(_L, _L.mt)
Core:Register(M.LibGlobals, _L)

--TODO: NEXT: deprecated
---@type LibGlobals
ABP_LibGlobals = _L

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function _L:GetLogLevel() return ABP_LOG_LEVEL end
---@param level number The log level between 1 and 100
function _L:SetLogLevel(level) ABP_LOG_LEVEL = level or 1 end


function _L:Get(...)
    local libNames = {...}
    local libs = {}
    for _, lib in ipairs(libNames) do
        local o = LibStub(lib)
        --assert(o ~= nil, 'Lib not found: ' .. lib)
        table.insert(libs, o)
    end
    return unpack(libs)
end

function _L:GetLogPrefix() return self.logPrefix end

---### Addon Version Info
---```Example:
---local version, major = G:GetVersionInfo()
---```
---@return string, string The version text, major version of the addon.
function _L:GetVersionInfo() return self.versionText, self.version end

---### Addon URL Info
---```Example:
---local versionText, curseForge, githubIssues, githubRepo = G:GetAddonInfo()
---```
---@return string, string, string The version and URL info for curse forge, github issues, github repo
function _L:GetAddonInfo()
    local versionText = self.versionText
    --@debug@
    versionText = '1.0.dev'
    --@end-debug@
    return versionText, GetAddOnMetadata(addonName, 'X-CurseForge'), GetAddOnMetadata(addonName, 'X-Github-Issues'),
                GetAddOnMetadata(addonName, 'X-Github-Repo')
end
