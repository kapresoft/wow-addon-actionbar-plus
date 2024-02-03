--- @type Namespace
local _, ns = ...
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub
local E, MSG, UnitId = GC.E, GC.M,  GC.UnitId
local PR, WMX = O.Profile, O.WidgetMixin
local AceEvent = O.AceLibrary.AceEvent

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local RegisterFrameForEvents, RegisterFrameForUnitEvents
        = FrameUtil.RegisterFrameForEvents, FrameUtil.RegisterFrameForUnitEvents
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = M.ActionBarController
--- @class ActionBarController : BaseLibraryObject_WithAceEvent
local L = LibStub:NewLibrary(libName); if not L then return end; AceEvent:Embed(L);
local p = L:GetLogger()
local safecall = O.Safecall:New(p)

-- Add to Modules.lua
--ActionBarController = 'ActionBarController',
--
----- @type ActionBarController
--ActionBarController = {},

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local ABPI = function() return O.ActionbarPlusAPI  end
local addon = function() return ABP  end

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

---@param bw ButtonUIWidget
local function IsCompanion(bw) return bw:IsCompanion() or bw:IsBattlePet() end
---@param bw ButtonUIWidget
local function UpdateIcon(bw)
    local icon = O.API:GetSpellIcon(bw:GetSpellData())
    if icon then bw:SetIcon(icon) end
end

--- @param applyFn FrameHandlerFunction | "function(fw) print(fw:GetName()) end"
function ForEachVisibleFrames(applyFn)
    local frames = PR:GetUsableBarFrames()
    if #frames <= 0 then return end
    for _,f in ipairs(frames) do applyFn(f.widget) end
end

--- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
function ForEachCompanionButton(applyFn)
    ForEachVisibleFrames(function(fw)
        fw:fevb(function(bw) return IsCompanion(bw) end, applyFn)
    end)
end

--- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
local function ForEachStealthButton(applyFn)
    ForEachVisibleFrames(function(fw)
        fw:fevb(function(bw) return bw:IsStealthSpell() end, applyFn)
    end)
end
--- @param applyFn ButtonHandlerFunction | "function(bw) print(bw:GetName()) end"
local function ForEachShapeshiftButton(applyFn)
    ForEachVisibleFrames(function(fw)
        fw:fevb(function(bw) return bw:IsShapeshiftSpell() end, applyFn)
    end)
end

--[[-----------------------------------------------------------------------------
Event Handlers
-------------------------------------------------------------------------------]]
local function OnStealthIconUpdate()
    ForEachStealthButton(UpdateIcon)
end

--- Update Items and Macros referencing items
local function OnBagUpdate()
    ForEachVisibleFrames(function(fw)
        fw:fevb(
            function(bw) return bw:IsItemOrMacro() end,
            function(bw)
                local success, itemInfo = safecall(function() return bw:GetItemData() end)
                if not (success and itemInfo) then return end
                bw:UpdateItemOrMacroState()
            end)
    end)
    ---@param handlerFn ButtonHandlerFunction
    local function CallbackFn(handlerFn) ABPI():UpdateM6Macros(handlerFn) end
    L:SendMessage(MSG.OnBagUpdateExt, libName, CallbackFn)
end

--- Not fired in classic-era
--- @param f EventFrameInterface
local function OnCompanionUpdate()
    ForEachCompanionButton(function(bw)
        C_Timer.NewTicker(0.5, function() bw:UpdateCompanionActiveState() end, 3)
    end)
end

local function OnUpdateStealth() OnStealthIconUpdate() end
local function OnShapeShift() ForEachShapeshiftButton(UpdateIcon) end
local function OnUpdateBindings() addon():UpdateKeyBindings() end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o ActionBarController
local function PropsAndMethods(o)

    ---@param evt string
    o[E.PLAYER_TARGET_CHANGED] = function(evt, ...)
        local t = UnitName('target') or 'NONE'
        p:log(10, 'PLAYER_TARGET_CHANGED: %s', t)
    end

    o[E.BAG_UPDATE] = OnBagUpdate
    o[E.BAG_UPDATE_DELAYED] = OnBagUpdate
    o[E.COMPANION_UPDATE] = OnCompanionUpdate

    o[E.PLAYER_CONTROL_LOST] = function()
        if not PR:IsHideWhenTaxi() then return end
        C_Timer.After(1, function()
            local playerOnTaxi = UnitOnTaxi(GC.UnitId.player)
            if playerOnTaxi ~= true then return end
            WMX:ShowActionbarsDelayed(false, 1)
        end)
    end

    o[E.PLAYER_CONTROL_GAINED] = function()
        if not PR:IsHideWhenTaxi() then return end
        WMX:ShowActionbarsDelayed(true, 2)
        p:log('handle player control: %s', E.PLAYER_CONTROL_GAINED)
    end
    o[E.UPDATE_BINDINGS]        = OnUpdateBindings
    o[E.UPDATE_STEALTH]         = OnUpdateStealth
    o[E.UPDATE_SHAPESHIFT_FORM] = OnShapeShift

end; PropsAndMethods(L)

---@param frame _Frame
local function OnAddOnReady(frame)
    OnStealthIconUpdate(); OnCompanionUpdate();

    RegisterFrameForEvents(frame, {
        E.PLAYER_TARGET_CHANGED,
        E.BAG_UPDATE,
        E.BAG_UPDATE_DELAYED,
        E.COMPANION_UPDATE,
        E.PLAYER_CONTROL_LOST, E.PLAYER_CONTROL_GAINED,
        E.UPDATE_BINDINGS,
        E.UPDATE_STEALTH, E.UPDATE_SHAPESHIFT_FORM,
    })
end

--[[-----------------------------------------------------------------------------
OnLoad & OnEvent Hooks
-------------------------------------------------------------------------------]]
---@param frame _Frame
function ABP_ActionBarController_OnLoad(frame)
    L:RegisterMessage(GC.M.OnAddOnReady, function() OnAddOnReady(frame)  end)

    ABP_ActionBarController_OnLoad = nil
end

---@param frame _Frame
function ABP_ActionBarController_OnEvent(frame, event, ...)
    --- @type fun(evt:string, ...: any)
    local handler = L[event]; if type(L[event]) ~= 'function' then return end
    --p:log('%s::%s: args=%s', frame:GetName(), event, pformat{args1, args2})
    handler(event, ...)
    ABP_ActionBarController_OnEvent = nil;
end
