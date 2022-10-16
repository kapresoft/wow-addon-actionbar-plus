--- Events: UNIT_SPELLCAST_START, UNIT_SPELLCAST_STOP, UNIT_SPELLCAST_FAILED_QUIET
--- Doc: [https://wowpedia.fandom.com/wiki/UNIT_SPELLCAST_START](https://wowpedia.fandom.com/wiki/UNIT_SPELLCAST_START)
--- @class _SpellCastEventArguments
local SpellCastEventArguments = {
    --- @see Blizzard_UnitId
    ['unitTarget'] = 'player',
    ['castGUID'] = 'Cast-3-55548-571-4-etc...',
    ['spellID'] = 53142,
}

--- Events: UNIT_SPELLCAST_SENT
--- Doc:  [https://wowpedia.fandom.com/wiki/UNIT_SPELLCAST_SENT](https://wowpedia.fandom.com/wiki/UNIT_SPELLCAST_SENT)
--- @class _SpellCastSentEventArguments
local SpellCastSentEventArguments = {
    --- @see Blizzard_UnitId
    ['unit'] = 'player',
    ['target'] = 'player',
    ['castGUID'] = 'Cast-3-55548-571-4-etc...',
    ['spellID'] = 53142,
}
