--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local unit = ns.O.UnitUtil

--- @type Kapresoft_Table_2_0
local Table = LibStub('Kapresoft-Table-2-0')
local tbl_DeepCopy = Table.DeepCopy

local MAX_BAR_COUNT = 10

--[[-------------------------------------------------------------------
Type Definitions
---------------------------------------------------------------------]]
--- @class RootConfig_ABP_2_0
--- @field characterSpecificAnchors boolean
--- @field hideWhenTaxi boolean
--- @field actionButtonMouseoverGlow boolean
--- @field hideTextOnSmallButtons boolean
--- @field hideCountdownNumbers boolean
--- @field tooltip TooltipConfig_ABP_2_0
--- @field equipmentSet EquipmentSetConfig_ABP_2_0
--- @field bars table<number, BarConfig_ABP_2_0>
--  ================================================
--- @class EquipmentSetConfig_ABP_2_0
--- @field openCharacterFrame boolean
--- @field openEquipmentManager boolean
--- @field showGlowWhenActive boolean
--  ================================================
--- @class TooltipConfig_ABP_2_0
--- @field visibilityKey string
--- @field visibilityCombatOverrideKey string
--- @field anchorType string
--  ================================================
--- @class PaddingConfig_ABP_2_0
--- @field left number
--- @field right number
--- @field top number
--- @field bottom number
--  ================================================
--- @class SpacingConfig_ABP_2_0
--- @field horizontal number
--- @field vertical number
--  ================================================
--- @class BarButtonUIConfig_ABP_2_0
--- @field size number
--- @field spacing SpacingConfig_ABP_2_0
--  ================================================
--- @class BarUIConfig_ABP_2_0
--- @field rowSize number
--- @field colSize number
--- @field alpha number
--- @field showEmptyButtons boolean
--- @field frameHandleMouseover boolean
--- @field frameHandleAlpha number
--- @field padding PaddingConfig_ABP_2_0        -- Bar frame padding
--- @field button BarButtonUIConfig_ABP_2_0     -- Button spacing configuration
--  ================================================
--- @class ButtonConfig_ABP_2_0
--- @field type string
--- @field id number
--  ================================================
--- @class BarConfig_ABP_2_0
--- @field enabled boolean                       -- Whether this bar is active
--- @field showKeybindText boolean               -- Show keybind text on buttons
--- @field showButtonIndex boolean               -- Show button index overlay
--- @field anchor Anchor                         -- Frame anchor definition
--- @field buttons table<number, table<number, ButtonConfig_ABP_2_0>>
--- @field ui BarUIConfig_ABP_2_0                -- Visual/layout configuration
--  ================================================
--- @class GlobalConfig_ABP_2_0 : RootConfig_ABP_2_0
--- @field schemaVersion number
--  ================================================
--- @class ProfileConfig_ABP_2_0 : RootConfig_ABP_2_0
--  ================================================
--- @class DatabaseObj_ABP_2_0 : AceDBObject_3_0
--- @field global GlobalConfig_ABP_2_0
--- @field profile ProfileConfig_ABP_2_0
--- @field char table|nil
--- @field realm table|nil
--- @field factionrealm table|nil

--[[-----------------------------------------------------------------------------
Module::DatabaseSchema
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
local libName = ns.M.DatabaseSchema()
--- @class DatabaseSchema_ABP_2_0
local S = {}; ns:Register(libName, S)
local p, pd, t, tf = ns:log(libName)

--[[-------------------------------------------------------------------
Schema
---------------------------------------------------------------------]]
local DB_VERSION = 1

--- @type DatabaseObj_ABP_2_0
local DEFAULT_DB = {
  -- GlobalConfig_ABP_2_0
  global = { schemaVersion = DB_VERSION, bars = {} },
  
  profile = {                     -- ProfileConfig_ABP_2_0
    hideWhenTaxi                  = true,
    characterSpecificAnchors      = true,
    actionButtonMouseoverGlow     = true,
    hideTextOnSmallButtons        = false,
    hideCountdownNumbers          = false,
    tooltip = {                   -- TooltipConfig_ABP_2_0
      visibilityKey               = "SHIFT",
      visibilityCombatOverrideKey = "SHIFT",
      anchorType                  = "CURSOR_TOPLEFT",
    },
    equipmentSet = {              -- EquipmentSetConfig_ABP_2_0
      openCharacterFrame          = true,
      openEquipmentManager        = true,
      showGlowWhenActive          = true,
    },
    bars = {}
  }
}

--- @type BarConfig_ABP_2_0
local DEFAULT_BAR = {
  enabled                   = true,
  showKeybindText           = true,
  showButtonIndex           = false,
  -- BarUIConfig_ABP_2_0
  ui = {
    rowSize                 = 2,
    colSize                 = 5,
    alpha                   = 0.8,
    showEmptyButtons        = true,
    frameHandleMouseover    = false,
    frameHandleAlpha        = 1.0,
    -- PaddingConfig_ABP_2_0
    padding = { left = 5, right = 5, top = 5, bottom = 5, },
    -- BarButtonUIConfig_ABP_2_0
    button = {
      size = 40,
      spacing = { horizontal = 3, vertical = 3, },
    },
  },
  -- Anchor (same as V1)
  anchor = { point = "CENTER", relativePoint = "CENTER", x = 0, y = 0, relativeTo = nil, },
}

--[[-----------------------------------------------------------------------------
Module::DatabaseSchema (Methods)
-------------------------------------------------------------------------------]]
--- @type DatabaseSchema_ABP_2_0
local o = S

--[[-------------------------------------------------------------------
Default Database
---------------------------------------------------------------------]]
--- @return DatabaseObj_ABP_2_0
function o:GetDefaultDatabase()
  local db = tbl_DeepCopy(DEFAULT_DB)
  
  for barIndex = 1, MAX_BAR_COUNT do
    db.profile.bars[barIndex] = self:CreateDefaultBar(barIndex)
  end
  
  return db
end

--- Creates and returns a default BarConfig_ABP_2_0 instance.
--- The returned table is a deep copy of the default bar template (index 1)
--- with an empty buttons table (no spec/button data pre-seeded).
--- @param barIndex number
--- @return BarConfig_ABP_2_0
function o:CreateDefaultBar(barIndex)
  assert(type(barIndex) == "number", "CreateDefaultBar(barIndex):: barIndex must be number")

  --- @type BarConfig_ABP_2_0
  local bar = tbl_DeepCopy(DEFAULT_BAR)

  -- Clear buttons to avoid copying seeded defaults
  
  local cols = bar.ui.colSize or 5
  local rows = bar.ui.rowSize or 1
  local totalButtons = cols * rows

  bar.buttons = {}
  local specIndex = unit:GetActiveSpecGroupIndex()
  for btnIndex = 1, totalButtons do
    bar.buttons[btnIndex] = {}
    bar.buttons[btnIndex][specIndex] = {}
  end
  return bar
end

--- @param actionType string @spell, item, equipmentset, etc...
--- @param action number|string @If 'spell', then the spell name or id, etc...
--- @return ButtonConfig_ABP_2_0
function o:CreateButtonConf(actionType, action)
  --- @type ButtonConfig_ABP_2_0
  local btn = {}
  btn['type'] = actionType
  btn[btn.type] = action
  return btn
end

--- @param db DatabaseObj_ABP_2_0
--- @return number
function o:GetVersion(db)
  assert(type(db) == "table", "GetVersion:: db is required.")
  assert(type(db.global) == "table", "GetVersion:: db.global missing.")
  local v = db.global.schemaVersion
  if type(v) ~= "number" then return DB_VERSION end
  return v
end
