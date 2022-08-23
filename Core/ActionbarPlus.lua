--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local ConfigureFrameToCloseOnEscapeKey = ConfigureFrameToCloseOnEscapeKey
local ReloadUI, IsShiftKeyDown, UnitOnTaxi = ReloadUI, IsShiftKeyDown, UnitOnTaxi
local UIParent, CreateFrame = UIParent, CreateFrame
--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local unpack, format = unpack, string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
-- Bump this version for every release tag
--
local LibStub, M, AceLibFactory, W, ProfileInitializer, G = ABP_LibGlobals:LibPack_NewAddon()
local ADDON_NAME = G.addonName
local FRAME_NAME = ADDON_NAME .. "Frame"

local PrettyPrint, Table, String, LogFactory = G:LibPackUtils()
local isEmpty = Table.isEmpty
local DEBUG_DIALOG_GLOBAL_FRAME_NAME = 'ABP_DebugPopupDialogFrame'
local TextureDialog = W:GetMacroTextureDialog()
local WU = ABP_WidgetUtil

-- ## Addon ----------------------------------------------------
-----class ActionbarPlus
--local A = LibStub:NewAddon(G.addonName)
--if not A then return end
--LogFactory:EmbedLogger(A)
local ACE_DB, ACE_DBO, ACE_CFG, ACE_CFGD = ABP_LibGlobals:LibPack_AceAddonLibs()
local C, P, BF = W:LibPack_AddonLibs()
local libModules = { C, P, BF }
local debugDialog

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
---- TODO: Move to ABP_WidgetUtil
--function getBindingByName(bindingName)
--    local bindCount = GetNumBindings()
--    if bindCount <=0 then return nil end
--
--    for i = 1, bindCount do
--        local command,cat,key1,key2 = GetBinding(i)
--        if bindingName == command then
--            return { name = command, category = cat, key1 = key1, key2 = key2 }
--        end
--    end
--    return nil
--end
--
---- TODO: Move to ABP_WidgetUtil
--function GetBarBindings(beginsWith)
--    local bindCount = GetNumBindings()
--    if bindCount <=0 then return nil end
--
--    --print('beginsWith:', beginsWith)
--    -- key: name, value: binding obj
--    local bindings = {}
--    for i = 1, bindCount do
--        local command,cat,key1,key2 = GetBinding(i)
--        --print('bindingName: ', command)
--        if string.find(command, beginsWith) then
--            local value = { name = command, category = cat, key1 = key1, key2 = key2 }
--            local keyName = 'BINDING_NAME_' .. command
--            local key = _G[keyName]
--            if key then
--                bindings[key] = value
--            end
--        end
--    end
--    return bindings
--end


local function OnUpdateBindings(addon)
    addon.barBindings = WU:GetBarBindingsMap()
    if addon.barBindings then BF:UpdateKeybindText() end
end

local function OnAddonLoaded(frame, event, ...)
    local isLogin, isReload = ...

    ---@type ActionbarPlus
    local addon = frame.obj

    if event == addon.E.UPDATE_BINDINGS then return OnUpdateBindings(addon) end

    addon:OnAddonLoadedModules()

    addon:log(10, 'IsLogin: %s IsReload: %s', isLogin, isReload)
    if UnitOnTaxi('player') == true then
        local hideWhenTaxi = P:IsHideWhenTaxi()
        addon:log(10, 'Hide-When-Taxi: %s', hideWhenTaxi)
        WU:SetEnabledActionBarStatesDelayed(not hideWhenTaxi, 3)
    end
    if not isLogin then return end

    local versionText, curseForge, githubIssues = G:GetAddonInfo()
    addon:log("%s initialized", versionText)
    addon:print('Available commands: /abp to open config dialog.')
    addon:print('Right-click on the button drag frame to open config dialog.')
    addon:print('Curse Forge:', curseForge)
    addon:print('Issues:', githubIssues)

end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
    ['RegisterSlashCommands'] = function(self)
        self:RegisterChatCommand("abp", "OpenConfig")
        --@debug@--
        self:RegisterChatCommand("cv", "SlashCommand_CheckVariable")
        --@end-debug@--
    end,
    ['CreateDebugPopupDialog'] = function(self)
        local AceGUI = AceLibFactory:GetAceGUI()
        local frame = AceGUI:Create("Frame")
        -- The following makes the "Escape" close the window
        ConfigureFrameToCloseOnEscapeKey(DEBUG_DIALOG_GLOBAL_FRAME_NAME, frame)
        frame:SetTitle("Debug Frame")
        frame:SetStatusText('')
        frame:SetCallback("OnClose", function(widget)
            widget:SetTextContent('')
            widget:SetStatusText('')
        end)
        frame:SetLayout("Flow")
        --frame:SetWidth(800)

        -- ABP_PrettyPrint.format(obj)
        local editbox = AceGUI:Create("MultiLineEditBox")
        editbox:SetLabel('')
        editbox:SetText('')
        editbox:SetFullWidth(true)
        editbox:SetFullHeight(true)
        editbox.button:Hide()
        frame:AddChild(editbox)
        frame.editBox = editbox

        function frame:SetTextContent(text)
            self.editBox:SetText(text)
        end
        function frame:SetIcon(iconPathOrId)
            if not iconPathOrId then return end
            self.iconFrame:SetImage(iconPathOrId)
        end

        frame:Hide()
        return frame
    end,
    ['ShowTextureDialog'] = function(self) TextureDialog:Show() end,
    ['SlashCommand_CheckVariable'] = function(self, spaceSeparatedArgs)
        --self:log('vars: ', spaceSeparatedArgs)
        local vars = table.parseSpaceSeparatedVar(spaceSeparatedArgs)
        if isEmpty(vars) then return end
        local firstVar = vars[1]

        if firstVar == '<profile>' then
            self:HandleSlashCommand_ShowProfile()
            return
        end

        local firstObj = _G[firstVar]
        PrettyPrint._ShowAll()
        local strVal = pformat(firstObj)
        debugDialog:SetTextContent(strVal)
        debugDialog:SetStatusText(format('Var: %s type: %s', firstVar, type(firstObj)))
        debugDialog:Show()
    end,
    ['HandleSlashCommand_ShowProfile'] = function(self)
        PrettyPrint._ShowAll()
        local profileData = self:GetCurrentProfileData()
        local strVal = pformat(profileData)
        local profileName = self.db:GetCurrentProfile()
        debugDialog:SetTextContent(strVal)
        debugDialog:SetStatusText(format('Current Profile Data for [%s]', profileName))
        debugDialog:Show()
    end,
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
    ['DBG'] = function(self, obj, optionalLabel) self:ShowDebugDialog(obj, optionalLabel)  end,
    ['ConfirmReloadUI'] = function(self)
        if IsShiftKeyDown() then
            ReloadUI()
            return
        end
        ShowReloadUIConfirmation()
    end,
    ['OpenConfig'] = function(self, sourceFrameWidget)
        --select the frame config tab if possible
        local optionsConfigPath = nil
        if sourceFrameWidget and sourceFrameWidget.GetFrameIndex  then
            optionsConfigPath = 'bar' .. sourceFrameWidget:GetFrameIndex()
        end
        if optionsConfigPath ~= nil then
            ACE_CFGD:SelectGroup(ADDON_NAME, optionsConfigPath)
        end
        ACE_CFGD:Open(ADDON_NAME)
    end,
    ['OnUpdate'] = function(self) self:log('OnUpdate called...') end,
    ['OnProfileChanged'] = function(self) self:ConfirmReloadUI() end,
    ['InitDbDefaults'] = function(self)
        local profileName = self.db:GetCurrentProfile()
        local defaultProfile = P:CreateDefaultProfile(profileName)
        local defaults = { profile =  defaultProfile }
        self.db:RegisterDefaults(defaults)
        self.profile = self.db.profile
        if isEmpty(ABP_PLUS_DB.profiles[profileName]) then
            ABP_PLUS_DB.profiles[profileName] = defaultProfile
            --error(profileName .. ': ' .. ABP_Table.toStringSorted(ABP_PLUS_DB.profiles[profileName]))
        end
    end,
    ['GetCurrentProfileData'] = function(self) return self.profile end,
    ['OnInitializeModules'] = function(self)
        for _, module in ipairs(libModules) do
            -- self.profile set earlier; see _Core#OnInitialize
            module:OnInitialize{ addon = self }
        end
    end,
    ['OnAddonLoadedModules'] = function(self)
        for _, module in ipairs(libModules) do
            module:OnAddonLoaded()
        end
    end,
    ['OnInitialize'] = function(self)
        -- Set up our database
        self.db = ACE_DB:New(ABP_PLUS_DB_NAME)
        self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
        self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
        self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
        self:InitDbDefaults()

        debugDialog = self:CreateDebugPopupDialog()
        ConfigureFrameToCloseOnEscapeKey(DEBUG_DIALOG_GLOBAL_FRAME_NAME, debugDialog.frame)

        self.barBindings = WU:GetBarBindingsMap()
        self:OnInitializeModules()

        local options = C:GetOptions()
        -- Register options table and slash command
        ACE_CFG:RegisterOptionsTable(ADDON_NAME, options, { "abp_options" })
        --cfgDialog:SetDefaultSize(ADDON_NAME, 800, 500)
        ACE_CFGD:AddToBlizOptions(ADDON_NAME, ADDON_NAME)

        -- Get the option table for profiles
        options.args.profiles = ACE_DBO:GetOptionsTable(self.db)

        self:RegisterSlashCommands()
        --C_Timer.After(5, function() self:RegisterKeyBindings() end)

    end
}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local function NewInstance()
    ---@type WidgetConstants
    local WC = ABP_WidgetConstants
    local frame = CreateFrame("Frame", FRAME_NAME, UIParent)
    frame:SetScript("OnEvent", OnAddonLoaded)
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent(WC.E.UPDATE_BINDINGS)

    local properties = {
        frame = frame,
        WC = WC,
        E = WC.E,
    }

    ---@class ActionbarPlus
    local A = LibStub:NewAddon(G.addonName)
    LogFactory:EmbedLogger(A)
    A.mt.__index = properties

    for method, func in pairs(methods) do
        A[method] = func
    end
    frame.obj = A

    return A
end

ABP = NewInstance()
