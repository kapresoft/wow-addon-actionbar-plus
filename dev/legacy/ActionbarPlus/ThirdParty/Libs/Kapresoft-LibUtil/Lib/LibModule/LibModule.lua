--[[-----------------------------------------------------------------------------
Usage:

--- @type Kapresoft_LibUtil_Modules
local M = {
   --- @type MyObj1
   MyObj1 = {},

   --- @type MyObj2
   MyObj2 = {},
}
-- This will add the @class fields of Kapresoft_LibUtil_Module including default constructor __call implementation.
LibModule.EnrichModules(M)

-- to get the string name of the module, call by:
local libName = MyObj1()
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Type: Kapresoft_LibUtil_Module
-------------------------------------------------------------------------------]]
--- @class Kapresoft_LibUtil_Module
--- @field _name string The module name
--- @field _libName string The module library name
--- @field GetName fun(self:Kapresoft_LibUtil_Module) : Name

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type LibStub
local LibStub = LibStub

--- @type Kapresoft_Base_Namespace
local ns = select(2, ...)
local K = ns.Kapresoft_LibUtil

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local MAJOR_VERSION = 'Kapresoft-LibModule-1.0'
--- @class Kapresoft_LibModule
local L = LibStub:NewLibrary(MAJOR_VERSION, 1); if not L then return end
L.mt = { __tostring = function() return MAJOR_VERSION .. '.' .. LibStub.minors[MAJOR_VERSION]  end }
setmetatable(L, L.mt)

--[[-----------------------------------------------------------------------------
Methods
------------------------------------------------------------------------------]]
--- @param o Kapresoft_LibModule
local function PropsAndMethods(o)

    --- @param moduleName Name
    function o:Init(moduleName)
        local t = type(moduleName)
        assert(t == 'string', 'Expecting moduleName to be type string but was ' .. t)

        self._name = moduleName
        self.mt = {
            --- @param m Kapresoft_LibUtil_Module
            __tostring = function(m) return 'Module: ' .. m._name end,
            --- @param m Kapresoft_LibUtil_Module
            __call = function(m, ...) return m._name end
        }
        self.Init = nil
        self.New = nil
        setmetatable(self, self.mt)
    end

    --- @param moduleName Name The module name
    --- @return Kapresoft_LibUtil_Module
    function o:New(moduleName) return K:CreateAndInitFromMixin(o, moduleName) end

    --- @return Name
    function o:GetName() return self._name end

    --- @param modules Kapresoft_LibUtil_Modules
    function o.EnrichModules(modules)
        local t = type(modules)
        assert(t == 'table', 'Expecting modules to be type table but was ' .. t)
        --- @param name Name
        for name in pairs(modules) do modules[name] = o:New(name) end
    end

end; PropsAndMethods(L)







