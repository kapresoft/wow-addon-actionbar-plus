--[[-----------------------------------------------------------------------------
Notes:
-------------------------------------------------------------------------------]]
--- For additional info, @see Blizzard_FrameXMLBase/Cata/Constants.lua
-- WOW_PROJECT_MAINLINE = 1;
-- WOW_PROJECT_CLASSIC = 2;
-- WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5;
-- WOW_PROJECT_WRATH_CLASSIC = 11;
-- WOW_PROJECT_CATACLYSM_CLASSIC = 14;
-- WOW_PROJECT_MISTS_CLASSIC = 19;
-- WOW_PROJECT_ID = WOW_PROJECT_CATACLYSM_CLASSIC;

--- @alias Kapresoft-GameVersion-2-0 string | "classic-era" | "tbc" | "wotlk" | "cataclysm" | "mists" | "mainline"

--[[-----------------------------------------------------------------------------
VERSION:: Bump MINOR_VERSION whenever a change occurs
-- 1: initial version
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'Kapresoft-GameVersionMixin-2-0', 1

--- @class Kapresoft-GameVersionMixin-2-0 A mixin for WoW versions
--- @field gameVersion string
local S = LibStub:NewLibrary(MAJOR, MINOR); if not S then return end
local mt = { __tostring = function() return MAJOR .. '.' .. LibStub.minors[MAJOR] end }
setmetatable(S, mt)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local o = S

o.GAME_VERSION_CLASSIC_ERA = "classic-era"
o.GAME_VERSION_TBC         = "tbc"
o.GAME_VERSION_WOTLK       = "wotlk"
o.GAME_VERSION_CATACLYSM   = "cataclysm"
o.GAME_VERSION_MISTS       = "mists"
o.GAME_VERSION_MAINLINE    = "mainline"

--- @return boolean
function o:IsClassicEra() return self.gameVersion == o.GAME_VERSION_CLASSIC_ERA end

--- @return boolean
function o:IsTBC() return self.gameVersion == o.GAME_VERSION_TBC end

--- @return boolean
function o:IsWOTLK() return self.gameVersion == o.GAME_VERSION_WOTLK end

--- @return boolean
function o:IsCata() return self.gameVersion == o.GAME_VERSION_CATACLYSM end

--- @return boolean
function o:IsMists() return self.gameVersion == o.GAME_VERSION_MISTS end

--- @return boolean
function o:IsMainline() return self.gameVersion == o.GAME_VERSION_MAINLINE end

--- @return boolean
function o:IsRetail() return self:IsMainline() end
