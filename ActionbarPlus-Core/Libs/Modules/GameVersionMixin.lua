--[[-------------------------------------------------------------------
GameVersion
---------------------------------------------------------------------]]
--- @alias GameVersion_2_0 string |"'classic-era'"|"'tbc'"|"'wotlk'"|"'cataclysm'"|"'mists'"|"'mainline'"
--
--
--- For additional info, @see Blizzard_FrameXMLBase/Cata/Constants.lua
-- WOW_PROJECT_MAINLINE = 1;
-- WOW_PROJECT_CLASSIC = 2;
-- WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5;
-- WOW_PROJECT_WRATH_CLASSIC = 11;
-- WOW_PROJECT_CATACLYSM_CLASSIC = 14;
-- WOW_PROJECT_MISTS_CLASSIC = 19;
-- WOW_PROJECT_ID = WOW_PROJECT_CATACLYSM_CLASSIC;
--[[-------------------------------------------------------------------
New Library
---------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--- @class GameVersionMixin_ABP_2_0
local o = {}
do
  o.GAME_VERSION_CLASSIC_ERA = "classic-era"
  o.GAME_VERSION_TBC         = "tbc"
  o.GAME_VERSION_WOTLK       = "wotlk"
  o.GAME_VERSION_CATACLYSM   = "cataclysm"
  o.GAME_VERSION_MISTS       = "mists"
  o.GAME_VERSION_MAINLINE    = "mainline"
  
  --- @return boolean
  function o:IsClassicEra() return ns.gameVersion == self.GAME_VERSION_CLASSIC_ERA end
  --- @return boolean
  function o:IsTBC() return ns.gameVersion == self.GAME_VERSION_TBC end
  --- @return boolean
  function o:IsWOTLK() return ns.gameVersion == self.GAME_VERSION_WOTLK end
  --- @return boolean
  function o:IsCata() return ns.gameVersion == self.GAME_VERSION_CATACLYSM end
  --- @return boolean
  function o:IsMists() return ns.gameVersion == self.GAME_VERSION_MISTS end
  --- @return boolean
  function o:IsMainLine() return ns.gameVersion == self.GAME_VERSION_MAINLINE end
end
ns:MixinGameVersion(o)

