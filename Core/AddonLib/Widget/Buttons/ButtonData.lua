--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetMacroSpell = GetMacroSpell

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = ABP_Namespace(...)
local LibStub, Core, O = ns.O.LibStub, ns.Core, ns.O

local String, Assert = O.String, O.Assert
local WAttr = O.GlobalConstants.WidgetAttributes
local SPELL, ITEM, MACRO, MOUNT, COMPANION, BATTLE_PET =
    WAttr.SPELL, WAttr.ITEM, WAttr.MACRO, WAttr.MOUNT,
    WAttr.COMPANION, WAttr.BATTLE_PET
local P, API = O.Profile, O.API

local IsBlank, IsNil = String.IsBlank, Assert.IsNil

local p = __K_Core:NewLogger('ButtonData')

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function removeElement(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then tbl[i] = nil end
    end
end

---@param profileButton Profile_Button
local function CleanupTypeData(profileButton)
    if profileButton == nil or profileButton.type == nil then return end
    local btnTypes = { SPELL, MACRO, ITEM, MOUNT}
    removeElement(btnTypes, profileButton.type)
    for _, v in ipairs(btnTypes) do
        if v ~= nil then profileButton[v] = {} end
    end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param bd ButtonData
local function methods(bd)

    function bd:GetBarConfig() return self.widget.dragFrame:GetConfig() end

    function bd:invalidButtonData(o, key)
        if type(o) ~= 'table' then return true end
        if type(o[key]) ~= 'nil' then
            local d = o[key]
            if type(d) == 'table' then return (IsBlank(d['id']) and IsBlank(d['index'])) end
        end
        return true
    end

    ---@return Profile_Button
    function bd:GetConfig()
        local w = self.widget
        local profile = w.profile
        local profileButton = profile:GetButtonData(w.frameIndex, w.buttonName)
        -- self cleanup
        CleanupTypeData(profileButton)
        return profileButton
    end

    ---@return Profile_Config
    function bd:GetProfileConfig() return self.widget.profile:P() end
    ---@return boolean
    function bd:IsHideWhenTaxi() return self.widget.profile:IsHideWhenTaxi() end
    ---@return boolean
    function bd:ContainsValidAction() return self:GetActionName() ~= nil end
    ---@return string
    function bd:GetActionName()
        local conf = self:GetConfig()
        if not self:invalidButtonData(conf, SPELL) then return conf.spell.name end
        if not self:invalidButtonData(conf, ITEM) then return conf.item.name end
        if not self:invalidButtonData(conf, MACRO) then return conf.macro.name end
        return nil
    end

    ---@return Profile_Spell
    function bd:GetSpellInfo()
        local w = self.widget
        ---@type Profile_Spell
        local spellInfo
        local conf = w:GetConfig()
        if not conf and (conf.spell or conf.macro) then return false end
        if w:IsConfigOfType(conf, SPELL) then
            spellInfo = conf[SPELL]
        elseif w:IsConfigOfType(conf, MACRO) and conf.macro.index then
            local macroSpellId =  GetMacroSpell(conf.macro.index)
            spellInfo = API:GetSpellInfo(macroSpellId)
        end
        if not (spellInfo and spellInfo.name) then return nil end
        return spellInfo
    end
    function bd:IsShapeshiftOrStealthSpell() return API:IsShapeshiftOrStealthSpell(self:GetSpellInfo()) end

    function bd:IsStealthSpell()
        local spellInfo = self:GetSpellInfo()
        if not (spellInfo and spellInfo.name) then return false end
        return API:IsStealthSpell(spellInfo.name)
    end
    function bd:IsShapeshiftSpell()
        local spellInfo = self:GetSpellInfo()
        if not (spellInfo and spellInfo.name) then return false end
        return API:IsShapeshiftSpell(spellInfo)
    end

    ---@type Profile_Item
    function bd:GetItemInfo() return self:GetConfig()[ITEM] end
    ---@type Profile_Macro
    function bd:GetMacroInfo() return self:GetConfig()[MACRO] end
    ---@return Profile_Mount
    function bd:GetMountInfo() return self:GetConfig()[MOUNT] end
    ---@return Profile_Companion
    function bd:GetCompanionInfo() return self:GetConfig()[COMPANION] end
    ---@return Profile_BattlePet
    function bd:GetBattlePetInfo() return self:GetConfig()[BATTLE_PET] end

    function bd:ConfigContainsValidActionType()
        if not type then return false end
        local btnConf = self:GetConfig()
        if not btnConf then return false end
        if IsBlank(btnConf.type) then return false end

        return true
    end

    ---@param m Profile_Mount
    function bd:IsInvalidMount(m)
        return IsNil(m) and IsNil(m.name) and IsNil(m.spell) and IsNil(m.spell.id)
    end

    ---@param c Profile_Companion
    function bd:IsInvalidCompanion(c)
        return IsNil(c) and IsNil(c.name) and IsNil(c.spell) and IsNil(c.spell.id)
    end

    ---@param pet Profile_BattlePet
    function bd:IsInvalidBattlePet(pet) return IsNil(pet) and IsNil(pet.guid) and IsNil(pet.name) end

    function bd:IsShowIndex() return P:IsShowIndex(self.widget.frameIndex) end
    function bd:IsShowEmptyButtons() return P:IsShowEmptyButtons(self.widget.frameIndex) end
    function bd:IsShowKeybindText() return P:IsShowKeybindText(self.widget.frameIndex) end

end

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local _B = LibStub:NewLibrary(Core.M.ButtonData)

---@param widget ButtonUIWidget
---@return ButtonData
function _B:Constructor(widget)
    ---@class ButtonData
    local o = { widget = widget }
    methods(o)
    return o
end

_B.mt.__call = _B.Constructor
