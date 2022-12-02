--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class DruidAPI
local L = LibStub:NewLibrary(Core.M.DruidAPI)
---@return LoggerTemplate
local p = L:GetLogger()
p:log("Hello: %s", Core.M.DruidAPI)

-- Add to Modules.lua
--DruidAPI = 'DruidAPI',
--
-----@type DruidAPI
--DruidAPI = {},

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

---@class DruidAPI_Methods
---@param o DruidAPI
local function Methods(o)
    ---@param formName string
    function o:IsActiveForm(formName)

        return false
    end
end

local function Init()
    Methods(L)
end

Init()

