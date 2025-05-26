--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return MultiOnUpdateFrameMixin, Kapresoft_CategoryLogger
local function CreateLib()
    local libName = M.MultiOnUpdateFrameMixin or 'MultiOnUpdateMixin'
    --- @class __MultiOnUpdateFrameMixin : BaseLibraryObject
    --- @private @field _onUpdateHandlers table<Name, fun(frame: Frame, elapsed: number)> | nil  # Map of handler names to update functions
    --- @private @field _onUpdateInstalled boolean | nil                                         # True if OnUpdate is currently hooked
    local newLib = ns:NewMixin(libName); if not newLib then return nil end

    --- @alias MultiOnUpdateFrameMixin __MultiOnUpdateFrameMixin | Frame
    local logger = ns:LC().SPELL_AUTO_REPEAT:NewLogger(libName)
    return newLib, logger
end; local L, p = CreateLib(); if not L then return end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o __MultiOnUpdateFrameMixin | MultiOnUpdateFrameMixin
local function PropsAndMethods(o)

    --- Adds a function to be called on every OnUpdate tick.
    --- @param name Name A unique identifier
    --- @param func fun(frame: Frame, elapsed: number)
    function o:AddOnUpdateCallback(name, func)
        self._onUpdateHandlers = self._onUpdateHandlers or {}

        -- Set or replace the handler
        self._onUpdateHandlers[name] = func
        p:f1(function() return 'Added: %s',  name end)

        -- Install OnUpdate dispatcher if not already running
        if not self._onUpdateInstalled then
            self:SetScript("OnUpdate", function(frame, elapsed)
                local handlers = frame._onUpdateHandlers
                if not handlers or next(handlers) == nil then
                    frame:SetScript("OnUpdate", nil)
                    frame._onUpdateInstalled = nil
                    return
                end
                for _, fn in pairs(handlers) do fn(frame, elapsed) end
            end)
            self._onUpdateInstalled = true
        end
    end

    --- Removes a previously registered update function.
    --- @param name Name A unique identifier
    function o:RemoveOnUpdateCallback(name)
        if not name then return end
        local handlers = self._onUpdateHandlers
        if not (handlers and handlers[name]) then return end

        handlers[name] = nil
        p:f1(function() return 'Removed: %s', name end)

        -- Cleanup if empty
        if next(handlers) == nil and self:GetScript("OnUpdate") then
            self:SetScript("OnUpdate", nil)
            self._onUpdateInstalled = nil
        end
    end

end; PropsAndMethods(L)



