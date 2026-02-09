--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local MSG = ns.GC.M
local LW_SKILL_ID = 165
local DRAGON_FLIGHT_LW_ICON = 4620678

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = ns.M.ProfessionController
--- @class ProfessionController
local L = ns:NewLib(libName)
local p = ns:CreateDefaultLogger(libName)
local ps = ns:LC().SPELL:NewLogger(libName)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function _lwspellfn(sp) return function() return 'sp.icon[%s/%s] is DF-LW=%s', sp.name, sp.icon, DRAGON_FLIGHT_LW_ICON == sp.icon end end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o ProfessionController | ModuleV2
local function PropsAndMethods(o)

    --- Called Automatically
    --- @see ModuleV2Mixin#Init
    function o:OnAddOnReady()
        if not self:IsInScope() then
            p:d('No special handling for LW Profession required.');
            return
        end
        self:RegisterMessage(MSG.OnButtonClickLeatherworking, function()
            self:OnButtonClickLeatherworking()
        end)
    end

    --- @private
    function o:IsInScope() return C_TradeSkillUI and C_TradeSkillUI.OpenTradeSkill end

    ---@param sp SpellInfoBasic
    function o:IsNewLeatherWorkingSpell(sp)
        if not self:IsInScope() then return false end
        local spIcon = sp and sp.icon; if not spIcon then return false end
        ps:d(_lwspellfn(sp))
        return DRAGON_FLIGHT_LW_ICON == sp.icon
    end

    --- Retail handles Leatherworking a little different
    function L:OnButtonClickLeatherworking()
        if ProfessionsFrame and ProfessionsFrame:IsVisible() then
            C_TradeSkillUI.CloseTradeSkill();
            return
        end
        C_TradeSkillUI.OpenTradeSkill(LW_SKILL_ID)
    end

end; PropsAndMethods(L)


