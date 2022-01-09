local AssertNotNil = Assert.AssertNotNil
local WLIB, ItemAttributeSetter = WidgetLibFactory, ItemAttributeSetter
local ButtonAttributes, _API_Spell, IsNil = ButtonAttributes, _API_Spell, Assert.IsNil
local LOG = LogFactory

local P = WLIB:GetProfile()

local S = {}
LOG:EmbedLogger(S, 'ItemDragEventHandler')
ItemDragEventHandler = S

---@param itemCursorInfo table Structure `{ -- }`
function S:Handle(btnUI, itemCursorInfo)
    if itemCursorInfo == nil or itemCursorInfo.id == nil then return end
    --local itemInfo = _API_Spell:GetSpellInfo(spellCursorInfo.id)
    message('TODO: Implement me')
    local itemInfo = nil
    if IsNil(itemInfo) then return end
    --self:logp('spellInfo', spellInfo)

    local actionbarInfo = btnUI:GetActionbarInfo()
    --self:logp('ActionBar', actionbarInfo)
    local btnName = btnUI:GetName()
    local barData = P:GetBar(actionbarInfo.index)

    local btnData = barData.buttons[btnName] or P:GetTemplate().Button
    btnData.type = ButtonAttributes.ITEM
    btnData[btnData.type] = itemInfo
    barData.buttons[btnName] = btnData

    ItemAttributeSetter(btnUI, btnData)
end
