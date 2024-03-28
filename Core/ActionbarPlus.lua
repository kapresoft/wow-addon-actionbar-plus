--[[-----------------------------------------------------------------------------
Alias
-------------------------------------------------------------------------------]]
--- @alias AddOnEvents  AceEvent | AceHook | AceConsole

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local unpack = unpack
local sformat, loadstring, format = string.format, loadstring, format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local ReloadUI, IsShiftKeyDown, UnitOnTaxi = ReloadUI, IsShiftKeyDown, UnitOnTaxi
local UIParent, CreateFrame = UIParent, CreateFrame
local InterfaceOptionsFrame, PlaySound, SOUNDKIT = InterfaceOptionsFrame, PlaySound, SOUNDKIT

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, LibStub = ns.O, ns.GC, ns.LibStub

local AO = O.AceLibFactory:A()
local GCC, M = GC.C, GC.M

local String, Table = O.String, O.Table
local IsEmptyTable, parseSpaceSeparatedVar = Table.isEmpty, Table.parseSpaceSeparatedVar
local IsBlank, IsAnyOf = String.IsBlank, String.IsAnyOf
local MX, WMX, BF = O.Mixin, O.WidgetMixin, O.ButtonFactory

local AceDB, AceConfigDialog = AO.AceDB, AO.AceConfigDialog
local P = O.Profile
local p, pd = ns:LC().ADDON:NewLogger(ns.name), ns:CreateDefaultLogger(ns.name)

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
--- @param frame ActionbarPlus_Frame
local function OnPlayerEnteringWorld(frame, event, ...)
    local isLogin, isReload = ...
    if event ~= GC.E.PLAYER_ENTERING_WORLD then return end

    if UnitOnTaxi(GC.UnitId.player) == true then
        local isShown = WMX:IsHideWhenTaxi() ~= true
        WMX:ShowActionbarsDelayed(isShown, 3)
        p:d(function() return "OnPlayerEnteringWorld(): Calling ShowActionbarsDelayed..." end)
    end
    p:d(function() return "OnPlayerEnteringWorld(): Sending message [%s]", M.OnAddOnReady end)
    frame.ctx.addon:SendMessage(M.OnAddOnReady, ns.name)

    --@debug@
    isLogin = true
    --@end-debug@

    if not isLogin then return end
    pd:vv(GC:GetMessageLoadedText())
end

--- @return ActionbarPlus_Frame
--- @param addon ActionbarPlus|ActionbarPlusEventMixin
local function RegisterEvents(addon)

    --- @class ActionbarPlus_Frame : _Frame
    local frame = CreateFrame("Frame", nil, UIParent)
    frame.ctx = { addon = addon }

    local E = GC.E
    frame:SetScript(E.OnEvent, OnPlayerEnteringWorld)
    frame:RegisterEvent(E.PLAYER_ENTERING_WORLD)

    --- @class ActionbarPlusEvent : ActionbarPlusEventMixin
    local addonEvents = ns:K():CreateAndInitFromMixin(O.ActionbarPlusEventMixin, addon)
    addon.addonEvents = addonEvents

    return frame
end

--- @return boolean
local function isConfigHidden()
    local fw = AceConfigDialog.OpenFrames[ns.name]; if not fw then return true end
    --- @type Frame
    local f = fw.frame; return f:IsVisible() ~= true
end
--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @class ActionbarPlus_Methods : ActionbarPlusProperties
--- @type string
local methods = {
    --- @param self ActionbarPlus
    --- @param isShown boolean
    ['ShowActionbars'] = function(self, isShown)
        WMX:ShowActionbarsDelayed(isShown, 1)
    end,
    --- @param self ActionbarPlus
    ['RegisterSlashCommands'] = function(self)
        self:RegisterChatCommand(GCC.CONSOLE_COMMAND_NAME, "SlashCommands")
        self:RegisterChatCommand(GCC.CONSOLE_COMMAND_SHORT, "SlashCommands")
    end,
    --- @param self ActionbarPlus
    --- @param spaceSeparatedArgs string
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
    --- @param self ActionbarPlus
    ['SlashCommand_Help_Handler'] = function(self)
        local C = GC:GetAceLocale()
        pd:vv('')
        pd:vv(function() return GCC.ABP_CONSOLE_HEADER_FORMAT, C['Available console commands'] end)
        pd:vv(function() return '%s:  /abp [%s]', C['usage'], C['options'] end)
        pd:vv(function() return '%s:', C['options'] end)
        pd:vv(function() return GCC.ABP_CONSOLE_OPTIONS_FORMAT, 'config', C['Shows the config UI (default)'] end)
        pd:vv(function() return GCC.ABP_CONSOLE_OPTIONS_FORMAT, 'info', C['Info Console Command Text'] end)
        pd:vv(function() return GCC.ABP_CONSOLE_OPTIONS_FORMAT, 'help', C['Shows this help'] end)
    end,
    --- @param self ActionbarPlus
    --- @param spaceSeparatedArgs string
    ['SlashCommand_Info_Handler'] = function(self, spaceSeparatedArgs)
        pd:vv(GC:GetAddonInfoFormatted())
    end,
    --- @param self ActionbarPlus
    ['ConfirmReloadUI'] = function(self)
        if IsShiftKeyDown() then
            ReloadUI()
            return
        end
        WMX:ShowReloadUIConfirmation()
    end,

    --- @param self ActionbarPlus
    ['InitializeDb'] = function(self)
        -- Set up our database
        --- @type ActionbarPlus_AceDB
        self.db = AceDB:New(GC.C.DB_NAME)
        ns.db = self.db
        self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
        self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
        self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
        self:InitDbDefaults()
        self:SendMessage(M.OnDBInitialized, ns.name)
    end,

    --- @param self ActionbarPlus
    ['InitDefaultProfile'] = function(self)
        local defaultProfile = P:CreateDefaultProfile()
        self.defaultDB = { profile =  defaultProfile }
        self.db:RegisterDefaults(self.defaultDB)
    end,

    --- @param self ActionbarPlus
    ['InitDbDefaults'] = function(self)
        self:InitDefaultProfile()
    end,
    --- @see ActionbarPlusEventMixin
    ['RetrieveKeyBindingsMap'] = function(self)
        self.barBindings = WMX:GetBarBindingsMap()
    end,
    ['UpdateKeyBindings'] = function(self)
        self.barBindings = WMX:GetBarBindingsMap()
        if self.barBindings then BF:UpdateKeybindText() end
    end,

}
--- @param o ActionbarPlus | AddOnEvents
local function AdditionalMethods(o)

    --- This is called automatically by Ace
    function o:OnInitialize()
        self:InitializeDb()
        self:RegisterSlashCommands()
        self:SendMessage(M.OnAddOnInitialized, ns.name)

        if ns.features.enableV2 ~= true then return end
        p:d(function() return 'OnInitialize(): IsV2Enabled: %s', tostring(ns.features.enableV2) end)
        self:SendMessage(M.OnAddOnInitializedV2, ns.name)
        p:d(function() return 'OnInitialize():MSG:OnAddOnInitializedV2 Sent' end)
    end

    --- This is called automatically by Ace
    --- Called during the PLAYER_LOGIN
    --- #### See Also: [Ace-addon-3-0](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0)
    function o:OnEnable()
        -- Do more initialization here, that really enables the use of your addon.
        -- Register Events, Hook functions, Create Frames, Get information from
        -- the game that wasn't available in OnInitialize
        self:RegisterHooks()
        self:SendMessage(M.OnAddOnEnabled, ns.name, self)
        if ns.features.enableV2 ~= true then return end

        self:SendMessage(M.OnAddOnEnabledV2, ns.name, self)
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
        pd:vv(GC:GetAddonInfoFormatted())
    end

    function o:ConfirmReloadUI()
        if IsShiftKeyDown() then ReloadUI(); return end
        WMX:ShowReloadUIConfirmation()
    end

    function o:OpenConfig(sourceFrameWidget)
        --select the frame config tab if possible
        local optionsConfigPath
        if sourceFrameWidget and sourceFrameWidget.GetFrameIndex  then
            optionsConfigPath = 'bar' .. sourceFrameWidget:GetFrameIndex()
        else optionsConfigPath = 'general' end

        AceConfigDialog:SelectGroup(ns.name, optionsConfigPath)
        local hidden = isConfigHidden()
        if hidden == true then
            self:DialogGlitchHack(optionsConfigPath)
            AceConfigDialog:Open(ns.name, self.configFrame)
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
        end

        self.onHideHooked = self.onHideHooked == true or false

        self.configDialogWidget = AceConfigDialog.OpenFrames[ns.name]
        if not self.configDialogWidget then return end
        if self.onHideHooked == true then return end

        --- @type Frame
        local frame = self.configDialogWidget and self.configDialogWidget.frame
        if frame and self.onHideHooked ~= true then
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
        if ns.name ~= name then return end
        self:OnHideSettings(true)
    end

    function o:OnHideBlizzardOptions()
        self:OnHideSettings(false)
    end

    --- @param enableSound boolean|nil
    function o:OnHideSettings(enableSound)
        enableSound = enableSound or false
        p:d(function() return 'OnHideSettings[%s] sound=%s', ns.name, enableSound end)
        if true == enableSound then PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE) end
    end

    --- This hacks solves the range UI notch not positioning properly
    function o:DialogGlitchHack(group)
        local sgroup = group or 'general'
        AceConfigDialog:SelectGroup(ns.name, "debugging")
        AceConfigDialog:Open(ns.name)
        C_Timer.After(0.01, function()
            AceConfigDialog:ConfigTableChanged('anyEvent', ns.name)
            AceConfigDialog:SelectGroup(ns.name, sgroup)
        end)
    end
end

--[[-----------------------------------------------------------------------------
New Addon Instance
-------------------------------------------------------------------------------]]
--- @return ActionbarPlus
local function NewInstance()
    --- @class ActionbarPlus : ActionbarPlus_Methods
    local A = LibStub:NewAddon(ns.name)
    --- The mountID for C_MountJournal Pickup Support
    --- @see APIHooks
    A.mountID = nil
    A.companionID = nil
    MX:Mixin(A, methods)
    AdditionalMethods(A)
    A.ActionbarEmptyGridShowing = false

    RegisterEvents(A)

    return A
end
if ABP then return end; ABP = NewInstance()
