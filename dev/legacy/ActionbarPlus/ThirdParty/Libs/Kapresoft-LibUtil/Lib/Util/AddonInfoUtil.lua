--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Kapresoft_Base_Namespace
local ns = select(2, ...);
local K  = ns.Kapresoft_LibUtil

local KO, LibStub, ModuleName = K.Objects, K.LibStub, K.M.AddonInfoUtil()

local DEBUG_CHAT_FRAME_ADDON   = 'DebugChatFrame'
local VERSION                  = 'Version'
local GITHUB_LAST_CHANGED_DATE = 'X-Github-Project-Last-Changed-Date'
local GITHUB_REPO              = 'X-Github-Repo'
local GITHUB_ISSUES            = 'X-Github-Issues'
local CURSE_FORGE              = 'X-CurseForge'

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
--- @class Kapresoft_LibUtil_AddonInfoUtil
local S = LibStub:NewLibrary(ModuleName, 1); if not S then return end

--- @type Kapresoft_LibUtil_ColorDefinition2
local DefaultConsoleColors = {
    primary = BRIGHTBLUE_FONT_COLOR,
    secondary = LIGHTYELLOW_FONT_COLOR,
    tertiary  = WHITE_FONT_COLOR,
}

--- @param addonName string
--- @return AceLocale
local function GetAceLocale(addonName)
    return KO.AceLibrary.O.AceLocale:GetLocale(addonName)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param addonName Name
--- @param consoleColors Kapresoft_LibUtil_ColorDefinition2
--- @param isDev boolean|nil Defaults to false
--- @return Kapresoft_LibUtil_AddonInfoUtil_Instance
function S:New(addonName, consoleColors, isDev)
    return K:CreateAndInitFromMixinWithDefExc(S, addonName, consoleColors, isDev)
end

--- @class Kapresoft_LibUtil_AddonInfoUtil_Instance
do

    local c1 = K:cf(FACTION_GREEN_COLOR)

    --- @type Kapresoft_LibUtil_AddonInfoUtil_Instance
    local o = S

    --- @private
    --- @param addonName Name
    --- @param consoleColors Kapresoft_LibUtil_ColorDefinition2
    --- @param isDev boolean|nil Defaults to false
    function o:Init(addonName, consoleColors, isDev)
        self._isDev        = isDev == true or false

        self.addonName     = addonName
        self.L             = KO.AceLocaleUtil:GetLocale(addonName, self:IsAceLocaleSilent())
        self.consoleColors = consoleColors or DefaultConsoleColors
        self.ch            = KO.Constants:NewConsoleHelper(self.consoleColors)
        --- Value Formatter.  Light Brown
        self.vf = KO.ColorUtil:NewFormatterFromHex('FFD299ff')

    end

    ---#### Example:
    --- `--- @type AddOnMetaInfo`
    ---```
    ---local meta = AddonInfoUtil:GetAddonInfo()
    ---```
    --- @return AddOnMetaInfo
    function o:GetAddOnMetaInfo()
        local lastUpdate          = self:GetLastUpdate()
        local versionText         = self:GetVersion()
        local wowInterfaceVersion = select(4, GetBuildInfo())
        local cf                  = GetAddOnMetadata(self.addonName, CURSE_FORGE) or CURSE_FORGE
        local issues              = GetAddOnMetadata(self.addonName, GITHUB_ISSUES) or GITHUB_ISSUES
        local repo                = GetAddOnMetadata(self.addonName, GITHUB_REPO) or GITHUB_REPO

        --- @type AddOnMetaInfo
        local meta = {
            version          = versionText,
            curseForge       = cf,
            issues           = issues,
            repo             = repo,
            lastUpdate       = lastUpdate,
            interfaceVersion = wowInterfaceVersion,
            locale           = GetLocale()
        }
        return meta
    end

    --- @return string The time in ISO Date Format. Example: 2024-03-22T17:34:00Z
    function o:GetLastUpdate()
        if self:IsDev() then return KO.TimeUtil:TimeToISODate() end
        return GetAddOnMetadata(self.addonName, GITHUB_LAST_CHANGED_DATE)
    end

    --- @return string The ActionbarPlus version string. Example: 2024.3.1
    function o:GetVersion()
        if self:IsDev() then return '1.0.0.dev' end
        return GetAddOnMetadata(self.addonName, VERSION)
    end

    --- @param command string The long version of the slash command, i.e. actionbarplus
    --- @param commandShort string The short version of the slash command, i.e. abp
    function o:GetMessageLoadedText(command, commandShort)
        local addonName, ch, LL = self.addonName, self.ch, GetAceLocale(self.addonName)

        local msg1Fmt = LL['%s version %s by %s is loaded.']
        local msg2Fmt = LL['Type %s or %s for available commands.']

        local author  = GetAddOnMetadata(addonName, 'Author')
        local msg1Txt = sformat(msg1Fmt, ch:P(addonName) , self:GetVersion(), ch:P(author))
        local msg2Txt = sformat(msg2Fmt, command, commandShort)

        return msg1Txt .. ' ' .. msg2Txt
    end

    function o:GetDebugChatFrameVersion()
        if not _G[DEBUG_CHAT_FRAME_ADDON] then return nil end

        local dcfVersion = GetAddOnMetadata(DEBUG_CHAT_FRAME_ADDON, VERSION)
        if self:IsDev() then
            dcfVersion = '1.0.0.dev'
        end
        return dcfVersion
    end

    --- @return string
    function o:GetInfoSlashCommandText()
        local LL = GetAceLocale(self.addonName)
        local s = sformat('%s: ', LL['Addon Info'])

        local function kvFormat(k, v)
            return sformat('\n%s: %s', self.ch:S(k), self.ch:T(v))
        end

        local meta = self:GetAddOnMetaInfo()
        local dcfVersion = self:GetDebugChatFrameVersion()

        s = s .. kvFormat(LL['Version'], meta.version)
        if ns.gameVersion then s = s .. kvFormat(LL['Game-Version'], c1(ns.gameVersion)) end
        s = s .. kvFormat(LL['Curse-Forge'], meta.curseForge)
        s = s .. kvFormat(LL['Bugs'], meta.issues)
        s = s .. kvFormat(LL['Repo'], meta.repo)
        s = s .. kvFormat(LL['Last-Update'], meta.lastUpdate)
        s = s .. kvFormat(LL['Locale'], meta.locale)
        if dcfVersion and ns.name ~= DEBUG_CHAT_FRAME_ADDON then
            s = s .. kvFormat(LL['DebugChatFrame'], dcfVersion)
        end
        s = s .. kvFormat(LL['Interface-Version'], meta.interfaceVersion)

        return s
    end

    --- @return fun(key:string, val:any) : void
    function o:infoKvFn()
        return function(k, v)
            return sformat('\n%s: %s', self.ch:S(k), self.ch:T(v))
        end
    end

    --- @return fun(key:string, val:any) : void
    function o:infoKvSubFn()
        return function(k, v)
            return sformat('\n  • %s: %s', self.ch:S(k), self.ch:T(v))
        end
    end

    --- @return boolean
    function o:IsDev() return self._isDev == true end
    function o:IsAceLocaleSilent() return not self:IsDev() end
end

