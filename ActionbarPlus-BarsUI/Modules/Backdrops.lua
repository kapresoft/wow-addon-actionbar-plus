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
local S = {}; ns:Register(libName, S)
local p, t = ns:log(libName)
--[[-------------------------------------------------------------------
Support Vars & Functions
---------------------------------------------------------------------]]
-- edgeSize is border size
--- @type table<string, BorderDef_ABP_2_0>
local BORDER_DEFS = {
  ['gold'] = {
    label = L['Gold'],
    backdrop = {
      bgFile = "Interface/Buttons/WHITE8x8",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
      tile = true,
      tileEdge = true,
      tileSize = 32,
      edgeSize = 32,  -- borderSize
      insets = { left = 11, right = 12, top = 12, bottom = 11 },
    },
    bgColor     = { 0.18, 0.13, 0.05, 0.99 }, -- dark warm brown/black background
    --bgColor = {1, 1, 1, 1}, -- dark warm brown/black background
    borderColor = { 1, 0.85, 0.45, 1 },       -- bright gold tint on the border art
    padding = 5,
    edgeSizeMin = 10,
    edgeSizeMax = 48,
  },
  ['minimalist'] = {
    label = L['Minimalist'],
    backdrop = {
      bgFile   = 'Interface/Buttons/WHITE8x8',
      edgeFile = nil,
      tile     = false, tileSize = 0, edgeSize = 0,
      insets   = { left = 2, right = 2, top = 2, bottom = 2 },
    },
    bgColor     = { 0, 0, 0, 0.35 },
    borderColor = { 0, 0, 0, 0 },
    padding = 0,
    edgeSizeMin = 0,
    edgeSizeMax = 48,
  },
  ['modern-dark'] = {
    label = L['Modern Dark'],
    backdrop = {
      bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
      edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
      tile     = true, tileSize = 16, edgeSize = 18,
      insets   = { left = 3, right = 3, top = 3, bottom = 3 },
    },
    bgColor     = { 0.1, 0.1, 0.1, 0.9 },
    borderColor = { 1, 1, 1, 1 },
    padding = 0,
    edgeSizeMin = 4,
    edgeSizeMax = 32,
  },
  ['stone'] = {
    label = L['Stone'],
    backdrop = {
      bgFile   = 'Interface/Tooltips/UI-Tooltip-Background',
      edgeFile = 'Interface/DialogFrame/UI-DialogBox-Border',
      tile     = true, tileSize = 32, edgeSize = 28,
      insets   = { left = 6, right = 6, top = 6, bottom = 6 },
    },
    bgColor     = { 0.15, 0.16, 0.18, 0.85 },  -- cool slate gray background
    borderColor = { 0.85, 0.85, 0.85, 1 },     -- light neutral gray, matches the stone art
    padding = 4,
    edgeSizeMin = 4,
    edgeSizeMax = 48,
  },
  ['wood'] = {
    label = L['Wood'],
    backdrop = {
      bgFile   = 'Interface/Buttons/WHITE8x8',
      edgeFile = "Interface\\AchievementFrame\\UI-Achievement-WoodBorder",
      tile     = true, tileEdge = true,
      tileSize = 34,
      edgeSize = 26,
      insets = { left = 1, right = 2, top = 2, bottom = 1 },
    },
    bgColor     = { 0.20, 0.12, 0.06, 0.9 },  -- deep walnut brown background
    borderColor = { 1, 0.95, 0.85, 1 },       -- warm off-white, lets the wood-grain art read true
    padding = 0,
    edgeSizeMin = 4,
    edgeSizeMax = 48,
  },
}

--[[-----------------------------------------------------------------------------
Module::Backdrops (Methods)
-------------------------------------------------------------------------------]]
--- @type Backdrops_ABP_2_0
local o = S

o.DEFAULT_BACKDROP = BORDER_DEFS.stone
o.BORDER_DEFS = BORDER_DEFS
