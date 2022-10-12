---@class CompanionInfo
---### Doc: [https://wowpedia.fandom.com/wiki/API_GetCompanionInfo](https://wowpedia.fandom.com/wiki/API_GetCompanionInfo)
local CompanionInfo = {
    ['petType'] = 'critter',
    ['index'] = -1,
    ['creatureID'] = -1,
    ['creatureName'] = '',
    ['creatureSpellID'] = -1,
    ['icon'] = '',
    ['isSummoned'] = false,
    ---  0x1: Ground
    ---  0x2: Can fly
    ---  0x4: ? (set for most mounts)
    ---  0x8: Underwater
    ---  0x10: Can jump (turtles cannot)
    ['mountType'] = -1
}

---@class CompanionCursor
---type: 'companion'
---info1: index
---info2: petType see PET_TYPE_SUFFIX
---### See Interface_<wow-version>/FrameXML/Constants.lua#PET_TYPE_SUFFIX
local CompanionCursor = {
    ['type'] = 'companion',
    ['index'] = -1,
    ['petType'] = 'Critter',
}