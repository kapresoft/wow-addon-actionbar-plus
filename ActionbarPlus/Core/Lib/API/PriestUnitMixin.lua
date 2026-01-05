--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return PriestUnitMixin, LoggerV2
local function CreateLib()
    local libName = M.PriestUnitMixin
    --- @class __PriestUnitMixin : UnitMixin
    local newLib = LibStub:NewLibrary(libName); if not newLib then return nil end
    --- @alias PriestUnitMixin __PriestUnitMixin | BaseLibraryObject
    O.UnitMixin:New(newLib, 'PRIEST')
    return newLib, ns:CreateDefaultLogger(libName)
end; local L, p = CreateLib(); if not L then return end


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o __PriestUnitMixin
local function PropsAndMethods(o)
    o.SHADOW_FORM_SPELL_ID = 15473
    o.SHADOW_FORM_SPELL_ID_RETAIL = 232698

    local formActiveIcon = (function()
        local activeIconClassic = ns.sformat(o.ADDON_TEXTURES_DIR_FORMAT, 'spell_shadowform_active')
        return {
            retail   = 136116,
            mop      = 136200,
            default  = activeIconClassic,
        }
    end)()

    ---@param spellID SpellID
    function o:IsShadowFormSpell(spellID)
        return spellID == self.SHADOW_FORM_SPELL_ID
                or spellID == self.SHADOW_FORM_SPELL_ID_RETAIL end

    --- @return boolean
    function o:IsInShadowForm()
        return self:IsBuffActive(self.SHADOW_FORM_SPELL_ID)
                or self:IsBuffActive(self.SHADOW_FORM_SPELL_ID_RETAIL) end

    function o:GetShadowFormActiveIcon()
        if ns:IsRetail() then return formActiveIcon.retail
        elseif ns:IsMoP() then return formActiveIcon.mop end
        return formActiveIcon.default
    end

end; PropsAndMethods(L)

