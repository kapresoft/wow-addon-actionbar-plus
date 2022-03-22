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

    local function removeElement(tbl, value)
        for i, v in ipairs(tbl) do
            if v == value then tbl[i] = nil end
        end
    end

    local function CleanupTypeData(bd)
        if bd == nil or bd.type == nil then return end
        local btnTypes = { 'spell', 'macro', 'item'}
        removeElement(btnTypes, bd.type)
        for _, v in ipairs(btnTypes) do
            if v ~= nil then bd[v] = {} end
        end
    end

    function bd:GetData()
        local bd = self.profile:GetButtonData(self.widget.frameIndex, self.widget.buttonName)
        -- self cleanup
        CleanupTypeData(bd)
        return bd
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
