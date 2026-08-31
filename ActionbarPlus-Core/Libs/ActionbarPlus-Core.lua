--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local O = ns.O

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local p, t = ns:log()
local L = ns:GetLocale()
local DatabaseMixin, PickupHooks = O.DatabaseMixin, O.PickupHooks
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded or IsAddOnLoaded
local function announcementDialog() return O.V2AnnouncementDialog end

local c1 = ns:ColorFn(ns.colorDef.util1)

local addonInfoUtil__
--- @return Kapresoft-AddonInfoUtil-2-0
local function addonInfoUtil()
  if not addonInfoUtil__ then addonInfoUtil__ = ns:AddonInfoUtil():New(ns.name, ns.colorDef) end
  return addonInfoUtil__
end

--- @type { cmd: string, desc: string }[] @Available slash commands, in display order
local slashCommands = {
  { cmd = 'info', desc = L['displays the addon info'] },
}

local dependentAddOns = {'ActionbarPlus-BarsUI', 'ActionbarPlus-OptionsUI'}
local V1_ADDON_NAME = 'ActionbarPlus'

--[[-------------------------------------------------------------------
AddOn: ActionbarPlus_Core
---------------------------------------------------------------------]]
--- @class ABP_Core_2_0 : AceAddon, AceEvent-3.0, AceBucket-3.0, AceConsole-3.0, Database_ABP_2_0
local o = ns:AceAddon():NewAddon(ns.name, "AceEvent-3.0", "AceBucket-3.0", "AceConsole-3.0")
ABP_Core_2_0 = o

--- @param evt EventName
--- @param addon AceAddon
function o:OnReadyDependentAddOn(evt, addon)
  ns:Register(addon:GetName(), addon)
  local completelyReady = self:AreCoreDependentsReady()
  if completelyReady then
    self:SendMessage(ns:msg('OnCoreDependentsReady'))
  end
end

function o:PrintSlashCommandHelp()
  self:Print(L['Available commands:'])
  for _, c in ipairs(slashCommands) do
    self:Print(('  %s - %s'):format(c1(c.cmd), c.desc))
  end
end

--- @param input string
function o:OnSlashCommand(input)
  local cmd = input:match('^(%S*)')
  if cmd == 'info' then
    self:Print(addonInfoUtil():GetInfoSlashCommandText())
  else
    self:PrintSlashCommandHelp()
  end
end

--- Called once, after:
--- - SavedVariables are loaded
--- - All addon Lua/XML files are loaded
--- - AceDB initialized
function o:OnInitialize()
  DatabaseMixin:InitDb(self)
  for _, a in ipairs(dependentAddOns) do
    self:RegisterMessage(a .. '::OnEnable', 'OnReadyDependentAddOn')
  end
  self:RegisterChatCommand('abp', 'OnSlashCommand')
  self:SendMessage(ns:msg('OnAddOnInitialized'))
end

function o:OnEnable()
  PickupHooks:Init()
  self:RegisterEvent('PLAYER_ENTERING_WORLD')
end

function o:PLAYER_ENTERING_WORLD()
  self:UnregisterEvent('PLAYER_ENTERING_WORLD')
  if not IsAddOnLoaded(V1_ADDON_NAME) then return end
  announcementDialog():Show()
end

--- @return Namespace_ABP_2_0
function o:ns() return ns end

--- /dump ABP_Core_2_0:AreCoreDependentsReady()
--- @return boolean
function o:AreCoreDependentsReady()
  for _, n in ipairs(dependentAddOns) do
    if not O[n] then return false end
  end
  return true
end

