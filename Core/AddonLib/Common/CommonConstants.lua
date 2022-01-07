if type(ABP_LOG_LEVEL) ~= "number" then ABP_LOG_LEVEL = 1 end
if type(ABP_DEBUG_MODE) ~= "boolean" then ABP_DEBUG_MODE = false end
ABP_PREFIX = '|cfdffffff{{|r|cfd2db9fbActionBarPlus|r|cfdfbeb2d%s|r|cfdffffff}}|r'

AceModule = {
    AceConsole = 'AceConsole-3.0',
    AceDB = 'AceDB-3.0',
    AceDBOptions = 'AceDBOptions-3.0',
    AceConfig = 'AceConfig-3.0',
    AceConfigDialog = 'AceConfigDialog-3.0',
    AceHook = 'AceHook-3.0',
    AceLibSharedMedia = 'LibSharedMedia-3.0'
}
Module = {
    Logger = 'Logger',
    Config = 'Config',
    Profile = 'Profile',
    ButtonUI = 'ButtonUI',
    ButtonFactory = 'ButtonFactory'
}
VERSION_FORMAT = 'ActionbarPlus-%s-1.0'
