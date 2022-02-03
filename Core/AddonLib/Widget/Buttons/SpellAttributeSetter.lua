-- Wow APIs
local GameTooltip, CreateFrame = GameTooltip, CreateFrame
local UIParent = UIParent

-- Lua APIs
local format = string.format
local tinsert, tremove = table.insert, table.remove
local unpack = unpack

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]

local LibStub, M, Assert, P, LSM, W, CC, G = ABP_WidgetConstants:LibPack()
local PrettyPrint, Table, String, LOG = ABP_LibGlobals:LibPackUtils()
local IsNotBlank, AssertNotNil = String.IsNotBlank, Assert.AssertNotNil
local BAttr, WAttr, UAttr = W:LibPack_WidgetAttributes()
local ANCHOR_TOPLEFT = ANCHOR_TOPLEFT

local TEXTURE_EMPTY, TEXTURE_HIGHLIGHT, TEXTURE_CASTING = ABP_WidgetConstants:GetButtonTextures()

---@class SpellAttributeSetter
local _L = LibStub:NewLibrary(M.SpellAttributeSetter)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

local waitTable = {};
local waitFrame = nil;

---#### Source
---* [https://wowwiki-archive.fandom.com/wiki/USERAPI_wait]
local function ABP_wait(delay, func, ...)
    if (type(delay)~="number" or type(func)~="function") then return false end
    if (waitFrame == nil) then
        waitFrame = CreateFrame("Frame", "WaitFrame", UIParent);
        waitFrame:SetScript("onUpdate", function (self, elapse)
            local count = #waitTable
            local i = 1
            while (i<=count) do
                local waitRecord = tremove(waitTable, i)
                local d = tremove(waitRecord, 1)
                local f = tremove(waitRecord, 1)
                local p = tremove(waitRecord, 1)
                if(d>elapse) then
                    tinsert(waitTable,i,{d-elapse, f, p})
                    i = i + 1
                else
                    count = count - 1
                    f(unpack(p))
                end
            end
        end)
    end
    tinsert(waitTable,{delay, func,{...}})
    return true
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

---@param link table The blizzard `GameTooltip` link
function _L:ShowTooltip(btnUI, btnData)
    if not btnUI or not btnData then return end
    local type = btnData.type
    if not type then return end

    local spellInfo = btnData[WAttr.SPELL]
    GameTooltip:SetOwner(btnUI, ANCHOR_TOPLEFT)
    GameTooltip:AddSpellByID(spellInfo.id)
    -- Replace 'Spell' with 'Spell (Rank #Rank)'
    if (IsNotBlank(spellInfo.rank)) then
        GameTooltip:AppendText(format(' |cff565656(%s)|r', spellInfo.rank))
    end
end

---### Button Data Example
---
---```lua
---['ActionbarPlusF1Button1'] = {
---   ['type'] = 'spell',
---   ['spell'] = {
---       -- spellInfo
---   }
---}
---```
---@param btnUI table The UIFrame
---@param btnData table The button data
function _L:SetAttributes(btnUI, btnData)
    btnUI.widget:ResetWidgetAttributes()

    ---@type SpellInfo
    local spellInfo = btnData[WAttr.SPELL]
    if type(spellInfo) ~= 'table' then return end
    if not spellInfo.id then return end
    AssertNotNil(spellInfo.id, 'btnData[spell].spellInfo.id')

    local spellIcon = TEXTURE_EMPTY
    if spellInfo.icon then spellIcon = spellInfo.icon end
    btnUI:SetNormalTexture(spellIcon)
    btnUI:SetHighlightTexture(TEXTURE_HIGHLIGHT)
    btnUI:SetAttribute(WAttr.TYPE, WAttr.SPELL)
    btnUI:SetAttribute(WAttr.SPELL, spellInfo.id)
    btnUI:SetAttribute(BAttr.UNIT2, UAttr.FOCUS)

end

--- So that we can call with SetAttributes(btnUI)
_L.mt.__call = _L.SetAttributes
