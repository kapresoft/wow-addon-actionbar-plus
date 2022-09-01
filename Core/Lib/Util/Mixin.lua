--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub = __K_Core:LibPack()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]

---@class Mixin
local _L = LibStub:NewLibrary(ABP_LibGlobals.Module.Mixin)

---@param object any The target object
function _L:Mixin(object, ...)
    for i = 1, select("#", ...) do
        local mixin = select(i, ...);
        for k, v in pairs(mixin) do
            object[k] = v;
        end
    end

    return object;
end

---@type Mixin
ABP_Mixin = _L