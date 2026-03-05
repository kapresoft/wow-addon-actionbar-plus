--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
Module::Constants
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
local libName = ns.M.Constants()
--- @class Constants_ABP_2_0
local S = {}; ns:Register(libName, S)
local p, pd, t, tf = ns:log(libName)
C_Timer.After(1, function() p("xxx Loaded...") end)

--[[-----------------------------------------------------------------------------
Module::Constants (Methods)
-------------------------------------------------------------------------------]]
--- @type Constants_ABP_2_0
local o = S

--- @class AttributeNames_ABP_2_0
local AttributeNames = {
  type = 'type',
  saved_type = 'abp_saved_type',
}; o.AttributeNames = AttributeNames

--- @class SupportedActionTypes_ABP_2_0
local SupportedActionTypes = {
  spell        = 'spell',
  item         = 'item',
  macro        = 'macro',
  mount        = 'mount',
  companion    = 'companion',
  battlepet    = 'battlepet',
  petaction    = 'petaction',
  equipmentset = 'equipmentset',
}; o.SupportedActionTypes = SupportedActionTypes
