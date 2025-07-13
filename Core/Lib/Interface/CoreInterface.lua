--[[-----------------------------------------------------------------------------
Alias Functions
-------------------------------------------------------------------------------]]
--- @alias FrameHandlerFunction fun(fw:ActionBarFrameWidget) : void | "function(fw) print(fw:GetName()) end"
--- @alias ButtonPredicateFunction fun(bw:ButtonUIWidget) : boolean | "function(bw) print(bw:GetName()) end"
--- @alias ButtonHandlerFunction fun(bw:ButtonUIWidget) : void | "function(bw) print(bw:GetName()) end"
--- @alias MessageCallbackFn fun(evt:string, source:string, ...:any) | "function(evt, source, ...) print('Called...') end"
--- @alias ActionBarFrameBuilderConsumerFn fun(name:Name, index:Index) | "function(name, index) end"

--[[-----------------------------------------------------------------------------
BaseLibraryObject
-------------------------------------------------------------------------------]]
--- @class BaseLibraryObject A base library object class definition.
--- @field mt table The metatable for objects of this class, including a custom `__tostring` function for debugging or logging purposes.
--- @field name string Retrieves the module's name. This is an instance method that should be implemented to return the name of the module.
--- @field major string Retrieves the major version of the module. i.e., <LibName>-1.0
--- @field minor string Retrieves the minor version of the module. i.e., <LibName>-1.0

--[[-----------------------------------------------------------------------------
BaseLibraryObject_WithAceEvent
-------------------------------------------------------------------------------]]
--- @class BaseLibraryObject_WithAceEvent : AceEvent A base library object that includes AceEvent functionality.
--- @field mt table The metatable for objects of this class, including a custom `__tostring` function for debugging or logging purposes.
--- @field name string Retrieves the module's name. This is an instance method that should be implemented to return the name of the module.
--- @field major string Retrieves the major version of the module. i.e., <LibName>-1.0
--- @field minor string Retrieves the minor version of the module. i.e., <LibName>-1.0

--[[-----------------------------------------------------------------------------
BaseLibraryObject_Initialized
-------------------------------------------------------------------------------]]
--- @class BaseLibraryObject_Initialized : BaseLibraryObject A derived class from BaseLibraryObject that has been initialized.
--- @field addon ActionbarPlus An instance of the ActionbarPlus class associated with this object.
--- @field profile Profile_Config The profile configuration for this object, containing settings and preferences.

--[[-----------------------------------------------------------------------------
BaseLibraryObject_Initialized_WithAceEvent
-------------------------------------------------------------------------------]]
--- @class BaseLibraryObject_Initialized_WithAceEvent : BaseLibraryObject_WithAceEvent A derived class from BaseLibraryObject_WithAceEvent that has been initialized.
--- @field addon ActionbarPlus An instance of the ActionbarPlus class associated with this object, indicating integration with the ActionbarPlus addon.
--- @field profile Profile_Config The profile configuration for this object, tailored for use with AceEvent functionalities.
