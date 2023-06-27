--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub

local SpellAttributeSetter, WAttr, PH = O.SpellAttributeSetter, GC.WidgetAttributes, O.PickupHandler
local API, Assert = O.API, O.Assert
local IsNil = Assert.IsNil

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class SpellDragEventHandler : DragEventHandler
local L = LibStub:NewLibrary(M.SpellDragEventHandler); if not L then return end
---@type LoggerTemplate
local p = L.logger()

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---spellCursorInfo `{ type = actionType, name='TODO', bookIndex = info1, bookType = info2, id = info3 }`
---@param btnUI ButtonUI
---@param cursorInfo table Data structure`{ type = actionType, info1 = info1, info2 = info2, info3 = info3 }`
function L:Handle(btnUI, cursorInfo)
    if not self:IsValid(btnUI, cursorInfo) then return end
    local spellCursorInfo = { type = cursorInfo.type,
                              id = cursorInfo.info3,
                              bookIndex = cursorInfo.info1,
                              bookType = cursorInfo.info2 }

    local spellInfo = API:GetSpellInfo(spellCursorInfo.id)

    if IsNil(spellInfo) then return end

    local w = btnUI.widget
    if w:IsPassiveSpell(spellInfo.name) then return end

    if C_TradeSkillUI then
        -- https://wowpedia.fandom.com/wiki/API_GetProfessions
        local tradeSkillName = GetSpellInfo(cursorInfo.info1, BOOKTYPE_PROFESSION)
        if spellInfo.name == tradeSkillName then
            local prof1, prof2 = GetProfessions()
            if prof1 then
                local skillName, _, _, _, _, _, skillLineID = GetProfessionInfo(prof1)
                if tradeSkillName == skillName then
                    spellInfo.skillLineID = skillLineID
                    p:log('TradeSkill[%s]: skillLineID=%s', tradeSkillName, spellInfo.skillLineID)
                end
            end
        end
    end


    local btnData = w.config()
    PH:PickupExisting(w)
    btnData[WAttr.TYPE] = WAttr.SPELL
    btnData[WAttr.SPELL] = spellInfo

    SpellAttributeSetter(btnUI, btnData)
end

function L:IsValid(btnUI, cursorInfo)
    return cursorInfo.type == nil or cursorInfo == nil or cursorInfo.id == nil
end
