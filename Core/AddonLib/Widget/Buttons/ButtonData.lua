--[[-----------------------------------------------------------------------------
ButtonData.lua
-------------------------------------------------------------------------------]]

-- WoW APIs
local CreateFrame = CreateFrame

-- Lua APIs
local format = string.format

-- Local APIs
local LibStub, M, P, LogFactory = ABP_LibGlobals:LibPack_NewLibrary()
local WAttr = ABP_CommonConstants.WidgetAttributes

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param bd ButtonData
local function ApplyMethods(bd)

    function bd:GetData()
        return self.profile:GetButtonData(self.widget.frameIndex, self.widget.buttonName)
    end

    function bd:IsActionTypeSpell()
        return self:GetData().type == WAttr.SPELL
    end

    function bd:IsLockActionBars()
        return self.profile:IsLockActionBars()
    end
end


--[[-----------------------------------------------------------------------------
Builder Methods
-------------------------------------------------------------------------------]]
---@type ButtonDataBuilder
local _B = LogFactory:NewLogger('ButtonDataBuilder', {})

---@param builder ButtonDataBuilder
local function ApplyBuilderMethods(builder)

    ---@param widget ButtonUIWidget
    function builder:Create(widget)
        ---@class ButtonData
        local bd = {
            profile = P,
            widget = widget
        }
        ApplyMethods(bd)

        return bd
    end

end

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local function NewLibrary()
    ---@class ButtonDataBuilder
    local _L = LibStub:NewLibrary(M.ButtonDataBuilder, 1)
    ApplyBuilderMethods(_L)
    return _L
end

NewLibrary()
