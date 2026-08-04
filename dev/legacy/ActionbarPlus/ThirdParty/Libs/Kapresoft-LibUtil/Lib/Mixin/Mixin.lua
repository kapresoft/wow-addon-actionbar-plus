---This is a customized version of Mixin based of Blizzards Mixin.lua
--- @see also Blizzard's Interface/SharedXML/Mixin.lua
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type LibStub
local LibStub = LibStub
local MIXIN_OBJ_REQUIRED_MSG = "Can't mixin to a nil object in Mixin(object, ...)"
local DEFAULT_EXCLUDES       = { '_name', '_major', '_minor', 'mt' }

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local MAJOR_VERSION = 'Kapresoft-Mixin-1.0'
--- @class Kapresoft_Mixin
local L = LibStub:NewLibrary(MAJOR_VERSION, 2); if not L then return end
L.mt = { __tostring = function() return MAJOR_VERSION .. '.' .. LibStub.minors[MAJOR_VERSION]  end }
setmetatable(L, L.mt)

--- ```
--- local newInstance = Mixin({}, Mixin1, Mixin2, MixinN)
--- // or
--- local existingObj = {}
--- local newInstance = Mixin(existingObj, Mixin1, Mixin2, MixinN)
--- ```
--- @see BlizzardInterfaceCode:Interface/SharedXML/Mixin.lua
--- @param object any The target object
--- @vararg any The objects to mixin
function L:Mixin(object, ...)
    for i = 1, select("#", ...) do
        local mixin = select(i, ...)
        for k, v in pairs(mixin) do
            object[k] = v
        end
    end

    return object
end

--- Mixes properties from one or more source objects into a target object while excluding specified properties.
--- @see BlizzardInterfaceCode:Interface/SharedXML/Mixin.lua
--- @param object any The target object
--- @vararg any The objects to mixin
--- @return any The new Mixin instance
function L:MixinWithDefExc(object, ...) return self:MixinWithExc(object, DEFAULT_EXCLUDES, ...) end

--- Mixes properties from one or more source objects into a target object while excluding specified properties.
--- @see BlizzardInterfaceCode:Interface/SharedXML/Mixin.lua
--- @param object any The target object
--- @param excludeList table A table containing property keys to exclude from mixing in
--- @vararg any The objects to mixin
--- @return any The new Mixin instance
function L:MixinWithExc(object, excludeList, ...)
    local exclude = {}
    for _, key in ipairs(excludeList) do exclude[key] = true end
    for i = 1, select("#", ...) do
        local mixin = select(i, ...)
        for k, v in pairs(mixin) do
            if not exclude[k] then object[k] = v end
        end
    end

    return object
end


--- ```
--- local Mixin1 = { 'properties and methods' }
--- local Mixin2 = { 'properties and methods' }
--- local newInstance = CreateFromMixins(Mixin1, Mixin2, MixinN)
--- ```
--- @vararg any The mixins
function L:CreateFromMixins(...) return self:Mixin({}, ...) end

--- @vararg any The mixins
--- @return any The new Mixin instance
function L:CreateFromMixinsWithDefExc(...) return self:MixinWithDefExc({}, ...) end

---```
--- Makes a new Mixin instance and calls the <new-instance>:Init(arg1, argN, ...) if it exists
--- local Mixin = { 'properties and methods' }
--- local MyObj = CreateAndInitFromMixin(Mixin, arg1, arg2, argN)
---```
--- @param mixin any The mixin
--- @vararg any The arguments to pass to the <new-instance>:Init(...) method
--- @return any The new Mixin instance
function L:CreateAndInitFromMixin(mixin, ...)
    if not mixin then error(MIXIN_OBJ_REQUIRED_MSG) end
    local o = self:Mixin({}, mixin)
    if o.Init then o:Init(...) end
    return o
end

---```
--- Makes a new Mixin instance that excludes certain private fields and
--- calls the <new-instance>:Init(arg1, argN, ...) if it exists
--- local Mixin = { 'properties and methods' }
--- local MyObj = CreateAndInitFromMixin(Mixin, arg1, arg2, argN)
---```
--- @param mixin any The mixin
--- @vararg any The arguments to pass to the <new-instance>:Init(...) method
--- @return any The new Mixin instance
function L:CreateAndInitFromMixinWithDefExc(mixin, ...)
    local o = self:CreateFromMixinsWithDefExc(mixin)
    if o.Init then
        o:Init(...)
        o.Init = nil; if o.New then o.New = nil end
    end
    return o
end
