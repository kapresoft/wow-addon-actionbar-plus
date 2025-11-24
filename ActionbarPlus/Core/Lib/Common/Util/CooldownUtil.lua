--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return CooldownUtil, Kapresoft_CategoryLogger
local function CreateLib()
    local libName = M.CooldownUtil
    --- @class CooldownUtil : Kapresoft_LibUtil_BaseLibrary
    local newLib = LibStub:NewLibrary(libName); if not newLib then return nil end
    local logger = ns:CreateDefaultLogger(libName)
    return newLib, logger
end; local L, p = CreateLib(); if not L then return end

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function api() return O.API end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @type CooldownUtil
local o = L

--- @param itemID ItemID
--- @return ItemCooldown
function o:GetItemCooldown(itemID)
    --- @type CooldownInfo
    local cd = { type='item', start=nil, duration=nil, enabled=0, details = {} }
    local itemCD = api():GetItemCooldownQuick(itemID)
    if not itemCD then return end

    cd.details = itemCD
    cd.start = itemCD.start
    cd.duration = itemCD.duration
    cd.enabled = itemCD.enabled

    return cd
end

--- @param bw ButtonUIWidget
--- @return SpellCooldown
--- @param spellID SpellID
function o:GetSpellCooldown(spellID)
    local spellCD = api():GetSpellCooldown(spellID); if not spellCD then return nil end

    --- @type SpellCooldown
    local cd = { type='spell', start=nil, duration=nil, enabled=0, details = {} }
    cd.details = spellCD
    cd.start = spellCD.start
    cd.duration = spellCD.duration
    cd.enabled = spellCD.enabled

    return cd
end

--- @param bw ButtonUIWidget
--- @return SpellCooldown | ItemCooldown
function o:GetMacroCooldown(bw)
    local c = bw:conf(); if not c:IsMacro() then return nil end

    local item = api():GetMacroItem(c.macro.index)
    if item and item.id then return self:GetItemCooldown(item.id) end

    local spellID = api():GetMacroSpellID(c.macro.index)
    if spellID then
        if O.DruidUnitMixin:IsProwl(spellID) then return nil end
        return self:GetSpellCooldown(spellID)
    end

    return nil;
end

