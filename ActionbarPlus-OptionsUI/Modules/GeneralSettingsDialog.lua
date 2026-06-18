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

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @return string
local function GetVersionText()
  local version = GetAddOnMetadata('ActionbarPlus-Core', 'Version')
  if not version or version:sub(1, 1) == '@' then return 'v1.0.0.DEV' end
  return version
end

--- @return table
local function CreateOptions()
  return {
    type = 'group',
    name = L['ActionbarPlus'],
    args = {
      general = {
        type = 'group',
        name = L['General'],
        order = 1,
        args = {
          version = {
            type = 'description',
            name = ('%s: %s'):format(VERSION, GetVersionText()),
            order = 0,
            fontSize = 'medium',
          },
        },
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
