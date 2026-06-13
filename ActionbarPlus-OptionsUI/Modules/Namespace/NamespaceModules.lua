--- @type Namespace_ABP_OptionsUI_2_0
local ns = select(2, ...)

--- @type Kapresoft-ModuleUtil-2-0
local ModuleUtil = LibStub('Kapresoft-ModuleUtil-2-0')

--[[-----------------------------------------------------------------------------
Type: Modules
-------------------------------------------------------------------------------]]
--- @class OptionsUI_Modules_ABP_2_0
local ModuleNames = {

}; ModuleUtil:EnrichModules(ModuleNames); ns.M = ModuleNames
