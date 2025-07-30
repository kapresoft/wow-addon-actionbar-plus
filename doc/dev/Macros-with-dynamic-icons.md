## Macros With Dynamic Icons To Test

### Priest

**Attack Sequence:**
```text
#showtooltip
/target [@mouseover,harm,nodead,nocombat]
/startattack [harm,exists]
/castsequence [harm,exists] reset=combat/target/7 Holy Fire, Shadow Word: Pain, Mind Blast, Smite
```

**Attack With Item:**
```text
/cast [@mouseover,harm] Cold Basilisk Eye; [@mouseover,help] Renew(Rank 1); Renew(Rank 1)
```

**With MouseOver To Test Dynamic Icons:**
```text
/target [@mouseover,harm,exists]
/cast [@mouseover,harm,exists] Mind Blast(Rank 1); [@mouseover,help,exists]Lesser Heal(Rank 1); Renew
```

** With Modifiers:**
```text
/cast [mod:shift] Mind Blast; Mind Flay
```
