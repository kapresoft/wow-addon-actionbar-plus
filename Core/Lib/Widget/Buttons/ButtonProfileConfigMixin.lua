--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M = ns.O, ns.GC, ns.M

local String, Table, W = ns:String(), ns:Table(), GC.WidgetAttributes
local IsEmptyTable = Table.IsEmpty
local IsBlankStr = String.IsBlank
local select = select

--[[-----------------------------------------------------------------------------
This is a new and enhanced button config mixin
-------------------------------------------------------------------------------]]
--- @return ButtonProfileConfigMixin, Kapresoft_CategoryLogger
local function CreateLib()
    local libName = M.ButtonProfileConfigMixin
    --- @class ButtonProfileConfigMixin : Profile_Button
    --- @field private conf Profile_Button
    local newLib = ns:NewMixin(libName); if not newLib then return nil end
    local logger = ns:CreateDefaultLogger(libName)

    --- Initializes the mixin with a configuration table.
    --- ```
    --- local btnConf = ButtonProfileConfigMixin:New(conf:Profile_Button)
    --- btnConf:IsEmpty()
    ---```
    --- All unknown field access (get/set) will proxy to conf.
    --- @param conf Profile_Button The button config table
    --- @return ButtonProfileConfigMixin
    function newLib:New(conf)
        assert(conf, 'Button Profile Config is missing.')
        local newObj = ns:K():CreateFromMixins(self)
        newObj.conf  = conf
        setmetatable(newObj, {
            __index = function(tbl, key)
                return tbl.conf and tbl.conf[key]
            end,
            __newindex = function(tbl, key, value)
                rawset(tbl.conf, key, value)
            end
        })
        return newObj
    end

    return newLib, logger
end; local L, p = CreateLib(); if not L then return end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o ButtonProfileConfigMixin
local function PropsAndMethods(o)

    function o:IsEmpty()
        local conf = self.conf
        if IsEmptyTable(conf) then return true end

        local t = conf.type
        if IsBlankStr(t) then return true end

        return IsEmptyTable(conf[t])
    end

    --- @return string
    function o:GetName()
        if self:IsEmpty() then return nil end

        if self:IsSpell() then return self.spell.name
        elseif self:IsItem() then return self.item.name
        elseif self:IsMacro() then return self.macro.name
        elseif self:IsEquipmentSet() then return self.equipmentset.name
        end

        return nil
    end

    ---@return boolean
    function o:IsSpell() return self:VTD(W.SPELL, "id", "name", "icon") end
    ---@return boolean
    function o:IsItem() return self:VTD(W.ITEM, "id") end
    ---@return boolean
    function o:IsMacro() return self:VTD(W.MACRO, "index", "name") end
    ---@return boolean
    function o:IsMacroText() return self:VTD(W.MACRO_TEXT, "body") end
    ---@return boolean
    function o:IsMount() return self:VTD(W.MOUNT, "name") end
    ---@return boolean
    function o:IsCompanion() return self:VTD(W.COMPANION, "id") end
    ---@return boolean
    function o:IsBattlePet() return self:VTD(W.BATTLE_PET, "name") end
    ---@return boolean
    function o:IsCompanionWOTLK() return self:IsCompanion() or self:IsBattlePet() end
    ---@return boolean
    function o:IsEquipmentSet() return self:VTD(W.EQUIPMENT_SET, "name") end

    --- @see WidgetAttributes
    --- @param expectedType string The button type
    function o:IsType(expectedType)
        local t = self.type
        return not self:IsEmpty() and t == expectedType and type(self[t]) == "table"
    end

    --- Utility to validate a config's type and existence of nested keys
    --- @param expectedType string
    --- @vararg string keys to check in the resolved config table
    --- @return boolean
    function o:HasValidTypeData(expectedType, ...)
        if not self:IsType(expectedType) then return false end
        local t = self[self.type]
        if type(t) ~= "table" then return false end

        for i = 1, select("#", ...) do
            local key = select(i, ...)
            if t[key] == nil then return false end
        end
        return true
    end

    function o:VTD(expectedType, ...) return self:HasValidTypeData(expectedType, ...) end

    --- Clear all fields and set a blank type field
    function o:Reset()
        if not self:IsEmpty() then
            p:i(function() return 'Reset[%s]: %s', self.type, self:GetName() end)
        end
        local conf = self.conf
        for k in pairs(conf) do conf[k] = nil end
        conf[W.TYPE] = ''
    end

end; PropsAndMethods(L)

