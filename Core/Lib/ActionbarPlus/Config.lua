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
local BF = nil
local PU = nil
local FF = nil

function C:OnAfterInitialize()
    PU, FF = ProfileUtil, FrameFactory
    P, BF = unpack(LibFactory:GetConfigLibs())
end

local function CreateSetterHandler(frameIndex)
    return function(_, v)
        local f = FF:GetFrameByIndex(frameIndex)
        f:SetFrameState(frameIndex, v)
    end
end

local function CreateGetterHandler(frameIndex)
    return function(_)
        local f = FF:GetFrameByIndex(frameIndex)
        return f:IsShownInConfig()
    end
end

function C:OnAfterAddonLoaded()
    local bars = P:GetBars()
    local count = P:GetBarSize()
end

-- Main Entry Point to config dialog
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


