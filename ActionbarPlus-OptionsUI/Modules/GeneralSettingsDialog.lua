--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_OptionsUI_2_0
local ns = select(2, ...)
local cns, O, L = ns:cns()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'GeneralSettingsDialog'
local appName = 'ABP_GeneralSettingsDialog_2_0'
--- @class GeneralSettingsDialog_ABP_2_0
local o = {}; ns:Register(libName, o)
local p, t = ns:log(libName)

local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
local VERSION = VERSION or L['Version']
local MAX_BAR_COUNT = 10

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @return string
local function GetVersionText()
  local version = GetAddOnMetadata('ActionbarPlus-Core', 'Version')
  if not version or version:sub(1, 1) == '@' then return 'v1.0.0.DEV' end
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
  for i = 1, MAX_BAR_COUNT do
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
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function o:Open()
  RegisterOptions()
  cns:AceConfigDialog():Open(appName)
end
