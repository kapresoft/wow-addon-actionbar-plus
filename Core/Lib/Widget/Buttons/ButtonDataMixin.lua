--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.LibStub
local IsBlankString, IsEmptyTable = O.String.IsBlank, O.Table.IsEmpty
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class ButtonDataMixin : BaseLibraryObject
local L = LibStub:NewLibrary(M.ButtonDataMixin); if not L then return end
local p = L.logger


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

---@param o ButtonDataMixin
local function PropsAndMethods(o)

    ---@param config Profile_Button
    function o:Init(config)
        assert(config, "Config is required")
        self.config = config
    end

    function o:IsEmpty()
        local type = self.config.type
        if IsBlankString(type) then return true end
        if IsEmptyTable(self.config[type]) then return true end
        return false
    end

end

PropsAndMethods(L)
