--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local tinsert = table.insert

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = abp_ns(...)
local O, GC, M, LibStub, LC = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub, ns.LogCategories()
local API, String = O.API, O.String
local IsBlank = String.IsBlank

--- @class ActionbarPlusAPI : BaseLibraryObject
local L = LibStub:NewLibrary(M.ActionbarPlusAPI); if not L then return end
local p = LC.API:NewLogger(M.ActionbarPlusAPI)

--- @param o ActionbarPlusAPI
local function PropertiesAndMethods(o)

    --- @param itemIDOrName number|string The itemID or itemName
    --- @return ItemInfo
    function o:GetItemInfo(itemIDOrName) return API:GetItemInfo(itemIDOrName) end

    --- @param itemIDOrName number|string The itemID or itemName
    --- @return ItemCooldown
    function o:GetItemCooldown(itemIDOrName) return API:GetItemCooldown(itemIDOrName) end

    --- @param spellNameOrID number|string Spell ID or Name. When passing a name requires the spell to be in your Spellbook.
    --- @return SpellCooldown
    function o:GetSpellCooldown(spellNameOrID) return API:GetSpellCooldown(spellNameOrID) end

    --- @param macroName string
    --- @return boolean
    function o:IsM6Macro(macroName) return GC:IsM6Macro(macroName) end
    
    --- @param btnHandlerFn ButtonHandlerFunction
    function o:UpdateMacros(btnHandlerFn)
        O.ButtonFactory:ApplyForEachVisibleFrames(function(fw)
            fw:ApplyForEachMacro(btnHandlerFn)
        end)
    end
    --- @param btnHandlerFn ButtonHandlerFunction
    function o:UpdateM6Macros(btnHandlerFn)
        O.ButtonFactory:ApplyForEachVisibleFrames(function(fw)
            fw:ApplyForEachMacro(function(bw)
                if not bw:IsM6Macro() then return end
                btnHandlerFn(bw)
            end)
        end)
    end

    --- @param btnHandlerFn ButtonHandlerFunction
    --- @param macroName string
    function o:UpdateMacrosByName(macroName, btnHandlerFn)
        if IsBlank(macroName) then return end
        O.ButtonFactory:ApplyForEachVisibleFrames(function(fw)
            fw:ApplyForEachMacro(function(bw)
                if bw:HasMacroName(macroName) then btnHandlerFn(bw) end
            end)
        end)
    end

    --- @param predicateFn ButtonPredicateFunction
    --- @return table<number, ButtonUIWidget>
    function o:FindMacros(predicateFn)
        local ret = {}
        O.ButtonFactory:ApplyForEachVisibleFrames(function(fw)
            fw:ApplyForEachMacro(function(bw)
                if predicateFn(bw) then tinsert(ret, bw) end
            end)
        end)
    end

end
PropertiesAndMethods(L)

ABP_API = L


