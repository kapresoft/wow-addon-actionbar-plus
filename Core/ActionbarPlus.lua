-- ## External -------------------------------------------------
local ConfigureFrameToCloseOnEscapeKey = ConfigureFrameToCloseOnEscapeKey
local ReloadUI, IsShiftKeyDown = ReloadUI, IsShiftKeyDown
local unpack, format = unpack, string.format
-- ## Local ----------------------------------------------------
local LibStub, M, AceLibFactory, W, ProfileInitializer, G = ABP_LibGlobals:LibPack_NewAddon()
local PrettyPrint, Table, String, LogFactory = G:LibPackUtils()
local _, ToStringSorted = G:LibPackPrettyPrint()
local isEmpty = Table.isEmpty
local DEBUG_DIALOG_GLOBAL_FRAME_NAME = 'ABP_DebugPopupDialogFrame'
local TextureDialog = W:GetMacroTextureDialog()

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

function getBindingByName(bindingName)
    local bindCount = GetNumBindings()
    if bindCount <=0 then return nil end

    for i = 1, bindCount do
        local command,cat,key1,key2 = GetBinding(i)
        if bindingName == command then
            return { name = command, category = cat, key1 = key1, key2 = key2 }
        end
    end
    return nil
end

function getBarBindings(beginsWith)
    local bindCount = GetNumBindings()
    if bindCount <=0 then return nil end

    --print('beginsWith:', beginsWith)
    -- key: name, value: binding obj
    local bindings = {}
    for i = 1, bindCount do
        local command,cat,key1,key2 = GetBinding(i)
        --print('bindingName: ', command)
        if string.find(command, beginsWith) then
            local value = { name = command, category = cat, key1 = key1, key2 = key2 }
            local keyName = 'BINDING_NAME_' .. command
            local key = _G[keyName]
            if key then
                bindings[key] = value
            end
        end
    end
    return bindings
end

local function BindActions()
    local barIndex = 1
    local buttonIndex = 3
    local nameFormat = format('ABP_ACTIONBAR1_BUTTON3', barnIndex, buttonIndex)
    local frameDetails = ProfileInitializer:GetAllActionBarSizeDetails()

    local bindingNames = getBarBindings('ABP_ACTIONBAR1')
    --ABP:DBG(bindingNames, 'Binding Names')
    local button3Binding = bindingNames[BINDING_NAME_ABP_ACTIONBAR1_BUTTON3]
    --print('Binding[ABP_ACTIONBAR1_BUTTON3]', pformat(button3Binding))
    if not (button3Binding and button3Binding.key1) then return end
    local button3 = 'ActionbarPlusF1Button3'
    local btnUI = _G[button3]
    if btnUI then
        ClearOverrideBindings(btnUI)
        SetOverrideBindingClick(btnUI, true, button3Binding.key1, button3)
        ABP:log(40, 'Button: %s OverrideBindingClick: %s', button3, button3Binding.key1)
        -- TODO: Does not respond after binding change event, need to add a listener to event UPDATE_BINDINGS
        if button3Binding.key2 then
            ABP:log(40, 'Button: %s OverrideBindingClick: %s', button3, button3Binding.key2)
            SetOverrideBindingClick(btnUI, true, button3Binding.key2, button3)
        end
    end
    --LoadBindings(1);
end

function Binding_ActionBar1()
    ABP:DBG(ABP.profile, 'Current Profile')
end

function Binding_ActionBar2()
    ABP:ShowTextureDialog()
end

function Binding_ActionBar3(...)
    --local bindings = getBarBindings('ABP_ACTIONBAR1')
    --ABP:DBG(bindings, 'Key Bindings')
    BindActions()
end

local function BindingUpdated(frame, event)
    --ABP:log(20, 'BindingUpdated: %s Frame:%s', event, frame:GetName())
    BindActions()
end

local function OnAddonLoaded(frame, event, ...)
    local isLogin, isReload = ...
    if (event == 'UPDATE_BINDINGS') then
        BindingUpdated(frame, event)
        return
    end

    BindActions()
    local addon = frame.obj
    addon:OnAddonLoadedModules()
    addon:log(10, 'IsLogin: %s IsReload: %s', isLogin, isReload)

    if not isLogin then return end


    local MAJOR, MINOR = G.addonName .. '-1.0', 1 -- Bump minor on changes
    addon:log("%s.%s initialized", MAJOR, MINOR)
    addon:print('Available commands: /abp to open config dialog.')
    addon:print('Right-click on the button drag frame to open config dialog.')
    addon:print('More at https://kapresoft.com/wow-addon-actionbar-plus')

end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
    ['RegisterSlashCommands'] = function(self)
        self:RegisterChatCommand("abp", "OpenConfig")
        self:RegisterChatCommand("cv", "SlashCommand_CheckVariable")
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
            text = PrettyPrint.pformat(obj)
        else
            text = obj
        end
        debugDialog:SetTextContent(text)
        debugDialog:SetStatusText(label)
        debugDialog:Show()
    end,
    ['DBG'] = function(self, obj, optionalLabel) self:ShowDebugDialog(obj, optionalLabel)  end,
    ['RegisterKeyBindings'] = function(self)
        --SetBindingClick("SHIFT-T", self:Info())
        --SetBindingClick("SHIFT-F1", BoxerButton3:GetName())
        --SetBindingClick("ALT-CTRL-F1", BoxerButton1:GetName())

        -- Warning: Replaces F5 keybinding in Wow Config
        -- SetBindingClick("F5", BoxerButton3:GetName())
        -- TODO: Configure Button 1 to be the Boxer Follow Button (or create an invisible one)
        --SetBindingClick("SHIFT-R", BoxerButton1:GetName())
    end,
    ['ConfirmReloadUI'] = function(self)
        if IsShiftKeyDown() then
            ReloadUI()
            return
        end
        ShowReloadUIConfirmation()
    end,
    ['OpenConfig'] = function(self) ACE_CFGD:Open(ADDON_NAME) end,
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

        self:OnInitializeModules()

        local options = C:GetOptions()
        -- Register options table and slash command
        ACE_CFG:RegisterOptionsTable(ADDON_NAME, options, { "abp_options" })
        --cfgDialog:SetDefaultSize(ADDON_NAME, 800, 500)
        ACE_CFGD:AddToBlizOptions(ADDON_NAME, ADDON_NAME)

        -- Get the option table for profiles
        options.args.profiles = ACE_DBO:GetOptionsTable(self.db)

        self:RegisterSlashCommands()
        self:RegisterKeyBindings()

        --macroIcons = self:FetchMacroIcons()
        ABP_buttons = P:FindButtonsBySpellById(30016)
    end
}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local function NewInstance()
    local frame = CreateFrame("Frame", ADDON_NAME .. "Frame", UIParent)
    frame:SetScript("OnEvent", OnAddonLoaded)
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent('UPDATE_BINDINGS')

    local properties = {
        frame = frame,
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

