--- @type Namespace_ABP_OptionsUI_2_0
local ns = select(2, ...)
local cns, O, L = ns:cns()

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]

local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
local VERSION = L['Version']
local DatabaseSchema = cns.O.DatabaseSchema
local DIALOG_WIDTH, DIALOG_HEIGHT = 530, 405
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

--- @param args table
--- @param order number
local function AddBarsArgs(args, order)
  args.barsHeader = {
    type = 'header',
    order = order,
    name = L['Bars'],
  }
  args.barsDesc = {
    type = 'description',
    order = order + 1,
    name = L['Disabled bars are hidden. Re-enable them here.'],
  }
  for i = 1, DatabaseSchema:GetMaxBarCount() do
    args['bar' .. i] = {
      type = 'toggle',
      width = 'half',
      order = order + 1 + i,
      name = ('%s %s'):format(L['Bar'], i),
      get = function() return cns:bar(i).enabled end,
      set = function(_, val)
        cns:bar(i).enabled = val
        cns:OptionsUI():SendMessage(ns:msg('OnBarOptionsChanged'), i)
      end,
    }
  end
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
  AddBarsArgs(generalArgs, 1)

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
  cns:AceConfigDialog():Open(appName)
  self:RegisterEvent('PLAYER_REGEN_DISABLED')
end

function o:PLAYER_REGEN_DISABLED()
  self:UnregisterEvent('PLAYER_REGEN_DISABLED')
  cns:AceConfigDialog():Close(appName)
end
