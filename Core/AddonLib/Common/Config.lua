--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local GC, Mixin = O.GlobalConstants, O.Mixin
local E = GC.E

local p = O.LogFactory(Core.M.Config)

---These are loaded in #fetchLibs()
---@type Profile
local P
---@type ProfileConfigNames
local PC
---@type TooltipKey
local TTK
---@type ButtonFactory
local BF
---@type ButtonFrameFactory
local FF

local LOCK_FRAME_DESC = [[


Options:
  Always: lock the frame at all times.
  In-Combat: lock the frame during combat.

Note: this option only prevents the frame from being moved and does not lock individual
action items.
]]

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
local function ConfirmAndReload() return Core.O().WidgetMixin:ConfirmAndReload() end
local function GetFrameWidget(frameIndex) return FF:GetFrameByIndex(frameIndex).widget end
---@return BarData
local function GetBarConfig(frameIndex) return GetFrameWidget(frameIndex):GetConfig() end

---@param applyFunction function Format: applyFuntion(ButtonUIWidget)
local function ApplyForEachButton(applyFunction, configVal)
    BF:ApplyForEachFrames(function(frameWidget)
        ---@param widget ButtonUIWidget
        frameWidget:ApplyForEachButtons(function(widget) applyFunction(widget, configVal) end)
    end)
end

local function PSetWithEvent(config, key, fallbackVal, eventName)
    return function(_, v)
        assert(type(key) == 'string', 'Profile key should be a string')
        config.profile[key] = v or fallbackVal
        if eventName then BF:Fire(eventName) end
    end
end

local function SetAndApplyGeneric(config, key, fallbackVal, postFunction)
    return function(_, v)
        assert(type(key) == 'string', 'Profile key should be a string')
        config.profile[key] = v or fallbackVal
        if 'function' == type(postFunction) then postFunction(config.profile[key]) end
    end
end

---@param fallback any The fallback value
---@param key string The key value
---@param config Config The config instance
local function SetAndApply(config, key, fallback, foreachButtonFunction)
    return function(_, v)
        assert(type(key) == 'string', 'Profile key should be a string')
        config.profile[key] = v or fallback
        if 'function' == type(foreachButtonFunction) then
            ApplyForEachButton(foreachButtonFunction, config.profile[key])
        end
    end
end

---@param frameIndex number
---@param key string The key value
---@param fallback any The fallback value
---@param eventNameOrFunction string | function | nil
---@see ProfileWidgetConfigNames
local function PSetWidget(frameIndex, key, fallback, eventNameOrFunction)
    return function(_, v)
        assert(type(key) == 'string', 'Widget attribute key should be a string, but was ' .. type(key))
        GetBarConfig(frameIndex).widget[key] = v or fallback
        if 'string' == type(eventNameOrFunction) then BF:Fire(eventNameOrFunction)
        elseif 'function' == type(eventNameOrFunction) then eventNameOrFunction(frameIndex, v or fallback) end
    end
end

---@param frameIndex number
---@param key string The key value
---@param fallback any The fallback value
---@see ProfileWidgetConfigNames
local function PGetWidget(frameIndex, key, fallback)
    return function(_)
        assert(type(key) == 'string', 'Widget attribute key should be a string, but was ' .. type(key))
        return GetBarConfig(frameIndex).widget[key] or fallback
    end
end

local function GetFrameStateSetterHandler(frameIndex)
    return function(_, v) GetFrameWidget(frameIndex):SetFrameState(v) end
end
local function GetFrameStateGetterHandler(frameIndex)
    return function(_) return GetFrameWidget(frameIndex):IsShownInConfig() end
end
local function GetShowButtonIndexStateGetterHandler(frameIndex)
    return function(_) return GetFrameWidget(frameIndex):IsShowIndex() end
end
local function GetShowButtonIndexStateSetterHandler(frameIndex)
    --TODO: NEXT: Use events instead
    return function(_, v) GetFrameWidget(frameIndex):ShowButtonIndices(v) end
end
local function GetShowKeybindTextStateGetterHandler(frameIndex)
    return function(_) return GetFrameWidget(frameIndex):IsShowKeybindText() end
end
local function GetShowKeybindTextStateSetterHandler(frameIndex)
    --TODO: NEXT: Use events instead
    return function(_, v) GetFrameWidget(frameIndex):ShowKeybindText(v) end
end
local function GetLockStateSetterHandler(frameIndex)
    return function(_, v)
        P:SetBarLockValue(frameIndex, v)
        GetFrameWidget(frameIndex):SetLockedState()
    end
end
local function GetLockStateGetterHandler(frameIndex)
    return function(_) return P:GetBarLockValue(frameIndex) end
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

---@param config Config The config instance
---@param key string The key value
---@param fallback any The fallback value
local function PSet(config, key, fallback)
    return function(_, v)
        assert(type(key) == 'string', 'Profile key should be a string')
        config.profile[key] = v or fallback
    end
end

---@param config Config The config instance
---@param fallback any The fallback value
---@param key string The key value
local function PGet(config, key, fallback)
    return function(_)
        assert(type(key) == 'string', 'Profile key should be a string')
        return config.profile[key] or fallback
    end
end

local function fetchLibs()
    P, BF, FF = O.Profile, O.ButtonFactory, O.ButtonFrameFactory
    PC = P:GetConfigNames()
    TTK = P:GetTooltipKey()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
    ['OnAfterInitialize'] = function(self) fetchLibs() end,
    ['OnAfterAddonLoaded'] = function(self) end,
    ['GetOptions'] = function(self)
        return {
            name = GC.C.ADDON_NAME, handler = self.addon, type = "group",
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
                -- TODO: Remove lock_actionbars; Addon now uses WOW's ActionBars / Pick Up Action Key Settings
                lock_actionbars = {
                    hidden = true,
                    type = 'toggle',
                    order = order + 1,
                    width = 'full',
                    name = ABP_GENERAL_CONFIG_LOCK_ACTION_BARS_NAME,
                    --desc = 'Prevents user from picking up or dragging spells, items, or macros from the ActionbarPlus bars.',
                    desc = ABP_GENERAL_CONFIG_LOCK_ACTION_BARS_DESC,
                    get = PGet(self, PC.lock_actionbars, false),
                    set = PSet(self, PC.lock_actionbars, false)
                },
                hide_while_taxi = {
                    type = 'toggle',
                    order = order + 2,
                    name = ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_NAME,
                    desc = ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_DESC,
                    get = PGet(self, PC.hide_when_taxi, false),
                    set = PSet(self, PC.hide_when_taxi, false)
                },
                action_button_mouseover_glow = {
                    type = 'toggle',
                    order = order + 3,
                    name = ABP_GENERAL_CONFIG_ENABLE_ACTION_BUTTON_GLOW_NAME,
                    desc = ABP_GENERAL_CONFIG_ENABLE_ACTION_BUTTON_GLOW_DESC,
                    get = PGet(self, PC.action_button_mouseover_glow, false),
                    set = PSetWithEvent(self, PC.action_button_mouseover_glow, false, E.OnMouseOverGlowSettingsChanged)
                },
                hide_text_on_small_buttons = {
                    type = 'toggle',
                    order = order + 4,
                    width = 'full',
                    name = ABP_GENERAL_CONFIG_HIDE_TEXTS_FOR_SMALLER_BUTTONS_NAME,
                    desc = ABP_GENERAL_CONFIG_HIDE_TEXTS_FOR_SMALLER_BUTTONS_DESC,
                    get = PGet(self, PC.hide_text_on_small_buttons, false),
                    set = PSetWithEvent(self, PC.hide_text_on_small_buttons, false, E.OnTextSettingsChanged),
                },
                hide_countdown_numbers = {
                    type = 'toggle',
                    order = order + 5,
                    width = 'full',
                    name = ABP_GENERAL_CONFIG_HIDE_COUNTDOWN_NUMBERS_ON_COOLDOWNS_NAME,
                    desc = ABP_GENERAL_CONFIG_HIDE_COUNTDOWN_NUMBERS_ON_COOLDOWNS_DESC,
                    get = PGet(self, PC.hide_countdown_numbers, false),
                    set = PSetWithEvent(self, PC.hide_countdown_numbers, false, E.OnCooldownTextSettingsChanged),
                },
                tooltip_header = { order = order + 6, type = "header", name = ABP_GENERAL_TOOLTIP_OPTIONS },
                tooltip_visibility_key = {
                    type = 'select', style = 'dropdown',
                    order = order + 7,
                    width = 'normal',
                    values = TTK.kvPairs, sorting = TTK.sorting,
                    name = ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_KEY_NAME,
                    desc = ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_KEY_DESC,
                    get = PGet(self, PC.tooltip_visibility_key, TTK.names.SHOW),
                    set = PSet(self, PC.tooltip_visibility_key, TTK.names.SHOW)
                },
                tooltip_visibility_combat_override_key = {
                    type = 'select', style = 'dropdown',
                    order = order + 8,
                    width = 'normal',
                    values = TTK.kvPairs, sorting = TTK.sorting,
                    name = ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_COMBAT_OVERRIDE_KEY_NAME,
                    desc = ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_COMBAT_OVERRIDE_KEY_DESC,
                    get = PGet(self, PC.tooltip_visibility_combat_override_key),
                    set = PSet(self, PC.tooltip_visibility_combat_override_key)
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
                    get = function(_) return GC:GetLogLevel() end,
                    set = function(_, v) GC:SetLogLevel(v) end,
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
                showIndex = {
                    type = "toggle",
                    name = "Show Button Numbers",
                    desc = format("Show each button index on %s", configName),
                    order = 1,
                    width = "full",
                    get = GetShowButtonIndexStateGetterHandler(frameIndex),
                    set = GetShowButtonIndexStateSetterHandler(frameIndex)
                },
                showKeybindText = {
                    type = "toggle",
                    name = "Show Keybind Text",
                    desc = format("Show each button keybind text on %s", configName),
                    order = 1,
                    width = "full",
                    get = GetShowKeybindTextStateGetterHandler(frameIndex),
                    set = GetShowKeybindTextStateSetterHandler(frameIndex)
                },
                spacer1 = { type="description", name=" ", order=2 },
                button_width = {
                    type = 'range',
                    order = 3,
                    step = 1,
                    min = 20,
                    max = 100,
                    width = 1,
                    name = 'Size (Width & Height)',
                    desc = 'The width and height of a buttons',
                    get = PGetWidget(frameIndex, "buttonSize", 36),
                    set = PSetWidget(frameIndex, "buttonSize", 36, E.OnButtonSizeChanged),
                },
                rows = {
                    type = 'range',
                    order = 4,
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
                    order = 5,
                    step = 1,
                    min = 1,
                    max = 10,
                    width = 0.8,
                    name = 'Columns',
                    desc = 'The number of columns for the buttons',
                    confirm = ConfirmAndReload,
                    get = GetColSizeGetterHandler(frameIndex),
                    set = GetColSizeSetterHandler(frameIndex)
                },
                spacer2 = { type="description", name=" ", order=6 },
                lock = {
                    type = "select", style = "radio",
                    values = {[''] = "No", ['always']="Always", ['in-combat']="In-Combat"},
                    name = "Lock Actionbar Frame?",
                    desc = format("Lock %s. " .. LOCK_FRAME_DESC, configName),
                    order = 7,
                    width = .8,
                    get = GetLockStateGetterHandler(frameIndex),
                    set = GetLockStateSetterHandler(frameIndex)
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
    local _L = LibStub:NewLibrary(Core.M.Config)
    _L.mt.__index = properties

    Mixin:Mixin(_L, methods)
    return _L
end

NewInstance()
