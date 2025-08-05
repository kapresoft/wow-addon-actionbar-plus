--[[-----------------------------------------------------------------------------
Handles changes to macros:
- renames
- body changes
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Types
-------------------------------------------------------------------------------]]
--- @class Macro
--- @field index Index
--- @field name string
--- @field body string
--- @field bodyFingerprint string
--- @field icon Icon

--[[-----------------------------------------------------------------------------
Wow Variables
-------------------------------------------------------------------------------]]
local GetNumMacros, GetMacroInfo = GetNumMacros, GetMacroInfo

--[[-----------------------------------------------------------------------------
Local Variables
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M = ns.O, ns.GC, ns.M
local E = ns.GC.E
local IsBlank = ns:String().IsBlank

local libName = M.MacroChangesController
--- @class MacroChangesController
local L = ns:NewController(libName); if not L then return end
local p = ns:LC().MACRO:NewLogger(libName)

local MACRO_INDEX_CHARACTER_START = 121

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function api() return O.API end
local function mas() return O.MacroAttributeSetter end
local function totalCharMacros(numChar) return MACRO_INDEX_CHARACTER_START + numChar - 1 end

--- @param index Index
--- @return Macro|nil
local function GetMacro(index)
    local name, icon, body = GetMacroInfo(index)
    if IsBlank(name) then return nil end
    return { index = index, name = name, body = body, icon = icon,
             bodyFingerprint = api():FingerprintMacroBody(body) }
end

--- Iterates through all general and character-specific macros and calls the handler.
--- @param handler fun(macro:Macro) | "function(macro) print('macro:', macro) end"
local function ForEachMacro(handler)
    if type(handler) ~= "function" then return end

    local numGeneral, numCharacter = GetNumMacros()

    -- General macros: 1 to numGeneral
    for i = 1, numGeneral do
        local m = GetMacro(i)
        if m then
            p:f1(function() return "Iter general macro: %s", m.name end)
            handler(m)
        end
    end
    for i = MACRO_INDEX_CHARACTER_START, totalCharMacros(numCharacter) do
        local m = GetMacro(i)
        if m then
            p:f1(function() return "Iter char macro: %s", m.name end)
            handler(m)
        end
    end
end

--- Iterates through all general and character-specific macros and calls the handler.
--- @param predicateFn fun(macro:Macro) | "function(macro) return true end"
--- @return Macro|nil
local function FindMacro(predicateFn)
    assert(type(predicateFn) == 'function', 'Requires a predicate')

    local numGeneral, numCharacter = GetNumMacros()

    -- General macros: 1 to numGeneral
    for i = 1, numGeneral do
        local m = GetMacro(i)
        if m and predicateFn(m) then return m end
    end
    for i = MACRO_INDEX_CHARACTER_START, totalCharMacros(numCharacter) do
        local m = GetMacro(i)
        if m and predicateFn(m) then return m end
    end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @type MacroChangesController | ControllerV2
local o = L

function o.OnAddOnReady()
    if InCombatLockdown() then return end
    o:RegisterAddOnMessage(E.UPDATE_MACROS, o.OnMacroChanged)

    o.OnMacroChanged()
end

--- @param bw ButtonUIWidget
function o.OnMacroChanged()
    o:ForEachMacroButton(function(bw) o:HandleChanges(bw) end)
end

--- @private
--- @param bw ButtonUIWidget
--- @param c ButtonProfileConfigMixin
function o:HandleChanges(bw)
    local c = bw:conf(); if not c:IsMacro() then return end
    local macroConf = c.macro

    local foundMatch = false

    ForEachMacro(function(macro)
        -- Exact match: name and index are both unchanged
        if macroConf.name == macro.name and macroConf.index == macro.index then
            foundMatch = true
            self:HandleBodyUpdate(bw, macroConf, macro)
            return
        end

        -- Index changed: same name, different location
        if macroConf.name == macro.name and macroConf.index ~= macro.index then
            foundMatch = true
            self:HandleIndexChange(bw, macroConf, macro)
            return
        end

        -- Name changed: same index and body
        if macroConf.name ~= macro.name and macroConf.index == macro.index
                and macroConf.bodyFingerprint == macro.bodyFingerprint then
            foundMatch = true
            self:HandleNameChange(bw, macroConf, macro)
            return
        end

        -- Loose body match (regardless of name/index)
        if macroConf.bodyFingerprint == macro.bodyFingerprint then
            foundMatch = true
            self:HandleBodyMatch(bw, macroConf, macro)
        end
    end)

    if not foundMatch then self:HandleDeletedMacros(bw, macroConf) end
end

--- @private
--- @param bw ButtonUIWidget
--- @param macroConf Profile_Macro
function o:HandleDeletedMacros(bw, macroConf)
    -- Try to re-find it
    local found = FindMacro(function(m) return m.name == macroConf.name end)
    if found then return end

    -- Deletion confirmed
    p:vv(function()
        return "HandleDeletedMacros::Macro[%s, btn:%s] was deleted. index=%s body={%s}",
        bw:GetName(),
        macroConf.name, macroConf.index, macroConf.bodyFingerprint
    end)

    bw:SetButtonAsEmpty()
end

--- @private
--- @param bw ButtonUIWidget
--- @param macroConf Profile_Macro
--- @param macro Macro
function o:HandleIndexChange(bw, macroConf, macro)
    -- index change
    local oldIndex = macroConf.index
    macroConf.index = macro.index
    macroConf.name = macro.name
    macroConf.bodyFingerprint = macro.bodyFingerprint
    mas():SetAttributes(bw.button())
    p:vv(function() return 'HandleIndexChange::Macro[%s] index changed, old=%s, new=%s',
        macroConf.name, oldIndex, macroConf.index end)
end

--- @private
--- @param bw ButtonUIWidget
--- @param macroConf Profile_Macro
--- @param macro Macro
function o:HandleNameChange(bw, macroConf, macro)
    local oldName = macroConf.name
    macroConf.index = macro.index
    macroConf.name = macro.name
    macroConf.bodyFingerprint = macro.bodyFingerprint
    p:vv(function() return 'HandleNameChange::Macro[index=%s] name changed, old=%s, new=%s',
        macro.index, oldName, macroConf.name end)
end

--- @private
--- @param bw ButtonUIWidget
--- @param macroConf Profile_Macro
--- @param macro Macro
function o:HandleBodyUpdate(bw, macroConf, macro)
    if macroConf.bodyFingerprint == macro.bodyFingerprint then return end
    local oldBody = macroConf.bodyFingerprint
    macroConf.bodyFingerprint = api():FingerprintMacroBody(macro.body)
    p:vv(function() return "HandleBodyUpdate::Macro[%s] body updated, old={%s}, new={%s}",
        macroConf.name, oldBody, macroConf.bodyFingerprint end)
end

--- @private
--- @param bw ButtonUIWidget
--- @param macroConf Profile_Macro
--- @param macro Macro
--- @return boolean
function o:HandleBodyMatch(bw, macroConf, macro)
    p:vv(function() return "HandleBodyMatch:: MacroConf[%s] matched body: %s from name=[%s], index=[%s]",
        macroConf.name, macroConf.bodyFingerprint, macro.name, macro.index end)

    macroConf.index = macro.index
    macroConf.name  = macro.name
    mas():SetAttributes(bw.button())
end

