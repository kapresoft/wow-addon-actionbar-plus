--[[-----------------------------------------------------------------------------
Modules
-------------------------------------------------------------------------------]]
--- @type Kapresoft_Base_Namespace
local kns = select(2, ...)

--- @class Modules
local L = {
    mt = {
        __tostring = function() return 'Modules' end
    }
}
setmetatable(L, L.mt)

--- @class Module
local M = {
    LibStub = '',

    -- Libraries
    ActionBarController = '',
    ActionbarPlusAPI = '',
    ActionbarPlusEventMixin = '',
    ActionType = '',
    API = '',
    Assert = '',
    BaseAPI = '',
    LogFactory = '',
    Logger = '',
    LuaEvaluator = '',
    PrettyPrint = '',
    Safecall = '',
    String = '',
    Table = '',

    --- @deprecated Use AceLibrary
    AceLibFactory = '',
    AceLibrary = '',
    APIHooks = '',

    -- Mixins
    Mixin = '',

    ActionBarHandlerMixin = '',
    ButtonMixin = '',
    ButtonProfileMixin = '',
    CursorMixin = '',
    DebuggingSettingsGroup = '',
    DruidUnitMixin = '',
    LoggerMixinV2 = '',
    PriestUnitMixin = '',
    ShamanUnitMixin = '',
    UnitMixin = '',

    BaseAttributeSetter = '',
    BattlePetAttributeSetter = '',
    BattlePetDragEventHandler = '',
    BagController = '',
    ButtonFactory = '',
    ButtonFrameFactory = '',
    ButtonUI = '',
    ButtonUIWidgetBuilder = '',
    CompanionAttributeSetter = '',
    CompanionDragEventHandler = '',
    ConfigDialogController = '',
    EventToMessageRelayController = '',
    EquipmentSetAttributeSetter = '',
    EquipmentSetController = '',
    EquipmentSetDragEventHandler = '',
    EquipmentSetButtonMixin = '',
    FrameHandleMixin = '',
    GlobalConstants = '',
    ItemAttributeSetter = '',
    ItemDragEventHandler = '',
    LocalizationUtil = '',
    MacroAttributeSetter = '',
    MacroDragEventHandler = '',
    MacroEventsHandler = '',
    MacrotextAttributeSetter = '',
    Modules = '',
    MountAttributeSetter = '',
    MountDragEventHandler = '',
    PickupHandler = '',
    Profile = '',
    ProfileInitializer = '',
    ReceiveDragEventHandler = '',
    Settings = '',
    SettingsEventHandlerMixin = '',
    SpellAttributeSetter = '',
    SpellDragEventHandler = '',
    WidgetMixin = '',
    -- Support Classes
    M6Support = ''
}; for moduleName in pairs(M) do M[moduleName] = moduleName end

--- @class GlobalObjects
--- @field AceLibFactory AceLibFactory Deprecated, Use #AceLibrary : Kapresoft_LibUtil_AceLibrary
--- @field AceLibrary Kapresoft_LibUtil_AceLibraryObjects
--- @field ActionBarHandlerMixin ActionBarHandlerMixin
--- @field ActionbarPlusAPI ActionbarPlusAPI
--- @field ActionbarPlusEventMixin ActionbarPlusEventMixin
--- @field ActionType ActionType
--- @field API API
--- @field Assert Kapresoft_LibUtil_Assert
--- @field BagController BagController
--- @field BaseAPI BaseAPI
--- @field BaseAttributeSetter BaseAttributeSetter
--- @field BattlePetAttributeSetter BattlePetAttributeSetter
--- @field BattlePetDragEventHandler BattlePetDragEventHandler
--- @field ButtonFactory ButtonFactory
--- @field ButtonFrameFactory ButtonFrameFactory
--- @field ButtonMixin ButtonMixin
--- @field ButtonProfileMixin ButtonProfileMixin
--- @field ButtonUI ButtonUI
--- @field ButtonUIWidgetBuilder ButtonUIWidgetBuilder
--- @field CompanionAttributeSetter CompanionAttributeSetter
--- @field CompanionDragEventHandler CompanionDragEventHandler
--- @field ConfigDialogController ConfigDialogController
--- @field DebuggingSettingsGroup DebuggingSettingsGroup
--- @field DruidUnitMixin DruidUnitMixin
--- @field EventToMessageRelayController EventToMessageRelayController
--- @field EquipmentSetAttributeSetter EquipmentSetAttributeSetter
--- @field EquipmentSetController EquipmentSetController
--- @field EquipmentSetDragEventHandler EquipmentSetDragEventHandler
--- @field EquipmentSetButtonMixin EquipmentSetButtonMixin
--- @field FrameHandleMixin FrameHandleMixin
--- @field ItemAttributeSetter ItemAttributeSetter
--- @field ItemDragEventHandler ItemDragEventHandler
--- @field LocalizationUtil LocalizationUtil
--- @field LogFactory LogFactory
--- @field Logger Logger
--- @field LoggerMixinV2 LoggerMixinV2
--- @field LuaEvaluator Kapresoft_LibUtil_LuaEvaluator
--- @field MacroAttributeSetter MacroAttributeSetter
--- @field MacroDragEventHandler MacroDragEventHandler
--- @field MacroEventsHandler MacroEventsHandler
--- @field MacrotextAttributeSetter MacrotextAttributeSetter
--- @field Mixin Kapresoft_LibUtil_Mixin
--- @field Modules Modules
--- @field MountAttributeSetter MountAttributeSetter
--- @field MountDragEventHandler MountDragEventHandler
--- @field PickupHandler PickupHandler
--- @field PriestUnitMixin PriestUnitMixin
--- @field Profile Profile
--- @field ProfileInitializer ProfileInitializer
--- @field ReceiveDragEventHandler ReceiveDragEventHandler
--- @field Safecall Kapresoft_LibUtil_Safecall
--- @field Settings Settings
--- @field SettingsEventHandlerMixin SettingsEventHandlerMixin
--- @field ShamanUnitMixin ShamanUnitMixin
--- @field SpellAttributeSetter SpellAttributeSetter
--- @field SpellDragEventHandler SpellDragEventHandler
--- @field String Kapresoft_LibUtil_String
--- @field Table Kapresoft_LibUtil_Table
--- @field UnitMixin UnitMixin
--- @field WidgetMixin WidgetMixin

L.M = M
kns.M = M

kns.O = kns.O or {}
kns.O.Modules = L
