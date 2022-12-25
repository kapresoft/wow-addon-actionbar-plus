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
---@return FrameWidget
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

---@param frameIndex number
local function OnResetAnchor(frameIndex) return function() GetFrameWidget(frameIndex):ResetAnchor() end end

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
    return function(_, v)
        GetBarConfig(frameIndex).widget.rowSize = v
        BF:Fire(E.OnButtonCountChanged)
    end
end
local function GetColSizeGetterHandler(frameIndex)
    return function(_) return GetBarConfig(frameIndex).widget.colSize or 6 end
end
local function GetColSizeSetterHandler(frameIndex)
    return function(_, v)
        GetBarConfig(frameIndex).widget.colSize = v
        BF:Fire(E.OnButtonCountChanged)
    end
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
--[[-----------------------------------------------------------------------------
Sequence
-------------------------------------------------------------------------------]]
local sp = '                                                                   '

---@class SequenceMixin
local SequenceMixin = {

    ---@param self SequenceMixin
    ---@param startingIndex number
    ["Init"] = function(self, startingIndex)
        self.order = startingIndex or 1
    end,
    ---@param self SequenceMixin
    ["get"] = function(self) return self.order  end,
    ---@param self SequenceMixin
    ---@param incr number An optional increment amount
    ["next"] = function(self, incr)
        self.order = self.order + (incr or 1)
        return self.order
    end,
    ---@param self SequenceMixin
    ["reset"] = function(self)
        local lastCount = self.order + 1
        self.order = 1
        return lastCount
    end
}

---@param startingSequence number Optional
---@return SequenceMixin
local function CreateSequence(startingSequence)
    ---@type SequenceMixin
    return CreateAndInitFromMixin(SequenceMixin, startingSequence)
end

local mainSeq = CreateSequence()
local barSeq = CreateSequence()

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
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

        configArgs['general'] = self:CreateGeneralGroup()
        configArgs['debugging'] = self:CreateDebuggingGroup()

        local barConfigs = self:CreateActionBarConfigs()
        for bName, bConf in pairs(barConfigs) do
            configArgs[bName] = bConf
        end


        return configArgs
    end,
    ---@param self Config
    ['CreateGeneralGroup'] = function(self)
        return {
            type = "group",
            name = "General",
            desc = "General Settings",
            order = mainSeq:next(),
            args = {
                desc = { name = GeneralConfigHeader, type = "header", order = 0 },
                -- TODO: Remove lock_actionbars; Addon now uses WOW's ActionBars / Pick Up Action Key Settings
                lock_actionbars = {
                    hidden = true,
                    type = 'toggle',
                    order = mainSeq:next(),
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
                    order = mainSeq:next(),
                    name = ABP_GENERAL_CONFIG_CHARACTER_SPECIFIC_FRAME_POSITIONS_NAME,
                    desc = ABP_GENERAL_CONFIG_CHARACTER_SPECIFIC_FRAME_POSITIONS_DESC,
                    get = PGet(self, PC.character_specific_anchors, false),
                    set = PSet(self, PC.character_specific_anchors, false)
                },
                hide_when_taxi = {
                    width = 'normal',
                    type = 'toggle',
                    order = mainSeq:next(),
                    name = ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_NAME,
                    desc = ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_DESC,
                    get = PGet(self, PC.hide_when_taxi, false),
                    set = PSet(self, PC.hide_when_taxi, false),
                    set = PSetWithEvent(self, PC.hide_when_taxi, false, E.OnHideWhenTaxiChanged)
                },
                action_button_mouseover_glow = {
                    width = 'normal',
                    type = 'toggle',
                    order = mainSeq:next(),
                    name = ABP_GENERAL_CONFIG_ENABLE_ACTION_BUTTON_GLOW_NAME,
                    desc = ABP_GENERAL_CONFIG_ENABLE_ACTION_BUTTON_GLOW_DESC,
                    get = PGet(self, PC.action_button_mouseover_glow, false),
                    set = PSetWithEvent(self, PC.action_button_mouseover_glow, false, E.OnMouseOverGlowSettingsChanged)
                },
                hide_text_on_small_buttons = {
                    width = 'full',
                    type = 'toggle',
                    order = mainSeq:next(),
                    name = ABP_GENERAL_CONFIG_HIDE_TEXTS_FOR_SMALLER_BUTTONS_NAME,
                    desc = ABP_GENERAL_CONFIG_HIDE_TEXTS_FOR_SMALLER_BUTTONS_DESC,
                    get = PGet(self, PC.hide_text_on_small_buttons, false),
                    set = PSetWithEvent(self, PC.hide_text_on_small_buttons, false, E.OnTextSettingsChanged),
                },
                hide_countdown_numbers = {
                    width = 'full',
                    type = 'toggle',
                    order = mainSeq:next(),
                    name = ABP_GENERAL_CONFIG_HIDE_COUNTDOWN_NUMBERS_ON_COOLDOWNS_NAME,
                    desc = ABP_GENERAL_CONFIG_HIDE_COUNTDOWN_NUMBERS_ON_COOLDOWNS_DESC,
                    get = PGet(self, PC.hide_countdown_numbers, false),
                    set = PSetWithEvent(self, PC.hide_countdown_numbers, false, E.OnCooldownTextSettingsChanged),
                },
                tooltip_header = { order = mainSeq:next(), type = "header", name = GeneralTooltipOptionsHeader },
                tooltip_visibility_key = {
                    width = 'normal',
                    type = 'select', style = 'dropdown',
                    order = mainSeq:next(),
                    values = TTK.kvPairs, sorting = TTK.sorting,
                    name = ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_KEY_NAME,
                    desc = ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_KEY_DESC,
                    get = PGet(self, PC.tooltip_visibility_key, TTK.names.SHOW),
                    set = PSet(self, PC.tooltip_visibility_key, TTK.names.SHOW)
                },
                tooltip_visibility_combat_override_key = {
                    width = 'normal',
                    type = 'select', style = 'dropdown',
                    order = mainSeq:next(),
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
    ['CreateDebuggingGroup'] = function(self)
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
    ['CreateActionBarConfigs'] = function(self)
        local count = P:GetBarSize()
        local bars = {}
        for i=1,count do
            -- barN is the config path name used for OptionDialog#OpenConfig()
            local key = 'bar' .. i
            bars[key] = self:CreateBarConfigDef(i)
        end
        return bars
    end,
    ---@param self Config
    ---@param frameIndex number
    ['CreateBarConfigDef'] = function(self, frameIndex)
        local configName = format('Action Bar #%s', tostring(frameIndex))
        return {
            type = 'group',
            name = configName,
            desc = format("%s Settings", configName),
            order = mainSeq:next(),
            args = {
                desc = { name = format("%s Settings", configName),
                         type = "header", order = barSeq:next(), },
                enabled = {
                    width = "full",
                    type = "toggle",
                    name = "Enable",
                    desc = format("Enable %s", configName),
                    order = barSeq:next(),
                    get = GetFrameStateGetterHandler(frameIndex),
                    set = GetFrameStateSetterHandler(frameIndex)
                },
                show_empty_buttons = {
                    width = "normal",
                    type = "toggle",
                    name = "Show empty buttons",
                    desc = "Check this option to always show the buttons on the action bar, even when they are empty.",
                    order = barSeq:next(),
                    get = PGetWidget(frameIndex, WC.show_empty_buttons, false),
                    set = PSetSpecificWidget(frameIndex, WC.show_empty_buttons, false, E.OnActionbarShowEmptyButtonsUpdated),
                },
                showIndex = {
                    width = "normal",
                    type = "toggle",
                    name = "Show Button Numbers",
                    desc = format("Show each button index on %s", configName),
                    order = barSeq:next(),
                    get = GetShowButtonIndexStateGetterHandler(frameIndex),
                    set = GetShowButtonIndexStateSetterHandler(frameIndex)
                },
                showKeybindText = {
                    width = "normal",
                    type = "toggle",
                    name = "Show Keybind Text",
                    desc = format("Show each button keybind text on %s", configName),
                    order = barSeq:next(),
                    get = GetShowKeybindTextStateGetterHandler(frameIndex),
                    set = GetShowKeybindTextStateSetterHandler(frameIndex)
                },
                spacer1 = { type="description", name = sp, width="full", order = barSeq:next() },
                alpha = {
                    width = "normal",
                    type = 'range',
                    order = barSeq:next(),
                    isPercent = true,
                    step = 0.01,
                    min = 0,
                    max = 1,
                    name = 'Alpha',
                    desc = 'Set the opacity of the actionbar',
                    get = PGetWidget(frameIndex, WC.buttonAlpha, 1.0),
                    set = PSetSpecificWidget(frameIndex, WC.buttonAlpha, 1.0, E.OnActionbarFrameAlphaUpdated),
                },
                button_width = {
                    width = "normal",
                    type = 'range',
                    order = barSeq:next(),
                    step = 1,
                    min = 20,
                    max = 100,
                    name = 'Size (Width & Height)',
                    desc = 'The width and height of a buttons',
                    get = PGetWidget(frameIndex, WC.buttonSize, 36),
                    set = PSetWidget(frameIndex, WC.buttonSize, 36, E.OnButtonSizeChanged),
                },
                rows = {
                    width = "normal",
                    type = 'range',
                    order = barSeq:next(),
                    step = 1,
                    min = 1,
                    max = 20,
                    name = 'Rows',
                    desc = 'The number of rows for the buttons',
                    --confirm = ConfirmAndReload,
                    get = GetRowSizeGetterHandler(frameIndex),
                    set = GetRowSizeSetterHandler(frameIndex)
                },
                cols = {
                    width = "normal",
                    type = 'range',
                    order = barSeq:next(),
                    step = 1,
                    min = 1,
                    max = 40,
                    name = 'Columns',
                    desc = 'The number of columns for the buttons',
                    --confirm = ConfirmAndReload,
                    get = GetColSizeGetterHandler(frameIndex),
                    set = GetColSizeSetterHandler(frameIndex)
                },
                spacer2 = { type="description", name=sp, width="full", order = barSeq:next() },
                lock = {
                    width = "normal",
                    type = "select", style = "dropdown",
                    order = barSeq:next(),
                    values = {[''] = "No", ['always']="Always", ['in-combat']="In-Combat"},
                    name = "Lock Actionbar?",
                    desc = format("Lock %s. " .. LOCK_FRAME_DESC, configName),
                    get = GetLockStateGetterHandler(frameIndex),
                    set = GetLockStateSetterHandler(frameIndex)
                },
                spacer3 = { type="description", name=sp, width="full", order = barSeq:next() },
                spacer4 = { type="header", name = "Frame Handle Settings", width="full", order = barSeq:next() },
                frame_handle_mouseover = {
                    width = "normal",
                    type = "toggle",
                    order = barSeq:next(),
                    name = "Mouseover",
                    desc = MOUSEOVER_FRAME_MOVER_DESC,
                    get = PGetWidget(frameIndex, WC.frame_handle_mouseover, false),
                    set = PSetSpecificWidget(frameIndex, WC.frame_handle_mouseover, false, E.OnFrameHandleMouseOverConfigChanged),
                },
                frame_handle_alpha = {
                    width = "normal",
                    type = 'range',
                    order = barSeq:next(),
                    name = 'Alpha',
                    desc = 'Set the opacity of the frame handle.',
                    isPercent = true,
                    step = 0.01,
                    min = 0,
                    max = 1,
                    get = PGetWidget(frameIndex, WC.frame_handle_alpha, 1.0),
                    set = PSetSpecificWidget(frameIndex, WC.frame_handle_alpha, 1.0, E.OnFrameHandleAlphaConfigChanged),
                },
                reset_anchor = {
                    width = "full",
                    type = 'execute',
                    order = barSeq:reset(),
                    name = ABP_BAR_CONFIG_RESET_ANCHOR_BUTTON_LABEL,
                    desc = ABP_BAR_CONFIG_RESET_ANCHOR_BUTTON_DESC,
                    func = OnResetAnchor(frameIndex),
                    --get = PGetWidget(frameIndex, WC.frame_handle_alpha, 1.0),
                    --set = PSetSpecificWidget(frameIndex, WC.frame_handle_alpha, 1.0, E.OnFrameHandleAlphaConfigChanged),
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
