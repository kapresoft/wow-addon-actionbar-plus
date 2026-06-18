--- @type Namespace_ABP_OptionsUI_2_0
local ns = select(2, ...)

--- @type Kapresoft-ModuleUtil-2-0
local ModuleUtil = LibStub('Kapresoft-ModuleUtil-2-0')

--[[-----------------------------------------------------------------------------
Type: Modules
-------------------------------------------------------------------------------]]
--- @class OptionsUI_Modules_ABP_2_0
local ModuleNames = {

  --- @type BarContextMenu_ABP_2_0
  BarContextMenu = {},
  --- @type BarOptionsDialog_ABP_2_0
  BarOptionsDialog = {},
  --- @type BarKeybindController_ABP_2_0
  BarKeybindController = {},
  --- @type QuickKeybindModeDialog_ABP_2_0
  QuickKeybindModeDialog = {},

}; ModuleUtil:EnrichModules(ModuleNames); ns.M = ModuleNames
