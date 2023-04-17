--[[-----------------------------------------------------------------------------
Lua Variables
-------------------------------------------------------------------------------]]
local format, str_lower = string.format, string.lower
--[[-----------------------------------------------------------------------------
Wow Variables
-------------------------------------------------------------------------------]]
local CreateFrame, UIParent = CreateFrame, UIParent
local GetNumMacros, GetMacroInfo, GetMacroIndexByName = GetNumMacros, GetMacroInfo, GetMacroIndexByName
local blankIcon = 1074161000
--[[-----------------------------------------------------------------------------
Local Variables
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, LibStub = ns:LibPack()

local P, Table, String = O.Profile, O.Table, O.String
local E = O.GlobalConstants.E
local toStringSorted = Table.toStringSorted

--- @class MacroEventsHandler : BaseLibraryObject
local L = LibStub:NewLibrary(ns.M.MacroEventsHandler)
local p = L:GetLogger()

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---### Find first-matching macro by body
--- @return MacroDetails
--- @param matchingBody string The macro body to match
local function findMacroByBody(matchingBody)
    -- Global Macros Max: 120
    -- Per Character Max: 18  [Index starts at 121]
    local globalMacroCount = 120
    local globalMacroStartIndex = 1
    local perCharMacroStartIndex = globalMacroCount + 1

    local globalCount, perCharCount = GetNumMacros()
    if globalCount <= 0 then return nil end
    --- @class MacroDetails
    local macroDetails = {}
    for macroIndex = globalMacroStartIndex, globalCount do
        local name, icon, body = GetMacroInfo(macroIndex)
        if name ~= nil and matchingBody == body then
            macroDetails = { name=name, icon=icon, index=macroIndex, global=true }
            return macroDetails
        end
    end

    if perCharCount <= 0 then return nil end
    local perCharMax = globalMacroCount + perCharCount
    for macroIndex = perCharMacroStartIndex, perCharMax do
        local name, icon, body = GetMacroInfo(macroIndex)
        if name ~= nil and matchingBody == body then
            macroDetails = { name=name, icon=icon, index= macroIndex, global=false }
            return macroDetails
        end
    end
    return nil
end

--[[local function HandleNameIconIndexChange(btnWidget, btnName, btnData)
    local macroData = btnData.macro
    local changed = false
    -- name and index changed: find by body
    local changedMacro = findMacroByBody(macroData.body)
    if changedMacro ~= nil then
        local d = {
            index={old=macroData.index, new=changedMacro.index},
            name={old=macroData.name, new=changedMacro.name},
            icon={old=macroData.icon, new=changedMacro.icon},
        }
        _L:log(15, 'Name,Icon,Index(%s) changed: %s', btnName, toStringSorted(d))
        macroData.name = changedMacro.name
        macroData.icon = changedMacro.icon
        macroData.index = changedMacro.index
        changed = true
    end

    return changed
end]]

---@param macroName string
local function GetM6Icon(macroName)
    if not M6 then return nil end
    if not String.StartsWithIgnoreCase(macroName, '_m6') then return nil end

    local _, m6SlotID = string.gmatch(macroName, "(%w+)%+s(%w+)")()
    if not m6SlotID then return nil end

    local slotID = tonumber(m6SlotID)
    p:log(30, 'M6 macro-name=[%s] SlotID: %s', tostring(macroName), tostring(slotID))
    if not slotID or slotID <= 0 then return nil end

    local slotIcon = M6:GetActionIcon(slotID)
    p:log(30, 'M6::Macro[%s]: m6-ID=%s, icon=%s', macroName, tostring(slotID), tostring(slotIcon))

    return slotIcon
end

local function HandleChangedMacros(btnName, btnData)
    if btnData == nil or btnData.macro == nil or btnData.macro.index == nil then return false end
    local macroData = btnData.macro
    local btnWidget = _G[btnName].widget

    local name, icon, body = GetMacroInfo(macroData.index)
    local macroIndex = GetMacroIndexByName(macroData.name)

    local changed = false
    local changeInfo = { type = '', old = '', new = '' }
    if macroData.body ~= body and macroData.name == name and macroData.icon == icon then
        -- body change
        --_L:log(15, '%s::body changed: %s', btnName, toStringSorted({ old=macroData.body, new=body }))
        changeInfo = { type = 'body', old = macroData.body, new = body }
        macroData.body = body
        changed = true
    elseif macroData.name ~= name and macroData.icon == icon and macroData.body == body then
        -- name change
        --_L:log(15, '%s::name changed: %s', btnName, toStringSorted({ old=macroData.name, new=name }))
        changeInfo = { type = 'name', old = macroData.name, new = name }
        macroData.name = name
        changed = true
    elseif macroData.name ~= name and macroData.icon ~= icon and macroData.body == body then
        -- name and icon change (from UI)
        changeInfo = { type = 'name-and-icon',
                       old = format('%s|%s', macroData.name, macroData.icon),
                       new = format('%s|%s', name, icon) }
        macroData.name = name
        macroData.icon = icon
        changed = true
    elseif macroData.icon ~= icon and macroData.name == name and macroData.body == body then
        local newIcon = icon
        local m6Icon = GetM6Icon(macroData.name)
        if m6Icon and m6Icon < blankIcon then newIcon = m6Icon end

        changeInfo = { type = 'icon', old = macroData.icon, new = newIcon }
        if newIcon <= blankIcon then
            p:log(30, 'Icon[%s]::Change-Info: %s, m6Icon=%s',
                    macroData.name, toStringSorted(changeInfo), tostring(m6Icon))
            macroData.icon = newIcon
            changed = true
        end
    elseif macroIndex ~= macroData.index then
            -- macro index changed due to
            -- (1) New Macro Created that causes the index/position to change
            -- (2) Macro renames that causes the index/position to change
            local macroDetails = findMacroByBody(macroData.body)
            if macroDetails ~= nil then
                if macroData.name == macroDetails.name and macroData.icon == macroDetails.icon then
                    changeInfo = { type = 'index', old = macroData.index, new = macroDetails.index }
                    macroData.index = macroDetails.index
                    changed = true
                else
                    changeInfo = { type = 'index-name-icon',
                                   old = format('%s|%s|%s', macroData.index, macroData.name, macroData.icon),
                                   new = format('%s|%s|%s', macroDetails.index, macroDetails.name, macroDetails.icon) }
                    macroData.index = macroDetails.index
                    macroData.name = macroDetails.name
                    macroData.icon = macroDetails.icon
                    changed = true
                end
            end
    end

    if changed then
        p:log(15, '%s::Changed? %s [%s]', btnName, changed, toStringSorted(changeInfo))
        btnWidget:Fire('OnMacroChanged')
    end
end

local function OnMacroUpdate()
    local buttons = P:FindButtonsByType('macro')
    if Table.isEmpty(buttons) then return end
    for name, data in pairs(buttons) do
        HandleChangedMacros(name, data)
    end
end

---### UPDATE_MACROS event fired when
---1. Macro UI Updates
---2. On Reload or Login
local function OnAddonLoaded(frame, event, ...)
    --- todo next: move to ActionbarPlusEventMixin
    if event == E.PLAYER_ENTERING_WORLD then
        p:log(10, event)
        frame:RegisterEvent('UPDATE_MACROS')
    end

    if event == 'UPDATE_MACROS' then
        p:log(20, 'Event Received: %s', event)
        OnMacroUpdate()
    end
end


--[[-----------------------------------------------------------------------------
Event Hook
-------------------------------------------------------------------------------]]
local frame = CreateFrame("Frame", ns.name .. "Frame", UIParent)
frame:SetScript(E.OnEvent, OnAddonLoaded)
frame:RegisterEvent(E.PLAYER_ENTERING_WORLD)

