--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Kapresoft_Base_Namespace
local ns = select(2, ...); local K = ns.Kapresoft_LibUtil
local LibStub, ModuleName = K.LibStub, K.M.AceLocaleUtil()

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
--- @class Kapresoft_LibUtil_AceLocaleUtil
local L = LibStub:NewLibrary(ModuleName, 1); if not L then return end

---@param addonName string
local function _GetLocale(addonName)
    return K.Objects.AceLibrary.O.AceLocale:GetLocale(addonName, true)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param addonName Name
--- @param silent boolean|nil Defaults to false
function L:GetLocale(addonName, silent)
    assert(addonName, 'Addon Name is required.')
    silent = silent == true
    local loc = _GetLocale(addonName); if not loc then return end
    if silent ~= true then return loc end

    -- Override index so we don't get an error for non-existing keys
    local meta = getmetatable(loc)
    meta.__index = function(self, key)
        rawset(loc, key, key)
        return key
    end
    return loc
end
