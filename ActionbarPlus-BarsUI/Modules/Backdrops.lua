--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns, O, L = ns:cns()

--[[-----------------------------------------------------------------------------
Module::Backdrops
-------------------------------------------------------------------------------]]
--- @see BarsUI_Modules_ABP_2_0
local libName = ns.M.Backdrops()
--- @class Backdrops_ABP_2_0
--- @field DEFAULT_BACKDROP BorderDef_ABP_2_0
--- @field BORDER_DEFS table<string, BorderDef_ABP_2_0>
local S = {}; ns:Register(libName, S)
local p, t = ns:log(libName)
--[[-------------------------------------------------------------------
Support Vars & Functions
---------------------------------------------------------------------]]
-- edgeSize is border size
--- @type table<string, BorderDef_ABP_2_0>
local BORDER_DEFS = {
  ['abyss'] = {
    label = L['Abyss'],
    backdrop = {
      bgFile   = [[interface\tooltips\ui-tooltip-background]],
      edgeFile = [[interface\addons\actionbarplus-core\assets\textures\ui-tooltip-border-maw]],
      tile     = true, tileSize = 16, edgeSize = 16,
      insets   = { left = 3, right = 3, top = 3, bottom = 3 },
    },
    bgColor = { 0.04, 0.08, 0.09, 0.92 },  -- near-black with a cool teal undertone
    borderColor = { 1, 1, 1, 1 },
    padding = 3, basePadding = 6, borderPadBottom = 0,
    edgeSize = { default = 26, min = 21, max = 32 },
  },
  ['dark-knight'] = {
    label = L['Dark Knight'],
    backdrop = {
      bgFile = [[interface\tooltips\chatbubble-background]],
      edgeFile = [[interface\tooltips\chatbubble-backdrop]],
      tile     = true, tileSize = 32, edgeSize = 6,
      insets   = { left = 6, right = 6, top = 6, bottom = 6 },
    },
    bgColor     = { 0, 0, 0, 1 },
    borderColor = { 0.54, 0.55, 0.75, 1 },
    padding = 0, basePadding = 6, borderPadBottom = 1,
    edgeSize = { default = 21, min = 14, max = 28 },
    dialog = { showBgColor = false, showBorderSize = false },
  },
  ['glow'] = {
    label = L['Glow'],
    backdrop = {
      bgFile   = [[interface\tooltips\ui-tooltip-background]],
      edgeFile = [[interface\addons\actionbarplus-core\assets\textures\ui-tooltip-border-azerite]],
      tile     = true, tileSize = 16, edgeSize = 20,
      insets   = { left = 3, right = 3, top = 3, bottom = 3 },
    },
    bgColor = { 0.05, 0.04, 0.02, 0.92 },
    borderColor = { 1, 1, 1, 1 },
    padding = 0, basePadding = 6, borderPadBottom = 0,
    edgeSize = { default = 12, min = 4, max = 32 },
  },
  ['gold'] = {
    label = L['Gold'],
    backdrop = {
      bgFile = [[Interface\Buttons\WHITE8x8]],
      edgeFile = [[Interface\DialogFrame\UI-DialogBox-Gold-Border]],
      tile = true,
      tileEdge = true,
      tileSize = 32,
      edgeSize = 32,  -- borderSize
      insets = { left = 11, right = 12, top = 12, bottom = 11 },
    },
    bgColor     = { 0.18, 0.13, 0.05, 0.99 }, -- dark warm brown/black background
    --bgColor = {1, 1, 1, 1}, -- dark warm brown/black background
    borderColor = { 1, 0.85, 0.45, 1 },       -- bright gold tint on the border art
    padding = 0, basePadding = 12, borderPadBottom = -1,
    edgeSize = { default = 32, min = 10, max = 48 },
    dialog = { showBorderColor = false },
  },
  ['minimalist'] = {
    label = L['Minimalist'],
    backdrop = {
      bgFile   = [[Interface\Buttons\WHITE8x8]],
      edgeFile = nil,
      tile     = false, tileSize = 0, edgeSize = 0,
      insets   = { left = 2, right = 2, top = 2, bottom = 2 },
    },
    bgColor     = { 0, 0, 0, 0.35 },
    borderColor = { 0, 0, 0, 0 },
    padding = 0, basePadding = 8, borderPadBottom = 0,
    edgeSize = { default = 0, min = 0, max = 48 },
    dialog = { showBorderColor = false, showBorderSize = false },
  },
  ['modern'] = {
    label = L['Modern'],
    backdrop = {
      bgFile   = [[Interface\Tooltips\UI-Tooltip-Background]],
      edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
      tile     = true, tileSize = 16, edgeSize = 16,
      insets   = { left = 3, right = 3, top = 3, bottom = 3 },
    },
    bgColor     = { 0.1, 0.1, 0.1, 0.9 },
    borderColor = { 1, 1, 1, 1 },
    padding = 0, basePadding = 6, borderPadBottom = 0.3,
    edgeSize = { default = 11, min = 11, max = 32 },
  },
  ['shadowmoon'] = {
    label = L['Shadowmoon'],
    backdrop = {
      bgFile = [[Interface\Buttons\WHITE8x8]],
      edgeFile = [[interface\glues\common\textpanel-border.blp]],
      tileEdge = false,
      tile     = false, tileSize = 32, edgeSize = 16,
      insets   = { left = 2, right = 2, top = 2, bottom = 2 },
    },
    bgColor     = { 0.098, 0.106, 0.129, 0.8 },
    borderColor = { 0.54, 0.55, 0.75, 1 },
    padding = 0, basePadding = 8, borderPadBottom = 1.5,
    edgeSize = { default = 21, min = 14, max = 28 },
  },
  ['stone'] = {
    label = L['Stone'],
    backdrop = {
      bgFile   = [[Interface\Tooltips\UI-Tooltip-Background]],
      edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
      tile     = true, tileSize = 32, edgeSize = 28,
      insets   = { left = 6, right = 6, top = 6, bottom = 6 },
    },
    bgColor     = { 0.15, 0.16, 0.18, 0.85 },  -- cool slate gray background
    borderColor = { 0.85, 0.85, 0.85, 1 },     -- light neutral gray, matches the stone art
    padding = 4, basePadding = 8, borderPadBottom = 0,
    edgeSize = { default = 28, min = 4, max = 48 },
  },
  ['wood'] = {
    label = L['Wood'],
    backdrop = {
      bgFile   = [[Interface\Buttons\WHITE8x8]],
      edgeFile = [[Interface\AchievementFrame\UI-Achievement-WoodBorder]],
      tile     = true, tileEdge = true,
      tileSize = 34,
      edgeSize = 26,
      insets = { left = 1, right = 2, top = 2, bottom = 1 },
    },
    bgColor     = { 0.20, 0.12, 0.06, 0.9 },  -- deep walnut brown background
    borderColor = { 1, 0.95, 0.85, 1 },       -- warm off-white, lets the wood-grain art read true
    padding = 0, basePadding = 8, borderPadBottom = 0,
    edgeSize = { default = 26, min = 4, max = 48 },
  },
}

--[[-----------------------------------------------------------------------------
Module::Backdrops (Methods)
-------------------------------------------------------------------------------]]
--- @type Backdrops_ABP_2_0
local o = S

o.DEFAULT_BACKDROP = BORDER_DEFS.shadowmoon
o.BORDER_DEFS = BORDER_DEFS
