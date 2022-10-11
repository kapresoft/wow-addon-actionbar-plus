--[[-----------------------------------------------------------------------------
Namespace Initialization
-------------------------------------------------------------------------------]]
---###Usage:
---```
---local addon, ns = ABP_Namespace(...)
---```
---#### See: [https://wowpedia.fandom.com/wiki/Using_the_AddOn_namespace](https://wowpedia.fandom.com/wiki/Using_the_AddOn_namespace)
---@return Namespace
function ABP_Namespace(...)
    ---@type string
    local addon
    ---@type table
    local ns
    addon, ns = ...
    ---this is in case we are testing outside of World of Warcraft
    addon = addon or ABP_GlobalConstants.C.ADDON_NAME

    ---The following declarations are not functionally need. This is for
    ---EmmyLua so we can tag the type for better functionality in IntelliJ/IDEs
    ---@class Namespace
    ---@type any
    local obj = {
        name = addon,
        ns = ns,
        ---@type GlobalObjects
        O = ns.O or {},
        ---@param self Namespace
        ---@return GlobalObjects, Core, LocalLibStub
        LibPack = function(self)
            return self.O, self.O.Core, self.O.LibStub
        end,
        mt = { __index = ns }
    }
    setmetatable(obj, obj.mt)

    return obj
end

