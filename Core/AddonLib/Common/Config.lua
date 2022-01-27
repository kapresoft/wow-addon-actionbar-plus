-- ## External -------------------------------------------------
local format = string.format

-- ## Local ----------------------------------------------------
local LibStub, M, G = ABP_LibGlobals:LibPack()
local PrettyPrint, Table, String = ABP_LibGlobals:LibPackUtils()
local unpack = Table.unpackIt

---@class Config
local _L = LibStub:NewLibrary(M.Config)
if not _L then return end

-- Initializedin OnAddonLoaded() - See Logger
_L.profile = nil
_L.addon = nil

local P
local BF
local FF

-- ## Functions ------------------------------------------------

function _L:OnAfterInitialize()
    local W = G:GetWidgetLibFactory()
    P, BF, FF = W:LibPack_Config()
end

local function CreateSetterHandler(frameIndex)
    return function(_, v)
        local f = FF:GetFrameByIndex(frameIndex)
        f:SetFrameState(frameIndex, v)
    end
end

local function CreateGetterHandler(frameIndex)
    return function(_)
        local f = FF:GetFrameByIndex(frameIndex)
        return f:IsShownInConfig(frameIndex)
    end
end

function _L:OnAfterAddonLoaded()
    local bars = P:GetBars()
    local count = P:GetBarSize()
end

-- Main Entry Point to config dialog
function _L:GetOptions()
    return {
        name = G.addonName, handler = _L.addon, type = "group",
        args = _L:CreateBarConfigArgsDef(),

    }
end

function _L:CreateBarConfigArgsDef()
    local configArgs = {}
    local count = P:GetBarSize()
    --local bars = P:GetBars()
    --error(format('frames count: %s', tostring(count)))
    --error(format('bars: %s', ABP_Table.toString(bars)))
    for i=1,count do
        local key = 'bar' .. i
        configArgs[key] = _L:CreateBarConfigDef(i)
    end

    configArgs.debugging = {
        type = "group",
        name = "Debugging",
        desc = "Debug Settings",
        order = 3,
        args = {
            desc = { name = " Debugging Configuration ", type = "header", order = 0 },
            log_level = {
                type = 'range',
                order = 1,
                step = 5,
                min = 0,
                max = 100,
                width = 1.2,
                name = 'Log Level',
                desc = 'Higher log levels generate for console logs.',
                get = function(_) return G:GetLogLevel() end,
                set = function(_, v) G:SetLogLevel(v) end,
            },
        },
    }

    return configArgs
end

function _L:CreateBarConfigDef(frameIndex)
    local configName = format('Action Bar #%s', tostring(frameIndex))
    return {
        type = 'group',
        name = configName,
        desc = format("%s Settings", configName),
        order = 1,
        args = {
            desc = { name = format("%s Settings", configName), type = "header", order = 0 },
            enabled = {
                type = "toggle",
                name = "Enable",
                desc = format("Enable %s", configName),
                order = 1,
                get = CreateGetterHandler(frameIndex),
                set = CreateSetterHandler(frameIndex)
            }
        }
    }
end
