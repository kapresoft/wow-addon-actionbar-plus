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
        _L:log(10, 'Clicked spell: %s', spellInfo.name)
        cooldowns[spellInfo.id] = _btnUI
    end)

    btnUI:HookScript('OnClick', function(_btnUI, mouseButton, down)
        local info = _API_Spell:GetSpellCooldown(spellInfo.id, spellInfo.name)
        --if info.start == 0 then info.start = GetTime() end
        --if info.duration == 0 then info.duration = 1.5 end
        _L:log('Clicked: %s', pformat(info))
        if 1 == info.enabled then
            _btnUI:SetCooldown(info)
        end
    end)

    local info = _API_Spell:GetSpellCooldown(spellInfo.id, spellInfo.name)
    if 1 == info.enabled then
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
    if (type(delay)~="number" or type(func)~="function") then
    return false;
    end
    if (waitFrame == nil) then
        waitFrame = CreateFrame("Frame", "WaitFrame", UIParent);
        waitFrame:SetScript("onUpdate", function (self, elapse)
            local count = #waitTable;
            local i = 1;
            while (i<=count) do
                local waitRecord = tremove(waitTable, i);
                local d = tremove(waitRecord, 1);
                local f = tremove(waitRecord, 1);
                local p = tremove(waitRecord, 1);
                if(d>elapse) then
                    tinsert(waitTable,i,{d-elapse, f, p});
                    i = i + 1;
                else
                    count = count - 1;
                    f(unpack(p));
                end
            end
        end );
    end
    tinsert(waitTable,{delay, func,{...}});
    return true;
end

--- TODO: Fire an AceEvent?
local function OnEvent(frame, event, ...)
    --print('event:', event)
    if (event ~= 'UNIT_SPELLCAST_SUCCEEDED') then return end
    local unitTarget, castGUID, spellID = ...
    _L:log('Event: %s args: %s', event, pformat({...}))

    local btnUI = cooldowns[spellID]
    if not btnUI then return end


    local function updateCooldown()
        local info = _API_Spell:GetSpellCooldown(spellID)
        btnUI:SetCooldown(info)
    end

    local info = _API_Spell:GetSpellCooldown(spellID)
    local delay = info.modRate + 0.2
    ABP_wait(delay, updateCooldown)

end

local frame = CreateFrame("Frame", "ABP_SpellAttributesSetterFrame", UIParent)
frame:SetScript("OnEvent", OnEvent)
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")