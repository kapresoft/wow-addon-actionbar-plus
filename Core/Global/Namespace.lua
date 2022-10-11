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
    ---@class Namespace
    local ns
    addon, ns = ...

    ---this is in case we are testing outside of World of Warcraft
    addon = addon or ABP_GlobalConstants.C.ADDON_NAME

    ---@type GlobalObjects
    ns.O = ns.O or {}
    ---@type string
    ns.name = addon
    ---Core exists in both ns.Core and ns.O.Core
    ---@type Core
    ns.Core = ns.Core or nil

    ---@return GlobalObjects, Core, LocalLibStub
    function ns:LibPack() return self.O, self.O.Core, self.O.LibStub end

    return ns
end

