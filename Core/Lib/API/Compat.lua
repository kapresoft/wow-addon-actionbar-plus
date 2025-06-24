--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CSpell_IsAutoRepeatSpell = C_Spell and C_Spell.IsAutoRepeatSpell or IsAutoRepeatSpell
local CSpell_IsCurrentSpell    = C_Spell and C_Spell.IsCurrentSpell or IsCurrentSpell
local C_GetSpecializationInfo  = C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo or C_GetSpecializationInfo
local C_GetActiveSpecGroup     = C_SpecializationInfo and C_SpecializationInfo.GetActiveSpecGroup
local C_GetItemCount           = C_Item and C_Item.GetItemCount or GetItemCount
local C_GetItemInfo            = C_Item and C_Item.GetItemInfo or GetItemInfo
local C_GetItemInfoInstant     = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
local C_GetItemSpell           = C_Item and C_Item.GetItemSpell or GetItemSpell
local C_IsUsableItem           = C_Item and C_Item.IsUsableItem or IsUsableItem
local C_PickupItem             = C_Item and C_Item.PickupItem or PickupItem
local GetSpecialization        = GetSpecialization
local GetActiveTalentGroup     = GetActiveTalentGroup

local FIRST_SPEC_INDEX     = 1
local SECOND_SPEC_INDEX    = 2
local THIRD_SPEC_INDEX   = 2
local FOURTH_SPEC_INDEX = 2

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M = ns.O, ns.GC, ns.M

--- @class Compat
local L = ns:NewLibStd(M.Compat)
local p = ns:CreateDefaultLogger(M.Compat)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @return boolean
--- @param o any An object to evaluate
local function IsFn(o) return 'function' == type(o) end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param spell SpellIdentifier | "'Auto Attack'" | "6603"
--- @return boolean
function L:IsCurrentSpell(spell) return CSpell_IsCurrentSpell(spell) end

--- This returns true for Water elemental (3167) and Auto Attack (6603)
--- Returns false for an UIError
--- @param spellIDorName SpellIdentifier | "'Smite'" | "585"
--- @return boolean
function L:IsCurrentSpell(spellIDorName)
    return spellIDorName and CSpell_IsCurrentSpell(spellIDorName)
end

--- @param spellIDorName SpellIdentifier | "'Smite'" | "585"
--- @return boolean
function L:IsAutoRepeatSpell(spellIDorName)
    return spellIDorName and CSpell_IsAutoRepeatSpell(spellIDorName)
end

--- @param specIndex number
--- @return Identifier, Name
function L:GetSpecializationInfo(specIndex) return C_GetSpecializationInfo(specIndex, false, false) end

--- C_SpecializationInfo.GetSpecialization
--- 1, 2, 3 retail ; 1, 2 classic
--- @return number
function L:GetSpecializationID()
    if IsFn(GetSpecialization) then return GetSpecialization()
    elseif IsFn(GetActiveTalentGroup) then return GetActiveTalentGroup()
    -- C_GetActiveSpecGroup: MoP Classic (the active specIndex tab)
    elseif IsFn(C_GetActiveSpecGroup) then return C_GetActiveSpecGroup()
    end
    return 1
end

--- @return boolean Returns true if the wow env supports dual or multi spec
function L:SupportsDualOrMultiSpec()
    return self:SupportsDualSpec() or self:SupportsDualSpecMoP() or self:SupportsMultiSpec()
end

--- @return boolean Returns true if the wow env supports dual spec
function L:SupportsDualSpec()
    return self:SupportsDualSpecCata() or self:SupportsDualSpecMoP()
end

--- @return boolean Returns true if the wow env supports dual spec
function L:SupportsDualSpecCata()
    local ok, result = pcall(function()
        return (GetNumTalentGroups and GetNumTalentGroups() > 1) or false
    end)
    return ok and (result == true)
end

--- @return boolean Returns true if the wow env supports dual spec
function L:SupportsDualSpecMoP()
    local ok, result = pcall(function()
        return type(GetNumSpecGroups) == 'function' and GetNumSpecGroups() > 1
    end)
    return ok and (result == true)
end

--- @return boolean Returns true if the wow env supports more than dual spec (up to 4)
function L:SupportsMultiSpec()
    return (GetNumSpecializations and GetNumSpecializations() > 1) or false
end

--- @return number The number of available specs
function L:GetAvailableSpecCount()
    if GetNumTalentGroups then return GetNumTalentGroups() end
    if GetNumSpecializations then return GetNumSpecializations() end
    return 1
end

--- @return boolean Returns true if the environment supports dual spec and the feature flag is enabled.
function L:IsDualSpecEnabled()
    if GC.F.ENABLE_MULTI_SPEC ~= true then return false end
    return self:SupportsDualSpec()
end

--- @return boolean Returns true if the environment supports dual spec and the feature flag is enabled.
function L:IsMultiSpecEnabled()
    if GC.F.ENABLE_MULTI_SPEC ~= true then return false end
    return self:SupportsDualSpec() or self:SupportsMultiSpec()
end

--- @return boolean
function L:IsPrimarySpec() return FIRST_SPEC_INDEX == self:GetSpecializationID() end
--- @return boolean
function L:IsSecondarySpec() return SECOND_SPEC_INDEX == self:GetSpecializationID() end
--- @return boolean
function L:IsTertiarySpec() return THIRD_SPEC_INDEX == self:GetSpecializationID() end
--- @return boolean
function L:IsQuaternarySpec() return FOURTH_SPEC_INDEX == self:GetSpecializationID() end

--- Checks if a spell is passive, compatible with both Retail and Classic WoW.
--- @param spellIDOrName SpellIdentifier
--- @return boolean|nil isPassive True if the spell is passive, or nil if not found.
function L:IsPassiveSpell(spellIDOrName)
    if C_Spell and C_Spell.IsSpellPassive then
        return C_Spell.IsSpellPassive(spellIDOrName)
    elseif IsPassiveSpell then
        return IsPassiveSpell(spellIDOrName)
    end
    return nil
end

--- Checks if a spell is in range for the specified target, compatible with both Retail and Classic WoW.
--- @param spell SpellID_Name_Or_Index The ID, name, or index of the spell to check.
--- @param target UnitID The target unit to check range against (e.g., "target", "focus", "player").
--- @return IsInRange boolean|nil True if the spell is in range, false otherwise, or nil if not found.
function L:IsSpellInRange(spell, target)
    if C_Spell and C_Spell.IsSpellInRange then
        return C_Spell.IsSpellInRange(spell, target)
    elseif IsSpellInRange then
        return IsSpellInRange(spell, target)
    end
    return nil
end

--- @param spellName SpellName
--- @return boolean The spell is known to the character
function L:IsSpellKnown(spellName)
    return type(spellName) == "string" and self:GetSpellInfo(spellName) ~= nil
end

--- Checks if a spell is usable, compatible with both Retail and Classic WoW.
--- @param spellIDOrName SpellID_Name_Or_Index
--- @return IsUsable, boolean IsUsable, NoMana
function L:IsUsableSpell(spellIDOrName)
    if C_Spell and C_Spell.IsSpellUsable then
        return C_Spell.IsSpellUsable(spellIDOrName)
    elseif IsUsableSpell then
        return IsUsableSpell(spellIDOrName)
    end
    return nil, nil
end

--- Retrieves the spell ID of a buff on the player by index.
--- Automatically adjusts for Retail and Classic versions of WoW.
--- @param index Index The index of the buff to check (starting at 1).
--- @return SpellID|nil number|SpellID|nil spellID The spell ID of the buff, or nil if no buff is found.
function L:GetBuffSpellID(index)
    if UnitBuff then
        -- Classic, TBC, and WotLK Classic versions
        local _, _, _, _, _, _, _, _, _, unitBuffSpellId = UnitBuff("player", index)
        return unitBuffSpellId
    else
        -- Retail version
        local aura = C_UnitAuras.GetAuraDataByIndex("player", index, "HELPFUL")
        if aura then
            return aura.spellId
        end
    end
    return nil
end

--- Retrieves the cooldown information for a spell, compatible with both Retail and Classic WoW.
--- @param spellIDOrName SpellID_Name_Or_Index
--- @return StartTime, Duration, Enabled, ChargeModRate
function L:GetSpellCooldown(spellIDOrName)
    if C_Spell and C_Spell.GetSpellCooldown then
        local cooldownInfo = C_Spell.GetSpellCooldown(spellIDOrName)
        if cooldownInfo then
            return cooldownInfo.startTime, cooldownInfo.duration, cooldownInfo.isEnabled, cooldownInfo.modRate
        end
    elseif GetSpellCooldown then
        return GetSpellCooldown(spellIDOrName)
    end
    return nil, nil, nil, nil
end

--- Retrieves spell information, compatible with both Retail and Classic WoW.
--- @param spellIDOrName SpellID_Name_Or_Index
--- @return SpellName, nil, Icon, CastTime, MinRange, MaxRange, SpellID, OriginalIcon
function L:GetSpellInfo(spellIDOrName)
    if C_Spell and C_Spell.GetSpellInfo then
        local spellInfo = C_Spell.GetSpellInfo(spellIDOrName)
        if spellInfo then
            return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID
        end
    elseif GetSpellInfo then
        return GetSpellInfo(spellIDOrName)
    end
    return nil
end

--- Retrieves the hyperlink of a spell, compatible with both Retail and Classic WoW.
--- @param spellIDOrName SpellID_Name_Or_Index
--- @return string|nil spellLink The hyperlink for the spell, or nil if not found.
function L:GetSpellLink(spellIDOrName)
    if C_Spell and C_Spell.GetSpellLink then
        return C_Spell.GetSpellLink(spellIDOrName)
    elseif GetSpellLink then
        return GetSpellLink(spellIDOrName)
    end
    return nil
end

--- Retrieves the subtext or rank of a spell, compatible with both Retail and Classic WoW.
--- @param spellIDOrName SpellID_Name_Or_Index
--- @return string|nil subText The subtext or rank of the spell, or nil if not found.
function L:GetSpellSubtext(spellIDOrName)
    if C_Spell and C_Spell.GetSpellDescription then
        --- @type SpellInfo
        local spellInfo = C_Spell.GetSpellInfo(spellIDOrName)
        if spellInfo then
            return spellInfo.name -- For some spells, detailed descriptions can be fetched this way
        end
    elseif GetSpellSubtext then
        return GetSpellSubtext(spellIDOrName)
    end
    return nil
end

--- Picks up the specified spell, compatible with both Retail and Classic WoW.
--- @param spell SpellID_Name_Or_Index The ID, name, or index of the spell to pick up.
function L:PickupSpell(spell)
    if C_Spell and C_Spell.PickupSpell then
        C_Spell.PickupSpell(spell)
    elseif PickupSpell then
        PickupSpell(spell)
    end
end

--- Checks if a spell has a range, compatible with both Retail and Classic WoW.
--- @param spell SpellID_Name_Or_Index The ID, name, or index of the spell to check.
--- @return boolean|nil hasRange True if the spell has a range, false otherwise, or nil if not found.
function L:SpellHasRange(spell)
    if C_Spell and C_Spell.SpellHasRange then
        return C_Spell.SpellHasRange(spell)
    elseif SpellHasRange then
        return SpellHasRange(spell)
    end
    return nil
end

--- @param item ItemInfo
--- @param includeBank OptionalFlag If true, includes the bank
--- @param includeUses OptionalFlag If true, includes each charge of an item similar to GetActionCount()
--- @param includeReagentBank OptionalFlag If true, includes the reagent bank
function L:GetItemCount(item, includeBank, includeUses, includeReagentBank) return C_GetItemCount(item, includeBank, includeUses, includeReagentBank) end

--- @param item ItemInfo
--- @return ItemID, ItemType, ItemSubType, ItemEquipLoc, Icon, ItemClassID, SubclassID
function L:GetItemInfoInstant(item) return C_GetItemInfoInstant(item) end

--- @param item ItemInfo
--- @return ItemName, ItemLink, ItemQuality, ItemLevel, ItemLevel, ItemType, ItemSubType, ItemStackCount, ItemEquipLoc, ItemTexture, SellPrice, ItemClassID, SubclassID, BindType, ExpacID, SetID, IsCraftingReagent
function L:GetItemInfo(item) return C_GetItemInfo(item) end

--- Returns the spell effect for an item.
--- #### See: [API_GetItemSpell](https://warcraft.wiki.gg/wiki/API_GetItemSpell)
--- @param item ItemInfo
--- @return SpellName, SpellID
function L:GetItemSpell(item) return C_GetItemSpell(item) end

--- ### Usages:
--- ```
--- usable, noMana = IsUsableItem('Cookie')
--- ```
--- @param item ItemInfo
--- @return Usable, CannotBeCastedDueToLowMana
function L:IsUsableItem(item) return C_IsUsableItem(item) end

--- @param item ItemInfo
function L:PickupItem(item) return C_PickupItem(item) end
