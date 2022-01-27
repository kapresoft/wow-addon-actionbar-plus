--[[-----------------------------------------------------------------------------
Config
-------------------------------------------------------------------------------]]

-- Lua APIs
local format = string.format

-- ActionbarPlus APIs
local LibStub, M, G = ABP_LibGlobals:LibPack()

---@type Profile
local P
---@type ProfileConfigNames
local PC
---@type ButtonFactory
local BF
---@type ButtonFrameFactory
local FF

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

local function CreateFrameStateSetterHandler(frameIndex)
    return function(_, v)
        local f = FF:GetFrameByIndex(frameIndex)
        f:SetFrameState(frameIndex, v)
    end
end

local function CreateFrameStateGetterHandler(frameIndex)
    return function(_)
        local f = FF:GetFrameByIndex(frameIndex)
        return f:IsShownInConfig(frameIndex)
    end
end

local function PropertySetter(config, key, fallbackVal)
    return function(_, v)
        assert(type(key) == 'string', 'Profile key should be a string')
        config.profile[key] = v or fallbackVal
    end
end

local function PropertyGetter(config, key, fallbackVal)
    return function(_)
        assert(type(key) == 'string', 'Profile key should be a string')
        return config.profile[key] or fallbackVal
    end
end

local function fetchLibs()
    local W = G:GetWidgetLibFactory()
    P, BF, FF = W:LibPack_Config()
    PC = P:GetConfigNames()
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
            args = self:CreateConfig(),
        }
    end,
    ['CreateConfig'] = function(self)
        local configArgs = {}

        configArgs['general'] = self:CreateGeneralGroup(1)
        configArgs['debugging'] = self:CreateDebuggingGroup(100)

        local barConfigs = self:CreateActionBarConfigs(9)
        for bName, bConf in pairs(barConfigs) do
            configArgs[bName] = bConf
        end


        return configArgs
    end,
    ['CreateGeneralGroup'] = function(self, order)
        return {
            type = "group",
            name = "General",
            desc = "General Settings",
            order = order or 999,
            args = {
                desc = { name = " General Configuration ", type = "header", order = 0 },
                lock_actionbars = {
                    type = 'toggle',
                    order = order + 1,
                    width = 'full',
                    name = ABP_GENERAL_CONFIG_LOCK_ACTION_BARS_NAME,
                    --desc = 'Prevents user from picking up or dragging spells, items, or macros from the ActionbarPlus bars.',
                    desc = ABP_GENERAL_CONFIG_LOCK_ACTION_BARS_DESC,
                    get = PropertyGetter(self, PC.lock_actionbars, false),
                    set = PropertySetter(self, PC.lock_actionbars, false)
                }
            }
        }
    end,
    ['CreateDebuggingGroup'] = function(self, order)
        return {
            type = "group",
            name = "Debugging",
            desc = "Debug Settings",
            order = order or 999,
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
    end,
    ['CreateActionBarConfigs'] = function(self, order)
        local count = P:GetBarSize()
        local bars = {}
        for i=1,count do
            local key = 'bar' .. i
            local barOrder = tonumber(tostring(order) .. tostring(i))
            bars[key] = self:CreateBarConfigDef(i, barOrder)
        end
        return bars
    end,
    ['CreateBarConfigDef'] = function(self, frameIndex, order)
        local configName = format('Action Bar #%s', tostring(frameIndex))
        return {
            type = 'group',
            name = configName,
            desc = format("%s Settings", configName),
            order = order or 999,
            args = {
                desc = { name = format("%s Settings", configName), type = "header", order = 0 },
                enabled = {
                    type = "toggle",
                    name = "Enable",
                    desc = format("Enable %s", configName),
                    order = 1,
                    get = CreateFrameStateGetterHandler(frameIndex),
                    set = CreateFrameStateSetterHandler(frameIndex)
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

    -- profile is injected OnAfterInitialize()
    local properties = {
        addon = nil,
        profile = nil
    }

    ---@class Config
    local _L = LibStub:NewLibrary(M.Config)
    _L.mt.__index = properties

    for method, func in pairs(methods) do
        _L[method] = func
    end

    return _L

end

NewInstance()
