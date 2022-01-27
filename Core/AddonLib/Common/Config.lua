--[[-----------------------------------------------------------------------------
Config
-------------------------------------------------------------------------------]]

local format = string.format
local LibStub, M, G = ABP_LibGlobals:LibPack()

---@type Profile
local P
---@type ButtonFactory
local BF
---@type ButtonFrameFactory
local FF

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

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

local function fetchLibs()
    local W = G:GetWidgetLibFactory()
    P, BF, FF = W:LibPack_Config()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
    ['OnAfterInitialize'] = function(self) fetchLibs() end,
    ['OnAfterAddonLoaded'] = function(self) end,
    ['GetOptions'] = function(self)
        return {
            name = G.addonName, handler = self.addon, type = "group",
            args = self:CreateBarConfigArgsDef(),
        }
    end,
    ['CreateBarConfigArgsDef'] = function(self)
        local configArgs = {}

        local count = P:GetBarSize()
        --local bars = P:GetBars()
        --error(format('frames count: %s', tostring(count)))
        --error(format('bars: %s', ABP_Table.toString(bars)))
        for i=1,count do
            local key = 'bar' .. i
            configArgs[key] = self:CreateBarConfigDef(i)
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
    end,
    ['CreateBarConfigDef'] = function(self, frameIndex)
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
    end,
}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@type Config
local function NewInstance()

    local properties = {
        addon = nil,
        profile = nil
    }

    ---@class Config
    local L = LibStub:NewLibrary(M.Config)
    print('__index:', getmetatable(L).__index or 'nil')
    L.mt.__index = properties

    for method, func in pairs(methods) do
        L[method] = func
    end

    return L

end

NewInstance()
