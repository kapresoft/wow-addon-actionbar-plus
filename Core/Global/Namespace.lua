--[[-----------------------------------------------------------------------------
Namespace Initialization
-------------------------------------------------------------------------------]]
---###Usage:
---```
---local addon, ns = ABP_Namespace(...)
---```
---#### See: [https://wowpedia.fandom.com/wiki/Using_the_AddOn_namespace](https://wowpedia.fandom.com/wiki/Using_the_AddOn_namespace)
---@return string, Namespace
function ABP_Namespace(...)
    ---@type string
    local addon
    ---@class Namespace
    local ns
    addon, ns = ...
    ---this is in case we are testing outside of World of Warcraft
    addon = addon or ABP_GlobalConstants.C.ADDON_NAME

    ---The following declarations are not functionally need. This is for
    ---EmmyLua so we can tag the type for better functionality in IntelliJ/IDEs
    ---@type Core
    ns.Core = ns.Core or nil
    ---@type GlobalObjects
    ns.O = ns.O or {}

    return addon, ns
end
