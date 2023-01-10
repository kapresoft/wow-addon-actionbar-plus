--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local unpack = unpack

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local ReloadUI, IsShiftKeyDown, UnitOnTaxi = ReloadUI, IsShiftKeyDown, UnitOnTaxi
local UIParent, CreateFrame = UIParent, CreateFrame
local GetBuildInfo, GetAddOnMetadata = GetBuildInfo, GetAddOnMetadata
local GetCVarBool = GetCVarBool
local InterfaceOptionsFrame, PlaySound, SOUNDKIT = InterfaceOptionsFrame, PlaySound, SOUNDKIT
--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat, loadstring, format = string.format, loadstring, format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
-- Bump this version for every release tag
--
local ns = ABP_Namespace(...)
local ADDON_NAME = ns.name

local LibStub, Core, O = ns.O.LibStub, ns.Core, ns.O

local GC, AO = O.GlobalConstants, O.AceLibFactory:A()
local GCC = GC.C
local FRAME_NAME = ADDON_NAME .. "Frame"

local String, Table, LogFactory = O.String, O.Table, O.LogFactory
local IsEmptyTable, parseSpaceSeparatedVar = Table.isEmpty, Table.parseSpaceSeparatedVar
local IsBlank, IsAnyOf = String.IsBlank, String.IsAnyOf
local MX, WMX, PopupDebugDialog = O.Mixin, O.WidgetMixin, O.PopupDebugDialog

local AceDB, AceDBOptions, AceConfig, AceConfigDialog = AO.AceDB, AO.AceDBOptions, AO.AceConfig, AO.AceConfigDialog

local C, P, BF = O.Config, O.Profile, O.ButtonFactory
local libModules = { C, P, BF }

---@type PopupDebugDialog
local popupDebugDialog

---@type LoggerTemplate
local p = LogFactory()

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
local function OnAddonLoaded(frame, event, ...)
    local isLogin, isReload = ...
    if event ~= GC.E.PLAYER_ENTERING_WORLD then return end

    ---@type ActionbarPlus
    local addon = frame.obj
    addon:OnAddonLoadedModules()

    if UnitOnTaxi(GC.UnitId.player) == true then
        local isShown = WMX:IsHideWhenTaxi() ~= true
        WMX:ShowActionbarsDelayed(isShown, 3)
    end

    BF:Fire(GC.E.OnAddonLoaded)

    --@debug@
    isLogin = true
    --@end-debug@

    if not isLogin then return end
    local versionText, curseForge, githubIssues = GC:GetAddonInfo()
    p:log("%s %s", versionText, ABP_INITIALIZED_TEXT)

end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@class ActionbarPlus_Methods
---@type string
local methods = {
    ['ShowActionbars'] = function(self, isShown)
        WMX:ShowActionbarsDelayed(isShown, 1)
    end,
    ---@param self ActionbarPlus
    ['RegisterSlashCommands'] = function(self)
        self:RegisterChatCommand("abp", "SlashCommands")
    end,
    ---@param self ActionbarPlus
    ['RegisterHooks'] = function(self)
        local f = SettingsPanel or InterfaceOptionsFrame
        if f then self:HookScript(f, 'OnHide', 'OnHide_Config_WithoutSound') end
    end,
    ---@param self ActionbarPlus
    ---@param spaceSeparatedArgs string
    ['SlashCommands'] = function(self, spaceSeparatedArgs)
        local args = parseSpaceSeparatedVar(spaceSeparatedArgs)
        if IsEmptyTable(args) then self:SlashCommand_Help_Handler(); return end
        if IsAnyOf('config', unpack(args))
                or IsAnyOf('conf', unpack(args)) then
            self:OpenConfig();
            return
        end
        if IsAnyOf('info', unpack(args)) then self:SlashCommand_Info_Handler(spaceSeparatedArgs); return end
        self:SlashCommand_Help_Handler()
    end,
    ---@param self ActionbarPlus
    ['SlashCommand_Help_Handler'] = function(self)
        p:log('')
        p:log(GCC.ABP_CONSOLE_HEADER_FORMAT, ABP_AVAILABLE_CONSOLE_COMMANDS_TEXT)
        p:log(ABP_USAGE_LABEL)
        p:log(ABP_OPTIONS_LABEL)
        p:log(GCC.ABP_CONSOLE_OPTIONS_FORMAT, 'config', ABP_COMMAND_CONFIG_TEXT)
        p:log(GCC.ABP_CONSOLE_OPTIONS_FORMAT, 'info', ABP_COMMAND_INFO_TEXT)
        --p:log(GCC.ABP_CONSOLE_OPTIONS_FORMAT, 'macros', 'Enable macro edit mode')
        p:log(GCC.ABP_CONSOLE_OPTIONS_FORMAT, 'help', ABP_COMMAND_HELP_TEXT)
    end,
    ---@param self ActionbarPlus
    ---@param spaceSeparatedArgs string
    ['SlashCommand_Info_Handler'] = function(self, spaceSeparatedArgs)
        p:log(GC:GetAddonInfoFormatted())
    end,
    ---@param self ActionbarPlus
    ---@param optionalLabel string
    ---@param obj table An arbitrary object
    ['ShowDebugDialog'] = function(self, obj, optionalLabel)
        local text
        local label = optionalLabel or ''
        if type(obj) ~= 'string' then
            text = pformat:A():pformat(obj)
        else
            text = obj
        end
        popupDebugDialog:SetTextContent(text)
        popupDebugDialog:SetStatusText(label)
        popupDebugDialog:Show()
    end,
    ---@param self ActionbarPlus
    ['ConfirmReloadUI'] = function(self)
        if IsShiftKeyDown() then
            ReloadUI()
            return
        end
        WMX:ShowReloadUIConfirmation()
    end,
    ---@param self ActionbarPlus
    ['OpenConfig'] = function(self, sourceFrameWidget)
        --select the frame config tab if possible
        local optionsConfigPath
        if sourceFrameWidget and sourceFrameWidget.GetFrameIndex  then
            optionsConfigPath = 'bar' .. sourceFrameWidget:GetFrameIndex()
        end
        if optionsConfigPath ~= nil then
            AceConfigDialog:SelectGroup(ADDON_NAME, optionsConfigPath)
        end
        AceConfigDialog:Open(ADDON_NAME, self.configFrame)
        self.onHideHooked = self.onHideHooked or false
        self.configDialogWidget = AceConfigDialog.OpenFrames[ADDON_NAME]

        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
        if not self.onHideHooked then
            self:HookScript(self.configDialogWidget.frame, 'OnHide', 'OnHide_Config_WithSound')
            self.onHideHooked = true
        end
    end,
    ---@param self ActionbarPlus
    ['OnHide_Config_WithSound'] = function(self) self:OnHide_Config(true) end,
    ---@param self ActionbarPlus
    ['OnHide_Config_WithoutSound'] = function(self) self:OnHide_Config() end,
    ---@param self ActionbarPlus
    ['OnHide_Config'] = function(self, enableSound)
        enableSound = enableSound or false
        p:log(10, 'OnHide_Config called with enableSound=%s', tostring(enableSound))
        if true == enableSound then PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE) end
    end,
    ---@param self ActionbarPlus
    ['OnUpdate'] = function(self) p:log('OnUpdate called...') end,
    ---@param self ActionbarPlus
    ['OnProfileChanged'] = function(self) self:ConfirmReloadUI() end,
    ---@param self ActionbarPlus
    ['InitDbDefaults'] = function(self)
        local profileName = self.db:GetCurrentProfile()
        local defaultProfile = P:CreateDefaultProfile(profileName)
        local defaults = { profile =  defaultProfile }
        self.db:RegisterDefaults(defaults)
        self.profile = self.db.profile
        if IsEmptyTable(ABP_PLUS_DB.profiles[profileName]) then
            ABP_PLUS_DB.profiles[profileName] = defaultProfile
            --error(profileName .. ': ' .. ABP_Table.toStringSorted(ABP_PLUS_DB.profiles[profileName]))
        end
    end,
    ---@param self ActionbarPlus
    ['GetCurrentProfileData'] = function(self) return self.profile end,
    ---@param self ActionbarPlus
    ['OnInitializeModules'] = function(self)
        for _, module in ipairs(libModules) do
            -- self.profile set earlier; see _Core#OnInitialize
            module:OnInitialize{ addon = self }
        end
    end,
    ---@param self ActionbarPlus
    ['OnAddonLoadedModules'] = function(self)
        for _, module in ipairs(libModules) do
            module:OnAddonLoaded()
        end
    end,
    ---@param self ActionbarPlus
    ['OnInitialize'] = function(self)
        -- Set up our database
        self.db = AceDB:New(GC.C.DB_NAME)
        self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
        self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
        self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
        self:InitDbDefaults()

        popupDebugDialog = PopupDebugDialog()

        self.barBindings = WMX:GetBarBindingsMap()
        self:OnInitializeModules()

        local options = C:GetOptions()
        -- Register options table and slash command
        AceConfig:RegisterOptionsTable(ADDON_NAME, options, { "abp_options" })
        AceConfigDialog:AddToBlizOptions(ADDON_NAME, ADDON_NAME)
        -- Use this to set the default size
        --AceConfigDialog:SetDefaultSize(ADDON_NAME, 800, 500)

        -- Get the option table for profiles
        options.args.profiles = AceDBOptions:GetOptionsTable(self.db)
        self:RegisterSlashCommands()
        self:RegisterHooks()
        self:SendMessage(GC.E.AddonMessage_OnAfterInitialize, self)
    end
}

---@return ActionbarPlus_Frame
---@param addon ActionbarPlus|ActionbarPlusEventMixin
local function CreateAddonFrame(addon)

    local E = GC.E

    ---@class ActionbarPlus_Frame : _Frame
    local frame = CreateFrame("Frame", FRAME_NAME, UIParent)
    addon.frame = frame

    frame:SetScript(E.OnEvent, OnAddonLoaded)
    frame:RegisterEvent(E.PLAYER_ENTERING_WORLD)

    ---@class ActionbarPlusEvent : ActionbarPlusEventMixin
    local addonEvents = MX:MixinAndInit(O.ActionbarPlusEventMixin, addon)
    addon.addonEvents = addonEvents

    frame.obj = addon
    return frame
end

--[[-----------------------------------------------------------------------------
New Addon Instance
-------------------------------------------------------------------------------]]
---@return ActionbarPlus
local function NewInstance()
    ---@class ActionbarPlus : ActionbarPlus_Methods
    local A = LibStub:NewAddon(GC.C.ADDON_NAME)
    CreateAddonFrame(A)
    MX:Mixin(A, methods)
    A.ActionbarEmptyGridShowing = false

    return A
end

ABP = NewInstance()
