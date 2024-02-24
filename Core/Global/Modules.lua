--[[-----------------------------------------------------------------------------
Modules
-------------------------------------------------------------------------------]]
local addon, ns = ...

--- @class Modules
local L = {
    mt = {
        __tostring = function() return 'Modules' end
    }
}
setmetatable(L, L.mt)

--- @class Module
local M = {
    LibStub = 'LibStub',

    -- Libraries
    ActionbarPlusAPI = 'ActionbarPlusAPI',
    BaseAPI = 'BaseAPI',
    API = 'API',
    Logger = 'Logger',
    LogFactory = 'LogFactory',
    PrettyPrint = 'PrettyPrint',
    Table = 'Table',
    String = 'String',
    Safecall = 'Safecall',
    LuaEvaluator = 'LuaEvaluator',
    ActionbarPlusEventMixin = 'ActionbarPlusEventMixin',
    ActionBarController = 'ActionBarController',
    ActionType = 'ActionType',
    Assert = 'Assert',
    --- @deprecated Use AceLibrary
    AceLibFactory = 'AceLibFactory',
    AceLibrary = 'AceLibrary',
    APIHooks = 'APIHooks',

    -- Mixins
    Mixin = 'Mixin',
    ActionBarHandlerMixin = 'ActionBarHandlerMixin',
    ButtonMixin = 'ButtonMixin',
    ButtonProfileMixin = 'ButtonProfileMixin',
    CursorMixin = 'CursorMixin',
    DebuggingConfigGroup = 'DebuggingConfigGroup',
    LoggerMixinV2 = 'LoggerMixinV2',

    UnitMixin = 'UnitMixin',
    DruidUnitMixin = 'DruidUnitMixin',
    PriestUnitMixin = 'PriestUnitMixin',
    ShamanUnitMixin = 'ShamanUnitMixin',

    -- Addons
    BaseAttributeSetter = 'BaseAttributeSetter',
    BattlePetDragEventHandler = 'BattlePetDragEventHandler',
    BattlePetAttributeSetter = 'BattlePetAttributeSetter',
    ButtonFactory = 'ButtonFactory',
    ButtonFrameFactory = 'ButtonFrameFactory',
    ButtonUI = 'ButtonUI',
    ButtonUIWidgetBuilder = 'ButtonUIWidgetBuilder',
    CompanionDragEventHandler = 'CompanionDragEventHandler',
    CompanionAttributeSetter = 'CompanionAttributeSetter',
    Config = 'Config',
    ConfigEventHandlerMixin = 'ConfigEventHandlerMixin',
    EquipmentSetDragEventHandler = 'EquipmentSetDragEventHandler',
    EquipmentSetAttributeSetter = 'EquipmentSetAttributeSetter',
    FrameHandleMixin = 'FrameHandleMixin',
    GlobalConstants = 'GlobalConstants',
    ItemAttributeSetter = 'ItemAttributeSetter',
    ItemDragEventHandler = 'ItemDragEventHandler',
    LocalizationUtil = 'LocalizationUtil',
    MacroAttributeSetter = 'MacroAttributeSetter',
    MacroDragEventHandler = 'MacroDragEventHandler',
    MacroEventsHandler = 'MacroEventsHandler',
    MacrotextAttributeSetter = 'MacrotextAttributeSetter',
    Modules = 'Modules',
    MountDragEventHandler = 'MountDragEventHandler',
    MountAttributeSetter = 'MountAttributeSetter',
    PickupHandler = 'PickupHandler',
    Profile = 'Profile',
    ProfileInitializer = 'ProfileInitializer',
    ReceiveDragEventHandler = 'ReceiveDragEventHandler',
    SpellAttributeSetter = 'SpellAttributeSetter',
    SpellDragEventHandler = 'SpellDragEventHandler',
    WidgetMixin = 'WidgetMixin',
    -- Support Classes
    M6Support = 'M6Support'
}

--- @class GlobalObjects
local GlobalObjectsTemplate = {
    --- @type LocalLibStub
    LibStub = {},

    --- @type ActionbarPlusAPI
    ActionbarPlusAPI = {},
    --- @type BaseAPI
    BaseAPI = {},
    --- @type API
    API = {},
    --- @deprecated Use #AceLibrary : Kapresoft_LibUtil_AceLibrary
    --- @type AceLibFactory
    AceLibFactory = {},
    --- @type Kapresoft_LibUtil_AceLibraryObjects
    AceLibrary = {},
    --- @type ActionBarHandlerMixin
    ActionBarHandlerMixin = {},
    --- @type ActionbarPlusEventMixin
    ActionbarPlusEventMixin = {},
    --- @type ActionType
    ActionType = {},
    --- @type Kapresoft_LibUtil_Assert
    Assert = {},
    --- @type BaseAttributeSetter
    BaseAttributeSetter = {},
    --- @type ButtonFactory
    ButtonFactory = {},
    --- @type ButtonFrameFactory
    ButtonFrameFactory = {},
    --- @type ButtonMixin
    ButtonMixin = {},
    --- @type ButtonProfileMixin
    ButtonProfileMixin = {},
    --- @type ButtonUI
    ButtonUI = {},
    --- @type ButtonUIWidgetBuilder
    ButtonUIWidgetBuilder = {},
    --- @type Config
    Config = {},
    --- @type ConfigEventHandlerMixin
    ConfigEventHandlerMixin = {},
    --- @type DebuggingConfigGroup
    DebuggingConfigGroup = {},
    --- @type DruidUnitMixin
    DruidUnitMixin = { },
    --- @type EquipmentSetDragEventHandler
    EquipmentSetDragEventHandler = {},
    --- @type EquipmentSetAttributeSetter
    EquipmentSetAttributeSetter = {},
    --- @type FrameHandleMixin
    FrameHandleMixin = {},
    --- @type GlobalConstants
    GlobalConstants = {},
    --- @type ItemAttributeSetter
    ItemAttributeSetter = {},
    --- @type ItemDragEventHandler
    ItemDragEventHandler = {},
    --- @type LocalizationUtil
    LocalizationUtil = {},
    --- @type LogFactory
    LogFactory = {},
    --- @type Logger
    Logger = {},
    --- @type LoggerMixinV2
    LoggerMixinV2 = {},
    --- @type Kapresoft_LibUtil_LuaEvaluator,
    LuaEvaluator = {},
    --- @type MacroAttributeSetter
    MacroAttributeSetter = {},
    --- @type MacroDragEventHandler
    MacroDragEventHandler = {},
    --- @type MacroEventsHandler
    MacroEventsHandler = {},
    --- @type MacrotextAttributeSetter
    MacrotextAttributeSetter = {},
    --- @type Modules
    Modules = {},
    --- @type MountDragEventHandler
    MountDragEventHandler = {},
    --- @type BattlePetDragEventHandler
    BattlePetDragEventHandler = {},
    --- @type BattlePetAttributeSetter
    BattlePetAttributeSetter = {},
    --- @type CompanionDragEventHandler
    CompanionDragEventHandler = {},
    --- @type CompanionAttributeSetter
    CompanionAttributeSetter = {},
    --- @type MountAttributeSetter
    MountAttributeSetter = {},
    --- @type Kapresoft_LibUtil_Mixin
    Mixin = {},
    --- @type PickupHandler
    PickupHandler = {},
    --- @type PriestUnitMixin
    PriestUnitMixin = {},
    --- @type Profile
    Profile = {},
    --- @type ProfileInitializer
    ProfileInitializer = {},
    --- @type ReceiveDragEventHandler
    ReceiveDragEventHandler = {},
    --- @type Kapresoft_LibUtil_Safecall
    Safecall = {},
    --- @type SpellAttributeSetter
    SpellAttributeSetter = {},
    --- @type SpellDragEventHandler
    SpellDragEventHandler = {},
    --- @type Kapresoft_LibUtil_String
    String = {},
    --- @type Kapresoft_LibUtil_Table
    Table = {},
    --- @type WidgetMixin
    WidgetMixin = {},
    --- @type ShamanUnitMixin
    ShamanUnitMixin = {},
    --- @type UnitMixin
    UnitMixin = {},
}
L.M = M
ns.M = M

ns.O = ns.O or {}
ns.O.Modules = L
