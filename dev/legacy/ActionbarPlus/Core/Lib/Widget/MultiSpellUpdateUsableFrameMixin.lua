--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M = ns.O, ns.GC, ns.M

--- @return MultiSpellUpdateUsableFrameMixin, Kapresoft_CategoryLogger
local function CreateLib()
    local libName = M.MultiSpellUpdateUsableFrameMixin
    --- @class __MultiSpellUpdateUsableFrameMixin : BaseLibraryObject
    --- @private @field _onUpdateHandlers table<string, fun(frame: Frame, elapsed: number)>|nil Map of update handler names to functions
    --- @private @field _onUpdateInstalled boolean|nil True if the OnUpdate dispatcher is active
    --- @private @field _eventHandlers table<string, fun(...: any)>|nil Map of registered event names to their handler functions
    --- @private @field _eventDispatcherInstalled boolean|nil True if the OnEvent dispatcher is currently active
    local newLib = ns:NewMixin(libName); if not newLib then return nil end

    --- @alias MultiSpellUpdateUsableFrameMixin __MultiSpellUpdateUsableFrameMixin | Frame
    local logger = ns:LC().SPELL_USABLE:NewLogger(libName)
    return newLib, logger
end; local L, p = CreateLib(); if not L then return end

--- @param o MultiSpellUpdateUsableFrameMixin
local function PropsAndMethods(o)

    ---------------------------------------------------------------------------
    -- OnUpdate Management
    ---------------------------------------------------------------------------
    function o:AddOnUpdateCallback(name, func)
        o._onUpdateHandlers = o._onUpdateHandlers or {}
        o._onUpdateHandlers[name] = func
        p:f1(function() return 'Added OnUpdate: %s', name end)

        if not o._onUpdateInstalled then
            o:SetScript("OnUpdate", function(frame, elapsed)
                local handlers = frame._onUpdateHandlers
                if not handlers or not next(handlers) then
                    frame:SetScript("OnUpdate", nil)
                    o._onUpdateInstalled = nil
                    return
                end
                for _, fn in pairs(handlers) do fn(frame, elapsed) end
            end)
            o._onUpdateInstalled = true
        end
    end

    function o:RemoveOnUpdateCallback(name)
        if not name then return end
        local handlers = o._onUpdateHandlers
        if not (handlers and handlers[name]) then return end

        handlers[name] = nil
        p:f1(function() return 'Removed OnUpdate: %s', name end)

        if next(handlers) == nil and o:GetScript("OnUpdate") then
            o:SetScript("OnUpdate", nil)
            o._onUpdateInstalled = nil
        end
    end

    ---------------------------------------------------------------------------
    -- General Event Dispatcher
    ---------------------------------------------------------------------------
    function o:RegisterEventHandler(event, fn)
        o._eventHandlers = o._eventHandlers or {}
        o._eventHandlers[event] = fn
        o:RegisterEvent(event)

        if not o._eventDispatcherInstalled then
            o:SetScript("OnEvent", function(_, e, ...)
                local handler = o._eventHandlers and o._eventHandlers[e]
                if handler then handler(...) end
            end)
            o._eventDispatcherInstalled = true
        end
    end

    function o:UnregisterEventHandler(event)
        if o._eventHandlers then o._eventHandlers[event] = nil end
        o:UnregisterEvent(event)

        if o._eventHandlers and not next(o._eventHandlers) then
            o:SetScript("OnEvent", nil)
            o._eventDispatcherInstalled = nil
        end
    end

    ---------------------------------------------------------------------------
    -- SPELL_UPDATE_USABLE Handler
    ---------------------------------------------------------------------------
    o._spellUsableCallbacks = {}

    function o:RegisterSpellUsableCallback(key, spell, fn)
        local spellName = type(spell) == "number" and GetSpellInfo(spell) or spell
        if not spellName then
            p:f1(function() return 'Invalid spell reference for key "%s"', key end)
            return
        end

        o._spellUsableCallbacks[key] = { spell = spellName, callback = fn }

        if not o._eventHandlers or not o._eventHandlers["SPELL_UPDATE_USABLE"] then
            o:RegisterEventHandler("SPELL_UPDATE_USABLE", function()
                for _, entry in pairs(o._spellUsableCallbacks) do
                    local usable, noMana = IsUsableSpell(entry.spell)
                    entry.callback(usable, noMana)
                end
            end)
        end
    end

    function o:UnregisterSpellUsableCallback(key)
        o._spellUsableCallbacks[key] = nil

        if not next(o._spellUsableCallbacks) then
            o:UnregisterEventHandler("SPELL_UPDATE_USABLE")
        end
    end

    function o:RegisterOnceSpellUsableCallback(key, spell, fn)
        o:RegisterSpellUsableCallback(key, spell, function(isUsable, noMana)
            if isUsable then
                fn(isUsable, noMana)
                o:UnregisterSpellUsableCallback(key)
            end
        end)
    end
end; PropsAndMethods(L)

