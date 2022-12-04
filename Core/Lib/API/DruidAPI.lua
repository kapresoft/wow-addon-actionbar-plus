--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetShapeshiftForm = GetShapeshiftForm

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
p:log(10, "Hello: %s", Core.M.DruidAPI)

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
    ---@param formSpellId number
    function o:IsActiveForm(formSpellId)
        local shapeShiftFormIndex = GetShapeshiftForm()
        local shapeShiftActive = false
        if shapeShiftFormIndex <= 0 then return shapeShiftActive end
        local icon, active, castable, spellID = GetShapeshiftFormInfo(shapeShiftFormIndex)
        return spellID == formSpellId and active
    end
end

local function Init()
    Methods(L)
end

Init()

