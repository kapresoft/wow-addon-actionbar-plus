-- Wow APIs
local GetSpellSubtext, GetSpellInfo, GetSpellLink = GetSpellSubtext, GetSpellInfo, GetSpellLink
local GetSpellCooldown = GetSpellCooldown

-- Lua APIs
local format = string.format

-- Local APIs
local _, _, String = ABP_LibGlobals:LibPackUtils()
local IsNotBlank = String.IsNotBlank

---@class API_Spell
local S = {}
---@type API_Spell
_API_Spell = S

--- See:
---  * https://wowpedia.fandom.com/wiki/API_GetSpellInfo
---### SpellInfo
---```
--- {
---    id = 1456,
---    name = 'Life Tap',
---    label = 'Life Tap (Rank 3)',
---    rank = 'Rank 3'
---    castTime = 0,
---    icon = 136126,
---    link = '[Life Tap]',
---    maxRange = 0,
---    minRange = 0,
--- }
---```
---@param spellNameOrId string Spell ID or Name
---@return SpellInfo
function S:GetSpellInfo(spellNameOrId)
    local name, _, icon, castTime, minRange, maxRange, id = GetSpellInfo(spellNameOrId)
    if name then
        local subTextOrRank = GetSpellSubtext(spellNameOrId)
        local spellLink = GetSpellLink(spellNameOrId)
        ---@class SpellInfo
        local spellInfo = { id = id, name = name, icon = icon,
                            link=spellLink, castTime = castTime,
                            minRange = minRange, maxRange = maxRange, rank = subTextOrRank }
        spellInfo.label = spellInfo.name
        if IsNotBlank(spellInfo.rank) then
            -- color codes format: |cAARRGGBB
            local labelFormat = '%s |c00747474(%s)|r'
            spellInfo.label = format(labelFormat, spellInfo.name, spellInfo.rank)
        end
        return spellInfo;
    end
    return nil
end

---@return SpellCooldownDetails
function S:GetSpellCooldownDetails(spellID, optionalSpell)
    local spell = optionalSpell or self:GetSpellInfo(spellID)
    if spell == nil then error("Spell not found: " .. spellID) end
    local start, duration, enabled, modRate = GetSpellCooldown(spellID);
    local cooldown = { start = start, duration = duration, enabled = enabled, modRate = modRate }
    ---@class SpellCooldownDetails
    local details = { spell = spell, cooldown = cooldown }
    return details
end

---@return SpellCooldown
function S:GetSpellCooldown(spellID, optionalSpell)
    local start, duration, enabled, modRate = GetSpellCooldown(spellID);
    ---@class SpellCooldown
    local info = {
        spell = { id=spellID },
        start = start, duration = duration, enabled = enabled, modRate = modRate }
    if optionalSpell then
        info.spell.details = optionalSpell
        info.spell.name = optionalSpell.name
    end
    return info
end

---@return SpellCooldownDetails
function S:GSCD(spellID, optionalSpell)
    return S:GetSpellCooldownDetails(spellID, optionalSpell)
end

---@return SpellCooldown
function S:GSC(spellID, optionalSpellName)
    return S:GetSpellCooldown(spellID, optionalSpellName)
end