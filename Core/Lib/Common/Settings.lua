--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC = ns.O, ns.GC

local Ace, BaseAPI = ns:AceLibrary(), O.BaseAPI
local E, MSG = GC.E, GC.M
local AceEvent, AceConfig = Ace.AceEvent, Ace.AceConfig
local AceConfigDialog, AceDBOptions = Ace.AceConfigDialog, Ace.AceDBOptions
local debugGroup = O.DebuggingSettingsGroup
local c1 = ns:ColorUtil():NewFormatterFromColor(BLUE_FONT_COLOR)

local libName = 'Settings'
local p = ns:CreateDefaultLogger(ns.M.Settings);

---These are loaded in #fetchLibs()
--- @type Profile
local P
--- @type Profile_Config_Names
local PC
--- @type Profile_Config_Widget_Names
local WC
--- @type TooltipKey
local TTK
--- @type TooltipAnchorTypeKey
local TTAK
--- @type ButtonFactory
local FB
--- @type ActionBarFrameBuilder
local FF
--- @type table<string, string|number>
local L

--- spacer
local sp = '                                                                   '

--- sequence
local mainSeq = ns:CreateSequence()
local barSeq = ns:CreateSequence()

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
local function fo() return O.ActionBarOperations end
local function ConfirmAndReload() return O.WidgetMixin:ConfirmAndReload() end

--- @param frameIndex number
--- @param key string The key value
--- @param fallback any The fallback value
--- @param msgName string | function | nil
local function PSetWidget(frameIndex, key, fallback, msgName)
    return function(_, v)
        assert(type(key) == 'string', 'Widget attribute key should be a string, but was ' .. type(key))
        P:GetBar(frameIndex).widget[key] = v or fallback
        if 'string' == type(msgName) then AceEvent:SendMessage(msgName, libName, frameIndex) end
    end
end

--- @param frameIndex number
--- @param key string The key value
--- @param fallback any The fallback value
local function PGetWidget(frameIndex, key, fallback)
    return function(_)
        assert(type(key) == 'string', 'Widget attribute key should be a string, but was ' .. type(key))
        return P:GetBar(frameIndex).widget[key] or fallback
    end
end

--- @param frameIndex number
local function OnResetAnchor(frameIndex) return function() fo():GetFrameWidgetByIndex(frameIndex):ResetAnchor() end end

local function GetFrameStateSetterHandler(frameIndex)
    return function(_, v) fo():GetFrameWidgetByIndex(frameIndex):SetFrameState(v) end
end
local function GetFrameStateGetterHandler(frameIndex)
    return function(_) return fo():GetFrameWidgetByIndex(frameIndex):IsShownInConfig() end
end
local function GetShowButtonIndexStateGetterHandler(frameIndex)
    return function(_) return fo():GetFrameWidgetByIndex(frameIndex):IsShowIndex() end
end
local function GetShowButtonIndexStateSetterHandler(frameIndex)
    --TODO: NEXT: Use events instead
    return function(_, v) fo():GetFrameWidgetByIndex(frameIndex):ShowButtonIndices(v) end
end
local function GetLockStateSetterHandler(frameIndex)
    return function(_, v)
        P:SetBarLockValue(frameIndex, v)
        fo():GetFrameWidgetByIndex(frameIndex):SetLockedState()
    end
end
local function GetLockStateGetterHandler(frameIndex)
    return function(_) return P:GetBarLockValue(frameIndex) end
end

local function GetRowSizeGetterHandler(frameIndex)
    return function(_) return P:GetBar(frameIndex).widget.rowSize or 2 end
end
local function GetRowSizeSetterHandler(frameIndex)
    return function(_, v)
        P:GetBar(frameIndex).widget.rowSize = v
        AceEvent:SendMessage(MSG.OnButtonCountChanged, libName, frameIndex)
    end
end
local function GetColSizeGetterHandler(frameIndex)
    return function(_) return P:GetBar(frameIndex).widget.colSize or 6 end
end
local function GetColSizeSetterHandler(frameIndex)
    return function(_, v)
        P:GetBar(frameIndex).widget.colSize = v
        AceEvent:SendMessage(MSG.OnButtonCountChanged, libName, frameIndex)
    end
end

--- @param config Settings The config instance
--- @param key string The key value
--- @param fallback any The fallback value
--- @param msg string|nil An optional string message to send
local function PSet(config, key, fallbackVal, msg)
    return function(_, v)
        assert(type(key) == 'string', 'Profile key should be a string')
        config.profile[key] = v or fallbackVal
        if msg then AceEvent:SendMessage(msg, libName, config.profile[key]) end
    end
end

--- @param config Settings The config instance
--- @param fallback any The fallback value
--- @param key string The key value
local function PGet(config, key, fallback)
    return function(_)
        assert(type(key) == 'string', 'Profile key should be a string')
        return config.profile[key] or fallback
    end
end

local function lazyInitLibs()
    P, FB, FF = O.Profile, O.ButtonFactory, O.ActionBarFrameBuilder
    PC        = GC.Profile_Config_Names
    WC = GC.Profile_Config_Widget_Names
    TTK = P:GetTooltipKey()
    TTAK = P:GetTooltipAnchorTypeKey()
    L = GC:GetAceLocale()
end

--- @param optArgs AceConfigOption
local function ConfigureDebugging(optArgs)
    --@do-not-package@
    if ns:IsDev() then
        optArgs.debugging = debugGroup:CreateDebuggingGroup()
        p:a(function()
            return 'Debugging tab in Settings UI is enabled with LogLevel=%s', c1(ABP_LOG_LEVEL)
        end)
        return
    end
    --@end-do-not-package@

    ABP_LOG_LEVEL = 0
end

--[[-----------------------------------------------------------------------------
Properties & Methods
-------------------------------------------------------------------------------]]
--- @param o Settings | AceEventPlus
local function PropsAndMethods(o)

    --- Call Order: Settings -> Profile -> ButtonFactory
    --- Message triggered by ActionbarPlus#OnInitializeModules
    --- @param msg string The message name
    function o:InitConfig(msg)
        lazyInitLibs()
        assert(ns.db.profile, "Profile is not initialized.")
        self.profile = ns.db.profile
        self.e = O.SettingsEventHandlerMixin:New()
        self:Initialize()
        self:SendMessage(GC.M.OnConfigInitialized, ns.M.Settings)
    end

    --- Sets up Ace config dialog
    function o:Initialize()
        local db = ns.db
        local options = self:GetOptions()
        -- Get the option table for profiles
        -- options.args.profiles = AceDBOptions:GetOptionsTable(self.db)
        AceConfig:RegisterOptionsTable(ns.name, options, { GC.C.CONSOLE_COMMAND_OPTIONS })
        AceConfigDialog:AddToBlizOptions(ns.name, ns.name)
        options.args.profiles = AceDBOptions:GetOptionsTable(db)
    end

    function o:GetOptions()
        return {
            name = GC.C.ADDON_NAME, handler = self.addon, type = "group",
            args = self:CreateConfig(),
        }
    end
    function o:CreateConfig()
        local configArgs = {}

        configArgs.general = self:CreateGeneralGroup()
        local hiddenGeneralConfigs = {
            'equipmentset_header',
            PC.equipmentset_open_character_frame,
            PC.equipmentset_open_equipment_manager,
            PC.equipmentset_show_glow_when_active,
        }
        if BaseAPI:IsClassicEra() then
            local gen = configArgs['general'].args
            for _, v in ipairs(hiddenGeneralConfigs) do gen[v] = nil end
        end; ConfigureDebugging(configArgs)

        local barConfigs = self:CreateActionBarConfigs()
        for bName, bConf in pairs(barConfigs) do
            configArgs[bName] = bConf
        end

        return configArgs
    end

    function o:CreateGeneralGroup()
        local GeneralConfigHeader = ' ' .. L['General Configuration'] .. ' '
        local GeneralTooltipOptionsHeader = ' ' .. L['Tooltip Options'] .. ' '

        return {
            type = "group",
            name = L['General'],
            desc = GeneralConfigHeader,
            order = mainSeq:next(),
            args = {
                desc = { name = GeneralConfigHeader, type = "header", order = 0 },
                character_specific_anchors = {
                    type = 'toggle',
                    width = 'full',
                    confirm = ConfirmAndReload,
                    order = mainSeq:next(),
                    name = L['Character Specific Frame Positions'],
                    desc = L['Character Specific Frame Positions::Description'],
                    get = PGet(self, PC.character_specific_anchors, false),
                    set = PSet(self, PC.character_specific_anchors, false)
                },
                hide_when_taxi = {
                    width = 'normal',
                    type = 'toggle',
                    order = mainSeq:next(),
                    name = L['Hide during taxi'],
                    desc = L['Hide during taxi::Description'],
                    get = PGet(self, PC.hide_when_taxi, false),
                    set = PSet(self, PC.hide_when_taxi, false, MSG.OnHideWhenTaxiSettingsChanged)
                },
                action_button_mouseover_glow = {
                    width = 'normal',
                    type = 'toggle',
                    order = mainSeq:next(),
                    name = L['Mouseover Glow'],
                    desc = L['Mouseover Glow::Description'],
                    get = PGet(self, PC.action_button_mouseover_glow, false),
                    set = PSet(self, PC.action_button_mouseover_glow, false, MSG.OnMouseOverGlowSettingsChanged)
                },
                hide_text_on_small_buttons = {
                    width = 'full',
                    type = 'toggle',
                    order = mainSeq:next(),
                    name = L['Hide text for smaller buttons'],
                    desc = L['Hide text for smaller buttons::Description'],
                    get = PGet(self, PC.hide_text_on_small_buttons, false),
                    set = PSet(self, PC.hide_text_on_small_buttons, false, MSG.OnTextSettingsChanged),
                },
                hide_countdown_numbers = {
                    width = 'full',
                    type = 'toggle',
                    order = mainSeq:next(),
                    name = L['Hide countdown numbers on cooldowns'],
                    desc = L['Hide countdown numbers on cooldowns::Description'],
                    get = PGet(self, PC.hide_countdown_numbers, false),
                    set = PSet(self, PC.hide_countdown_numbers, false, MSG.OnCooldownTextSettingsChanged),
                },

                equipmentset_header = { order = mainSeq:next(), type = "header", name = "Equipment Set Options" },
                equipmentset_open_character_frame = {
                    order = mainSeq:next(),
                    width = 'normal',
                    type = 'toggle',
                    name = 'Open Character Frame',
                    -- todo next: localize strings
                    desc = 'When the player clicks an equipment set button, the character frame should automatically open. This will provide the user with quick access to their character\'s equipped gear, without requiring them to manually open the frame.',
                    get = self.e:PC(PC.equipmentset_open_character_frame, false),
                    set = self.e:PCSet(PC.equipmentset_open_character_frame),
                },
                equipmentset_open_equipment_manager = {
                    order = mainSeq:next(),
                    width = 1.2,
                    type = 'toggle',
                    name = "Open Equipment Manager",
                    desc = 'When the player clicks an equipment set button, the character frame should automatically open, as well as the Equipment Manager. This will allow users to quickly and easily manage their equipment while also viewing their character\'s information. This setting only applies if "Open Character Frame" is enabled.',
                    get = PGet(self, PC.equipmentset_open_equipment_manager, false),
                    set = self:CM(PC.equipmentset_open_equipment_manager, false),
                },
                equipmentset_show_glow_when_active = {
                    order = mainSeq:next(),
                    width = 'normal',
                    type = 'toggle',
                    name = "Glow After Equip",
                    desc = 'When the player equips a set, the button should light up or glow to provide clear visual feedback and confirm that the equipment set has been successfully equipped.',
                    get = PGet(self, PC.equipmentset_show_glow_when_active, false),
                    set = self:CM(PC.equipmentset_show_glow_when_active, false),
                },
                tooltip_header = { order = mainSeq:next(), type = "header", name = GeneralTooltipOptionsHeader },
                tooltip_visibility_key = {
                    width = 'normal',
                    type = 'select', style = 'dropdown',
                    order = mainSeq:next(),
                    values = TTK.kvPairs, sorting = TTK.sorting,
                    name = L['Tooltip Visibility'],
                    desc = L['Tooltip Visibility::Description'],
                    get = PGet(self, PC.tooltip_visibility_key),
                    set = PSet(self, PC.tooltip_visibility_key)
                },
                tooltip_visibility_combat_override_key = {
                    width = 'normal',
                    type = 'select', style = 'dropdown',
                    order = mainSeq:next(),
                    values = TTK.kvPairs, sorting = TTK.sorting,
                    name = L['Combat Override Key'],
                    desc = L['Combat Override Key::Description'],
                    get = PGet(self, PC.tooltip_visibility_combat_override_key),
                    set = PSet(self, PC.tooltip_visibility_combat_override_key)
                },
                tooltip_anchor_type = {
                    width = 'normal',
                    type = 'select', style = 'dropdown',
                    order = mainSeq:next(),
                    values = TTAK.kvPairs, sorting = TTAK.sorting,
                    name = L['Tooltip Anchor'],
                    desc = L['Tooltip Anchor::Description'],
                    get = PGet(self, PC.tooltip_anchor_type),
                    set = self:CM(PC.tooltip_anchor_type, GC.TooltipAnchor.CURSOR_TOPLEFT, GC.M.OnTooltipFrameUpdate),
                }
            }
        }
    end

    function o:CreateActionBarConfigs()
        local count = P:GetBarSize()
        local bars = {}
        for i=1,count do
            -- barN is the config path name used for OptionDialog#OpenConfig()
            local key = 'bar' .. i
            bars[key] = self:CreateBarConfigDef(i)
        end
        return bars
    end

    --- @param frameIndex number
    function o:CreateBarConfigDef(frameIndex)
        local configName = format('%s #%s', ABP_ACTIONBAR_BASE_NAME, tostring(frameIndex))
        return {
            type = 'group',
            name = configName,
            desc = format("%s %s", configName, L['Settings']),
            order = mainSeq:next(),
            args = {
                desc = { name = format("%s ", configName, L['Settings']),
                         type = "header", order = barSeq:next(), },
                enabled = {
                    width = "full",
                    type = "toggle",
                    name = L['Enable'],
                    desc = format("%s %s", ABP_ACTIONBAR_BASE_NAME, configName),
                    order = barSeq:next(),
                    get = GetFrameStateGetterHandler(frameIndex),
                    set = GetFrameStateSetterHandler(frameIndex)
                },
                show_empty_buttons = {
                    width = "normal",
                    type = "toggle",
                    name = L['Show empty buttons'],
                    desc = L['Show empty buttons::Description'],
                    order = barSeq:next(),
                    get = PGetWidget(frameIndex, WC.show_empty_buttons, false),
                    set = PSetWidget(frameIndex, WC.show_empty_buttons, false, MSG.OnShowEmptyButtons),
                },
                showIndex = {
                    width = "normal",
                    type = "toggle",
                    name = L['Show Button Numbers'],
                    desc = format(L['Show Button Numbers::Description'], configName),
                    order = barSeq:next(),
                    get = GetShowButtonIndexStateGetterHandler(frameIndex),
                    set = GetShowButtonIndexStateSetterHandler(frameIndex)
                },
                showKeybindText = {
                    width = "normal",
                    type = "toggle",
                    name = L['Show Keybind Text'],
                    desc = format(L['Show Keybind Text::Description'], configName),
                    order = barSeq:next(),
                    get = self.e:BC(frameIndex, PC.show_keybind_text),
                    set = self.e:BCSet(frameIndex, PC.show_keybind_text, MSG.OnShowKeybindTextSettingsUpdated)
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
                    name = L['Alpha'],
                    desc = L['Alpha::Description'],
                    get = PGetWidget(frameIndex, WC.buttonAlpha, 1.0),
                    set = PSetWidget(frameIndex, WC.buttonAlpha, 1.0, MSG.OnActionbarFrameAlphaUpdated),
                },
                button_width = {
                    width = "normal",
                    type = 'range',
                    order = barSeq:next(),
                    step = 1,
                    min = 20,
                    max = 100,
                    name = L['Size (Width & Height)'],
                    desc = L['Size (Width & Height)::Description'],
                    get = PGetWidget(frameIndex, WC.buttonSize, 36),
                    set = PSetWidget(frameIndex, WC.buttonSize, 36, MSG.OnButtonSizeChanged),
                },
                rows = {
                    width = "normal",
                    type = 'range',
                    order = barSeq:next(),
                    step = 1,
                    min = 1,
                    max = self.maxCols,
                    name = L['Rows'],
                    desc = L['Rows::Description'],
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
                    max = self.maxRows,
                    name = L['Columns'],
                    desc = L['Columns::Description'],
                    --confirm = ConfirmAndReload,
                    get = GetColSizeGetterHandler(frameIndex),
                    set = GetColSizeSetterHandler(frameIndex)
                },
                spacer2 = { type="description", name=sp, width="full", order = barSeq:next() },
                lock = {
                    width = "normal",
                    type = "select", style = "dropdown",
                    order = barSeq:next(),
                    values = { [''] = L['No'],
                               ['always'] = L['Always'],
                               ['in-combat'] = L['In-Combat'] },
                    name = L['Lock Actionbar'],
                    desc = L['Lock Actionbar::Description'],
                    get = GetLockStateGetterHandler(frameIndex),
                    set = GetLockStateSetterHandler(frameIndex)
                },
                spacer3 = { type="description", name=sp, width="full", order = barSeq:next() },
                spacer4 = { type="header", name = L['Frame Handle Settings'], width="full", order = barSeq:next() },
                frame_handle_mouseover = {
                    width = "normal",
                    type = "toggle",
                    order = barSeq:next(),
                    name = L['Mouseover'],
                    desc = L['Mouseover::Description'],
                    get = PGetWidget(frameIndex, WC.frame_handle_mouseover, false),
                    set = PSetWidget(frameIndex, WC.frame_handle_mouseover, false, MSG.OnMouseOverFrameHandleConfigChanged),
                },
                frame_handle_alpha = {
                    width = "normal",
                    type = 'range',
                    order = barSeq:next(),
                    name = L['Mouseover'],
                    desc = L['Mouseover::Description'],
                    isPercent = true,
                    step = 0.01,
                    min = 0,
                    max = 1,
                    get = PGetWidget(frameIndex, WC.frame_handle_alpha, 1.0),
                    set = PSetWidget(frameIndex, WC.frame_handle_alpha, 1.0, MSG.OnFrameHandleAlphaConfigChanged),
                },
                reset_anchor = {
                    width = "normal",
                    type = 'execute',
                    order = barSeq:reset(),
                    name = L['Reset Anchor'],
                    desc = L['Reset Anchor::Description'],
                    func = OnResetAnchor(frameIndex),
                }
            }
        }
    end

    --- TODO NEXT: Migrate event-base to message-base
    --- Creates a callback function that sends a message after
    --- @param key string The profile key to update
    --- @param fallbackVal any The fallback value
    --- @param message string The message to send
    --- @return fun(_, v:any) : void The function parameter "v" is the option value selected by the user
    --- @see SettingsEventHandlerMixin#SetConfigWithMessage
    function o:CM(key, fallbackVal, message) return self.e:SetConfigWithMessage(key, fallbackVal, message) end

end

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- properties "addon" and "profile" is injected OnAfterInitialize()
--- @return Settings
local function NewInstance()

    --- @class Settings A settings class for addon configuration and event handling.
    --- @field addon ActionbarPlus The associated addon instance.
    --- @field profile Profile The user profile for settings and preferences.
    --- @field e SettingsEventHandlerMixin Handles addon events.
    --- @field maxRows Index Maximum number of rows for UI elements.
    --- @field maxCols Index Maximum number of columns for UI elements.
    local newConfig = ns:NewLib(ns.M.Settings)
    newConfig.maxRows = 20
    newConfig.maxCols = 40
    -- With the default of 20 x 40, a frame may have up to 800 buttons
    newConfig.maxButtons = newConfig.maxRows * newConfig.maxCols

    PropsAndMethods(newConfig)
    newConfig:RegisterMessage(MSG.OnAddOnEnabled, function(evt, msg, ...) newConfig:InitConfig(evt, msg, ...) end)
    return newConfig
end; NewInstance()
