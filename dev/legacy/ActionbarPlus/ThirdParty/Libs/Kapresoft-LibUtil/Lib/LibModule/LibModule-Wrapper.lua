--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Kapresoft_LibUtil
local K = select(2, ...).Kapresoft_LibUtil

--[[-----------------------------------------------------------------------------
New Instance
LibStub Example:
local o = LibStub('Kapresoft-LibUtil-LibModule-1.0')
-------------------------------------------------------------------------------]]
--- @class Kapresoft_LibUtil_LibModule : Kapresoft_LibModule
local W = K:CreateLibWrapper('LibModule', 1, 'Kapresoft-LibModule-1.0')
