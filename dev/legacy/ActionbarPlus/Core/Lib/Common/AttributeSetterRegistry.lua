-- todo next: Move Attribute setters to AttributeSetterRegistry #503

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return AttributeSetterRegistry, Kapresoft_CategoryLogger
local function CreateLib()
    local libName = M.AttributeSetterRegistry
    --- @class AttributeSetterRegistry : BaseLibraryObject
    local newLib = ns:NewLib(libName); if not newLib then return nil end
    local logger = ns:CreateDefaultLogger(libName)
    return newLib, logger
end; local L, p = CreateLib(); if not L then return end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o AttributeSetterRegistry
local function PropsAndMethods(o)

    --- @type table<string, any>
    local registry = {}

    --- @generic T : BaseAttributeSetter
    --- @param name Name
    --- @param obj T
    --- @return T
    function o:Register(name, obj)
        assert(type(name) == 'string' and type(obj) == 'table', 'Invalid name or object.')
        assert(not registry[name], "AttributeSetter already registered: " .. name)
        -- p:vv(function() return 'Registered: name=%s (%s)', name, tostring(obj) end)
        registry[name] = obj
        return obj
    end

    --- @param name Name
    --- @return BaseAttributeSetter
    function o:Get(name) return registry[name] end

    --- @return table<string, BaseAttributeSetter>
    function o:GetAttributeSetters() return registry end

end; PropsAndMethods(L)

