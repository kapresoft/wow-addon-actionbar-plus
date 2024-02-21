--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub
local PR = O.Profile

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return ActionBarHandlerMixin, Logger
local function CreateLib()
    local libName = M.ActionBarHandlerMixin or 'ActionBarHandlerMixin'
    --- @class ActionBarHandlerMixin : BaseLibraryObject
    local newLib = LibStub:NewLibrary(libName); if not newLib then return nil end
    local logger = newLib:GetLogger()
    return newLib, logger
end; local L, p = CreateLib(); if not L then return end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o ActionBarHandlerMixin
local function PropsAndMethods(o)
    local isCompanionFn = function(bw) return bw:IsCompanionWOTLK() end
    local isShapeShiftFn = function(bw) return bw:IsShapeshiftSpell() end
    local isStealthSpellFn = function(bw) return bw:IsStealthSpell() end
    local isItemOrMacroFn = function(bw) return bw:IsItemOrMacro() end

    --- @param applyFn FrameHandlerFunction | "function(fw) print(fw:GetName()) end"
    function o:ForEachVisibleFrames(applyFn)
        local frames = PR:GetUsableBarFrames()
        if #frames <= 0 then return end
        for _, f in ipairs(frames) do
            applyFn(f.widget)
        end
    end

    --- Apply for each button with a predicateFn
    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    --- @param predicateFn ButtonPredicateFunction | "function(bw) print(bw:GetName()) end"
    function o:ForEachButton(applyFn, predicateFn)
        self:ForEachVisibleFrames(function(fw)
            for _, btn in ipairs(fw.buttonFrames) do
                local shouldApply = predicateFn and predicateFn(btn.widget)
                if true == shouldApply then applyFn(btn.widget) end
            end
        end)
    end

    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    function o:ForEachCompanionButton(applyFn)
        assert(applyFn, "ForEachCompanionButton(fn):: Function handler missing")
        self:ForEachButton(applyFn,isCompanionFn)
    end

    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    function o:ForEachStealthButton(applyFn)
        assert(applyFn, "ForEachStealthButton(fn):: Function handler missing")
        self:ForEachButton(applyFn, isStealthSpellFn)
    end

    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    function o:ForEachShapeshiftButton(applyFn)
        assert(applyFn, "ForEachShapeshiftButton(fn):: Function handler missing")
        self:ForEachButton(applyFn, isShapeShiftFn)
    end

    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    function o:ForEachItemButton(applyFn)
        assert(applyFn, "ForEachItemButton(fn):: Function handler missing")
        self:ForEachButton(applyFn, isItemOrMacroFn)
    end

    --- Any buttons that has an effective SpellID (includes macros, items, mounts?)
    --- @param matchSpellId number
    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    function o:ForEachMatchingSpellButton(matchSpellId, applyFn)
        assert(applyFn, "ForEachMatchingSpellButton(fn):: Function handler missing")
        self:ForEachButton(applyFn, function(bw) return bw:IsMatchingMacroOrSpell(matchSpellId) end)
    end

end;
PropsAndMethods(L)

