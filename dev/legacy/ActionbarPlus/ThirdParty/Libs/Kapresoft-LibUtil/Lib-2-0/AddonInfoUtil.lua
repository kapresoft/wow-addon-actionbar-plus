--[[-----------------------------------------------------------------------------
VERSION:: Bump MINOR_VERSION whenever a change occurs
-- 1: initial version

DEPENDS ON:
- LibStub, AceLocale-3.0, Kapresoft-ConsoleHelperMixin-2-0
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'Kapresoft-AddonInfoUtil-2-0', 1

--- @class Kapresoft-AddonInfoUtil-2-0
local S = LibStub:NewLibrary(MAJOR, MINOR); if not S then return end
local mt = { __tostring = function() return MAJOR .. '.' .. LibStub.minors[MAJOR] end }
setmetatable(S, mt)

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
local sformat = string.format
local Locale__, ConsoleHelperMixin__

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--local ns = select(2, ...);
--local K  = ns.Kapresoft_LibUtil
--
--local KO, LibStub, ModuleName = K.Objects, K.LibStub, K.M.AddonInfoUtil()

local DEBUG_CHAT_FRAME_ADDON   = 'DebugChatFrame'
local VERSION                  = 'Version'
local GITHUB_LAST_CHANGED_DATE = 'X-Github-Project-Last-Changed-Date'
local GITHUB_REPO              = 'X-Github-Repo'
local GITHUB_ISSUES            = 'X-Github-Issues'
local CURSE_FORGE              = 'X-CurseForge'

--- @type Kapresoft-ColorDefinition-2-0
local DefaultConsoleColors = {
  primary   = BRIGHTBLUE_FONT_COLOR,
  secondary = LIGHTYELLOW_FONT_COLOR,
  tertiary  = WHITE_FONT_COLOR,
}

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param addonName string
--- @return table<string, string>
local function GetAceLocale(addonName)
  if not Locale__ then
    Locale__ = LibStub('AceLocale-3.0'):GetLocale(addonName)
  end
  return Locale__
end

--- @param colorDef Kapresoft-ColorDefinition-2-0
--- @return Kapresoft-ConsoleHelperMixin-2-0
local function NewConsoleHelper(colorDef)
  if not ConsoleHelperMixin__ then
    ConsoleHelperMixin__ = LibStub('Kapresoft-ConsoleHelperMixin-2-0')
  end
  return CreateAndInitFromMixin(ConsoleHelperMixin__, colorDef)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local o = S

--- @param addonName Name
--- @param consoleColors Kapresoft-ColorDefinition-2-0
--- @return Kapresoft-AddonInfoUtil-2-0
function o:New(addonName, consoleColors)
  return CreateAndInitFromMixin(S, addonName, consoleColors)
end

--- @private
--- @param addonName Name
--- @param consoleColors Kapresoft-ColorDefinition-2-0
function o:Init(addonName, consoleColors)
  self.addon         = addonName
  self.L             = GetAceLocale(addonName)
  self.consoleColors = consoleColors or DefaultConsoleColors
  self.ch            = NewConsoleHelper(self.consoleColors)
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
  local cf                  = GetAddOnMetadata(self.addon, CURSE_FORGE) or CURSE_FORGE
  local issues              = GetAddOnMetadata(self.addon, GITHUB_ISSUES) or GITHUB_ISSUES
  local repo                = GetAddOnMetadata(self.addon, GITHUB_REPO) or GITHUB_REPO

  --- @type AddOnMetaInfo
  local meta                = {
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

--- @return string|osdate @The time in ISO Date Format. Example: 2024-03-22T17:34:00Z
function o:GetLastUpdate()
  return GetAddOnMetadata(self.addon, GITHUB_LAST_CHANGED_DATE)
end

--- @return string @The ActionbarPlus version string. Example: 2024.3.1
function o:GetVersion()
  return GetAddOnMetadata(self.addon, VERSION)
end

--- @param command string @The long version of the slash command, i.e. actionbarplus
--- @param commandShort string @The short version of the slash command, i.e. abp
function o:GetMessageLoadedText(command, commandShort)
  local ch, LL  = self.ch, GetAceLocale(self.addon)

  local msg1Fmt = LL['%s version %s by %s is loaded.']
  local msg2Fmt = LL['Type %s or %s for available commands.']

  local author  = GetAddOnMetadata(self.addon, 'Author')
  local msg1Txt = sformat(msg1Fmt, ch:P(self.addon), self:GetVersion(), ch:P(author))
  local msg2Txt = sformat(msg2Fmt, command, commandShort)

  return msg1Txt .. ' ' .. msg2Txt
end

function o:GetDebugChatFrameVersion()
  if not _G[DEBUG_CHAT_FRAME_ADDON] then return nil end

  local dcfVersion = GetAddOnMetadata(DEBUG_CHAT_FRAME_ADDON, VERSION)
  return dcfVersion
end

--- @return string
function o:GetInfoSlashCommandText()
  local LL = GetAceLocale(self.addon)
  local s = sformat('%s: ', LL['Addon Info'])

  local function kvFormat(k, v)
    return sformat('\n%s: %s', self.ch:S(k), self.ch:T(v))
  end

  local meta = self:GetAddOnMetaInfo()
  local dcfVersion = self:GetDebugChatFrameVersion()

  s = s .. kvFormat(LL['Version'], meta.version)
  if ns.gameVersion then s = s .. kvFormat(LL['Game-Version'], ns.gameVersion) end
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
