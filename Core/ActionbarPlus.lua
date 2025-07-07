--[[-----------------------------------------------------------------------------
Alias
-------------------------------------------------------------------------------]]
--- @alias AddOnEvents  AceEvent | AceHook | AceConsole

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local unpack = unpack

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local ReloadUI, IsShiftKeyDown = ReloadUI, IsShiftKeyDown
local InterfaceOptionsFrame, PlaySound, SOUNDKIT = InterfaceOptionsFrame, PlaySound, SOUNDKIT

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...); local addon = ns.addon
local O, GC, LibStub = ns.O, ns.GC, ns.LibStub
local AO = ns:KO().AceLibrary.O
local GCC, M = GC.C, GC.M

local String, Table = ns:String(), ns:Table()
local IsEmptyTable, parseSpaceSeparatedVar = Table.isEmpty, Table.parseSpaceSeparatedVar
local IsBlank, IsAnyOf = String.IsBlank, String.IsAnyOf
local WMX, BF = O.WidgetMixin, O.ButtonFactory

local AceDB, AceConfigDialog = AO.AceDB, AO.AceConfigDialog
local P = O.Profile
local p, pd = ns:LC().ADDON:NewLogger(addon), ns:CreateDefaultLogger(addon)

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
--- @return boolean
local function isConfigHidden()
    local fw = AceConfigDialog.OpenFrames[addon]; if not fw then return true end
    --- @type Frame
    local f = fw.frame; return f:IsVisible() ~= true
end
--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o ActionbarPlus | AddOnEvents
local function PropertiesAndMethods(o)

    --- The mountID for C_MountJournal Pickup Support
    --- @see APIHooks
    o.mountID = nil
    o.companionID = nil
    o.ActionbarEmptyGridShowing = false


    --- This is called automatically by Ace
    function o:OnInitialize()
        self:InitializeDb()
        self:RegisterSlashCommands()
        self:SendMessage(M.OnAddOnInitialized, addon)

        if ns.features.enableV2 ~= true then return end
        p:d(function() return 'OnInitialize(): IsV2Enabled: %s', tostring(ns.features.enableV2) end)
        self:SendMessage(M.OnAddOnInitializedV2, addon)
        p:d(function() return 'OnInitialize():MSG:OnAddOnInitializedV2 Sent' end)
    end

    function o:InitializeDb()
        -- Set up our database
        --- @type ActionbarPlus_AceDB
        self.db = AceDB:New(GC.C.DB_NAME)
        ns.db = self.db
        self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
        self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
        self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
        self:InitDbDefaults()
        self:SendMessage(M.OnDBInitialized, addon)
    end

    function o:InitDefaultProfile()
        local defaultProfile = P:CreateDefaultProfile()
        self.defaultDB = { profile =  defaultProfile }
        self.db:RegisterDefaults(self.defaultDB)
    end

    function o:InitDbDefaults() self:InitDefaultProfile() end
    function o:RetrieveKeyBindingsMap() self.barBindings = WMX:GetBarBindingsMap() end

    function o:RegisterSlashCommands()
        self:RegisterChatCommand(GCC.CONSOLE_COMMAND_NAME, "SlashCommands")
        self:RegisterChatCommand(GCC.CONSOLE_COMMAND_SHORT, "SlashCommands")
    end

    --@end-do-not-package@

    --- @param spaceSeparatedArgs string
    function o:SlashCommands(spaceSeparatedArgs)
        local args = parseSpaceSeparatedVar(spaceSeparatedArgs)
        if IsEmptyTable(args) then self:SlashCommand_Help_Handler(); return end
        if IsAnyOf('config', unpack(args))
            or IsAnyOf('conf', unpack(args)) then
            self:OpenConfig();
            return
        end
        if IsAnyOf('clear', unpack(args)) then return self:SlashCommand_ClearConsole_Handler() end
        if IsAnyOf('info', unpack(args)) then return self:SlashCommand_Info_Handler() end
        self:SlashCommand_Help_Handler()
    end

    function o:SlashCommand_Help_Handler()
        local C = GC:GetAceLocale()
        pd:a('')
        pd:a(function() return GCC.ABP_CONSOLE_HEADER_FORMAT, C['Available console commands'] end)
        pd:a(function() return '%s:  /abp [%s]', C['usage'], C['options'] end)
        pd:a(function() return '%s:', C['options'] end)
        pd:a(function() return GCC.ABP_CONSOLE_OPTIONS_FORMAT, 'config', C['Shows the config UI (default)'] end)
        pd:a(function() return GCC.ABP_CONSOLE_OPTIONS_FORMAT, 'info', C['Info Console Command Text'] end)
        pd:a(function() return GCC.ABP_CONSOLE_OPTIONS_FORMAT, 'help', C['Shows this help'] end)
    end

    function o:SlashCommand_Info_Handler() pd:vv(GC:GetAddonInfoFormatted()) end
    function o:SlashCommand_ClearConsole_Handler() return ns.chatFrame and ns.chatFrame:Clear() end

    function o:ConfirmReloadUI()
        if IsShiftKeyDown() then
            ReloadUI()
            return
        end
        WMX:ShowReloadUIConfirmation()
    end

    -- TODO: Migrate to a new KeyBindingsController
    function o:UpdateKeyBindings()
        self.barBindings = WMX:GetBarBindingsMap()
        if self.barBindings then BF:UpdateKeybindText() end
    end

    --- This is called automatically by Ace
    --- Called during the PLAYER_LOGIN
    --- #### See Also: [Ace-addon-3-0](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0)
    function o:OnEnable()
        -- Do more initialization here, that really enables the use of your addon.
        -- Register Events, Hook functions, Create Frames, Get information from
        -- the game that wasn't available in OnInitialize
        self:RegisterHooks()
        self:SendMessage(M.OnAddOnEnabled, addon, self)
        if ns.features.enableV2 ~= true then return end

        self:SendMessage(M.OnAddOnEnabledV2, addon, self)
        p:d('OnEnable():MSG:OnAddOnEnabledV2 Sent')
    end

    function o:OnProfileChanged() self:ConfirmReloadUI() end

    --- This is for AceConfigDialog.BlizOptions[appName]
    function o:RegisterHooks()
        local f = SettingsPanel or InterfaceOptionsFrame
        if f then self:HookScript(f, 'OnHide', 'OnHideBlizzardOptions') end
    end

    --- @vararg any
    function o:SmartMount(...)
        local flying,ground = ...
        p:d(function() return "flying=%s ground=%s", flying, ground end)
        if 'string' == type(flying) and 'string' == type(ground) then
            O.API:SummonMountSimple(flying, ground)
        end
    end

    --- @param spaceSeparatedArgs string
    function o:SlashCommand_Info_Handler(spaceSeparatedArgs)
        pd:a(GC:GetAddonInfoFormatted())
    end

    function o:ConfirmReloadUI()
        if IsShiftKeyDown() then ReloadUI(); return end
        WMX:ShowReloadUIConfirmation()
    end

    --- @param sourceFrameWidget FrameWidget
    function o:OpenConfig(sourceFrameWidget)
        --select the frame config tab if possible
        local optionsConfigPath
        if sourceFrameWidget and sourceFrameWidget.GetIndex  then
            optionsConfigPath = 'bar' .. sourceFrameWidget:GetIndex()
        else optionsConfigPath = 'general' end

        -- TODO: For Development
        -- optionsConfigPath = 'debugging'

        AceConfigDialog:SelectGroup(addon, optionsConfigPath)
        local hidden = isConfigHidden()
        if hidden == true then
            self:DialogGlitchHack(optionsConfigPath)
            AceConfigDialog:Open(addon, self.configFrame)
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
        end

        self.onHideHooked = self.onHideHooked == true or false

        self.configDialogWidget = AceConfigDialog.OpenFrames[addon]
        if not self.configDialogWidget then return end
        if self.onHideHooked == true then return end

        --- @type Frame
        local frame = self.configDialogWidget and self.configDialogWidget.frame
        if frame and self.onHideHooked ~= true then
            -- Set the frame strata above "LOW" or equal to "DIALOG"
            -- because we want it to show behind the confirm dialog.
            frame:SetFrameStrata('MEDIUM')
            frame:SetFrameLevel(0)
            local success, msg = pcall(function()
                self:HookScript(frame, 'OnHide', function()
                    self:OnHide(frame, self.configDialogWidget:GetUserData('appName'))
                    self.onHideHooked = true
                end)
            end)
            if success ~= true then p:f3(function() return "onHideHookFailed: %s", msg end) end
        end
    end

    --- Since AceConfigDialog caches the frames, we want to make sure the appName is this addOn
    --- @param name Name The appName
    --- @param frame Frame
    function o:OnHide(frame, name)
        if addon ~= name then return end
        self:OnHideSettings(true)
    end

    function o:OnHideBlizzardOptions()
        self:OnHideSettings(false)
    end

    --- @param enableSound boolean|nil
    function o:OnHideSettings(enableSound)
        enableSound = enableSound or false
        p:d(function() return 'OnHideSettings[%s] sound=%s', addon, enableSound end)
        if true == enableSound then PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE) end
    end

    --- This hacks solves the range UI notch not positioning properly
    function o:DialogGlitchHack(group)
        local sgroup = group or 'general'
        AceConfigDialog:SelectGroup(addon, "debugging")
        AceConfigDialog:Open(addon)
        C_Timer.After(0.01, function()
            AceConfigDialog:ConfigTableChanged('anyEvent', addon)
            AceConfigDialog:SelectGroup(addon, sgroup)
        end)
    end
end
--[[-----------------------------------------------------------------------------
New Addon Instance
-------------------------------------------------------------------------------]]
--- @return ActionbarPlus
local function NewInstance()
    --- @class ActionbarPlus
    local A = LibStub:NewAddon(addon); PropertiesAndMethods(A)
    function A.ns() return ns end
    return A
end
if ABP then return end; ABP = NewInstance()
