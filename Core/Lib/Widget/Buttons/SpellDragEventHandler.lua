--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

local API, Assert, String, PH = O.API, ns:Assert(), ns:String(), O.PickupHandler
local IsNil, AssertNotNil = Assert.IsNil, Assert.AssertNotNil
local IsNotBlank, IsBlank = String.IsNotBlank, String.IsBlank
local BAttr, WAttr, UAttr = GC.ButtonAttributes,  GC.WidgetAttributes, GC.UnitIDAttributes
local Compat, Dru = O.Compat, O.DruidUnitMixin

--[[-----------------------------------------------------------------------------
New Instance: SpellDragEventHandler
-------------------------------------------------------------------------------]]
--- @class SpellDragEventHandler : DragEventHandler
local L = LibStub:NewLibrary(M.SpellDragEventHandler); if not L then return end
local p = ns:LC().DRAG_AND_DROP:NewLogger(M.SpellDragEventHandler)

--[[-----------------------------------------------------------------------------
New Instance: SpellAttributeSetter
-------------------------------------------------------------------------------]]
---@class SpellAttributeSetter : BaseAttributeSetter
local S = LibStub:NewLibrary(M.SpellAttributeSetter); if not L then return end

---@type BaseAttributeSetter
local BaseAttributeSetter = LibStub(M.BaseAttributeSetter)

--[[-----------------------------------------------------------------------------
Methods: SpellDragEventHandler
-------------------------------------------------------------------------------]]
---@param e SpellDragEventHandler
local function eventHandlerMethods(e)

    ---spellCursorInfo `{ type = actionType, name='TODO', bookIndex = info1, bookType = info2, id = info3 }`
    ---@param btnUI ButtonUI
    ---@param cursorInfo table Data structure`{ type = actionType, info1 = info1, info2 = info2, info3 = info3 }`
    function e:Handle(btnUI, cursorInfo)
        if not self:IsValid(btnUI, cursorInfo) then return end
        local spellCursorInfo = { type = cursorInfo.type,
                                  id = cursorInfo.info3,
                                  bookIndex = cursorInfo.info1,
                                  bookType = cursorInfo.info2 }
        p:d(function() return 'cursor: %s', pformat:B()(spellCursorInfo) end)
        local spellInfo = API:GetSpellInfo(spellCursorInfo.id)
        if IsNil(spellInfo) then return end

        local w = btnUI.widget
        if Compat:IsPassiveSpell(spellInfo.name) then return end

        local btnData = w:conf()
        PH:PickupExisting(w)
        btnData[WAttr.TYPE] = WAttr.SPELL
        btnData[WAttr.SPELL] = self:ToSpellData(spellInfo)

        p:f3(function()
            local sp1, sp2, btn1, btn2 = w:_confButtonNames()
            return 'button data: primary[%s->%s], secondary[%s->%s]', sp1, btn1, sp2, btn2
        end)

        S(btnUI)
    end

    function e:IsValid(btnUI, cursorInfo)
        return cursorInfo.type == nil or cursorInfo == nil or cursorInfo.id == nil
    end

    --- @private
    --- @param sp SpellInfo
    --- @return Profile_Spell
    function e:ToSpellData(sp)
        if not sp then return nil end
        return {
            id = sp.id, name = sp.name, icon = sp.icon,
            runeSpell = sp.runeSpell,
        }
    end

end


--[[-----------------------------------------------------------------------------
Methods: SpellAttributeSetter
-------------------------------------------------------------------------------]]
--- @param a SpellAttributeSetter
local function attributeSetterMethods(a)
    ---@param btnUI ButtonUI The UIFrame
    function a:SetAttributes(btnUI)
        local w = btnUI.widget
        w:ResetWidgetAttributes()

        local spell = w:GetSpellData()
        if type(spell) ~= 'table' then return end
        if not spell.id then return end
        AssertNotNil(spell.id, 'btnData[spell].spellInfo.id')

        local spellIcon = GC.Textures.TEXTURE_EMPTY
        if spell.icon then spellIcon = API:GetSpellIcon(spell) end
        w:SetIcon(spellIcon)

        btnUI:SetAttribute(BAttr.UNIT2, UAttr.FOCUS)

        btnUI:SetAttribute(WAttr.TYPE, WAttr.SPELL)
        local spellAttrValue = API:GetSpellAttributeValue(spell)
        btnUI:SetAttribute(WAttr.SPELL, spellAttrValue)

        self:SetAttributesCataclysmDruid(btnUI, spell)

        p:f1(function() return 'SpellID[%s]: %s', spell.name, spell.id end)

        w:UpdateSpellCheckedStateDelayed()
        self:OnAfterSetAttributes(btnUI)
    end

    --- @param spell SpellInfo
    --- @param btnUI ButtonUI
    function a:SetAttributesCataclysmDruid(btnUI, spell)
        if not Dru:IsCataclysmDruidSpecializedSpell(spell.id) then return end

        p:f1(function() return 'Druid special attribute spell[%s]: %s', spell.name, spell.id end)
        btnUI:SetAttribute(WAttr.SPELL, spell.id)
    end

    --- @param btnUI ButtonUI
    function a:ShowTooltip(btnUI)
        local w = btnUI.widget
        if not w:ConfigContainsValidActionType() then return end

        local spellInfo = w:GetSpellData()
        if w:IsInvalidSpell(spellInfo) then return end

        GameTooltip:SetSpellByID(spellInfo.id)

        -- Replace 'Spell' with 'Spell (Rank #Rank)'
        if not GetSpellBookItemName then return end
        local rank = self:GetHighestSpellRank(spellInfo.name)
        if IsBlank(rank) then return end
        GameTooltip:AppendText(format(' |cff565656(%s)|r', rank))
    end

    function a:GetHighestSpellRank(spellName)
        if not GetSpellBookItemName then return nil end
        local i = 1
        local lastRank
        while true do
            local name, rank = GetSpellBookItemName(i, BOOKTYPE_SPELL)
            if not name then break end
            if rank and name == spellName then lastRank = rank end
            i = i + 1
        end
        return lastRank
    end

end

--[[-----------------------------------------------------------------------------
Init
-------------------------------------------------------------------------------]]
local function Init()
    eventHandlerMethods(L)
    attributeSetterMethods(S)

    S.mt.__index = BaseAttributeSetter
    S.mt.__call = S.SetAttributes
end

Init()
