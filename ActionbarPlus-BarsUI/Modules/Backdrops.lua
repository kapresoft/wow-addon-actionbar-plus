--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)

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
--- @type table<string, BorderDef_ABP_2_0>
local BORDER_DEFS = {
  modernDark = {
    backdrop = {
      bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
      edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
      tile     = true, tileSize = 16, edgeSize = 12,
      insets   = { left = 4, right = 4, top = 4, bottom = 4 },
    },
    bgColor     = { 0.1, 0.3, 0.7, 0.8 },
    borderColor = { 1, 1, 1, 1 },
  },
  stone = {
    backdrop = {
      bgFile   = 'Interface/Tooltips/UI-Tooltip-Background',
      edgeFile = 'Interface/DialogFrame/UI-DialogBox-Border',
      tile     = true, tileSize = 32, edgeSize = 32,
      insets   = { left = 6, right = 6, top = 6, bottom = 6 },
    },
    --bgColor = { 0.5, 0.4, 0.1, 0.8 },
    bgColor     = { 0.1, 0.3, 0.7, 0.8 },
    borderColor = { 0.9, 0.9, 0.9, 0.9 },
  },
  minimalist = {
    backdrop = {
      bgFile   = 'Interface/Buttons/WHITE8x8',
      edgeFile = nil,
      tile     = false, tileSize = 0, edgeSize = 0,
      insets   = { left = 0, right = 0, top = 0, bottom = 0 },
    },
    bgColor     = { 0, 0, 0, 0.25 },
    borderColor = { 0, 0, 0, 0 },
  },
}

--[[-----------------------------------------------------------------------------
Module::Backdrops (Methods)
-------------------------------------------------------------------------------]]
--- @type Backdrops_ABP_2_0
local o = S

o.DEFAULT_BACKDROP = BORDER_DEFS.stone
o.BORDER_DEFS = BORDER_DEFS
