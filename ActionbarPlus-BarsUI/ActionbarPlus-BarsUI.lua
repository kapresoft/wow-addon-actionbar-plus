--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns = ns:cns()
local AceAddon = cns.O.AceAddon
local MF = ns.O.BarModuleFactory
local EMBEDS = { 'AceEvent-3.0', 'AceBucket-3.0', 'AceConsole-3.0', 'AceHook-3.0' }

local quickKeybindModeActive = false

--[[-------------------------------------------------------------------
Addon
---------------------------------------------------------------------]]

--- @class ABP_BarsUI_2_0 : AceAddon, AceEvent-3.0, AceBucket-3.0, AceConsole-3.0, AceHook-3.0
local o = cns:AceAddon():NewAddon(ns.name, unpack(EMBEDS)); ABP_BarsUI_2_0 = o
local p, t = ns:log()

o:SetDefaultModuleLibraries(unpack(EMBEDS))
o:SetDefaultModuleState(false)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

local function ResyncAllButtonsEmptyState()
  local isQKB = ns:a():IsQuickKeybindModeActive()
  ns:a():ForEach(function(bm)
    local ui = bm:c().ui
    bm:ForEach(function(btn) btn.widget:UpdateEmptyState(ui.showEmptyButtons) end)
    -- hide extra buttons during QKB mode, restore after
    local eb = ui.extraButton
    if eb and eb.enabled then
      bm:ForEachExtraButton(function(btn)
        if isQKB then
          btn:Hide()
        else
          btn:Show()
          btn.widget:UpdateEmptyState(eb.showEmptyButtons ~= false)
        end
      end, true)
    end
  end)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- Called once, after:
--- - ActionbarPlus-Core is loaded
--- - SavedVariables are loaded
--- - All addon Lua/XML files are loaded
--- - AceDB initialized
function o:OnInitialize()
  self:SendMessage(ns:msg('OnInitialize'))
  self:RegisterMessage(cns:msg('OnCoreDependentsReady'), self.OnCoreDependentsReady, self)
  -- Masque's own UI can enable/disable a skin group independent of anything ActionbarPlus
  -- does; that resets/re-applies Masque's textures but leaves ActionbarPlus's own
  -- per-button visuals (hotkey position, empty-button overlay, etc.) stale until the
  -- affected bars are re-rendered.
  self:RegisterMessage(cns:msg('OnMasqueGroupToggled'), self.OnMasqueGroupToggled, self)
end

-- On group disable, Masque re-skins each button with its own default skin (the classic
-- UI-Quickslot2 outer border on the button's NormalTexture, plus a leftover FloatingBG
-- backdrop if one was created) and then stops managing those regions -- so the
-- template's own visuals have to be re-asserted manually. Only on disable: on enable,
-- Masque's ReSkin owns these regions again and restoring them would stomp the skin.
--- @param btn Button_ABP_2_0_X
local function RestoreButtonVisuals(btn)
  if btn.FloatingBG then btn.FloatingBG:Hide() end
  btn.widget:ResetTemplateVisuals()
end

--- @param disabled boolean true when the Masque group was just disabled
function o:OnMasqueGroupToggled(_, disabled)
  self:ForEach(function(bm)
    MF:ApplyLayout(bm.barFrame, bm:c())
    if disabled then
      bm:ForEach(RestoreButtonVisuals)
      bm:ForEachExtraButton(RestoreButtonVisuals, true)
    end
  end)
end

function o:OnCoreDependentsReady()
  local optionsNS = cns:OptionsNS()
  ns:a():RegisterMessage(optionsNS:msg('OnQuickKeybindModeActive'), function()
    quickKeybindModeActive = true
    ResyncAllButtonsEmptyState()
  end)
  ns:a():RegisterMessage(optionsNS:msg('OnQuickKeybindModeNotActive'), function()
    quickKeybindModeActive = false
    ResyncAllButtonsEmptyState()
  end)
end

--- @return boolean
function o:IsQuickKeybindModeActive() return quickKeybindModeActive end

function o:OnEnable()
  MF:CreateAddonModules()
  self:SendMessage(ns:msg('OnEnable'), self)
end

function o:OnDisable()
  self:SendMessage(ns:msg('OnDisable'))
end

--- @param callbackFn fun(module:BarModule_2_0):void
function o:ForEach(callbackFn)
  assert(type(callbackFn) == 'function', "ForEach(callbackFn): callbackFn should be a function")
  for name, module in ns:a():IterateModules() do
    --- @type BarModule_2_0
    local barModule = module
    callbackFn(barModule)
  end
end

function o:EnableBars()
  self:ForEach(function(module)
    module:Enable()
  end)
end

function o:DisableBars()
  self:ForEach(function(module)
    module:Disable()
  end)
end

--- @return Namespace_ABP_BarsUI_2_0
function o:ns() return ns end
