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
local ALF, GC = O.AceLibFactory, O.GlobalConstants

local ADDON_NAME = Core.addonName
local FRAME_NAME = ADDON_NAME .. "Frame"

local Table, LogFactory = O.Table, O.LogFactory
local IsEmptyTable, parseSpaceSeparatedVar = Table.isEmpty, Table.parseSpaceSeparatedVar
local IsBlank = O.String.IsBlank
local MX, WMX, DebugDialog = O.Mixin, O.WidgetMixin, O.DebugDialog

local AceDB, AceDBOptions = ALF:GetAceDB(), ALF:GetAceDBOptions()
local AceConfig, AceConfigDialog = ALF:GetAceConfig(), ALF:GetAceConfigDialog()

local C, P, BF = O.Config, O.Profile, O.ButtonFactory
local libModules = { C, P, BF }

---@type DebugDialog
local debugDialog

---@type LoggerTemplate
local p = LogFactory()

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
local function OnUpdateBindings(addon)
    addon.barBindings = WMX:GetBarBindingsMap()
    if addon.barBindings then BF:UpdateKeybindText() end
end

local function OnAddonLoaded(frame, event, ...)
    local isLogin, isReload = ...

    ---@type ActionbarPlus
    local addon = frame.obj
    if event == GC.E.UPDATE_BINDINGS then return OnUpdateBindings(addon) end

    addon:OnAddonLoadedModules()

    --p:log(10, 'IsLogin: %s IsReload: %s', isLogin, isReload)
    if UnitOnTaxi('player') == true then
        local hideWhenTaxi = WMX:IsHideWhenTaxi()
        --p:log(10, 'Hide-When-Taxi: %s', hideWhenTaxi)
        WMX:SetEnabledActionBarStatesDelayed(not hideWhenTaxi, 3)
    end
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

---@param literalVarName string
local function evalValue(literalVarName)
    if IsBlank(literalVarName) then return end
    local scriptToEval = format([[ return %s]], literalVarName)
    local func, errorMessage = loadstring(scriptToEval, "Eval-Variable")
    local val = func()
    if type(val) == 'function' then
        local status, error = pcall(function() val = val() end)
        if not status then
            val = nil
        end
    end
    return val
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@class ActionbarPlus_Methods
local methods = {
    ---@param self ActionbarPlus
    ['RegisterSlashCommands'] = function(self)
        self:RegisterChatCommand("abp", "OpenConfig")
        --@debug@--
        self:RegisterChatCommand("cv", "SlashCommand_CheckVariable")
        --@end-debug@--
    end,
    ---@param self ActionbarPlus
    ['SlashCommand_CheckVariable'] = function(self, spaceSeparatedArgs)
        --TODO: NEXT: Move to DevTools addon
        local vars = parseSpaceSeparatedVar(spaceSeparatedArgs)
        if IsEmptyTable(vars) then return end
        local firstVar = vars[1]

        if firstVar == '<profile>' then
            self:HandleSlashCommand_ShowProfile()
            return
        end

        local strVal = evalValue(firstVar)
        debugDialog:SetTextContent(pformat:A()(strVal))
        debugDialog:SetStatusText(sformat('Var: %s type: %s', firstVar, type(strVal)))
        debugDialog:Show()
    end,
    ---@param self ActionbarPlus
    ['HandleSlashCommand_ShowProfile'] = function(self)
        local profileData = self:GetCurrentProfileData()
        local strVal = pformat:A():pformat(profileData)
        local profileName = self.db:GetCurrentProfile()
        debugDialog:SetTextContent(strVal)
        debugDialog:SetStatusText(sformat('Current Profile Data for [%s]', profileName))
        debugDialog:Show()
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
        debugDialog:SetTextContent(text)
        debugDialog:SetStatusText(label)
        debugDialog:Show()
    end,
    ---@param self ActionbarPlus
    ['DBG'] = function(self, obj, optionalLabel) self:ShowDebugDialog(obj, optionalLabel)  end,
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

        debugDialog = DebugDialog()

        self.barBindings = WMX:GetBarBindingsMap()
        self:OnInitializeModules()

        local options = C:GetOptions()
        -- Register options table and slash command
        AceConfig:RegisterOptionsTable(ADDON_NAME, options, { "abp_options" })
        --cfgDialog:SetDefaultSize(ADDON_NAME, 800, 500)
        AceConfigDialog:AddToBlizOptions(ADDON_NAME, ADDON_NAME)

        -- Get the option table for profiles
        options.args.profiles = AceDBOptions:GetOptionsTable(self.db)
        self:RegisterSlashCommands()
    end
}

---@return ActionbarPlus_Frame
---@param addon ActionbarPlus
local function CreateAddonFrame(addon)
    local E = GC.E
    ---@class ActionbarPlus_Frame
    local frame = CreateFrame("Frame", FRAME_NAME, UIParent)
    frame:SetScript(E.OnEvent, OnAddonLoaded)
    frame:RegisterEvent(E.PLAYER_ENTERING_WORLD)
    frame:RegisterEvent(E.UPDATE_BINDINGS)
    addon.frame = frame
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
