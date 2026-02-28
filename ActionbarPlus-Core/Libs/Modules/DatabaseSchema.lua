--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--- @type Kapresoft_Table_2_0
local Table = LibStub('Kapresoft-Table-2.0')

--[[-------------------------------------------------------------------
Type Definitions
---------------------------------------------------------------------]]
--- @class RootConfigData_ABP_2_0
--- @field characterSpecificAnchors boolean
--- @field hideWhenTaxi boolean
--- @field actionButtonMouseoverGlow boolean
--- @field hideTextOnSmallButtons boolean
--- @field hideCountdownNumbers boolean
--- @field tooltip TooltipConfig_ABP_2_0
--- @field equipmentSet EquipmentSetConfig_ABP_2_0
--- @field bars table<number, BarData_ABP_2_0>
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
--- @class BarUIData_ABP_2_0
--- @field rowSize number
--- @field colSize number
--- @field buttonSize number
--- @field alpha number
--- @field showEmptyButtons boolean
--- @field frameHandleMouseover boolean
--- @field frameHandleAlpha number
--  ================================================
--- @class ButtonData_ABP_2_0
--- @field type string
--- @field id number
--  ================================================
--- @class BarData_ABP_2_0
--- @field enabled boolean                     -- Whether this bar is active
--- @field showKeybindText boolean           -- Show keybind text on buttons
--- @field showButtonIndex boolean           -- Show button index overlay
--- @field ui BarUIData_ABP_2_0                -- Visual/layout configuration
--- @field anchor Anchor                -- Frame anchor definition
--- @field buttons table<number, table<number, ButtonData_ABP_2_0>>
--  ================================================
--- @class GlobalData_ABP_2_0 : RootConfigData_ABP_2_0
--  ================================================
--- @class ProfileData_ABP_2_0 : RootConfigData_ABP_2_0
--  ================================================
--- @class Database_ABP_2_0
--- @field global GlobalData_ABP_2_0
--- @field profile ProfileData_ABP_2_0
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
--- @type Database_ABP_2_0
local DEFAULT_DB = {
  global = { bars = {} },
  
  profile = {
    hideWhenTaxi                  = true,
    characterSpecificAnchors      = true,
    actionButtonMouseoverGlow     = true,
    hideTextOnSmallButtons        = false,
    hideCountdownNumbers          = false,
    tooltip = {
      visibilityKey               = "SHIFT",
      visibilityCombatOverrideKey = "SHIFT",
      anchorType                  = "CURSOR_TOPLEFT",
    },
    equipmentSet = {
      openCharacterFrame          = true,
      openEquipmentManager        = true,
      showGlowWhenActive          = true,
    },
    
    bars = {  -- Bars (numeric indexed)
      [1] = {
        enabled                   = true,
        showKeybindText           = true,
        showButtonIndex           = false,
        ui = { -- Appearance (bar-specific)
          rowSize                 = 2,
          colSize                 = 6,
          buttonSize              = 40,
          alpha                   = 0.8,
          showEmptyButtons        = true,
          frameHandleMouseover    = false,
          frameHandleAlpha        = 1.0,
        },
        anchor = { -- Anchor (same as V1)
          point                   = "CENTER",
          relativePoint           = "CENTER",
          x                       = 0,
          y                       = 0,
          relativeTo              = nil,
        },
        buttons = { -- Buttons (index-based, spec-overlay)
          [1] = { -- Button 1
            [1] = { -- Spec 1 button
              type = "spell",
              id   = 2061, -- Flash Heal
            },
            [2] = { -- Spec 2 button
              type = "spell",
              id   = 589, -- Shadow Word: Pain
            }
          },
        }
      }
    }
  }
}

--[[-----------------------------------------------------------------------------
Module::DatabaseSchema (Methods)
-------------------------------------------------------------------------------]]
--- @type DatabaseSchema_ABP_2_0
local o = S

--[[-------------------------------------------------------------------
Default Database
---------------------------------------------------------------------]]
--- @return Database_ABP_2_0
function o:GetDefaultDatabase() return Table.DeepCopy(DEFAULT_DB) end

