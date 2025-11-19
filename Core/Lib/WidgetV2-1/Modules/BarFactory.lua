--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, MSG, LibStub = ns.O, ns.GC, ns.M, ns.GC.M, ns.LibStub

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return BarFactory, Kapresoft_CategoryLogger
local function CreateLib()
    local libName = M.BarFactory or 'BarFactory'
    --- @class BarFactory : BaseLibraryObject
    local newLib = ns:NewLib(libName); if not newLib then return nil end
    local logger = ns:CreateDefaultLogger(libName)
    return newLib, logger
end; local L, p = CreateLib(); if not L then return end
p:v(function() return "Loaded: %s", L.name or tostring(L) end)

-- Add to Modules.lua
--BarFactory = 'BarFactory',
--
----- @type BarFactory
--BarFactory = {},

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @type BarFactory
local o = L

-- Or Use This Style
--- @param o BarFactory
local function PropsAndMethods(o)

    -- CONFIG: how many bars you want
    local NUM_BARS = 2

    --========================================================
    -- Creates a new bar module with a given index
    --========================================================
    function o:CreateBarModule(index)

        local moduleName = "Bar" .. index

        -- Create the Ace module dynamically
        local mod = ns:a():NewModule(moduleName, "AceEvent-3.0", "AceHook-3.0")
        if not mod then return end

        mod.index = index
        mod.buttons = {}

        local cols = 5
        local rows = 2

        local cfg = {
            enabled = true,
            numButtons = cols*rows,
            size = 36,
            spacing = 6,
        }

        --------------------------------------------------------
        -- LIFECYCLE
        --------------------------------------------------------

        function mod:OnInitialize() end

        function mod:OnEnable()
            local index = self.index

            if not cfg.enabled then
                return self:Disable()
            end

            ----------------------------------------------------
            -- create bar frame from XML virtual template
            ----------------------------------------------------
            local frameName = "ActionbarPlusF" .. index
            self.frame = CreateFrame("Frame", frameName, UIParent, "ABP_BarFrameTemplate_V2_1_1")

            ----------------------------------------------------
            -- create buttons
            ----------------------------------------------------
            local baseID = 1000
            for i = 1, cfg.numButtons do
                local btnName = frameName .. "Button" .. i
                --- @type CheckButton
                local btn = CreateFrame("CheckButton", btnName, self.frame, "ABP_ButtonTemplate_V2_1_1")
                p:vv(function() return 'Btn Created[%s]: %s', btn:GetID(), btn:GetName() end)
                table.insert(self.buttons, btn)
            end

            ----------------------------------------------------
            -- resize bar frame based on cols x rows
            ----------------------------------------------------
            local paddingLeft  = 16
            local paddingRight = 16
            local paddingTop   = 14
            local paddingBottom = 14

            local totalWidth  = paddingLeft + (cfg.size + cfg.spacing) * (cols - 1) + cfg.size + paddingRight
            local totalHeight = paddingTop + (cfg.size + cfg.spacing) * rows - cfg.spacing + paddingBottom

            self.frame:SetSize(totalWidth, totalHeight)

            ----------------------------------------------------
            -- layout buttons using cols x rows
            ----------------------------------------------------
            local col, row = 1, 1

            for i, btn in ipairs(self.buttons) do
                btn:SetSize(cfg.size, cfg.size)
                btn:ClearAllPoints()

                -- compute row/col based on index
                local indexInGrid = i - 1
                col = (indexInGrid % cols) + 1
                row = math.floor(indexInGrid / cols) + 1

                -- starting offsets
                local startX = 16
                local startY = -paddingTop

                -- compute position
                local x = startX + (cfg.size + cfg.spacing) * (col - 1)
                local y = startY - (cfg.size + cfg.spacing) * (row - 1)

                -- anchor inside the frame
                btn:SetPoint("TOPLEFT", self.frame, "TOPLEFT", x, y)
            end
        end

        function mod:OnDisable()
            if self.frame then
                self.frame:Hide()
            end
        end

        return mod
    end

    --========================================================
    -- Create ALL bars dynamically
    --========================================================
    function o:CreateAllBars()
        for i = 1, NUM_BARS do
            self:CreateBarModule(i)
        end
    end

end; PropsAndMethods(L)


L:RegisterMessage(MSG.OnAddOnEnabledV2, function(msg, source, addOn)
    p:vv('OnAddOnEnabled() called...')
    L:CreateAllBars()
end)
