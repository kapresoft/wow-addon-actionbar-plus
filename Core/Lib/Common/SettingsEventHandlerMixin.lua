--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, M, LibStub = ns.O, ns.M, ns.LibStub
local IsNotBlank = ns:String().IsNotBlank

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = M.SettingsEventHandlerMixin
--- @class SettingsEventHandlerMixin : BaseLibraryObject_WithAceEvent
local L = LibStub:NewLibrary(libName); if not L then return end; ns:AceEvent(L)
local p = ns:LC().EVENT:NewLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o SettingsEventHandlerMixin
local function MethodsAndProperties(o)

    local function fo() return O.ActionBarOperations end

    --- @return SettingsEventHandlerMixin
    function o:New() return ns:K():CreateAndInitFromMixin(o, ns.db.profile) end

    --- @param profileConf Profile_Config
    function o:Init(profileConf)
        self.profile = profileConf
    end

    --- @private
    --- @param barIndex Index
    --- @return ActionBarFrameWidget, Profile_Bar
    function o:GetBarInfo(barIndex)
        local fw = fo():GetFrameWidgetByIndex(barIndex)
        return fw, fw and fw:conf()
    end

    --- @param barIndex Index
    --- @param key string The key value
    --- @param fallback any The fallback value
    --- @return fun(_) : any A supplier function that provides the value of the property `<key>`
    function o:GetBarConfig(barIndex, key, fallback)
        --- @return any
        return function(_)
            assert(type(key) == 'string', 'Bar config attribute key should be a string, but was ' .. type(key))
            local fw, barConf = self:GetBarInfo(barIndex)
            return barConf[key] or fallback
        end
    end

    --- Alias
    --- @see SettingsEventHandlerMixin#GetBarConfig
    --- @param frameIndex Index
    --- @param key string The key value
    --- @param fallback any The fallback value
    --- @return fun(_) : any A supplier function that provides the value of the property `<key>`
    function o:BC(frameIndex, key, fallback) return self:GetBarConfig(frameIndex, key, fallback) end

    --- Creates a callback function that sets a bar profile
    --- config field and sends a message after.
    --- @see Profile_Bar
    --- @param barIndex Index The action bar index
    --- @param key string The profile key to update
    --- @param message string The message to send
    --- @return fun(_, v:any) : void The function parameter "v" is the option value selected by the user
    function o:SetBarConfigWithMessage(barIndex, key, message)
        return function(_, v)
            assert(type(key) == 'string', 'Bar config key should be a string')
            local fw, barConf = self:GetBarInfo(barIndex)
            barConf[key] = v
            --p:vv(function() return 'BarConf[%s]: %s', key, barConf[key] end)
            if IsNotBlank(message) then self:SendMessage(message, libName, fw) end
        end
    end

    --- Alias
    --- @see SettingsEventHandlerMixin#SetBarConfigWithMessage
    --- @param barIndex Index The action bar index
    --- @param key string The profile key to update
    --- @param message string The message to send
    --- @return fun(_, v:any) : void The function parameter "v" is the option value selected by the user
    function o:BCSet(barIndex, key, message)
        return self:SetBarConfigWithMessage(barIndex, key, message)
    end

    --- Creates a callback function that sets a profile
    --- config field and sends a message after.
    --- @see Profile_Config
    --- @param key string The profile key to update
    --- @param message string The message to send
    --- @return fun(_, v:any) : void The function parameter "v" is the option value selected by the user
    function o:SetConfigWithMessage(key, message)
        return function(_, v)
            assert(type(key) == 'string', 'Profile config key should be a string')
            self.profile[key] = v
            if IsNotBlank(message) then self:SendMessage(message, libName, key, self.profile[key]) end
        end
    end

    --- @param config Settings The config instance
    --- @param fallback any The fallback value
    --- @param key string The key value
    function o:GetProfileConfig(key, fallback)
        return function(_)
            assert(type(key) == 'string', 'Profile key should be a string')
            return self.profile[key] or fallback
        end
    end

    --- @param fallback any The fallback value
    --- @param key string The key value
    function o:PC(key, fallback) return self:GetProfileConfig(key, fallback) end

    --- Alias
    --- @see SettingsEventHandlerMixin#SetConfigWithMessage
    --- @param key string The profile key to update
    --- @param message string The message to send
    --- @return fun(_, v:any) : void The function parameter "v" is the option value selected by the user
    function o:PCSet(key, message)
        return self:SetConfigWithMessage(key, fallbackVal, message)
    end

end; MethodsAndProperties(L)

