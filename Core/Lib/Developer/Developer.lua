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
local ab = O.ActionBarHandlerMixin

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
Hooks
-------------------------------------------------------------------------------]]
function L.OnAddOnReady()
    if not ShadowUF then L:CustomFrameLocations() end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
-- /dump a:c("\n\t  ")
function L:c(str)
    return O.MacroChangesController.OnMacroChanged()
end

-- /run a:f1()
function L:f1()

    --- @type ActionBarFrame
    local f = ActionbarPlusF1
    f:ClearAllPoints()
    f:SetPoint("BOTTOMRIGHT", MultiBarBottomRight, "TOPRIGHT", 0, 5)

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
--- @param buttonIndex Index
--- @return ButtonUIWidget
function L:GetButton(frameIndex, buttonIndex)
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

function L:PetAction()
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

-- Name: ||::AB Form1
-- /run a:align()
function L:SetupButtonsLargeUI()

    local fb = O.ActionBarFrameBuilder
    --- @type _AnchorUtil
    local AnchorUtil = AnchorUtil

    local alpha1 = 1
    local alpha2  = 1

    --- @param fr ActionBarFrame
    local function toUIParent(fr)
        local screenX, screenY = fr:GetCenter()
        fr:ClearAllPoints()
        fr:SetPoint("CENTER", UIParent, "BOTTOMLEFT", screenX, screenY)
    end

    --- @type ActionBarFrame
    local f1 = ActionbarPlusF1
    f1.widget:SetFrameState(true)
    f1.widget:SetButtonCount(1, 11)
    f1.widget:SetButtonWidth(50)
    f1.widget:SetButtonAlpha(alpha1)
    f1:ClearAllPoints()
    f1:SetPoint("TOP", UIParent, "TOP", 0, -5)
    f1.widget:UpdateAnchor()

    if not f1:IsShown() then return end
    --- @type ActionBarFrame
    local f2 = ActionbarPlusF2
    f2.widget:SetFrameState(true)
    f2.widget:SetButtonCount(1, 13)
    f2.widget:SetButtonWidth(35)
    f2.widget:SetButtonAlpha(alpha2)
    f2:ClearAllPoints()
    f2:SetPoint("TOPRIGHT", f1, "BOTTOMRIGHT", -3, -3)
    toUIParent(f2)
    f2.widget:UpdateAnchor()

    --- @type ActionBarFrame
    local f3 = ActionbarPlusF3
    if f3:IsShown() then
        f3.widget:SetButtonAlpha(alpha2)
    end

    --- @type ActionBarFrame
    local f4 = ActionbarPlusF4
    f4.widget:SetFrameState(true)
    f4.widget:SetButtonCount(2, 3)
    f4.widget:SetButtonWidth(60)
    f4.widget:SetButtonAlpha(alpha2)
    f4:ClearAllPoints()
    f4:SetPoint("BOTTOMRIGHT", UIParent, "CENTER", -100, 50)
    f4.widget:UpdateAnchor()

    --- @type ActionBarFrame
    local f5 = ActionbarPlusF5
    f5.widget:SetFrameState(true)
    f5.widget:SetButtonCount(2, 3)
    f5.widget:SetButtonWidth(60)
    f5.widget:SetButtonAlpha(alpha2)
    f5:ClearAllPoints()
    f5:SetPoint("BOTTOMLEFT", UIParent, "CENTER", 100, 50)
    f5.widget:UpdateAnchor()

    --- @type ActionBarFrame
    local f10 = ActionbarPlusF10
    f10.widget:SetFrameState(true)
    f10.widget:SetButtonCount(1, 7)
    f10.widget:SetButtonWidth(30)
    f10.widget:SetButtonAlpha(alpha2)
    f10:ClearAllPoints()
    f10:SetPoint("BOTTOMRIGHT", MultiBarBottomRight, "TOPRIGHT", -3, 3)
    toUIParent(f10)
    f10.widget:UpdateAnchor()
end

function L:SecureFuncExample()
    --[[--- @type ActionBarFrame
    local f1 = ActionbarPlusF1
    --- @type ActionBarFrame
    local f2 = ActionbarPlusF2
    f2.widget:SetButtonCount(1, 13)

    -- example on how to lock
    local function LockF2ToF1()
        f2:ClearAllPoints()
        f2:SetPoint("TOP", f1, "BOTTOM", 0, -4)
    end
    -- Initial positioning
    LockF2ToF1()

    -- Lock dynamically against outside modifications
    hooksecurefunc(f2, "SetPoint", function()
        if not InCombatLockdown() then
            LockF2ToF1()
        end
    end)

    hooksecurefunc(f2, "ClearAllPoints", function()
        if not InCombatLockdown() then
            LockF2ToF1()
        end
    end)]]
end

-- /run a:p()
function L:CustomFrameLocations()
    if ShadowUF then return end

    local scale = 0.85
    local ofsy = -200
    if ns:IsMoP() then ofsy = -120 end

    --- @type Frame
    local pf = PlayerFrame
    pf:SetScale(scale)
    pf:ClearAllPoints()
    pf:SetPoint("TOPRIGHT", UIParent, "CENTER", -100, ofsy)

    local tf = TargetFrame
    tf:ClearAllPoints()
    tf:SetScale(scale)
    tf:SetPoint("TOPLEFT", UIParent, "CENTER", 100, ofsy)
end

--s.CreateEquipmentSet('Heals', 135907)
--s.CreateEquipmentSet('Shadow', 136207)
--s.SaveEquipmentSet(1)
--s.SaveEquipmentSet(0)
--s.DeleteEquipmentSet(0)
--s.PickupEquipmentSet(0)
--s.PickupEquipmentSet(1)
--s.DeleteEquipmentSet(0)
function L:CreateES1() local icon=135907; C_EquipmentSet.CreateEquipmentSet('Heals', icon) end
function L:CreateES2() local icon=136207; C_EquipmentSet.CreateEquipmentSet('Shadow', icon) end

-- /dump a:SaveES1()
function L:SaveES1() C_EquipmentSet.SaveEquipmentSet(0); p:vv('First EquipmentSet Saved.') end
-- /dump a:SaveES2()
function L:SaveES2() C_EquipmentSet.SaveEquipmentSet(1); p:vv('Second EquipmentSet Saved.') end
function L:PickupES1() C_EquipmentSet.PickupEquipmentSet(0) end
-- /dump a:PickupES2()
function L:PickupES2() C_EquipmentSet.PickupEquipmentSet(1) end
function L:DelES1() C_EquipmentSet.DeleteEquipmentSet(0) end
function L:DelES2() C_EquipmentSet.DeleteEquipmentSet(1) end


L:RegisterMessage(ns.GC.M.OnAddOnReady, L.OnAddOnReady)
