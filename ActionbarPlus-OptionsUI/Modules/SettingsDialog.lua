--- @type Namespace_ABP_OptionsUI_2_0
local ns = select(2, ...)
local cns, O, L = ns:cns()

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]

local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
local VERSION = L['Version']
local DIALOG_WIDTH, DIALOG_HEIGHT = 550, 405
local TREE_WIDTH = 130

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]

local libName = 'SettingsDialog'
local appName = 'ABP_SettingsDialog_2_0'
--- @class SettingsDialog_ABP_2_0 : AceEvent-3.0
local o = ns:Register(libName, cns:NewAceEvent())
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @return string
local function GetVersionText()
  local version = GetAddOnMetadata('ActionbarPlus-Core', 'Version')
  --@debug@
  version = 'v1.0.0.DEV'
  --@end-debug@
  return version
end

--- @return table
local function CreateOptions()
  local generalArgs = {
    version = {
      type = 'description',
      name = ('%s: %s'):format(VERSION, GetVersionText()),
      order = 0,
      fontSize = 'medium',
    },
  }

  return {
    type = 'group',
    name = L['ActionbarPlus'],
    args = {
      general = {
        type = 'group',
        name = L['General'],
        order = 1,
        args = generalArgs,
      },
    },
  }
end

local registered = false
local function RegisterOptions()
  if registered then return end
  registered = true

  local AceConfig = cns:AceConfig()
  local AceDBOptions = cns:AceDBOptions()

  local options = CreateOptions()
  options.args.profiles = AceDBOptions:GetOptionsTable(cns:db())
  options.args.profiles.order = 2

  AceConfig:RegisterOptionsTable(appName, options)
  local AceConfigDialog = cns:AceConfigDialog()
  AceConfigDialog:SetDefaultSize(appName, DIALOG_WIDTH, DIALOG_HEIGHT)
  -- group tree (General/Profiles) width; no SetDefault* helper for this, so seed the status
  -- table directly. The root TreeGroup widget reads from status.groups, not status itself
  -- (AceConfigDialog-3.0.lua:1733-1738 — tree:SetStatusTable(status.groups)).
  local status = AceConfigDialog:GetStatusTable(appName)
  status.groups = status.groups or {}
  status.groups.treewidth = TREE_WIDTH
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function o:Open()
  RegisterOptions()
  local AceConfigDialog = cns:AceConfigDialog()
  AceConfigDialog:Open(appName)
  local widget = AceConfigDialog.OpenFrames[appName]
  if widget and widget.frame then
    widget.frame:SetResizeBounds(DIALOG_WIDTH, DIALOG_HEIGHT)
    widget.frame:SetClampedToScreen(true)
  end
  self:RegisterEvent('PLAYER_REGEN_DISABLED')
end

function o:OpenProfiles()
  self:Open()
  cns:AceConfigDialog():SelectGroup(appName, 'profiles')
end

function o:OpenGeneral()
  self:Open()
  cns:AceConfigDialog():SelectGroup(appName, 'general')
end

function o:PLAYER_REGEN_DISABLED()
  self:UnregisterEvent('PLAYER_REGEN_DISABLED')
  cns:AceConfigDialog():Close(appName)
end
