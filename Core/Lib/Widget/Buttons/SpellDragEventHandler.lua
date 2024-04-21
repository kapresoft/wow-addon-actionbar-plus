--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

local API, Assert, String, PH = O.API, ns:Assert(), ns:String(), O.PickupHandler
local IsNil, AssertNotNil = Assert.IsNil, Assert.AssertNotNil
local IsNotBlank = String.IsNotBlank
local BAttr, WAttr, UAttr = GC.ButtonAttributes,  GC.WidgetAttributes, GC.UnitIDAttributes

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
        if w:IsPassiveSpell(spellInfo.name) then return end

        local btnData = w:conf()
        PH:PickupExisting(w)
        btnData[WAttr.TYPE] = WAttr.SPELL
        btnData[WAttr.SPELL] = spellInfo

        S(btnUI, btnData)
    end

    function e:IsValid(btnUI, cursorInfo)
        return cursorInfo.type == nil or cursorInfo == nil or cursorInfo.id == nil
    end
end


--[[-----------------------------------------------------------------------------
Methods: SpellAttributeSetter
-------------------------------------------------------------------------------]]
---@param a SpellAttributeSetter
local function attributeSetterMethods(a)
    ---@param btnUI ButtonUI The UIFrame
    ---@param btnData Profile_Button The button data
    function a:SetAttributes(btnUI, btnData)
        local w = btnUI.widget
        w:ResetWidgetAttributes()

        local spellInfo = w:GetSpellData()
        if type(spellInfo) ~= 'table' then return end
        if not spellInfo.id then return end
        AssertNotNil(spellInfo.id, 'btnData[spell].spellInfo.id')

        local spellIcon = GC.Textures.TEXTURE_EMPTY
        if spellInfo.icon then spellIcon = API:GetSpellIcon(spellInfo) end
        w:SetIcon(spellIcon)

        btnUI:SetAttribute(BAttr.UNIT2, UAttr.FOCUS)

        btnUI:SetAttribute(WAttr.TYPE, WAttr.SPELL)
        local spellAttrValue = API:GetSpellAttributeValue(spellInfo)
        btnUI:SetAttribute(WAttr.SPELL, spellAttrValue)

        self:OnAfterSetAttributes(btnUI)
    end

    ---@param btnUI ButtonUI
    function a:ShowTooltip(btnUI)
        local w = btnUI.widget
        if not w:ConfigContainsValidActionType() then return end

        local spellInfo = w:GetSpellData()
        if w:IsInvalidSpell(spellInfo) then return end

        GameTooltip:SetSpellByID(spellInfo.id)

        -- Replace 'Spell' with 'Spell (Rank #Rank)'
        if (IsNotBlank(spellInfo.rank)) then
            GameTooltip:AppendText(format(' |cff565656(%s)|r', spellInfo.rank))
        end

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
