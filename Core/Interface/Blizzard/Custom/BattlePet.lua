---@class BattlePetInfo
local BattlePetInfo = {
    ['guid'] = 'BattlePet-0-000008C13591',
    ---some battle pets are faction-based
    ['canSummon'] = true,
    ['speciesID'] = 2779,
    ['customName'] = '',
    ['level'] = 1,
    ['xp'] = 0,
    ['maxXp'] = 50,
    ['displayID'] = 93349,
    ['isFavorite'] = true,
    ['name'] = 'Anima Wyrmling',
    ['icon'] = 3038273,
    ['petType'] = 2,
    ['creatureID'] = 157969,
    ['sourceText'] = 'Promotion: Shadowlands Epic Edition',
    ['description'] = 'Even the smallest creatures in the Shadowlands rely on anima to survive.',
    ['isWild'] = false,
    ['canBattle'] = true,
    ['tradable'] = false,
    ['unique'] = true,
    ['obtainable'] = true
}

---@class BattlePetCursor
local BattlePetCursor = {
    type='battlepet',
    --- info1
    --- GUID of a battle pet in your collection.
    guid = ''
}