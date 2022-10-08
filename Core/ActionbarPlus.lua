--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local ReloadUI, IsShiftKeyDown, UnitOnTaxi = ReloadUI, IsShiftKeyDown, UnitOnTaxi
local UIParent, CreateFrame = UIParent, CreateFrame
--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat, loadstring, format = string.format, loadstring, format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
-- Bump this version for every release tag
--
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local GC, AO = O.GlobalConstants, O.AceLibFactory:A()
local ADDON_NAME = Core.addonName
local FRAME_NAME = ADDON_NAME .. "Frame"

local Table, LogFactory = O.Table, O.LogFactory
local IsEmptyTable, parseSpaceSeparatedVar = Table.isEmpty, Table.parseSpaceSeparatedVar
local IsBlank = O.String.IsBlank
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
    if not ('PLAYER_ENTERING_WORLD') then return end

    ---@type ActionbarPlus
    local addon = frame.obj
    addon:OnAddonLoadedModules()

    if UnitOnTaxi('player') == true then
        local hideWhenTaxi = WMX:IsHideWhenTaxi()
        WMX:SetEnabledActionBarStatesDelayed(not hideWhenTaxi, 3)
    end

    BF:Fire(GC.E.OnAddonLoaded)

    --@debug@
    isLogin = true
    --@end-debug@

    if not isLogin then return end
    local versionText, curseForge, githubIssues = GC:GetAddonInfo()
    p:log("%s initialized", versionText)
    p:log('Available commands: /abp to open config dialog.')
    p:log('Right-click on the button drag frame to open config dialog.')
    p:log('Curse Forge: %s', curseForge)
    p:log('Issues: %s', githubIssues)

end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@class ActionbarPlus_Methods
local methods = {
    ---@param self ActionbarPlus
    ['RegisterSlashCommands'] = function(self)
        self:RegisterChatCommand("abp", "OpenConfig")
        self:RegisterChatCommand("cv", "SlashCommand_CheckVariable")
    end,
    ---@param self ActionbarPlus
    ['SlashCommand_CheckVariable'] = function(self, spaceSeparatedArgs)
        local vars = parseSpaceSeparatedVar(spaceSeparatedArgs)
        if IsEmptyTable(vars) then
            p:log(GC.C.ABP_CHECK_VAR_SYNTAX_FORMAT, "Variable Checker Syntax", "/cv <var-name>")
            p:log(GC.C.ABP_CHECK_VAR_SYNTAX_FORMAT, "Example", "/cv <profile> or /cv ABP.profile")
            return
        end

        local firstArg = vars[1]
        if firstArg == '<profile>' then
            local profileData = self:GetCurrentProfileData()
            local profileName = self.db:GetCurrentProfile()
            popupDebugDialog:EvalObjectThenShow(profileData, profileName)
            return
        end

        popupDebugDialog:EvalThenShow(firstArg)
    end,
    ---@param self ActionbarPlus
    ['ShowDebugDialog'] = function(self, obj, optionalLabel)
        local text = nil
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
        local optionsConfigPath = nil
        if sourceFrameWidget and sourceFrameWidget.GetFrameIndex  then
            optionsConfigPath = 'bar' .. sourceFrameWidget:GetFrameIndex()
        end
        if optionsConfigPath ~= nil then
            AceConfigDialog:SelectGroup(ADDON_NAME, optionsConfigPath)
        end
        AceConfigDialog:Open(ADDON_NAME)
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

    local addonEvents = MX:MixinAndInit(O.ActionbarPlusEventMixin, addon)
    addonEvents:RegisterEvents()

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

    return A
end

ABP = NewInstance()
