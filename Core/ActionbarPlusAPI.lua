--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local tinsert = table.insert

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub
local TimeUtil = ns:K().Objects.TimeUtil
local Compat, API, String = O.Compat, O.API, ns:String()
local IsBlank = String.IsBlank

--- ActionbarPlusAPI is a Library used by other addOns like ActionbarPlus-M6
local libName = M.ActionbarPlusAPI
--- @class ActionbarPlusAPI
local L = ns:NewController(libName)
local p = ns:LC().API:NewLogger(libName)

--- @param o ActionbarPlusAPI | ControllerV2
local function PropertiesAndMethods(o)

    -- These fields are used for dependent addons like ActionbarPlus-M6
    --
    --- @see GlobalConstants#GetVersion()
    --- @return string
    function o:GetVersion() return GC:GetVersion() end
    --- @see GlobalConstants#GetLastUpdate()
    --- @return string
    function o:GetLastUpdate() return GC:GetLastUpdate() end
    --- @see GlobalConstants#GetActionbarPlusM6CompatibleVersionDate()
    --- @return string
    function o:GetActionbarPlusM6CompatibleVersionDate() return GC:GetActionbarPlusM6CompatibleVersionDate() end

    --- @return boolean, string OutOfDate result and the ActionbarPlus version text
    function o:IsActionbarPlusM6OutOfDate()
        local outOfDate = TimeUtil:IsOutOfDate(self:GetLastUpdate(), self:GetActionbarPlusM6CompatibleVersionDate())
        return outOfDate, self:GetVersion()
    end

    --- @param itemIDOrName number|string The itemID or itemName
    --- @return ItemInfoDetails
    function o:GetItemInfo(itemIDOrName) return API:GetItemInfo(itemIDOrName) end

    --- @param itemIDOrName number|string The itemID or itemName
    --- @return ItemCooldown
    function o:GetItemCooldown(itemIDOrName) return API:GetItemCooldown(itemIDOrName) end

    --- @param spellNameOrID SpellID|SpellName Spell ID or Name. When passing a name requires the spell to be in your Spellbook.
    --- @return SpellCooldown
    function o:GetSpellCooldown(spellNameOrID) return API:GetSpellCooldown(spellNameOrID) end

    --- @param spellNameOrID SpellID|SpellName
    --- @return SpellName, SpellID
    function o:GetSpell(spellNameOrID)
        local name, id = API:GetSpellName(spellNameOrID); return name, id
    end

    --- Retrieves spell information, compatible with both Retail and Classic WoW.
    --- @param spellIDOrName SpellID_Name_Or_Index
    --- @return SpellName, nil, Icon, CastTime, MinRange, MaxRange, SpellID, OriginalIcon
    function o:GetSpellInfo(spellIDOrName) return Compat:GetSpellInfo(spellIDOrName) end

    --- @param spellNameOrID SpellID|SpellName
    --- @return boolean, SpellID, SpellName
    function o:IsStealthSpell(spellNameOrID)
        local name, id = API:GetSpellName(spellNameOrID)
        return API:IsStealthSpell(id), name, id
    end

    --- @param id SpellID
    --- @return boolean
    function o:IsStealthSpellByID(id) return API:IsStealthSpell(id) end

    --- @param macroName string
    --- @return boolean
    function o:IsM6Macro(macroName) return GC:IsM6Macro(macroName) end

    --- @param btnHandlerFn ButtonHandlerFunction
    function o:UpdateMacros(btnHandlerFn) self:ForEachMacroButton(btnHandlerFn) end

    --- @param btnHandlerFn ButtonHandlerFunction
    function o:UpdateM6Macros(btnHandlerFn)
        self:ForEachMacroButton(function(bw)
            return bw:IsM6Macro() and btnHandlerFn(bw)
        end)
    end

    --- @param btnHandlerFn ButtonHandlerFunction
    --- @param macroName string
    function o:UpdateMacrosByName(macroName, btnHandlerFn)
        if IsBlank(macroName) then return end
        self:ForEachMacroButton(function(bw)
            return bw:HasMacroName(macroName) and btnHandlerFn(bw)
        end)
    end

    --- This ABP_API is required by dependent addons like ActionbarPlus-M6
    function o:OnAddOnReady()
        local fn = function() return 'ABP_API is: %s', tostring(ABP_API) end
        if not ABP_API then return p:e(fn) end
        p:d(fn)
    end

end
PropertiesAndMethods(L); ABP_API = L
