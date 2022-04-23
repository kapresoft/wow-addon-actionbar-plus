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
local ADDON_NAME = ADDON_NAME
local LibStub, M, P, LogFactory = ABP_LibGlobals:LibPack_NewLibrary()
local PrettyPrint, Table, String, LogFactory = ABP_LibGlobals:LibPackUtils()
local toStringSorted = Table.toStringSorted

---@class MacroEventsHandler
local _L = LibStub:NewLibrary(M.MacroEventsHandler)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

--[[
    {
        ["type"] = "macro",
        ["index"] = 67,
        ["name"] = "z#Moon",
        ["icon"] = 132093,
        ["body"] = "/moon\n",
    }
]]


---### Find first-matching macro by body
---@return MacroDetails
---@param matchingBody string The macro body to match
local function findMacroByBody(matchingBody)
    local count = GetNumMacros()
    if count <= 0 then return nil end
    for macroIndex = 1, count do
        local name, icon, body = GetMacroInfo(macroIndex)
        if matchingBody == body then
            ---@class MacroDetails
            local macroDetails = { name=name, icon=icon, index=macroIndex }
            return macroDetails
        end
    end
    return nil
end

local function HandleNameIconIndexChange(btnWidget, btnName, btnData)
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
        -- name and icon change (from UI)
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
        _L:log(15, '%s::Changed? %s [%s]', btnName, changed, toStringSorted(changeInfo))
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
    if event == 'PLAYER_ENTERING_WORLD' then
        _L:log(5, event)
        frame:RegisterEvent('UPDATE_MACROS')
    end

    if event == 'UPDATE_MACROS' then
        _L:log(15, 'Event Received: %s', event)
        OnMacroUpdate()
    end
end


--[[-----------------------------------------------------------------------------
Event Hook
-------------------------------------------------------------------------------]]
local frame = CreateFrame("Frame", ADDON_NAME .. "Frame", UIParent)
frame:SetScript("OnEvent", OnAddonLoaded)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

