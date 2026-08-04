--[[-----------------------------------------------------------------------------
Type: CoreNamespace
-------------------------------------------------------------------------------]]
--- @class CoreNamespace : Kapresoft_Base_Namespace
--- @field gameVersion GameVersion
--- @field chatFrame ChatLogFrame

--[[-----------------------------------------------------------------------------
Namespace
-------------------------------------------------------------------------------]]
--- @type string
local addon
--- @type CoreNamespace
local ns

addon, ns = ...; ns.addon  = addon

--[[-----------------------------------------------------------------------------
Local Variables
-------------------------------------------------------------------------------]]
local K = ns.Kapresoft_LibUtil
local KO, M = K.Objects, K.M
local LibStub = K.LibStub
local ModuleName = M.CoreNamespaceMixin()

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
--- @class Kapresoft_LibUtil_CoreNamespaceMixin
local L = LibStub:NewLibrary(ModuleName, 8); if not L then return end

--[[-----------------------------------------------------------------------------
Type: Kapresoft_ChatLogFrameMixin
-------------------------------------------------------------------------------]]
--- @class Kapresoft_ChatLogFrameMixin
local ChatLogFrameMixin = {}; do
    local FONT_SIZE_ERR_MSG = 'Invalid:: Font size must be 10, 12, 14, 16, and 18'

    local m = ChatLogFrameMixin
    --- @param o CoreNamespace
    function m:Mixin(o)
        --- @return ChatLogFrame
        function o:ChatFrame() return self.chatFrame end

        --- @return boolean
        function o:HasChatFrame() return self:ChatFrame() ~= nil end

        --- @return boolean
        function o:IsChatFrameTabShown()
            return self:HasChatFrame() and self:ChatFrame():IsShown()
        end

        --- Set the Font Size of the ChatFrame Console
        --- @param fontSize number Font Size between 12 and 18
        function o:SetChatFrameFontSize(fontSize)
            if not self.chatFrame then return end

            fontSize = fontSize or 14
            assert((fontSize % 2) == 0, FONT_SIZE_ERR_MSG)
            assert(fontSize >= 10 and fontSize <= 18, FONT_SIZE_ERR_MSG)
            local font, _, outline = self.chatFrame:GetFont()
            return font and self.chatFrame:SetFont(font, fontSize, outline)
        end
    end
end

--[[-----------------------------------------------------------------------------
CoreNamespaceMixin
Usage: K:Mixin(any, KO.NamespaceAceLibraryMixin, ...)
-------------------------------------------------------------------------------]]
--- @see AceLibraryMixin.lua
--- @type CoreNamespace
local o = L; ChatLogFrameMixin:Mixin(o); do

    local TimeUtil = KO.TimeUtil

    o.sformat      = string.format
    o.pformat      = K.pformat

    local function ts() return o.sformat('[%s]', TimeUtil:NowInHoursMinSeconds()) end

    -- global print/logger ('c')
    local function _LogFn(...)
        if o:IsChatFrameTabShown() then
            return o:ChatFrame():log(ts(), ...)
        end
        print(ts(), ...)
    end

    --- @param module Name
    local function _LogpFn(module, ...)
        local cf = ns.chatFrame
        if cf then return cf:log(ts(), module, ...) end
        print(ts(), module, ...)
    end

    local function _PrintFn(...)
        print(ts(), ...)
    end

    --- @param module Name
    local function _PrintpFn(module, ...)
        print(ts(), module, ...)
    end

    --- @return Kapresoft_LibUtil
    function o:K() return K end

    --- @return Kapresoft_LibUtil_Modules
    function o:KO() return KO end

    --- @return Kapresoft_LibUtil_SequenceMixin
    --- @param startingSequence number|nil
    function o:CreateSequence(startingSequence) return KO.SequenceMixin:New(startingSequence) end

    --- @param colorDef Kapresoft_LibUtil_ColorDefinition | Kapresoft_LibUtil_ColorDefinition2
    --- @return Kapresoft_LibUtil_ConsoleHelper
    function o:NewConsoleHelper(colorDef) return KO.Constants:NewConsoleHelper(colorDef) end

    --- @return Kapresoft_LibUtil_AceLibraryObjects
    function o:AceLibrary() return KO.AceLibrary.O end

    --- @return AceConfigDialog
    function o:AceConfigDialog() return self:AceLibrary().AceConfigDialog end

    --- @return AceDB
    function o:AceDB() return self:AceLibrary().AceDB end

    --- @return Kapresoft_LibUtil_Assert
    function o:Assert() return KO.Assert end

    --- @return Kapresoft_LibUtil_ColorUtil
    function o:ColorUtil() return KO.ColorUtil end

    --- @return Kapresoft_LibUtil_Safecall
    function o:Safecall() return KO.Safecall end

    --- @return Kapresoft_LibUtil_String
    function o:String() return KO.String end

    --- @return Kapresoft_LibUtil_Table
    function o:Table() return KO.Table end

    --- @return Kapresoft_LibUtil_TimeUtil
    function o:TimeUtil() return KO.TimeUtil end

    --- @return Kapresoft_LibUtil_AceLocaleUtil
    function o:AceLocaleUtil() return KO.AceLocaleUtil end

    --- @param addonName Name
    --- @param silent boolean|nil Defaults to false
    function o:GetLocale(addonName, silent) return self:AceLocaleUtil():GetLocale(addonName, silent) end

    --- @return Kapresoft_LibUtil_AddonUtil
    function o:AddonUtil() return KO.AddonUtil end

    --- @return Kapresoft_LibUtil_AddonInfoUtil
    function o:AddonInfoUtil() return KO.AddonInfoUtil end

    --- @return GameVersion
    function o:IsVanilla() return self.gameVersion == 'classic' end
    
    --- @return GameVersion
    function o:IsTBC()
        return self.gameVersion == 'tbc'
                or self.gameVersion == 'tbc_classic'
                or self.gameVersion == 'tbc_anniversary'
    end
    
    --- @return GameVersion
    function o:IsWOTLK() return self.gameVersion == 'wotlk_classic' end
    --- @return GameVersion
    function o:IsCataclysm() return self.gameVersion == 'cataclysm_classic' end
    --- @return GameVersion
    function o:IsMoP() return self.gameVersion == 'mop_classic' end
    --- @return GameVersion
    function o:IsRetail() return self.gameVersion == 'retail' end

    ---@param chatFrame ChatLogFrame
    function o:RegisterChatFrame(chatFrame) self.chatFrame = chatFrame end

    o.LogFunctions = {}; do
        local f = o.LogFunctions
        --- ### Usage
        --- ```
        --- local logp = ns.f.logp('MyController')
        --- logp('Hello', 'World!')
        --- ```
        --- @param module Name
        --- @return fun(...:any) : void
        function f.logp(module) return function(...) _LogpFn(module, ...)  end end

        --- ### Usage
        --- ```
        --- local printp = ns.f.printp('MyController')
        --- printp('Hello', 'World!')
        --- ```
        --- @param module Name
        --- @return fun(...:any) : void
        function f.printp(module) return function(...) _PrintpFn(module, ...)  end end
    end

    ---------------------------------------------------------------
    -- Print Functions --
    ---------------------------------------------------------------
    o.log   = _LogFn
    o.logp  = _LogpFn
    o.print = _PrintFn
    o.printp = _PrintpFn

end
