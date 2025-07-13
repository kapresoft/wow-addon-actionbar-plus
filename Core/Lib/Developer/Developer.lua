------------------------------------------------------------------------
-- test stuff.
------------------------------------------------------------------------
local format = string.format
--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local SetCVar, GetCVarBool  = SetCVar, GetCVarBool

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O = ns.O
local AceEvent = ns:AceLibrary().AceEvent
local P = O.Profile

ABP_enableV2 = false
ns.features.enableV2 = ABP_enableV2

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'Developer'
--- @class Developer : BaseLibraryObject_WithAceEvent
local L = {}; AceEvent:Embed(L); a = L
local p = ns:LC().DEV:NewLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function L:f1()

    -- Disc: 256
    -- Shadow: 258
    -- /dump GetSpecializationInfoForClassID(5, 1)
    -- /dump GetSpecializationInfoForSpecID(258)

    local D = O.DruidUnitMixin
    local Pr = O.PriestUnitMixin

    local playerC  = D:GetPlayerUnitClass()
    local isDruid  = D:IsUs(playerC)
    local isPriest = Pr:IsUs(playerC)

    --ActionbarPlusF1.widget.frameHandle:ClearBackdrop()
    p:vv(function() return 'f1 unit class: %s is-druid: %s is-priest: %s class-id: %s',
            playerC, isDruid, isPriest, O.PriestUnitMixin:ClassID() end)
end
--- /dump IsSpellKnown(106785)
--- /dump IsSpellKnown(C_Spell.GetSpellIDForSpellIdentifier('Swipe'))
--- /dump C_Spell.GetSpellIDForSpellIdentifier('Swipe')
--- /dump C_Spell.DoesSpellExist('Swipe')
function L:sp1()

    local spellids = { [348] = 1, [116858] = 1, [29722] = 1 }
    for i = 1, 100 do
        local info = C_SpellBook.GetSpellBookItemInfo(i, Enum.SpellBookSpellBank.Player)
        if info.name == 'Swipe' then
        p:vv(function() return 'info=%s', info end) end
        --if info and spellids[info.spellID] then print("Slot:", i, "ID:", info.spellID, info.name) end
    end

end

function L:sp1b()

    local spellids = { [348] = 1, [116858] = 1, [29722] = 1 }
    for i = 1, 100 do
        local info = GetSpellBookItemInfo(i, Enum.SpellBookSpellBank.Player)
        if info.name == 'Swipe' then
            p:vv(function() return 'info=%s', info end) end
        --if info and spellids[info.spellID] then print("Slot:", i, "ID:", info.spellID, info.name) end
    end

end

-- /run a:cs2()
function L:cs2()
    ns.db.profile.spec2_init = nil
    p:vv('profile.spec2_init cleared')
end

-- /dump a:spc()
function L:spc()
    p:vv(function() return 'Spec Available: %s', O.Compat:GetAvailableSpecCount() end)
end

function L:TT()
    self:SendMessage(ns.GC.M.OnTooltipFrameUpdate, libName)
end

--- down or up
function L:KDT()
    local useKeyDown = GetCVarBool("ActionButtonUseKeyDown")
    p:v(function() return 'ActionButtonUseKeyDown[before]: %s', tostring(useKeyDown) end)
    useKeyDown = not useKeyDown
    SetCVar("ActionButtonUseKeyDown", useKeyDown)
    p:v(function() return 'ActionButtonUseKeyDown[current]: %s', tostring(useKeyDown) end)
    return useKeyDown
end

function L:ResetBarConfig()

    for i = 1, 8 do
        --- @type ActionBarFrame
        local f = _G['ActionbarPlusF' .. i]
        local w = f.widget
        local cf = w:GetConfig()
        cf.enabled = nil
        cf.anchor = nil
        cf.widget.buttonSize = nil
    end

end

function L:GetGlobalProfile() return P:G() end


function L:AnchorX(frameIndex, x)
    local fw = self:F(frameIndex).widget
    local a = fw:GetConfig().anchor
    a.x = x
end
function L:AnchorReset(frameIndex)
    local fw = self:F(frameIndex).widget
    local barData = fw:GetConfig()
    --barData.anchor = {}
    local a = barData.anchor
    a.point = nil
    a.relativePoint = nil
    a.x = nil
    a.y = nil
    print('Anchor Reset Done')
end

--- @param frameIndex Index
--- @param buttonIndex Index
--- @return ActionBarFrameWidget
function L:F(frameIndex, buttonIndex)
    if not buttonIndex then return _G['ActionbarPlusF' .. tostring(frameIndex)].widget end
    return self:B(frameIndex, buttonIndex)
end

--- @param frameIndex Index
--- @return Profile_Bar
function L:C(frameIndex) return self:F(frameIndex):GetConfig() end

function L:M() return GetMouseFocus() end

--- @param frameIndex Index
--- @param buttonIndex Index
--- @return ButtonUIWidget
function L:B(frameIndex, buttonIndex)
    local bn = string.format('ActionbarPlusF%sButton%s', frameIndex, buttonIndex)
    return _G[bn].widget
end

function L:API() return O.BaseAPI, O.API end
function L:NS() return ns end
function L:O() return ns.O end

function L:SM(msg) self:SendMessage(msg, libName) end


--- Get the button attributes. Used only for debugging
--- @return table<string, string>
--- @param frameIndex Index
--- @param buttonIndex Index
function L:BA(frameIndex, buttonIndex)
    local ret = {}
    local attributes = {
        "type", "spell", "item", "unit", "macro", "toy",
        "harmbutton1", "harmbutton2", "helpbutton1", "helpbutton2",
        "spell-nuke1", "spell-nuke2", "alt-spell-nuke1", "alt-spell-nuke2",
        "target", "action", "actionbar", "flyout", "glyph", "stop",
        "focus", "assist", "click", "attribute", "togglemenu",
        "destroymenu",
    }
    local bw = self:B(frameIndex, buttonIndex)
    for _, attr in ipairs(attributes) do
        local value = bw.button():GetAttribute(attr)
        if value then ret[attr] = value; end
    end

    return ret
end

-- Prints the number of talent points spent in each talent tree for the current specialization.
function L:t1()
    local totalPoints = 0
    for i = 1, GetNumTalentTabs() do
        local name, _, pointsSpent = GetTalentTabInfo(i)
        print(name .. " tree: " .. pointsSpent .. " points")
        totalPoints = totalPoints + pointsSpent
    end
    print("Total points spent: " .. totalPoints)
end
-- Prints the number of talent points spent in each talent tree for the current specialization.
function L:t()
    local info = O.UnitMixin:GetTalentInfo()
    c('Talent:', info)
end

-- Prints the currently selected talents for each tier in the player's current specialization.
function L:tr()
    local specIndex = GetSpecialization()
    if not specIndex then
        c("You need to be in a specialization to use this function.")
        return
    end

    local _, specName = GetSpecializationInfo(specIndex)
    c("Current Specialization: " .. specName)

    for tier = 1, 7 do -- Talent tiers generally range from 1 to 7
        for column = 1, 3 do -- There are typically three talents per tier
            local talentID, name, texture, selected = GetTalentInfoBySpecialization(specIndex, tier, column)
            if selected then
                c("Tier " .. tier .. ": " .. name)
            end
        end
    end
end


function L:c()
    local c = ns.chatFrame
    for i=1, NUM_PET_ACTION_SLOTS, 1 do
        local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID, checksRange, inRange = GetPetActionInfo(i);
        if name then
            local x = { name=name, texture=texture, isToken=isToken,
                     isActive=isActive, autoCastAllowed=autoCastAllowed,
                     autoCastEnabled=autoCastEnabled, spellID=spellID,
                     checksRange=checksRange, inRange=inRange }
            c:log('pet-action:', pformat(x))
        end
    end
end

function L:c1()
    c('chatFrame:', ns.chatFrame:IsSelected())

    for i = 1, NUM_CHAT_WINDOWS do
        local name, fontSize, r, g, b, alpha, isSelected = GetChatWindowInfo(i)
        c('tab:', name, 'selected:', isSelected)
    end

end
