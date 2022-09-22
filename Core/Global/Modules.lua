---@class Modules
local L = {
    mt = {
        __tostring = function() return 'Modules' end
    }
}
setmetatable(L, L.mt)

---@class Module
local M = {
    -- Libraries
    BaseAPI = 'BaseAPI',
    API = 'API',
    LibGlobals = 'LibGlobals',
    Logger = 'Logger',
    LogFactory = 'LogFactory',
    PrettyPrint = 'PrettyPrint',
    Table = 'Table',
    String = 'String',
    ActionType = 'ActionType',
    Assert = 'Assert',
    AceLibFactory = 'AceLibFactory',
    -- Constants
    CommonConstants = 'CommonConstants',
    -- Mixins
    Mixin = 'Mixin',
    ButtonMixin = 'ButtonMixin',
    ButtonProfileMixin = 'ButtonProfileMixin',
    -- Addons
    BaseAttributeSetter = 'BaseAttributeSetter',
    ButtonData = 'ButtonData',
    ButtonFactory = 'ButtonFactory',
    ButtonFrameFactory = 'ButtonFrameFactory',
    ButtonUI = 'ButtonUI',
    ButtonUIWidgetBuilder = 'ButtonUIWidgetBuilder',
    Config = 'Config',
    GlobalConstants = 'GlobalConstants',
    ItemAttributeSetter = 'ItemAttributeSetter',
    ItemDragEventHandler = 'ItemDragEventHandler',
    MacroAttributeSetter = 'MacroAttributeSetter',
    MacroDragEventHandler = 'MacroDragEventHandler',
    MacroEventsHandler = 'MacroEventsHandler',
    MacrotextAttributeSetter = 'MacrotextAttributeSetter',
    MacroTextureDialog = 'MacroTextureDialog',
    MountDragEventHandler = 'MountDragEventHandler',
    MountAttributeSetter = 'MountAttributeSetter',
    PickupHandler = 'PickupHandler',
    Profile = 'Profile',
    ProfileInitializer = 'ProfileInitializer',
    ReceiveDragEventHandler = 'ReceiveDragEventHandler',
    SpellAttributeSetter = 'SpellAttributeSetter',
    SpellDragEventHandler = 'SpellDragEventHandler',
    WidgetConstants = 'WidgetConstants',
    WidgetMixin = 'WidgetMixin',
}

---@class GlobalObjects
local GlobalObjectsTemplate = {

    ---@type BaseAPI
    BaseAPI = {},
    ---@type API
    API = {},
    ---@type AceLibFactory
    AceLibFactory = {},
    ---@type ActionType
    ActionType = {},
    ---@type Assert
    Assert = {},
    ---@type BaseAttributeSetter
    BaseAttributeSetter = {},
    ---@type ButtonData
    ButtonData = {},
    ---@type ButtonFactory
    ButtonFactory = {},
    ---@type ButtonFrameFactory
    ButtonFrameFactory = {},
    ---@type ButtonMixin
    ButtonMixin = {},
    ---@type ButtonProfileMixin
    ButtonProfileMixin = {},
    ---@type ButtonUI
    ButtonUI = {},
    ---@type ButtonUIWidgetBuilder
    ButtonUIWidgetBuilder = {},
    ---@type CommonConstants
    CommonConstants = {},
    ---@type Config
    Config = {},
    ---@type GlobalConstants
    GlobalConstants = {},
    ---@type ItemAttributeSetter
    ItemAttributeSetter = {},
    ---@type ItemDragEventHandler
    ItemDragEventHandler = {},
    ---@type LibGlobals
    LibGlobals = {},
    ---@type LogFactory
    LogFactory = {},
    ---@type Logger
    Logger = {},
    ---@type MacroAttributeSetter
    MacroAttributeSetter = {},
    ---@type MacroDragEventHandler
    MacroDragEventHandler = {},
    ---@type MacroEventsHandler
    MacroEventsHandler = {},
    ---@type MacroTextureDialog
    MacroTextureDialog = {},
    ---@type MacrotextAttributeSetter
    MacrotextAttributeSetter = {},
    ---@type Modules
    Modules = {},
    ---@type MountDragEventHandler
    MountDragEventHandler = {},
    ---@type MountAttributeSetter
    MountAttributeSetter = {},
    ---@type Mixin
    Mixin = {},
    ---@type PickupHandler
    PickupHandler = {},
    ---@type Profile
    Profile = {},
    ---@type ProfileInitializer
    ProfileInitializer = {},
    ---@type ReceiveDragEventHandler
    ReceiveDragEventHandler = {},
    ---@type SpellAttributeSetter
    SpellAttributeSetter = {},
    ---@type SpellDragEventHandler
    SpellDragEventHandler = {},
    ---@type String
    String = {},
    ---@type Table
    Table = {},
    ---@type WidgetConstants
    WidgetConstants = {},
    ---@type WidgetMixin
    WidgetMixin = {},
}
L.M = M

---@type Modules
ABP_Modules = L
