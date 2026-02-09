--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local ItemClass = Enum.ItemClass

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

local classNameCache = {}
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return ItemUtil, Kapresoft_CategoryLogger
local function CreateLib()
    local libName = M.ItemUtil
    --- @class ItemUtil : BaseLibraryObject
    local newLib = LibStub:NewLibrary(libName); if not newLib then return nil end
    local logger = ns:CreateDefaultLogger(libName)
    return newLib, logger
end; local L, p = CreateLib(); if not L then return end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local o = L

function o:GetItemClassNameByID(classID)
    if classNameCache[classID] then return classNameCache[classID] end

    for k, v in pairs(ItemClass) do
        if v == classID then
            classNameCache[classID] = k
            return k
        end
    end
end



