--[[-----------------------------------------------------------------------------
Lua Variables
-------------------------------------------------------------------------------]]
local format = string.format
--[[-----------------------------------------------------------------------------
Wow Variables
-------------------------------------------------------------------------------]]
local CreateFrame, UIParent = CreateFrame, UIParent
local GetNumMacros, GetMacroInfo, GetMacroIndexByName = GetNumMacros, GetMacroInfo, GetMacroIndexByName

--[[-----------------------------------------------------------------------------
Local Variables
-------------------------------------------------------------------------------]]
local ns = abp_ns(...)
local O, GC, M, LibStub, LC = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub, ns.LogCategories()

local P, Table, String = O.Profile, O.Table, O.String
local E = O.GlobalConstants.E
local toStringSorted = Table.toStringSorted

--- @class MacroEventsHandler : BaseLibraryObject
local L = LibStub:NewLibrary(M.MacroEventsHandler)
local p = LC.EVENT:NewLogger(M.MacroEventsHandler)
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
        changeInfo = { type = 'body', old = macroData.body, new = body }
        macroData.body = body
        changed = true
    elseif macroData.name ~= name and macroData.icon == icon and macroData.body == body then
        -- name change
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
        changeInfo = { type = 'icon', old = macroData.icon, new = icon }
        macroData.icon = icon
        changed = true
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
        p:d( function() return '%s::Changed? %s [%s]', btnName, tostring(changed), toStringSorted(changeInfo) end)
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
    local inCombat = InCombatLockdown()
    p:t(function() return 'Event Received: %s combat=%s', event, tostring(inCombat) end)
    if inCombat then return end

    OnMacroUpdate()
end

--[[-----------------------------------------------------------------------------
Event Hook
-------------------------------------------------------------------------------]]
ns:AceEvent():RegisterMessage(GC.M.OnAddOnReady, function(evt, source, ...)
    local pm = LC.MESSAGE:NewLogger(M.MacroEventsHandler)
    pm:d(function() return "MSG:R: %s", evt end)
    local frame = CreateFrame("Frame", M.MacroEventsHandler .. "Frame", UIParent)
    frame:SetScript(E.OnEvent, OnAddonLoaded)
    FrameUtil.RegisterFrameForEvents(frame, { E.UPDATE_MACROS })
end)
