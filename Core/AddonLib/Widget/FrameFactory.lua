local _G, type, ipairs, tinsert = _G, type, ipairs, table.insert
local WLIB, Assert = WidgetLibFactory, Assert

local F = {}
FrameFactory = F

local P = WidgetLibFactory:GetProfile()

local function Embed(frame)
    local P = WLIB:GetProfile()
    local AssertThatMethodArgIsNotNil = Assert.AssertThatMethodArgIsNotNil

    frame.rendered = false
    frame.buttons = {}

    function frame:GetFrameIndex()
        return self.frameIndex
    end

    function frame:Toggle()
        if self:IsShown() then self:Hide(); return end
        self:Show()
    end

    function frame:SetFrameState(frameIndex, isEnabled)
        AssertThatMethodArgIsNotNil(frameIndex, 'frameIndex', 'SetFrameState(frameIndex)')
        P:SetBarEnabledState(frameIndex, isEnabled)
        if isEnabled then
            if self.ShowGroup then self:ShowGroup() end
            return
        end
        if self.HideGroup then self:HideGroup() end
    end

    -- Synchronize UI and Profile data
    function frame:IsShownInConfig(frameIndex)
        AssertThatMethodArgIsNotNil(frameIndex, 'frameIndex', 'IsShownInConfig(frameIndex)')
        local actualFrameIsShown = self:IsShown()
        P:SetBarEnabledState(frameIndex, actualFrameIsShown)
        return P:IsBarEnabled(frameIndex)
    end

    function frame:ToggleGroup()
        if #self.buttons > 0 then
            local firstBtn = _G[self.buttons[1]]
            if firstBtn:IsShown() then self:HideGroup()
            else self:ShowButtons() end
        end
    end

    function frame:HideGroup()
        self:Hide()
        self:HideButtons()
    end

    function frame:ShowGroup()
        self:Show()
        self:ShowButtons()
    end

    function frame:ShowButtons()
        for _, btnName in ipairs(self.buttons) do
            _G[btnName]:Show()
        end
    end

    function frame:HideButtons()
        for _, btnName in ipairs(self.buttons) do
            _G[btnName]:Hide()
        end
    end

    function frame:AddButton(buttonName)
        if type(buttonName) ~= 'string' then return end
        tinsert(self.buttons, buttonName)
    end

    function frame:GetButtonCount() return #self.buttons end

    function frame:GetButtons()
        return self.buttons
    end

    function frame:IsRendered()
        return self.rendered
    end

    function frame:IsNotRendered()
        return not self:IsRendered()
    end

    function frame:MarkRendered()
        self.rendered = true
    end

end

--local function getProfileUtil()
--    if not P then P = WidgetLibFactory:GetProfile() end
--    return P
--end

function F:GetFrameByIndex(frameIndex)
    local frameName = P:GetFrameNameByIndex(frameIndex)
    return _G[frameName]
end

function F:IsFrameShownByIndex(frameIndex)
    return self:GetFrameByIndex(frameIndex):IsShown()
end

function F:CreateFrame(frameIndex)
    local f = self:GetFrameByIndex(frameIndex)
    if type(f) ~= 'table' then return end

    f.frameIndex = frameIndex
    Embed(f)

    return f
end

setmetatable(F, {
    __call = function (_, ...)
        return F:CreateFrame(...)
    end
})