local _, _, String = ABP_LibGlobals:LibPackUtils()
local format, IsNotBlank = string.format, String.IsNotBlank
local GetSpellSubtext, GetSpellInfo, GetSpellLink = GetSpellSubtext, GetSpellInfo, GetSpellLink

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

---@return SpellCooldown
function S:GetSpellCooldown(spellID, optionalSpellName)
    local start, duration, enabled, modRate = GetSpellCooldown(spellID);
    ---@class SpellCooldown
    local info = {
        spell = { id=spellID, name=optionalSpellName },
        start = start, duration = duration, enabled = enabled, modRate = modRate }
    return info
end
