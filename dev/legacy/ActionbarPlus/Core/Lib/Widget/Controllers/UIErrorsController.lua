--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC = ns.O, ns.GC
local MSG = GC.M
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'UIErrorsController'
--- @class UIErrorsController
local L = ns:NewController(libName)
local p = ns:CreateDefaultLogger(libName)
local ps = ns:LC().MESSAGE:NewLogger(libName)

--[[-----------------------------------------------------------------------------
-- TODO next Move to KapresoftLib
Type: UIError
-------------------------------------------------------------------------------]]
--- @class UIErrorMixin
local UIErrorMixin = {}

--- @param o UIErrorMixin
local function UIErrorMixin_Methods(o)

    function o:New() return ns:K():CreateFromMixins(UIErrorMixin) end

    function o:clear()
        self.code = nil; self.name = nil; self.msg  = nil
    end

    function o:HasError() return self.code ~= nil end
    function o:GetLastError() return self.code, self.name, self.msg end

    ---@param c number
    function o:HasErrorCode(c)
        if not self:HasError() then return false end
        return self.code == c
    end

    --- Checks if the object's error code matches any of the provided codes.
    --- &lt;number&gt; is a vararg list of error codes to match against.
    --- @vararg number
    --- @return boolean true if the code matches any of the provided values.
    function o:HasErrorCodes(...)
        local c = self.code
        for i = 1, select("#", ...) do
            if c == select(i, ...) then
                return true
            end
        end
        return false
    end


    --- @param code Number
    --- @param msg string :: Optional
    function o:Update(code, msg)
        self.code = code
        self.name = GetGameMessageInfo and GetGameMessageInfo(code)
        self.msg = msg or _G[self.name]
    end

end; UIErrorMixin_Methods(UIErrorMixin)

--[[-----------------------------------------------------------------------------
Type: UIError
GetGameMessageInfo(55)
-------------------------------------------------------------------------------]]
--- @class UIError : UIErrorMixin
--- @field code number The LE_GAME_ERR_<NAME> code, i.e. LE_GAME_ERR_SPELL_COOLDOWN
--- @field name string The name of the game error, i.e. ERR_SPELL_COOLDOWN
--- @field msg string The value of the global var ERR_<NAME> value, i.e _G['ERR_SPELL_COOLDOWN']
local UIError = UIErrorMixin:New()
function ns:uie() return UIError end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o UIErrorsController | ControllerV2
local function PropsAndMethods(o)

    --- Automatically called
    --- @see ModuleV2Mixin#Init
    --- @private
    function o:OnAddOnInitialized()
        self:RegisterMessage(GC.M.OnButtonBeforePreClick, o.OnButtonBeforePreClick)
        self:RegisterAddOnMessage(GC.E.UI_ERROR_MESSAGE, o.OnUIErrorMessage)
    end

    --- @see ButtonUI#OnReceiveDrag
    --- @param msg Name The message name
    --- @param src Name Should be from 'ButtonUI'
    --- @param w ButtonUIWidget Only fires on a non-empty action slot
    function o.OnButtonBeforePreClick(msg, src, w)
        ns:uie():clear()
    end

    --- When the action is dragged out, the button is EMPTY.
    --- @see ButtonUI#OnReceiveDrag
    --- @param msgName Name The message name
    --- @param src Name Should be from 'ButtonUI'
    --- @param code Number
    --- @param val string
    function o.OnUIErrorMessage(msgName, src, code, val)
        local codeName = GetGameMessageInfo and GetGameMessageInfo(code)
        ps:f3(function() return 'UI-Error:: [%s:%s]=[%s]', (codeName or 'nil'), code, val end)
        ns:uie():Update(code)
    end

end; PropsAndMethods(L)


