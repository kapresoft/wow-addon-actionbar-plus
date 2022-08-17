--[[
    ActionbarPlus Addon
--]]
---@type Localization
local L = LibStub("AceLocale-3.0"):GetLocale("ActionbarPlus")

-- General
ABP_TITLE                                    = "ActionbarPlus"
ABP_CATEGORY                                 = "AddOns/" .. ABP_TITLE

-- Key binding localization text
BINDING_HEADER_ABP                           = ABP_TITLE
BINDING_HEADER_ABP_CATEGORY                  = ABP_CATEGORY

-- TODO: update with for loop
-- bar max: 8
-- button max 20
for bar = 1,8,1
do
    local headerVar = string.format('BINDING_HEADER_ABP_HEADER_ACTIONBAR%s', bar)
    local headerVarValue = string.format('%s Bar #%s', ABP_TITLE, bar)
    _G[headerVar] = headerVarValue

    for button = 1,20,1
    do
        -- Example: _G["BINDING_NAME_CLICK ActionbarPlusF1Button1:LeftButton"]  = L["BINDING_NAME_ABP_ACTIONBAR1_BUTTON1"]
        --print(string.format('i: %s', button))
        local left = string.format('BINDING_NAME_CLICK ActionbarPlusF%sButton%s:LeftButton', bar, button)
        local right = string.format('BINDING_NAME_ABP_ACTIONBAR%s_BUTTON%s', bar, button)
        --_G["BINDING_NAME_CLICK ActionbarPlusF1Button1:LeftButton"]  = L["BINDING_NAME_ABP_ACTIONBAR1_BUTTON1"]
        --print(string.format('_G[%s] = %s', left, right))
        _G[left] = L[right]
    end
end

ABP_GENERAL_CONFIG_LOCK_ACTION_BARS_NAME     = L['ABP_GENERAL_CONFIG_LOCK_ACTION_BARS_NAME']
ABP_GENERAL_CONFIG_LOCK_ACTION_BARS_DESC     = L['ABP_GENERAL_CONFIG_LOCK_ACTION_BARS_DESC']

ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_NAME     = L['ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_NAME']
ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_DESC     = L['ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_DESC']
