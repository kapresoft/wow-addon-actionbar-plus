--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub = __K_Core:LibPack()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]

---@class Mixin
local _L = LibStub:NewLibrary(ABP_LibGlobals.M.Mixin)

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

function _L:Mixin(object, ...)
    return self:MixinExcept(object, { 'GetName', 'mt', 'log' }, ...)
end

function _L:MixinExcept(object, skipList, ...)
    for i = 1, select("#", ...) do
        local mixin = select(i, ...)
        for k, v in pairs(mixin) do
            if 'string' == type(k) then
                if not listContains(skipList, k) then object[k] = v end
            else
                object[k] = v
            end
        end
    end

    return object
end

---@type Mixin
ABP_Mixin = _L