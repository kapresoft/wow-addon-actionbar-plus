--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format = string.format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local StaticPopup_Visible, StaticPopup_Show = StaticPopup_Visible, StaticPopup_Show

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local CONFIRM_RELOAD_UI = 'CONFIRM_RELOAD_UI'

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
local function ConfirmAndReload()
    if StaticPopup_Visible(CONFIRM_RELOAD_UI) == nil then return StaticPopup_Show(CONFIRM_RELOAD_UI) end
    return false
end

local function GetFrameWidget(frameIndex) return FF:GetFrameByIndex(frameIndex).widget end
---@return BarData
local function GetBarConfig(frameIndex) return GetFrameWidget(frameIndex):GetConfig() end
local function GetFrameStateSetterHandler(frameIndex)
    return function(_, v)
        local f = FF:GetFrameByIndex(frameIndex)
        f.widget:SetFrameState(frameIndex, v)
    end
end

local function GetFrameStateGetterHandler(frameIndex)
    return function(_)
        local f = FF:GetFrameByIndex(frameIndex)
        return f.widget:IsShownInConfig(frameIndex)
    end
end

local function GetButtonSizeGetterHandler(frameIndex)
    return function(_) return GetBarConfig(frameIndex).widget.buttonSize or 36 end
end

local function GetButtonSizeSetterHandler(frameIndex)
    return function(_, v) GetBarConfig(frameIndex).widget.buttonSize = v end
end

local function GetResizeButtonHandler(frameIndex)
    return function(_, v)
        GetButtonSizeSetterHandler(frameIndex)(nil, v)
        ---@type FrameWidget
        BF:RefreshActionbar(frameIndex)
    end
end

local function GetRowSizeGetterHandler(frameIndex)
    return function(_) return GetBarConfig(frameIndex).widget.rowSize or 2 end
end
local function GetRowSizeSetterHandler(frameIndex)
    return function(_, v) GetBarConfig(frameIndex).widget.rowSize = v end
end
local function GetColSizeGetterHandler(frameIndex)
    return function(_) return GetBarConfig(frameIndex).widget.colSize or 6 end
end
local function GetColSizeSetterHandler(frameIndex)
    return function(_, v) GetBarConfig(frameIndex).widget.colSize = v end
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
                },
                hide_while_taxi = {
                    type = 'toggle',
                    order = order + 2,
                    width = 'full',
                    name = ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_NAME,
                    desc = ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_DESC,
                    get = PropertyGetter(self, PC.hide_when_taxi, false),
                    set = PropertySetter(self, PC.hide_when_taxi, false)
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
            -- barN is the config path name used for OptionDialog#OpenConfig()
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
                    width = "full",
                    get = GetFrameStateGetterHandler(frameIndex),
                    set = GetFrameStateSetterHandler(frameIndex)
                },
                button_width = {
                    type = 'range',
                    order = 2,
                    step = 1,
                    min = 20,
                    max = 100,
                    width = 1,
                    name = 'Size (Width & Height)',
                    desc = 'The width and height of a buttons',
                    --confirm = ConfirmAndReload,
                    get = GetButtonSizeGetterHandler(frameIndex),
                    --set = GetButtonSizeSetterHandler(frameIndex)
                    set = GetResizeButtonHandler(frameIndex)
                },
                rows = {
                    type = 'range',
                    order = 3,
                    step = 1,
                    min = 1,
                    max = 10,
                    width = 0.8,
                    name = 'Rows',
                    desc = 'The number of rows for the buttons',
                    confirm = ConfirmAndReload,
                    get = GetRowSizeGetterHandler(frameIndex),
                    set = GetRowSizeSetterHandler(frameIndex)
                },
                cols = {
                    type = 'range',
                    order = 4,
                    step = 1,
                    min = 1,
                    max = 10,
                    width = 0.8,
                    name = 'Columns',
                    desc = 'The number of columns for the buttons',
                    confirm = ConfirmAndReload,
                    get = GetColSizeGetterHandler(frameIndex),
                    set = GetColSizeSetterHandler(frameIndex)
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
