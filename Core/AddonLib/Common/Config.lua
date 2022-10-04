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
local GeneralConfigHeader = ' ' .. ABP_GENERAL_CONFIG_HEADER .. ' '
local GeneralTooltipOptionsHeader = ' ' .. ABP_GENERAL_TOOLTIP_OPTIONS_HEADER .. ' '
local MOUSEOVER_FRAME_MOVER_DESC = "Hide the frame mover at the top of the actionbar by default.  Mouseover to make it visible for moving the frame."

local p = O.LogFactory(Core.M.Config)

---These are loaded in #fetchLibs()
---@type Profile
local P
---@type Profile_Config_Names
local PC
---@type Profile_Config_Widget_Names
local WC
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
---@return Profile_Bar
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
local function PSetWidget(frameIndex, key, fallback, eventNameOrFunction)
    return function(_, v)
        assert(type(key) == 'string', 'Widget attribute key should be a string, but was ' .. type(key))
        GetBarConfig(frameIndex).widget[key] = v or fallback
        if 'string' == type(eventNameOrFunction) then BF:Fire(eventNameOrFunction, frameIndex)
        elseif 'function' == type(eventNameOrFunction) then eventNameOrFunction(frameIndex, v or fallback) end
    end
end

---@param frameIndex number
---@param key string The key value
---@param fallback any The fallback value
---@param eventNameOrFunction string | function | nil
local function PSetSpecificWidget(frameIndex, key, fallback, eventNameOrFunction)
    return function(_, v)
        assert(type(key) == 'string', 'Widget attribute key should be a string, but was ' .. type(key))
        GetBarConfig(frameIndex).widget[key] = v or fallback
        --print('key:', key, 'val:', GetBarConfig(frameIndex).widget[key])
        if 'string' == type(eventNameOrFunction) then BF:FireOnFrame(frameIndex, eventNameOrFunction)
        elseif 'function' == type(eventNameOrFunction) then eventNameOrFunction(frameIndex, v or fallback) end
    end
end

---@param frameIndex number
---@param key string The key value
---@param fallback any The fallback value
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
    PC = GC.Profile_Config_Names
    WC = GC.Profile_Config_Widget_Names
    TTK = P:GetTooltipKey()
end

---@param order number
---@param optionalIncrement number
local function nextOrder(order, optionalIncrement)
    order = order + (optionalIncrement or 1)
    print('new order:', order)
    return order
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@class OrderInfo
local orderInfo = {
    order = 1,

    ---@param self OrderInfo
    ---@param incr number An optional increment amount
    ["nextOrder"] = function(self, incr)
        self.order = self.order + (incr or 1)
        return self.order
    end
}
---@class ActionbarOrderInfo
local barOrderInfo = {
    order = 1,

    ---@param self OrderInfo
    ---@param incr number An optional increment amount
    ["nextOrder"] = function(self, incr)
        self.order = self.order + (incr or 1)
        return self.order
    end,
    ["reset"] = function(self)
        local lastCount = self.order + 1
        self.order = 1
        return lastCount
    end
}

---@class Config_Methods
local methods = {
    ---@param self Config
    ['OnAfterInitialize'] = function(self) fetchLibs() end,
    ---@param self Config
    ['OnAfterAddonLoaded'] = function(self) end,
    ---@param self Config
    ['GetOptions'] = function(self)
        return {
            name = GC.C.ADDON_NAME, handler = self.addon, type = "group",
            args = self:CreateConfig(),
        }
    end,
    ---@param self Config
    ['CreateConfig'] = function(self)
        local configArgs = {}

        configArgs['general'] = self:CreateGeneralGroup(orderInfo)
        configArgs['debugging'] = self:CreateDebuggingGroup(orderInfo)

        local barConfigs = self:CreateActionBarConfigs(orderInfo)
        for bName, bConf in pairs(barConfigs) do
            configArgs[bName] = bConf
        end


        return configArgs
    end,
    ---@param self Config
    ---@param order OrderInfo
    ['CreateGeneralGroup'] = function(self, order)
        return {
            type = "group",
            name = "General",
            desc = "General Settings",
            order = order:nextOrder(),
            args = {
                desc = { name = GeneralConfigHeader, type = "header", order = 0 },
                -- TODO: Remove lock_actionbars; Addon now uses WOW's ActionBars / Pick Up Action Key Settings
                lock_actionbars = {
                    hidden = true,
                    type = 'toggle',
                    order = order:nextOrder(),
                    name = ABP_GENERAL_CONFIG_LOCK_ACTION_BARS_NAME,
                    --desc = 'Prevents user from picking up or dragging spells, items, or macros from the ActionbarPlus bars.',
                    desc = ABP_GENERAL_CONFIG_LOCK_ACTION_BARS_DESC,
                    get = PGet(self, PC.lock_actionbars, false),
                    set = PSet(self, PC.lock_actionbars, false)
                },
                character_specific_anchors = {
                    type = 'toggle',
                    width = 'full',
                    confirm = ConfirmAndReload,
                    order = order:nextOrder(),
                    name = ABP_GENERAL_CONFIG_CHARACTER_SPECIFIC_FRAME_POSITIONS_NAME,
                    desc = ABP_GENERAL_CONFIG_CHARACTER_SPECIFIC_FRAME_POSITIONS_DESC,
                    get = PGet(self, PC.character_specific_anchors, false),
                    set = PSet(self, PC.character_specific_anchors, false)
                },
                hide_while_taxi = {
                    type = 'toggle',
                    order = order:nextOrder(),
                    name = ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_NAME,
                    desc = ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_DESC,
                    get = PGet(self, PC.hide_when_taxi, false),
                    set = PSet(self, PC.hide_when_taxi, false)
                },
                action_button_mouseover_glow = {
                    type = 'toggle',
                    order = order:nextOrder(),
                    name = ABP_GENERAL_CONFIG_ENABLE_ACTION_BUTTON_GLOW_NAME,
                    desc = ABP_GENERAL_CONFIG_ENABLE_ACTION_BUTTON_GLOW_DESC,
                    get = PGet(self, PC.action_button_mouseover_glow, false),
                    set = PSetWithEvent(self, PC.action_button_mouseover_glow, false, E.OnMouseOverGlowSettingsChanged)
                },
                hide_text_on_small_buttons = {
                    type = 'toggle',
                    order = order:nextOrder(),
                    width = 'full',
                    name = ABP_GENERAL_CONFIG_HIDE_TEXTS_FOR_SMALLER_BUTTONS_NAME,
                    desc = ABP_GENERAL_CONFIG_HIDE_TEXTS_FOR_SMALLER_BUTTONS_DESC,
                    get = PGet(self, PC.hide_text_on_small_buttons, false),
                    set = PSetWithEvent(self, PC.hide_text_on_small_buttons, false, E.OnTextSettingsChanged),
                },
                hide_countdown_numbers = {
                    type = 'toggle',
                    order = order:nextOrder(),
                    width = 'full',
                    name = ABP_GENERAL_CONFIG_HIDE_COUNTDOWN_NUMBERS_ON_COOLDOWNS_NAME,
                    desc = ABP_GENERAL_CONFIG_HIDE_COUNTDOWN_NUMBERS_ON_COOLDOWNS_DESC,
                    get = PGet(self, PC.hide_countdown_numbers, false),
                    set = PSetWithEvent(self, PC.hide_countdown_numbers, false, E.OnCooldownTextSettingsChanged),
                },
                tooltip_header = { order = order:nextOrder(), type = "header", name = GeneralTooltipOptionsHeader },
                tooltip_visibility_key = {
                    type = 'select', style = 'dropdown',
                    order = order:nextOrder(),
                    width = 'normal',
                    values = TTK.kvPairs, sorting = TTK.sorting,
                    name = ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_KEY_NAME,
                    desc = ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_KEY_DESC,
                    get = PGet(self, PC.tooltip_visibility_key, TTK.names.SHOW),
                    set = PSet(self, PC.tooltip_visibility_key, TTK.names.SHOW)
                },
                tooltip_visibility_combat_override_key = {
                    type = 'select', style = 'dropdown',
                    order = order:nextOrder(),
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
    ---@param self Config
    ---@param order OrderInfo
    ['CreateDebuggingGroup'] = function(self, order)
        return {
            type = "group",
            name = "Debugging",
            desc = "Debug Settings",
            -- Place right before Profiles
            order = 90,
            args = {
                desc = { name = " Debugging Configuration ", type = "header", order = 0 },
                log_level = {
                    type = 'range',
                    order = 1,
                    step = 5,
                    min = 0,
                    max = 50,
                    width = 1.2,
                    name = 'Log Level',
                    desc = 'Higher log levels generate for console logs.',
                    get = function(_) return GC:GetLogLevel() end,
                    set = function(_, v) GC:SetLogLevel(v) end,
                },
            },
        }
    end,
    ---@param self Config
    ---@param order OrderInfo
    ['CreateActionBarConfigs'] = function(self, order)
        local count = P:GetBarSize()
        local bars = {}
        for i=1,count do
            -- barN is the config path name used for OptionDialog#OpenConfig()
            local key = 'bar' .. i
            bars[key] = self:CreateBarConfigDef(i, order)
        end
        return bars
    end,
    ---@param self Config
    ---@param frameIndex number
    ---@param order OrderInfo
    ['CreateBarConfigDef'] = function(self, frameIndex, order)
        local configName = format('Action Bar #%s', tostring(frameIndex))
        return {
            type = 'group',
            name = configName,
            desc = format("%s Settings", configName),
            order = order:nextOrder(),
            args = {
                desc = { name = format("%s Settings", configName),
                         type = "header", order = barOrderInfo:nextOrder(), },
                enabled = {
                    type = "toggle",
                    name = "Enable",
                    desc = format("Enable %s", configName),
                    order = barOrderInfo:nextOrder(),
                    width = "full",
                    get = GetFrameStateGetterHandler(frameIndex),
                    set = GetFrameStateSetterHandler(frameIndex)
                },
                mouseover_frame_handle = {
                    type = "toggle",
                    name = "Mouseover Frame Mover",
                    desc = MOUSEOVER_FRAME_MOVER_DESC,
                    order = barOrderInfo:nextOrder(),
                    width = "double",
                    get = PGetWidget(frameIndex, WC.mouseover_frame_handle, false),
                    set = PSetWidget(frameIndex, WC.mouseover_frame_handle, false),
                },
                show_empty_buttons = {
                    type = "toggle",
                    name = "Show empty buttons",
                    desc = "Check this option to always show the buttons on the action bar, even when they are empty.",
                    order = barOrderInfo:nextOrder(),
                    width = "double",
                    get = PGetWidget(frameIndex, WC.show_empty_buttons, false),
                    set = PSetWidget(frameIndex, WC.show_empty_buttons, false),
                },
                showIndex = {
                    type = "toggle",
                    name = "Show Button Numbers",
                    desc = format("Show each button index on %s", configName),
                    order = barOrderInfo:nextOrder(),
                    width = "double",
                    get = GetShowButtonIndexStateGetterHandler(frameIndex),
                    set = GetShowButtonIndexStateSetterHandler(frameIndex)
                },
                showKeybindText = {
                    type = "toggle",
                    name = "Show Keybind Text",
                    desc = format("Show each button keybind text on %s", configName),
                    order = barOrderInfo:nextOrder(),
                    width = "double",
                    get = GetShowKeybindTextStateGetterHandler(frameIndex),
                    set = GetShowKeybindTextStateSetterHandler(frameIndex)
                },
                spacer1 = { type="description", name=" ", order = order:nextOrder() },
                alpha = {
                    type = 'range',
                    order = barOrderInfo:nextOrder(),
                    isPercent = true,
                    step = 0.01,
                    min = 0,
                    max = 1,
                    width = "full",
                    name = 'Alpha',
                    desc = 'Actionbar alpha',
                    get = PGetWidget(frameIndex, WC.buttonAlpha, 1.0),
                    set = PSetSpecificWidget(frameIndex, WC.buttonAlpha, 1.0, E.OnActionbarFrameAlphaUpdated),
                },
                button_width = {
                    type = 'range',
                    order = barOrderInfo:nextOrder(),
                    step = 1,
                    min = 20,
                    max = 100,
                    width = 1,
                    name = 'Size (Width & Height)',
                    desc = 'The width and height of a buttons',
                    get = PGetWidget(frameIndex, WC.buttonSize, 36),
                    set = PSetWidget(frameIndex, WC.buttonSize, 36, E.OnButtonSizeChanged),
                },
                rows = {
                    type = 'range',
                    order = barOrderInfo:nextOrder(),
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
                    order = barOrderInfo:nextOrder(),
                    step = 1,
                    min = 1,
                    max = 40,
                    width = 0.8,
                    name = 'Columns',
                    desc = 'The number of columns for the buttons',
                    confirm = ConfirmAndReload,
                    get = GetColSizeGetterHandler(frameIndex),
                    set = GetColSizeSetterHandler(frameIndex)
                },
                spacer2 = { type="description", name=" ", order = barOrderInfo:nextOrder() },
                lock = {
                    type = "select", style = "radio",
                    order = barOrderInfo:reset(),
                    values = {[''] = "No", ['always']="Always", ['in-combat']="In-Combat"},
                    name = "Lock Actionbar Frame?",
                    desc = format("Lock %s. " .. LOCK_FRAME_DESC, configName),
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
    --local properties = {
    --    addon = nil,
    --    profile = nil
    --}

    ---@class Config : Config_Methods
    local _L = LibStub:NewLibrary(Core.M.Config)

    Mixin:Mixin(_L, methods)
    return _L
end

NewInstance()
