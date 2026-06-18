--- @type Namespace_ABP_OptionsUI_2_0
local ns = select(2, ...)
local cns = ns:cns()

local BarContextMenu = ns.O.BarContextMenu
local EMBEDS = { 'AceEvent-3.0', 'AceConsole-3.0' }
local p, t = ns:log()

--[[-------------------------------------------------------------------
Addon
---------------------------------------------------------------------]]
--- @class ABP_OptionsUI_2_0 : AceAddon, AceEvent-3.0, AceConsole-3.0
local o = cns:AceAddon():NewAddon(ns.name, unpack(EMBEDS)); ABP_OptionsUI_2_0 = o

function o.Init()
  o:RegisterMessage(cns:BarsNS():msg('OnBarFrameRightClick'), o.OnBarFrameRightClick)
  o:RegisterMessage(ns:msg('OnBarOptionsChanged'), o.OnBarOptionsChanged)
end

--- @param evt EventName
--- @param barFrame BarFrame_ABP_2_0
function o.OnBarFrameRightClick(evt, barFrame) BarContextMenu:Show(barFrame) end

--- @param evt EventName
--- @param barIndex Index
function o.OnBarOptionsChanged(evt, barIndex)
  cns:BarsUI():ns().O.BarModuleFactory:RebuildLayout(barIndex)
end

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

--[[-----------------------------------------------------------------------------
Register Messages
-------------------------------------------------------------------------------]]
o:RegisterMessage(cns:msg('OnCoreDependentsReady'), o.Init)
