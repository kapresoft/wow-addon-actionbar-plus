--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M = ns.O, ns.GC, ns.M

--- @class Compat
local L = ns:NewLibStd(M.Compat)
local p = ns:CreateDefaultLogger(M.Compat)

--- Checks if a spell is passive, compatible with both Retail and Classic WoW.
--- @param spellIDOrName SpellID_Name_Or_Index
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
