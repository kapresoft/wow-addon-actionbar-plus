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
local _L = LibStub:NewLibrary('MacroEventsHandler')

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
-- get all action bars with type macro
-- iterate and GetMacroByIndex
--   index changed
--   name changed
--   icon changed
-- Update Change Macro Info
-- Update actionbar attributes
local function findMacroByBody(matchingBody)
    local count = GetNumMacros()
    if count <= 0 then return nil end
    for macroIndex = 1, count do
        local name, icon, body = GetMacroInfo(macroIndex)
        if matchingBody == body then
            print('found match')
            return { name=name, icon=icon, index=macroIndex }
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
        _L:log(10, 'Name,Icon,Index(%s) changed: %s', btnName, toStringSorted(d))
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
    local changed = false

    -- Name/Icon change UI only allows name and icon change
    if name ~= nil and macroData.body == body then
        if macroData.name == name and macroData.icon == icon then
            -- body change
            if macroData.body ~= body then
                _L:log(15, '%s::body changed: %s', btnName, toStringSorted({ old=macroData.body, new=body }))
                macroData.body = body
                changed = true
            end
        else
            -- name or icon change
            if macroData.name ~= name then
                _L:log(15, '%s::name changed: %s', btnName, toStringSorted({ old=macroData.name, new=name }))
                macroData.name = name
                changed = true
            end
            if macroData.icon ~= icon then
                _L:log(15, '%s::icon changed: %s', btnName, toStringSorted({ old=macroData.icon, new=icon }))
                macroData.icon = icon
                changed = true
            end
        end
    else
        -- use-case: macro created or updated that affected the macro index
        name, icon, body = GetMacroInfo(macroData.name)
        if name ~= nil then
            -- index change
            local macroIndex = GetMacroIndexByName(macroData.name)
            macroData.index = macroIndex
            changed = true
            -- icon changed
            if macroData.icon ~= icon then
                _L:log(15, '%s::icon changed: %s', btnName, toStringSorted({ old=macroData.icon, new=icon }))
                macroData.icon = icon
                changed = true
            end
        else
            -- use-case: User changed name and/or icon that affected the macro index
            -- only choice is to match by body
            -- name(and index) and/or icon changed
            local macroDetails = findMacroByBody(macroData.body)
            if macroDetails ~= nil then
                _L:log(15, '%s::name and/or icon changed', btnName)
                macroData.name = macroDetails.name
                macroData.icon = macroDetails.icon
                macroData.index = macroDetails.index
                changed = true
            else
                -- Save macro in the future?
                macroData.name = nil
                macroData.icon = nil
                macroData.index = nil
                changed = true
            end
        end
    end

    if changed then btnWidget:Fire('OnMacroChanged') end
    _L:log(15, 'HandleMacro[%s] Changed? %s', btnName, changed)
end

function OnMacroUpdate()
    local buttons = P:FindButtonsByType('macro')
    if Table.isEmpty(buttons) then return end
    for name, data in pairs(buttons) do
        HandleChangedMacros(name, data)
    end
end

function OnAddonLoaded(frame, event, ...)
    if event == 'PLAYER_ENTERING_WORLD' then
        _L:log(event)
        frame:RegisterEvent('UPDATE_MACROS')
    end

    if event == 'UPDATE_MACROS' then
        OnMacroUpdate()
    end
end


--[[-----------------------------------------------------------------------------
Event Hook
-------------------------------------------------------------------------------]]
local frame = CreateFrame("Frame", ADDON_NAME .. "Frame", UIParent)
frame:SetScript("OnEvent", OnAddonLoaded)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

