--- @type Namespace_ABP_OptionsUI_2_0
local ns = select(2, ...)
local cns = ns:cns()
local EMBEDS = { 'AceEvent-3.0', 'AceConsole-3.0' }
local p, t = ns:log()

--[[-------------------------------------------------------------------
Addon
---------------------------------------------------------------------]]
--- @class ABP_OptionsUI_2_0 : AceAddon, AceEvent-3.0, AceConsole-3.0
local o = cns:AceAddon():NewAddon(ns.name, unpack(EMBEDS)); ABP_OptionsUI_2_0 = o

function o:OnCoreDependentsReady(evt)
  --t('OnCoreDependentsReady', 'evt=', evt)
  -- todo: migrate right-click bar options here.
end

o:RegisterMessage(cns:msg('OnCoreDependentsReady'), 'OnCoreDependentsReady')

function o:OnInitialize()
  self:SendMessage(ns:msg('OnInitialize'))
end

function o:OnEnable()
  self:SendMessage(ns:msg('OnEnable'), self)
end

function o:OnDisable()
  self:SendMessage(ns:msg('OnDisable'))
end

--- @return Namespace_ABP_OptionsUI_2_0
function o:ns() return ns end

