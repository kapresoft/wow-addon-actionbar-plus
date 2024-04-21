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
    EquipmentSetAttributeSetter = '',
    EquipmentSetController = '',
    EquipmentSetDragEventHandler = '',
    EquipmentSetButtonMixin = '',
    FrameHandleBuilderMixin = '',
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
    ProfessionController = '',
    Profile = '',
    ProfileInitializer = '',
    ReceiveDragEventHandler = '',
    Settings = '',
    SettingsEventHandlerMixin = '',
    SpellAttributeSetter = '',
    SpellDragEventHandler = '',
    WidgetMixin = '',

    -- M6 AddOn Support
    M6Support = ''
}; for moduleName in pairs(M) do M[moduleName] = moduleName end

--- @class GlobalObjects
--- @field M6Support M6Support
--- @field AceLibraryMixin AceLibraryMixin
--- @field ActionBarHandlerMixin ActionBarHandlerMixin
--- @field ActionBarOperations ActionBarOperations
--- @field ActionbarPlusAPI ActionbarPlusAPI
--- @field ActionType ActionType
--- @field API API
--- @field BagController BagController
--- @field BaseAPI BaseAPI
--- @field ModuleV2Mixin ModuleV2Mixin
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
--- @field EquipmentSetAttributeSetter EquipmentSetAttributeSetter
--- @field EquipmentSetController EquipmentSetController
--- @field EquipmentSetDragEventHandler EquipmentSetDragEventHandler
--- @field EquipmentSetButtonMixin EquipmentSetButtonMixin
--- @field FrameHandleBuilderMixin FrameHandleBuilderMixin
--- @field ItemAttributeSetter ItemAttributeSetter
--- @field ItemDragEventHandler ItemDragEventHandler
--- @field LocalizationUtil LocalizationUtil
--- @field LogFactory LogFactory
--- @field Logger Logger
--- @field MacroAttributeSetter MacroAttributeSetter
--- @field MacroDragEventHandler MacroDragEventHandler
--- @field MacroEventsHandler MacroEventsHandler
--- @field MacrotextAttributeSetter MacrotextAttributeSetter
--- @field Modules Modules
--- @field MountAttributeSetter MountAttributeSetter
--- @field MountDragEventHandler MountDragEventHandler
--- @field PickupHandler PickupHandler
--- @field PriestUnitMixin PriestUnitMixin
--- @field ProfessionController ProfessionController
--- @field Profile Profile
--- @field ProfileInitializer ProfileInitializer
--- @field ReceiveDragEventHandler ReceiveDragEventHandler
--- @field Settings Settings
--- @field SettingsEventHandlerMixin SettingsEventHandlerMixin
--- @field ShamanUnitMixin ShamanUnitMixin
--- @field SpellAttributeSetter SpellAttributeSetter
--- @field SpellDragEventHandler SpellDragEventHandler
--- @field UnitMixin UnitMixin
--- @field VehicleAndPetBattleEventsStateDriver VehicleAndPetBattleEventsStateDriver
--- @field WidgetMixin WidgetMixin

L.M = M
kns.M = M

kns.O = kns.O or {}
kns.O.Modules = L
