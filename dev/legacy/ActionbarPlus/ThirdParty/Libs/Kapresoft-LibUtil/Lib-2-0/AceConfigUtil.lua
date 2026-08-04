--[[-----------------------------------------------------------------------------
VERSION:: Bump MINOR_VERSION whenever a change occurs
-- 1: initial version

DEPENDS ON:
- LibStub, AceLocale-3.0, Kapresoft-ColorFormatter-2-0
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'Kapresoft-AceConfigUtil-2-0', 1

--- @class Kapresoft-AceConfigUtil-2-0
local S = LibStub:NewLibrary(MAJOR, MINOR); if not S then return end
local mt = { __tostring = function() return MAJOR .. '.' .. LibStub.minors[MAJOR] end }
setmetatable(S, mt)

--[[-----------------------------------------------------------------------------
Library Methods
-------------------------------------------------------------------------------]]
local o = S

local sformat = string.format
local AceLocale__, ColorFormatter__

--- @return AceLocale-3.0
local function AceLocale()
    if not AceLocale__ then AceLocale__ = LibStub('AceLocale-3.0') end
    return AceLocale__
end
--- @return Kapresoft-ColorFormatter-2-0
local function ColorFormatter()
    if not ColorFormatter__ then ColorFormatter__ = LibStub('Kapresoft-ColorFormatter-2-0') end
    return ColorFormatter__
end

--- ### Usage:
--- ```
--- local util = LibStub('Kapresoft-AceConfigUtil-2-0').New('DevSuite', true)
--- ```
--- @return Kapresoft-AceConfigUtil-2-0
--- @param addonName Name
--- @param silent boolean|nil Setting this to false will silence non-existing Locale Keys. [default: true]
function o:New(addonName, silent)
  return CreateAndInitFromMixin(o, addonName, silent)
end

--- @private
--- @param addonName Name
--- @param silent boolean Setting this to true will silence non-existing Locale Keys.
function o:Init(addonName, silent)
  assertsafe(addonName, 'AceConfigUtil:Init(addonName:string, silent): {addonName} is missing.')
  self.addonName = addonName

  local cformat = ColorFormatter()
  local c1, c2 = cformat:ColorFn(HEIRLOOM_BLUE_COLOR), cformat:ColorFn(YELLOW_FONT_COLOR)
  self.printp = function(...) print(sformat('{{%s::%s}}', c1(addonName), c2(MAJOR)), ...) end

  local success, result = pcall(function() return AceLocale():GetLocale(addonName) end)
  if not success then
    return self.printp(sformat('GetLocale(%s) failed with: %s', self.addonName, result))
  end; self.L = result
  assertsafe(self.L, 'Failed to create Locale for: %s', tostring(self.addonName))
  if silent ~= false then
    -- Override index so we don't get an error for non-existing keys
    local meta = getmetatable(self.L)
    meta.__index = function(self, key)
      rawset(self, key, key)
      return key
    end
  end

  self.globalSetting = c1(self.L['Global Setting'])
  self.charSetting   = c1(self.L['Character Setting'])
end

--[[-----------------------------------------------------------------------------
Instance Methods
-------------------------------------------------------------------------------]]

--- @param localeKey string
function o:G(localeKey)
  return sformat('%s (%s)', self.L[localeKey], self.globalSetting)
end

--- @param localeKey string
function o:Gn(localeKey)
  return sformat('%s\n(%s)', self.L[localeKey], self.globalSetting)
end

--- @param localeKey string
function o:C(localeKey)
  return sformat('%s (%s)', self.L[localeKey], self.charSetting)
end

--- @param localeKey string
function o:Cn(localeKey)
  return sformat('%s\n(%s)', self.L[localeKey], self.charSetting)
end

--- @param opt AceConfigOption
--- @param localeKey string
function o:NameDesc(opt, localeKey)
  local descKey = localeKey .. '::Desc'
  if not self.L then
    opt.name, opt.desc = localeKey, descKey
    return
  end

  opt.name = self.L[localeKey]
  opt.desc = self.L[descKey]
end

--- @param opt AceConfigOption
--- @param localeKey string
function o:NameDescGlobal(opt, localeKey)
  local descKey = localeKey .. '::Desc'
  if not self.L then
    opt.name, opt.desc = localeKey, descKey
    return
  end

  opt.name = self.L[localeKey]
  opt.desc = self:G(descKey)
end

--- @param opt AceConfigOption
--- @param localeKey string
function o:NameDescCharacter(opt, localeKey)
  local descKey = localeKey .. '::Desc'
  if not self.L then
    opt.name, opt.desc = localeKey, descKey
    return
  end

  opt.name = self.L[localeKey]
  opt.desc = self:C(descKey)
end

--- Create a Global Option
--- @param localeKey string The locale key
--- @param options AceConfigOption
--- @return AceConfigOption
function o:CreateOption(localeKey, options)
  --- @type AceConfigOption
  local option = {};
  self:NameDesc(option, localeKey)
  if options == nil or type(options) ~= 'table' then return option end
  for k in pairs(option) do options[k] = option[k] end
  return options
end

--- Create a Global Option
--- @param localeKey string The locale key
--- @param options AceConfigOption
--- @return AceConfigOption
function o:CreateGlobalOption(localeKey, options)
  --- @type AceConfigOption
  local option = {}
  self:NameDescGlobal(option, localeKey)
  if options == nil or type(options) ~= 'table' then return option end
  for k in pairs(option) do options[k] = option[k] end
  return options
end

--- Create a Character-Specific Option
--- @param localeKey string The locale key
--- @param options AceConfigOption
--- @return AceConfigOption
function o:CreateCharOption(localeKey, options)
  --- @type AceConfigOption
  local option = {}
  self:NameDescCharacter(option, localeKey)
  if options == nil or type(options) ~= 'table' then return option end
  for k in pairs(option) do options[k] = option[k] end
  return options
end

--- @param localeKey Name
--- @return AceConfigOption
function o:CreateLabel(localeKey, options)
  return o:CreateLabelByName(self.L[localeKey], options)
end

--- @param name Name
--- @return AceConfigOption
function o:CreateLabelByName(name, options)
  --- @type AceConfigOption
  local option = { type = "description", width = 'full', fontSize = 'medium', name = name, }
  if options == nil or type(options) ~= 'table' then return option end
  for k in pairs(option) do if not options[k] then options[k] = option[k] end end
  return options
end

--- ##### Usage:
--- ```
--- local sp = self.CreateSpacer()
--- local sp = self.CreateSpacer(1) -- order
--- local sp = self.CreateSpacer('__')
--- local sp = self.CreateSpacer('__', { order = 2, width=1.0 })
--- local sp = self.CreateSpacer({ order = 2, width=1.0 })
--- ```
--- @param spacerTextOrOrderOrOptions string|number|AceConfigOption|nil
--- @param options AceConfigOption|nil
--- @return AceConfigOption
function o:CreateSpacer(spacerTextOrOrderOrOptions, options)
  local spacerText = ' '
  --- @type AceConfigOption
  local option = { type = "description", width = 'full', fontSize = 'medium', name = spacerText, }
  if type(spacerTextOrOrderOrOptions) == 'string' then
    option.name = spacerTextOrOrderOrOptions
  elseif type(spacerTextOrOrderOrOptions) == 'number' then
    option.order = spacerTextOrOrderOrOptions
  elseif type(spacerTextOrOrderOrOptions) == 'table' then
    options = spacerTextOrOrderOrOptions
  end
  if options == nil or type(options) ~= 'table' then return option end
  for k in pairs(option) do if not options[k] then options[k] = option[k] end end
  return options
end
