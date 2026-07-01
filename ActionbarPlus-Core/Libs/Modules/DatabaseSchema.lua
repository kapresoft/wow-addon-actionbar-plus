--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]

--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local tbl_DeepCopy = ns:Table().DeepCopy

-- Wrath/Cata/TBC dual-spec max; classic always 1
-- todo: revisit for retail because N talents are based off a class, i.e. DRUID has a few spec/talents
local MAX_SPEC_GROUPS = 2
local MAX_BAR_COUNT = 10
local MAX_ROW_SIZE, MAX_COL_SIZE = 18, 36
local MIN_BTN_SIZE, MAX_BTN_SIZE = 20, 120
local MIN_EXTRA_BTN_SIZE, MAX_EXTRA_BTN_SIZE = 16, 80

--[[-------------------------------------------------------------------
Type Definitions
---------------------------------------------------------------------]]

--- @class RootConfig_ABP_2_0
--- @field characterSpecificAnchors boolean
--- @field hideWhenTaxi boolean
--- @field hideWhenGhost boolean
--- @field actionButtonMouseoverGlow boolean
--- @field hideTextOnSmallButtons boolean
--- @field hideCountdownNumbers boolean
--- @field tooltip TooltipConfig_ABP_2_0
--- @field equipmentSet EquipmentSetConfig_ABP_2_0
--- @field bars table<string, BarConfig_ABP_2_0>

--  ==========================rFrame boolean
----- @field openEquipmen======================

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

--- @class SpacingConfig_ABP_2_0
--- @field horizontal number
--- @field vertical number

--  ================================================

--- @class BarUIButtonConfig_ABP_2_0
--- @field size number
--- @field spacing SpacingConfig_ABP_2_0

--  ================================================

--- @alias RGBA number[]  -- {r,g,b,a} each value 0.0–1.0

--- @class BarUIBackdropConfig_ABP_2_0
--- @field theme string        -- Border theme key (see BORDER_DEFS in Backdrops.lua)
--- @field padding number      -- Backdrop internal padding (uniform, all sides)
--- @field bgColor RGBA        -- Backdrop background color
--- @field borderColor RGBA    -- Backdrop border color
--- @field edgeSize number     -- Backdrop border size
--  ================================================

--- @class ExtraButtonConfig_ABP_2_0
--- @field enabled boolean
--- @field anchor string         -- 'TOP' | 'BOTTOM' | 'TOPLEFT' | 'TOPRIGHT' | 'BOTTOMLEFT' | 'BOTTOMRIGHT'
--- @field colSize number        -- number of buttons in the single row
--- @field size number           -- button size
--- @field showEmptyButtons boolean

--- @class BarUIConfig_ABP_2_0
--- @field rowSize number
--- @field colSize number
--- @field alpha number
--- @field showEmptyButtons boolean
--- @field frameHandleMouseover boolean
--- @field frameHandleAlpha number
--- @field padding number                       -- Bar frame padding (uniform, all sides)
--- @field button BarUIButtonConfig_ABP_2_0     -- Button spacing configuration
--- @field backdrop BarUIBackdropConfig_ABP_2_0
--- @field extraButton ExtraButtonConfig_ABP_2_0
--  ================================================

--- @class ButtonConfig_ABP_2_0
--- @field type string    The button action type e.g. 'spell', 'item', 'mount', 'battlepet'
--- @field id ActionValue The identifier for the action; a numeric ID for spells/items/mounts or a GUID string for battle pets

--- @class MacroButtonConfig_ABP_2_0 : ButtonConfig_ABP_2_0
--- @field hash number    The hash to identify the macro; typically the hash of the macro body

--  ================================================

--- @class DragFrameConfig_ABP_2_0
--- @field anchor string    -- 'TOPLEFT' | 'TOPRIGHT'
--- @field thickness number

--- @class BarConfig_ABP_2_0
--- @field enabled boolean                       Whether this bar is active
--- @field showKeybindText boolean               Show keybind text on buttons
--- @field showButtonIndex boolean               Show button index overlay
--- @field anchor Anchor                         Frame anchor definition
--- @field buttons table<string, table<string, ButtonConfig_ABP_2_0>> -- i.e., buttons['b1']
--- @field ui BarUIConfig_ABP_2_0                Visual/layout configuration
--- @field dragFrame DragFrameConfig_ABP_2_0

--  ================================================

--- @class GlobalConfig_ABP_2_0 : RootConfig_ABP_2_0
--- @field schemaVersion number

--  ================================================

--- @class ProfileConfig_ABP_2_0 : RootConfig_ABP_2_0
--- @field barCount number

--  ================================================

--- @class DatabaseObj_ABP_2_0 : AceDBObject-3.0
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
local o = {}
ns:Register(libName, o)
local p, t = ns:log(libName)

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]

--- @param barIndex Index
--- @return string
local function barKey(barIndex)
  assert(type(barIndex) == 'number', 'barKey(barIndex):: expected a numeric index.')
  return 'bar_' .. barIndex
end

--- @param btnIndex Index
--- @return string
local function buttonKey(btnIndex)
  assert(type(btnIndex) == 'number', 'buttonKey(btnIndex):: expected a numeric index.')
  return 'btn_' .. btnIndex
end

--- @param extraBtnIndex Index  @1-based index within the extra button row
--- @return string              @e.g. 'btn_1e', 'btn_2e'
local function extraButtonKey(extraBtnIndex)
  assert(
    type(extraBtnIndex) == 'number',
    'extraButtonKey(extraBtnIndex):: expected a numeric index.'
  )
  return 'btn_' .. extraBtnIndex .. 'e'
end

--- @param specGroupIndex Index
--- @return string
local function specGroupKey(specGroupIndex)
  assert(type(specGroupIndex) == 'number', 'buttonKey(activeSpecGroup):: expected a numeric index.')
  return 'spg_' .. specGroupIndex
end

o.Util = {
  barKey = barKey,
  buttonKey = buttonKey,
  extraButtonKey = extraButtonKey,
  specGroupKey = specGroupKey,
  EXTRA_BTN_ENCODED_OFFSET = 900,
}

--[[-------------------------------------------------------------------
Schema
---------------------------------------------------------------------]]
local DB_VERSION = 1

--- @type DatabaseObj_ABP_2_0
local DEFAULT_DB = {
  -- GlobalConfig_ABP_2_0
  ['global'] = { schemaVersion = DB_VERSION, bars = {} },

  profile = { -- ProfileConfig_ABP_2_0
    barCount = 10,
    hideWhenTaxi = true,
    hideWhenGhost = true,
    characterSpecificAnchors = false,
    --actionButtonMouseoverGlow     = true,
    --hideTextOnSmallButtons        = false,
    --hideCountdownNumbers          = false,
    tooltip = { -- TooltipConfig_ABP_2_0
      visibilityKey = 'SHIFT',
      visibilityCombatOverrideKey = 'SHIFT',
      anchorType = 'CURSOR_TOPLEFT',
    },
    equipmentSet = { -- EquipmentSetConfig_ABP_2_0
      openCharacterFrame = true,
      openEquipmentManager = true,
      showGlowWhenActive = true,
    },
    bars = {},
  },
}

--- @type BarConfig_ABP_2_0
local DEFAULT_BAR = {
  enabled = false,
  showKeybindText = true,
  showButtonIndex = false,
  -- BarUIConfig_ABP_2_0
  ui = {
    rowSize = 2,
    colSize = 5,
    alpha = 1.0,
    showEmptyButtons = true,
    frameHandleMouseover = false,
    frameHandleAlpha = 1.0,
    padding = 5, -- Button padding (uniform, all sides)
    -- BarButtonUIConfig_ABP_2_0
    button = {
      size = 50,
      spacing = { horizontal = 3, vertical = 3 },
    },
    backdrop = {},
    extraButton = {
      enabled = false,
      anchor = 'TOPRIGHT',
      colSize = 5,
      size = 30,
      showEmptyButtons = true,
    },
  },
  dragFrame = { anchor = 'TOPLEFT', thickness = 14 },
  -- Anchor (same as V1)
  anchor = { point = 'CENTER', relativePoint = 'CENTER', x = 0, y = 0, relativeTo = nil },

  --buttons = {
  --  ['btn1'] = {
  --    ['spec1'] = {},
  --    ['spec2'] = {},
  --  }
  --}
}

--[[-----------------------------------------------------------------------------
Module::DatabaseSchema (Methods)
-------------------------------------------------------------------------------]]

--- Default Database
--- @return DatabaseObj_ABP_2_0
function o:GetDefaultDatabase()
  local db = tbl_DeepCopy(DEFAULT_DB) --[[@as DatabaseObj_ABP_2_0]]

  for barIndex = 1, MAX_BAR_COUNT do
    local key = barKey(barIndex)
    db['profile'].bars[key] = self:CreateDefaultBar(barIndex)
    db['global'].bars[key] = {
      anchor = { point = 'CENTER', relativePoint = 'CENTER', x = 0, y = 0, relativeTo = nil },
    }
  end

  return db
end

--- Creates and returns a default BarConfig_ABP_2_0 instance.
--- Buttons are pre-seeded for all spec groups so AceDB treats them as defaults
--- and does not write them to SavedVariables when empty.
--- @param barIndex number
--- @return BarConfig_ABP_2_0
function o:CreateDefaultBar(barIndex)
  assert(type(barIndex) == 'number', 'CreateDefaultBar(barIndex):: barIndex must be number')

  --- @type BarConfig_ABP_2_0
  local bar = tbl_DeepCopy(DEFAULT_BAR)
  bar.enabled = barIndex == 1

  local cols = bar.ui.colSize or 5
  local rows = bar.ui.rowSize or 1
  local totalButtons = cols * rows

  -- todo: revisit for retail because it has specs > 2 (class-based, i.e. druid has a lot of 4 talent specs)
  bar.buttons = {}
  for btnIndex = 1, totalButtons do
    local key = buttonKey(btnIndex)
    bar.buttons[key] = {}
    for spg = 1, MAX_SPEC_GROUPS do
      bar.buttons[key][specGroupKey(spg)] = {}
    end
  end

  local extraCols = bar.ui.extraButton.colSize or 1
  for i = 1, extraCols do
    local key = extraButtonKey(i)
    bar.buttons[key] = {}
    for spg = 1, MAX_SPEC_GROUPS do
      bar.buttons[key][specGroupKey(spg)] = {}
    end
  end

  return bar
end

function o:GetBar(barIndex) end

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
  assert(type(db) == 'table', 'GetVersion:: db is required.')
  assert(type(db['global']) == 'table', 'GetVersion:: db.global missing.')
  local v = db['global'].schemaVersion
  if type(v) ~= 'number' then return DB_VERSION end
  return v
end

--- @return number
function o:GetMaxBarCount() return MAX_BAR_COUNT end
--- @return number
function o:GetMaxRowSize() return MAX_ROW_SIZE end
--- @return number
function o:GetMaxColSize() return MAX_COL_SIZE end
--- @return number
function o:GetMinBtnSize() return MIN_BTN_SIZE end
--- @return number
function o:GetMaxBtnSize() return MAX_BTN_SIZE end
--- @return number
function o:GetMinExtraBtnSize() return MIN_EXTRA_BTN_SIZE end
--- @return number
function o:GetMaxExtraBtnSize() return MAX_EXTRA_BTN_SIZE end
