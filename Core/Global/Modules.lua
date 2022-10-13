--[[-----------------------------------------------------------------------------
Modules
-------------------------------------------------------------------------------]]
---@class Modules
local L = {
    mt = {
        __tostring = function() return 'Modules' end
    }
}
setmetatable(L, L.mt)

---@class Module
local M = {
    Core = 'Core',
    LibStub = 'LibStub',

    -- Libraries
    BaseAPI = 'BaseAPI',
    API = 'API',
    Logger = 'Logger',
    LogFactory = 'LogFactory',
    PrettyPrint = 'PrettyPrint',
    Table = 'Table',
    String = 'String',
    LuaEvaluator = 'LuaEvaluator',
    ActionbarPlusEventMixin = 'ActionbarPlusEventMixin',
    ActionType = 'ActionType',
    Assert = 'Assert',
    AceLibFactory = 'AceLibFactory',
    -- Mixins
    Mixin = 'Mixin',
    ButtonMixin = 'ButtonMixin',
    ButtonProfileMixin = 'ButtonProfileMixin',
    CursorMixin = 'CursorMixin',
    -- Addons
    BaseAttributeSetter = 'BaseAttributeSetter',
    BattlePetDragEventHandler = 'BattlePetDragEventHandler',
    BattlePetAttributeSetter = 'BattlePetAttributeSetter',
    ButtonData = 'ButtonData',
    ButtonFactory = 'ButtonFactory',
    ButtonFrameFactory = 'ButtonFrameFactory',
    ButtonUI = 'ButtonUI',
    ButtonUIWidgetBuilder = 'ButtonUIWidgetBuilder',
    CompanionDragEventHandler = 'CompanionDragEventHandler',
    CompanionAttributeSetter = 'CompanionAttributeSetter',
    Config = 'Config',
    FrameHandleMixin = 'FrameHandleMixin',
    GlobalConstants = 'GlobalConstants',
    Incrementer = 'Incrementer',
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
    PopupDebugDialog = 'PopupDebugDialog',
    Profile = 'Profile',
    ProfileInitializer = 'ProfileInitializer',
    ReceiveDragEventHandler = 'ReceiveDragEventHandler',
    SpellAttributeSetter = 'SpellAttributeSetter',
    SpellDragEventHandler = 'SpellDragEventHandler',
    WidgetMixin = 'WidgetMixin',
}

---@class GlobalObjects
local GlobalObjectsTemplate = {
    ---@type Core,
    Core = {},
    ---@type LocalLibStub
    LibStub = {},

    ---@type BaseAPI
    BaseAPI = {},
    ---@type API
    API = {},
    ---@type AceLibFactory
    AceLibFactory = {},
    ---@type ActionbarPlusEventMixin
    ActionbarPlusEventMixin = {},
    ---@type ActionType
    ActionType = {},
    ---@type Kapresoft_LibUtil_Assert
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
    ---@type Config
    Config = {},
    ---@type FrameHandleMixin
    FrameHandleMixin = {},
    ---@type GlobalConstants
    GlobalConstants = {},
    ---@type Kapresoft_LibUtil_Incrementer
    Incrementer = {},
    ---@type ItemAttributeSetter
    ItemAttributeSetter = {},
    ---@type ItemDragEventHandler
    ItemDragEventHandler = {},
    ---@type LogFactory
    LogFactory = {},
    ---@type Logger
    Logger = {},
    ---@type Kapresoft_LibUtil_LuaEvaluator,
    LuaEvaluator = {},
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
    ---@type BattlePetDragEventHandler
    BattlePetDragEventHandler = {},
    ---@type BattlePetAttributeSetter
    BattlePetAttributeSetter = {},
    ---@type CompanionDragEventHandler
    CompanionDragEventHandler = {},
    ---@type CompanionAttributeSetter
    CompanionAttributeSetter = {},
    ---@type MountAttributeSetter
    MountAttributeSetter = {},
    ---@type Kapresoft_LibUtil_Mixin
    Mixin = {},
    ---@type PickupHandler
    PickupHandler = {},
    ---@type PopupDebugDialog
    PopupDebugDialog = {},
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
    ---@type Kapresoft_LibUtil_String
    String = {},
    ---@type Kapresoft_LibUtil_Table
    Table = {},
    ---@type WidgetMixin
    WidgetMixin = {},
}
L.M = M

---@type Modules
ABP_Modules = L
