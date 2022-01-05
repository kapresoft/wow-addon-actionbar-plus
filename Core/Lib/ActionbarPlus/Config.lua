local format, unpack, pack, tinsert = string.format, table.unpackIt, table.pack, table.insert
local ADDON_NAME = ADDON_NAME
local C = LibFactory:NewAceLib('Config')
if not C then return end

---- ## Start Here ----
-- Initializedin OnAddonLoaded() - See Logger
C.profile = nil
C.addon = nil

-- Profile initialized in OnAfterInitialize()
---@type Profile
local P = nil
local PU = ProfileUtil

local function IsFrameShown(frameIndex)
    local frameName = PU:GetFrameNameFromIndex(frameIndex)
    local f = _G[frameName]
    return f:IsShown()
end

local function SetFrameState(frameIndex, isEnabled)
    -- TODO: needs reload
    local frameName = PU:GetFrameNameFromIndex(frameIndex)
    local f = _G[frameName]
    if isEnabled then
        if f.ShowGroup then f:ShowGroup() end
        P:SetBarEnabledState(frameIndex, isEnabled)
        return
    end
    if f.HideGroup then f:HideGroup() end
end

local function CreateSetterHandler(frameIndex)
    local p = C.profile
    return function(_, v)
        local frameName = PU:GetFrameNameFromIndex(frameIndex)
        p.bars[frameName].enabled = v
        if type(p.bars[frameName]) == 'nil' then p.bars[frameName] = {} end
        SetFrameState(frameIndex, v)
    end
end

local function CreateGetterHandler(frameIndex)
    local p = C.profile
    return function(_)
        -- handle hiding in ButtonFactory
        local frameName = PU:GetFrameNameFromIndex(frameIndex)
        if type(p.bars[frameName]) == 'nil' then p.bars[frameName] = {} end
        local enabled = IsFrameShown(frameIndex)
        --p.bars[frameName].enabled = enabled
        --return enabled
        return p.bars[frameName].enabled
    end
end

function C:OnAfterInitialize()
    P = LibFactory:GetProfile()
end

function C:OnAfterAddonLoaded()
    local bars = P:GetBars()
    local count = P:GetBarSize()
end

function C:GetOptions()
    return {
        name = ADDON_NAME, handler = C.addon, type = "group",
        args = C:CreateBarConfigArgsDef()
    }
end

function C:CreateBarConfigArgsDef()
    local configArgs = {}
    local count = P:GetBarSize()
    for i=1,count do
        local key = 'bar' .. i
        configArgs[key] = C:CreateBarConfigDef(i)
    end
    return configArgs
end

function C:CreateBarConfigDef(frameIndex)
    local configName = format('Action Bar #%s', tostring(frameIndex))
    return {
        type = 'group',
        name = configName,
        desc = format("%s Settings", configName),
        order = 1,
        args = {
            desc = { name = format("%s Settings", configName), type = "header", order = 0 },
            enabled = {
                type = "toggle",
                name = "Enable",
                desc = format("Enable %s", configName),
                order = 1,
                get = CreateGetterHandler(frameIndex),
                set = CreateSetterHandler(frameIndex)
            }
        }
    }
end

function C:CreateButtonDef(baseId, settings, handler)
    local btnId = 'Boxer' .. baseId;
    local buttonDef = {
        order = 0, type = "group", name = baseId,
        args = {
            button_label = {
                type = 'input', order = 1, width = "normal", name = 'Spell, Macro, or Tooltip',
                desc = 'Spell Name, Macro Name or Tooltip label for macrotext type.',
                get = function(_) return settings:GetButtonSettings(btnId).label end,
                set = function(_, v) handler:OnButtonLabelUpdate(btnId, v) end,
            },
            button_type = {
                type = "select", style = "dropdown", order = 2, width = "normal", name = 'Type',
                values = settings.ButtonTypeNames,
                get = function(_) return settings:GetButtonSettings(btnId).typeIndex or 1 end,
                set = function(_, v) handler:OnButtonTypeUpdate(btnId, v) end,
            },
            button_icon = {
                type = 'input', order = 3, width = "normal", name = 'Icon', desc="This option nly applies to macros.",
                get = function(_) return settings:GetButtonSettings(btnId).icon end,
                set = function(_, v) handler:OnButtonIconUpdate(btnId, v) end,
            },
            button_value = {
                type = 'input', order = 4, width = "full", multiline = true, name = 'Macro Text',
                desc = 'This field only applies when type is macrotext.',
                get = function(_) return settings:GetButtonSettings(btnId).value or '' end,
                set = function(_, v) handler:OnButtonValueUpdate(btnId, v) end,
            },
        }
    }

    return buttonDef
end

