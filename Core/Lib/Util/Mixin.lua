--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub, Core = __K_Core:LibPack()
local WRONG_TYPE_MSG = 'Expecting table to be source of mixin but got type [%s] instead'
local WRONG_ARG_TYPE_MSG = 'Expected arg #2 to be a list of string properties.'
local MIXIN_OBJ_REQUIRED_MSG = "Can't mixin to a nil object in Mixin(object, ...)"

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]

---@class Mixin
local _L = LibStub:NewLibrary(Core.M.Mixin)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param source table The source table
---@param match string The string to match
local function listContains(source, match)
    for _,v in ipairs(source) do if match == v then return true end end
    return false
end

---@param object any The target object
function _L:MixinAll(object, ...)
    for i = 1, select("#", ...) do
        local mixin = select(i, ...)
        for k, v in pairs(mixin) do
            object[k] = v
        end
    end

    return object
end

---Example:
---```
---local o = {}
---local String = String()
---Mixin:(o, String)
---```
---@param object any
function _L:Mixin(object, ...)
    if not object then error(MIXIN_OBJ_REQUIRED_MSG) end
    return self:MixinExcept(object, { 'GetName', 'mt', 'log' }, ...)
end

---Mixin the ... with target object
---otherwise mixin selfObj if no args {...} are provided
function _L:MixinOrElseSelf(target, selfObj, ...)
    local arg = {...}
    if 0 == #arg then self:Mixin(target, selfObj) else self:Mixin(target, ...) end
    return target
end

---@param propertySkipItems table local items = { 'Property1', 'Property2' }
function _L:MixinExcept(object, propertySkipItems, ...)
    if 'table' ~= type(propertySkipItems) then error(WRONG_ARG_TYPE_MSG) end
    local arg = {...}
    if 0 == #arg then
        print(string.format(LibStub.logPrefix .. ':: %s', 'Mixin', 'No objects were passed to mixin.'))
        return
    end
    for i = 1, select("#", ...) do
        local mixin = select(i, ...)
        local objectType = type(mixin)
        if 'table' ~= objectType then error(string.format(WRONG_TYPE_MSG, tostring(objectType))) end
        for k, v in pairs(mixin) do
            -- Apply skipList to key of string types only
            if 'string' == type(k) then
                if not listContains(propertySkipItems, k) then object[k] = v end
            else
                print('non-string')
                object[k] = v
            end
        end
    end
    return object
end
