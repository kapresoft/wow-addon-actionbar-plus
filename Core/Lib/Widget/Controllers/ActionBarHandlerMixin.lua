--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, M = ns.O, ns.M
local Compat, PR = O.Compat, O.Profile
local PI = O.ProfileInitializer
local tinsert = table.insert

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = M.ActionBarHandlerMixin
--- @class ActionBarHandlerMixin : BaseLibraryObject
local L = ns:NewLibStd(libName)
local p = ns:CreateDefaultLogger(libName)
--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param frameIndex Index
local function assertFrameIndex(frameIndex)
    assert(type(frameIndex) == 'number', 'Expected frameIndex to be a number but got ' .. type(frameIndex))
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o ActionBarHandlerMixin
local function PropsAndMethods(o)

    --- @param bw ButtonUIWidget
    local isCompanionFn = function(bw) return bw:IsCompanionWOTLK() end
    --- @param bw ButtonUIWidget
    local isMountFn = function(bw) return bw:IsMount() end
    --- @param bw ButtonUIWidget
    local isShapeShiftFn = function(bw) return bw:IsShapeshiftSpell() end
    --- @param bw ButtonUIWidget
    local isStealthSpellFn = function(bw) return bw:IsStealthSpell() end
    --- @param bw ButtonUIWidget
    local isItemOrMacroFn = function(bw) return bw:IsItemOrMacro() end
    --- @param bw ButtonUIWidget
    local isEquipmentSetFn = function(bw) return bw:IsEquipmentSet() end

    --- @return any The embedded object (same as what was passed)
    --- @param obj any The object to embed
    function o:Embed(obj) assert(obj, "The target embed object is missing."); return ns:K():Mixin(obj, o) end

    --- @return API
    function o:a() return O.API end
    --- @return ActionBarOperations
    function o:o() return O.ActionBarOperations end

    --- Includes Non-Visible in Settings
    --- @param frameIndex Index
    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    --- @param predicateFn ButtonPredicateFunction|nil | "function(bw) return true end"
    --- @return FrameWidget
    function o:FrameForEachButtonCondition(frameIndex, applyFn, predicateFn)
        local pfn = predicateFn or function() return true end
        assertFrameIndex(frameIndex)
        local fw = self:o():GetFrameWidgetByIndex(frameIndex); if not fw then return nil end
        for _, btn in ipairs(fw.buttonFrames) do
            if pfn(btn.widget) == true then applyFn(btn.widget) end
        end
        return fw
    end

    --- Includes Non-Visible in Settings
    --- @param frameIndex Index
    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    --- @return FrameWidget
    function o:FrameForEachEmptyButton(frameIndex, applyFn)
        return self:FrameForEachButtonCondition(frameIndex, applyFn,
                function(bw) return bw:IsEmpty() end)
    end

    --- Includes Non-Visible in Settings
    --- @param frameIndex Index
    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    --- @return FrameWidget
    function o:FrameForAllButton(frameIndex, applyFn)
        return self:FrameForEachButtonCondition(frameIndex, applyFn)
    end

    --- Includes Non-Visible in Settings
    --- @param applyFn FrameHandlerFunction | "function(fw) print(fw:GetName()) end"
    function o:ForEachFrames(applyFn)
        local frames = self:o():GetAllBarFrames()
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
        local frames = self:o():GetVisibleBarFrames()
        if #frames <= 0 then return end
        for _, f in ipairs(frames) do applyFn(f.widget) end
    end

    --- Apply for each button with a predicateFn
    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    --- @param predicateFn ButtonPredicateFunction | "function(bw) return true end"
    function o:ForEachButton(applyFn, predicateFn)
        local pfn = predicateFn or function(bw) return true end
        self:fevf(function(fw)
            for _, btn in ipairs(fw.buttonFrames) do
                local shouldApply = btn.widget and pfn(btn.widget)
                if true == shouldApply then applyFn(btn.widget) end
            end
        end)
    end

    --- Apply for each non-empty button with a predicateFn
    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    --- @param predicateFn ButtonPredicateFunction | "function(bw) return true end"
    function o:ForEachNonEmptyButton(applyFn, predicateFn)
        local pfn = predicateFn or function(bw) return true end
        self:fevf(function(fw)
            for _, btn in ipairs(fw.buttonFrames) do
                local shouldApply = btn.widget and not btn.widget:IsEmpty() and pfn(btn.widget)
                if true == shouldApply then applyFn(btn.widget) end
            end
        end)
    end

    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    function o:ForEachMountButton(applyFn)
        assert(applyFn, "ForEachCompanionButton(fn):: Function handler missing")
        self:ForEachNonEmptyButton(applyFn, isMountFn)
    end

    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    function o:ForEachCompanionButton(applyFn)
        assert(applyFn, "ForEachCompanionButton(fn):: Function handler missing")
        self:ForEachNonEmptyButton(applyFn, isCompanionFn)
    end

    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    function o:ForEachStealthButton(applyFn)
        assert(applyFn, "ForEachStealthButton(fn):: Function handler missing")
        self:ForEachNonEmptyButton(applyFn, isStealthSpellFn)
    end

    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    function o:ForEachShapeshiftButton(applyFn)
        assert(applyFn, "ForEachShapeshiftButton(fn):: Function handler missing")
        self:ForEachNonEmptyButton(applyFn, isShapeShiftFn)
    end

    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    function o:ForEachItemButton(applyFn)
        assert(applyFn, "ForEachItemButton(fn):: Function handler missing")
        self:ForEachNonEmptyButton(applyFn, isItemOrMacroFn)
    end

    --- Any buttons that has an effective SpellID (includes macros, items, mounts?)
    --- @param matchSpellId number
    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    function o:ForEachMatchingSpellButton(matchSpellId, applyFn)
        assert(applyFn, "ForEachMatchingSpellButton(fn):: Function handler missing")
        self:ForEachNonEmptyButton(applyFn, function(bw) return matchSpellId == bw:GetSpellIDx() end)
    end

    --- Iterate spell buttons that has an effective SpellID (includes macros, items, mounts?)
    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    function o:ForEachAutoRepeatSpellButton(applyFn)
        assert(applyFn, "ForEachAutoRepeatSpellButton(fn):: Function handler missing")
        self:ForEachNonEmptyButton(applyFn, function(bw)
            local spID = bw:GetSpellIDx(); return spID and Compat:IsAutoRepeatSpell(spID)
        end)
    end

    --- Any buttons that has an effective SpellID (includes macros, items, mounts?)
    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    function o:ForEachMacroButton(applyFn)
        assert(applyFn, "ForEachMacroButton(fn):: Function handler missing")
        self:ForEachNonEmptyButton(applyFn, function(bw) return bw:IsMacro() end)
    end

    --- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
    function o:ForEachEquipmentSetButton(applyFn)
        assert(applyFn, "ForEachEquipmentSetButton(fn):: Function handler missing")
        self:ForEachNonEmptyButton(applyFn, isEquipmentSetFn)
    end

end;
PropsAndMethods(L)

