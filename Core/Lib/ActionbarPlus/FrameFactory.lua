local _G, type, ipairs, tinsert = _G, type, ipairs, table.insert
FrameFactory = {}

local function Embed(frame)
    frame.buttons = {}

    function frame:Toggle()
        if self:IsShown() then self:Hide(); return end
        self:Show()
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
end

function FrameFactory:GetFrame(frameName)
    local f = _G[frameName]
    if type(f) ~= 'table' then return end

    Embed(f)

    return f
end