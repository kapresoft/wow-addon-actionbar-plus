--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

local seedID = 4999

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return BarFrameTemplate_V2_1_1, Kapresoft_CategoryLogger
local function CreateLib()
    local libName = M.BarFrameTemplate_V2_1_1 or 'BarFrameTemplate_V2_1_1'
    --- @class BarFrameTemplate_V2_1_1 : BaseLibraryObject
    local newLib = ns:NewMixin(libName); if not newLib then return nil end
    local logger = ns:CreateDefaultLogger(libName)
    return newLib, logger
end; local L, p = CreateLib(); if not L then return end
p:v(function() return "Loaded: %s", L.name or tostring(L) end)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o BarFrameTemplate_V2_1_1 | Frame
local function PropsAndMethods(o)

    --[[-----------------------------------------------------------------------------
    Mixin Methods
    -------------------------------------------------------------------------------]]
    --- @param self Frame
    function o.OnLoad(self)
        C_Timer.After(1, function()
            p:vv(function() return 'OnLoad: %s', self:GetName() end)
        end)
        if ABP_enableV2 ~= true then self:UnregisterAllEvents(); self:Hide(); return; end
        self:RegisterForDrag("LeftButton")
        self:SetScale(UIParent:GetScale())

        ABP_ApplyBackdrop(self, ABP_BACKDROPS.backdrop)

        --local numButtons = 5
        --local buttonSize = 36
        --local padding = 6 -- space between buttons
        --local paddingAll = 14
        --
        --local totalWidth = paddingAll + (numButtons * buttonSize) + ((numButtons - 1) * padding) + paddingAll
        --local totalHeight = buttonSize + paddingAll + paddingAll
        --
        --self:SetSize(totalWidth, totalHeight)
    end

    function o.OnDragStart(self) self:StartMoving() end
    function o.OnDragStop(self) self:StopMovingOrSizing() end


end; PropsAndMethods(L)

ABP_BarFrameTemplateMixin_V2_1_1 = L
