--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetShapeshiftForm = GetShapeshiftForm

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, LibStub, ns = ABP_LibPack()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class DruidAPI : BaseLibraryObject
local L = LibStub:NewLibrary(ns.M.DruidAPI)

local p = L:GetLogger()

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

