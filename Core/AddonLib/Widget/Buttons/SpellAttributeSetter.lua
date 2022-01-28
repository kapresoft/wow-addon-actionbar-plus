-- ## External -------------------------------------------------
local format = string.format
local GameTooltip = GameTooltip

-- ## Local ----------------------------------------------------
local LibStub, M, Assert, P, LSM, W, CC, G = ABP_WidgetConstants:LibPack()
local PrettyPrint, Table, String, LOG = ABP_LibGlobals:LibPackUtils()
local IsNotBlank, AssertNotNil = String.IsNotBlank, Assert.AssertNotNil
local BAttr, WAttr, UAttr = W:LibPack_WidgetAttributes()
local ANCHOR_TOPLEFT = ANCHOR_TOPLEFT

local TEXTURE_EMPTY, TEXTURE_HIGHLIGHT = ABP_WidgetConstants:GetButtonTextures()
local cooldowns = {}

---@class SpellAttributeSetter
local _L = LibStub:NewLibrary(M.SpellAttributeSetter)

-- ## Functions ------------------------------------------------

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
    W:ResetWidgetAttributes(btnUI)

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

    btnUI:SetScript("OnEnter", function(_btnUI) self:ShowTooltip(_btnUI, btnData)  end)
    btnUI.cooldownFrame.spellInfo = spellInfo

    btnUI:RegisterForDrag('LeftButton')
    btnUI:SetScript("OnDragStart", function(_btnUI)
        if InCombatLockdown() then return end
        if P:IsLockActionBars() and not IsShiftKeyDown() then return end
        _btnUI:ClearCooldown()
        _L:log(20, 'DragStarted| Actionbar-Info: %s', pformat(_btnUI:GetActionbarInfo()))
        PickupSpell(spellInfo.id)
        W:ResetWidgetAttributes(_btnUI)
        btnData[WAttr.SPELL] = {}
        btnUI:SetNormalTexture(TEXTURE_EMPTY)
        btnUI:SetScript("OnEnter", nil)
    end)

    btnUI:HookScript('OnClick', function(_btnUI, mouseButton, down)
        cooldowns[spellInfo.id] = _btnUI
        local info = _API_Spell:GetSpellCooldown(spellInfo.id, spellInfo.name)
        _btnUI:SetCooldown(info)

        --_L:log("### Cooldown #1: %s", Table.toStringSorted(info))

        --_L:log('Clicked: %s[%s] duration=%s start=%s, modRate=%s, enabled=%s', info.spell.name,
        --        info.spell.id, info.duration, info.start, info.modRate, info.enabled)
        --if 1 == info.enabled then
        --    _btnUI:SetCooldown(info)
        --end

    end)

    local info = _API_Spell:GetSpellCooldown(spellInfo.id, spellInfo.name)
    if 1 == info.enabled and info.start > 0 then
        btnUI:SetCooldown(info)
    end

end

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

--- So that we can call with SetAttributes(btnUI)
_L.mt.__call = _L.SetAttributes



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

--- TODO: Fire an AceEvent?
local function OnEvent(frame, event, ...)
    if not (event == 'UNIT_SPELLCAST_SUCCEEDED' or event == 'UNIT_SPELLCAST_SENT') then return end

    local unit, unitTarget, target, castGUID, spellID
    local evt = 'SUCCEEDED'
    if event == 'UNIT_SPELLCAST_SENT' then
        evt = 'SENT'
        unit, target, castGUID, spellID = ...
    else
        unitTarget, castGUID, spellID = ...
    end
    --if unitTarget ~= 'player' then return end
    --_L:log('Event: %s args: %s', event, pformat({...}))
    local spell = _API_Spell:GetSpellInfo(spellID)
    local logEvent = false
    local logCooldown = true
    if logEvent then
        _L:log('SpellCast event=%s spell=%s[%s] unitTarget=%s target=%s',
                evt, spell.name, spellID, unitTarget or '', target or '')
    end

    local btnUI = cooldowns[spellID]
    if not btnUI then return end

    --local info1 = _API_Spell:GetSpellCooldown(spellID)
    --_L:log('CD#1: %s[%s] duration=%s start=%s, modRate=%s, enabled=%s', info1.spell.name,
    --        info1.spell.id, info1.duration, info1.start, info1.modRate, info1.enabled)
    --btnUI:SetCooldown(info1)

    local function updateCooldown()
        local info = _API_Spell:GetSpellCooldown(spellID)
        -- Don't update cooldown on instant cast spells
        if info.duration <= 0 then
            if logCooldown then
                _L:log('%s[%s][%s] <<SKIPPED>>', spell.name, spellID, evt)
            end
            return
        end
        btnUI:SetCooldown(info)
        if logCooldown then
            _L:log('%s[%s][%s]\n%s', spell.name, spellID, evt, Table.toStringSorted(info))
            if evt == 'SUCCEEDED' then _L:log('') end
        end
    end

    --Update #1: When clicked (and Global CD)
    --updateCooldown()

    --Update #2: Spell Cooldown
    --info.modRate is always 1 somehow
    --ABP_wait(0, updateCooldown)

    if event == 'UNIT_SPELLCAST_SENT' then
        updateCooldown()
    else
        ABP_wait(0, updateCooldown)
    end
end

local frame = CreateFrame("Frame", "ABP_SpellAttributesSetterFrame", UIParent)
frame:SetScript("OnEvent", OnEvent)
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
frame:RegisterEvent("UNIT_SPELLCAST_SENT")