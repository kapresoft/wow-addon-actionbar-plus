--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]

local O, LibStub, ns = ABP_LibPack()
local GC, AceEvent, String = O.GlobalConstants, O.AceLibrary.AceEvent, O.String
local IsNotBlank = String.IsNotBlank

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class ConfigEventHandlerMixin : BaseLibraryObject_WithAceEvent
local L = LibStub:NewLibrary(ns.M.ConfigEventHandlerMixin); if not L then return end
AceEvent:Embed(L)
local p = L:GetLogger()

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o ConfigEventHandlerMixin
local function MethodsAndProperties(o)
    function o:Init()
        self.profile = ns.db.profile
    end

    --- Creates a callback function that sends a message after
    --- @param key string The profile key to update
    --- @param fallbackVal any The fallback value
    --- @param message string The message to send
    --- @return fun(_, v:any) : void The function parameter "v" is the option value selected by the user
    function o:SetConfigWithMessage(key, fallbackVal, message)
        return function(_, v)
            assert(type(key) == 'string', 'Profile config key should be a string')
            self.profile[key] = v or fallbackVal
            p:log(1, 'SetConfigWithMessage(): %s=[%s] msg: %s', key, self.profile[key], message)
            if IsNotBlank(message) then self:SendMessage(message, key, self.profile[key]) end
        end
    end
end

MethodsAndProperties(L)

