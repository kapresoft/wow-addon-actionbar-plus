--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, M = ns.O, ns.M
local PR = O.Profile

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = M.ActionBarHandlerMixin
--- @class ActionBarHandlerMixin : BaseLibraryObject
local L = ns:NewLibStd(libName)
local p = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o ActionBarHandlerMixin
local function PropsAndMethods(o)

    ---@param bw ButtonUIWidget
    local isCompanionFn = function(bw) return bw:IsCompanionWOTLK() end
    ---@param bw ButtonUIWidget
    local isShapeShiftFn = function(bw) return bw:IsShapeshiftSpell() end
    ---@param bw ButtonUIWidget
    local isStealthSpellFn = function(bw) return bw:IsStealthSpell() end
    ---@param bw ButtonUIWidget
    local isItemOrMacroFn = function(bw) return bw:IsItemOrMacro() end
    ---@param bw ButtonUIWidget
    local isEquipmentSetFn = function(bw) return bw:IsEquipmentSet() end

    --- @return any The embedded object (same as what was passed)
    --- @param obj any The object to embed
    function o:Embed(obj) assert(obj, "The target embed object is missing."); return ns:K():Mixin(obj, o) end

    --- @return API
    function o:a() return O.API end
    --- @return ActionBarOperations
    function o:o() return O.ActionBarOperations end

    --- Includes Non-Visible in Settings
    --- @param applyFn FrameHandlerFunction | "function(fw) print(fw:GetName()) end"
    function o:ForEachFrames(applyFn)
        local frames = PR:GetAllBarFrames()
        if #frames <= 0 then return end
        for _, f in ipairs(frames) do applyFn(f.widget) end
    end

    --- Visible in Settings
    --- @see ActionBarHandlerMixin#ForEachSettingsVisibleFrames
    --- @param applyFn FrameHandlerFunction | "function(fw) print(fw:GetName()) end"
    function o:ForEachVisibleFrames(applyFn)
        return self:ForEachSettingsVisibleFrames(applyFn)
    end

    --- Visible in Settings
    --- @see ActionBarHandlerMixin#ForEachSettingsVisibleFrames
    --- @param applyFn FrameHandlerFunction | "function(fw) print(fw:GetName()) end"
    function o:fevf(applyFn) return self:ForEachSettingsVisibleFrames(applyFn) end

    --- Visible in Settings
    --- @param applyFn FrameHandlerFunction | "function(fw) print(fw:GetName()) end"
    function o:ForEachSettingsVisibleFrames(applyFn)
        local frames = PR:GetUsableBarFrames()
        if #frames <= 0 then return end
        for _, f in ipairs(frames) do applyFn(f.widget) end
    end

    --- Apply for each button with a predicateFn
    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    --- @param predicateFn ButtonPredicateFunction | "function(bw) print(bw:GetName()) end"
    function o:ForEachButton(applyFn, predicateFn)
        local pfn = predicateFn or function(bw) return true end
        self:fevf(function(fw)
            for _, btn in ipairs(fw.buttonFrames) do
                local shouldApply = btn.widget and pfn(btn.widget)
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

    --- Any buttons that has an effective SpellID (includes macros, items, mounts?)
    --- @param matchSpellId number
    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    function o:ForEachMatchingSpellAndAllMacrosButton(matchSpellId, applyFn)
        assert(applyFn, "ForEachMatchingSpellButton(fn):: Function handler missing")
        self:ForEachButton(applyFn, function(bw) return bw:IsMacro() or bw:IsMatchingMacroOrSpell(matchSpellId) end)
    end

    --- Any buttons that has an effective SpellID (includes macros, items, mounts?)
    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    function o:ForEachMacroButton(applyFn)
        assert(applyFn, "ForEachMacroButton(fn):: Function handler missing")
        self:ForEachButton(applyFn, function(bw) return bw:IsMacro() end)
    end

    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    function o:ForEachEquipmentSetButton(applyFn)
        assert(applyFn, "ForEachEquipmentSetButton(fn):: Function handler missing")
        self:ForEachButton(applyFn, isEquipmentSetFn)
    end

end;
PropsAndMethods(L)

