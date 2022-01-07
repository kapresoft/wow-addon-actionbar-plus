local _G = _G
local format,IsNotBlank = string.format, string.IsNotBlank
local GetSpellSubtext, GetSpellInfo, GetSpellLink = GetSpellSubtext, GetSpellInfo, GetSpellLink
local CreateFrame  = CreateFrame

local S = {}
_Spell = S

--- See:
---  * https://wowpedia.fandom.com/wiki/API_GetSpellInfo
---@param spellNameOrId string Spell ID or Name
function S:GetSpellInfo(spellNameOrId)
    local name, _, icon, castTime, minRange, maxRange, id = GetSpellInfo(spellNameOrId)
    if name then
        local subTextOrRank = GetSpellSubtext(spellNameOrId)
        local spellLink = GetSpellLink(spellNameOrId)
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