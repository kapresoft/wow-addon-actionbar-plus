--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, M, LibStub = ns.O, ns.M, ns.LibStub
local IsNotBlank = O.String.IsNotBlank

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class SettingsEventHandlerMixin : BaseLibraryObject_WithAceEvent
local L = LibStub:NewLibrary(M.SettingsEventHandlerMixin); if not L then return end; ns:AceEvent(L)
local p = ns:LC().EVENT:NewLogger(M.SettingsEventHandlerMixin)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o SettingsEventHandlerMixin
local function MethodsAndProperties(o)
    function o:Init() self.profile = ns.db.profile end

    --- Creates a callback function that sends a message after
    --- @param key string The profile key to update
    --- @param fallbackVal any The fallback value
    --- @param message string The message to send
    --- @return fun(_, v:any) : void The function parameter "v" is the option value selected by the user
    function o:SetConfigWithMessage(key, fallbackVal, message)
        return function(_, v)
            assert(type(key) == 'string', 'Profile config key should be a string')
            self.profile[key] = v or fallbackVal
            if IsNotBlank(message) then self:SendMessage(message, key, self.profile[key]) end
        end
    end
end; MethodsAndProperties(L)

