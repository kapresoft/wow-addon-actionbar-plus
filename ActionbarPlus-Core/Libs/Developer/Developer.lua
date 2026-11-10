--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local O = ns.O
local trace_cvar = ns.trace_ui_cvar
local Str_IsBlank = ns:String().IsBlank
local p, t = ns:log('Developer')
local unit, comp, hu = O.UnitUtil, O.Compat, O.HashUtil
local au = O.ActionUtil

--- @class Developer_ABP_2_0 : AceEvent-3.0
local o = ns:NewAceEvent(); Developer_ABP_2_0 = o; dd = o

--- @return Namespace_ABP_BarsUI_2_0
local function bar_ns() return ABP_BARSUI_NS end

--- ### Example:
--- ```lua
--- dd:ReplayAnnouncements()
--- ```
function o:ReplayAnnouncements()
  ns:g().announcementsShown = {}
  O.Announcements:ShowNextUnseen()
end

--- Prints which equipment set tooltip path this client takes (#672)
--- ### Example:
--- ```lua
--- dd:EquipmentSetInfo()
--- ```
function o:EquipmentSetInfo()
  local bySetID = C_TooltipInfo and C_TooltipInfo.GetEquipmentSet
  local numSets = C_EquipmentSet and C_EquipmentSet.GetNumEquipmentSets()
  print('Tooltip path:', bySetID and 'setID' or 'name')
  print('Equipment sets:', numSets or 'no C_EquipmentSet')
end

--- Prints whether this client gets the Retail & Forever notice (#679)
--- ### Example:
--- ```lua
--- dd:SecretRestrictionsInfo()
--- ```
function o:SecretRestrictionsInfo()
  print('HasSecretRestrictions:', ns:HasSecretRestrictions())
end

-- POC: open Masque options directly to Skin Settings/ActionbarPlus/Action Bars
-- Masque lazy-loads its 'Skins' options group only after Core:ToggleOptions()
-- runs once (triggered by the /msq slash command). There's no exposed global/API
-- to call ToggleOptions() directly, so fire the slash command first to force the
-- lazy setup, then close it and reopen targeted at our group.
function o.ms()
  local ACD = LibStub('AceConfigDialog-3.0', true)
  local m = 'Masque'

  if SlashCmdList and SlashCmdList['MASQUE'] then
    SlashCmdList['MASQUE']('') -- forces Setup('LoD'), opens to Skins/Global
    if ACD.OpenFrames[m] then ACD:Close(m) end
    t('called masq')
  end

  C_Timer.After(0.01, function()
    ACD:Open(m)
    local ok, err = pcall(
      function() ACD:SelectGroup(m, 'Skins', 'ActionbarPlus', 'ActionbarPlus_Action Bars') end
    )
    if not ok then p('ms', 'SelectGroup failed:', err) end
  end)
end

function o.OnBarsEnabled(evt)
  --local dlg = ABP_BARSUI_NS.O.QuickKeybindModeDialog
  --dlg:Open()
end

function o:disable()
  bar_ns():a():ForEach(function(module) module:Disable() end)
end

function o:enable()
  bar_ns():a():ForEach(function(module) module:Enable() end)
end

function o:macroInfo(macroIdentifier) return comp:GetMacroInfo(macroIdentifier) end
function o:hash(str) return hu.string(str) end

--- @param frameIndex Index
--- @param btnIndex Index
--- @return ButtonConfig_ABP_2_0?
function o:btnConf(frameIndex, btnIndex)
  local n = ('ABP_2_0_F%sButton%s'):format(frameIndex, btnIndex)
  --- @type Button_ABP_2_0_X
  local btn = _G[n]
  if not (btn and btn.widget) then return nil end
  return btn.widget:conf()
end

function o:skills()
  for i = 1, GetNumSkillLines() do
    local skillName, isHeader, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank =
      GetSkillLineInfo(i)
    if not isHeader then print(skillName .. ': ' .. skillRank .. '/' .. skillMaxRank) end
  end
end

--- /dump dd:IsPrimaryProfessionSpell(25230)
function o:IsPrimaryProfessionSpell(spellID)
  local prof1, prof2 = GetProfessions()
  for _, prof in ipairs({ prof1, prof2 }) do
    if prof then
      local _, _, _, _, _, _, id = GetProfessionInfo(prof)
      if id == spellID then return true end
    end
  end
  return false
end

--- @param msg string
function o:devMsg(msg) UIErrorsFrame:AddMessage('ABP: ' .. msg, 0, 1, 0) end

--- @param itemInfo ItemName|ItemID|ItemLink
--- @return ItemCooldownInfo?
function o:GetItemCooldown(itemInfo) return comp:GetItemCooldown(itemInfo) end

function o:IsSealActive(spellID)
  if not (spellID and C_UnitAuras and C_UnitAuras.GetBuffDataByIndex) then return false end
  local index = 1
  while true do
    local aura = C_UnitAuras.GetBuffDataByIndex('player', index)
    if not aura then break end
    if aura.spellId == spellID then return true end
    index = index + 1
  end
  return false
end

--[[-----------------------------------------------------------------------------
Spike #681: cooldown swipes under secret restrictions
-------------------------------------------------------------------------------]]
local HEARTHSTONE = 6948
local PROBE_ICON_SIZE = 64

--- @type Frame?
local probe

--- @param label string
--- @param point 'LEFT'|'RIGHT'
--- @return Cooldown
local function AddProbeIcon(label, point)
  local icon = probe:CreateTexture(nil, 'BACKGROUND')
  icon:SetSize(PROBE_ICON_SIZE, PROBE_ICON_SIZE)
  icon:SetPoint(point)
  local cooldown = CreateFrame('Cooldown', nil, probe, 'CooldownFrameTemplate')
  cooldown:ClearAllPoints()
  cooldown:SetAllPoints(icon)
  cooldown.icon = icon
  local text = probe:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
  text:SetPoint('TOP', icon, 'BOTTOM', 0, -2)
  text:SetText(label)
  return cooldown
end

--- Left icon gets a duration object, right gets numbers
--- @param texture number|string
--- @return Cooldown, Cooldown
local function ShowProbe(texture)
  if not probe then
    probe = CreateFrame('Frame', nil, UIParent)
    probe:SetSize(PROBE_ICON_SIZE * 2 + 10, PROBE_ICON_SIZE)
    probe:SetPoint('CENTER', 0, 200)
    probe:EnableMouse(true)
    probe:SetScript('OnMouseUp', probe.Hide)
    probe.object = AddProbeIcon('object', 'LEFT')
    probe.numbers = AddProbeIcon('numbers', 'RIGHT')
  end
  probe.object.icon:SetTexture(texture)
  probe.numbers.icon:SetTexture(texture)
  probe:Show()
  return probe.object, probe.numbers
end

--- @param label string
--- @param fn fun()
local function Try(label, fn)
  local ok, err = pcall(fn)
  print('  ' .. label .. ':', ok and 'ok' or err)
end

--- @param spell SpellIdentifier
--- @param info SpellCooldownInfo
--- @param itemID ItemID
local function ReportCooldown(spell, info, itemID)
  local duration = C_Spell.GetSpellCooldownDuration(spell)
  local itemStart, itemDuration = C_Container.GetItemCooldown(itemID)
  print('Cooldown probe:', spell, 'in combat:', InCombatLockdown())
  print('  isOnGCD:', info.isOnGCD)
  print('  ShouldCooldownsBeSecret:', C_Secrets.ShouldCooldownsBeSecret())
  print('  ShouldSpellCooldownBeSecret:', C_Secrets.ShouldSpellCooldownBeSecret(spell))
  print('  info.duration secret:', issecretvalue(info.duration))
  print('  duration object secret:', duration and duration:HasSecretValues())
  print('  item start/duration secret:', issecretvalue(itemStart), issecretvalue(itemDuration))
  local object, numbers = ShowProbe(C_Spell.GetSpellTexture(spell))
  Try('duration object', function() object:SetCooldownFromDurationObject(duration) end)
  Try('numbers', function() numbers:SetCooldown(info.startTime, info.duration, info.modRate) end)
end

--- One-shot: runs on the spell's next active cooldown
--- @param spell SpellIdentifier
--- @param callbackFn fun(info: SpellCooldownInfo)
--- @param skipGCD boolean? @Wait for the spell's own cooldown
local function OnNextCooldown(spell, callbackFn, skipGCD)
  o:RegisterEvent('SPELL_UPDATE_COOLDOWN', function()
    local info = C_Spell.GetSpellCooldown(spell)
    if not (info and info.isActive) then return end
    if skipGCD and info.isOnGCD then return end
    o:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
    callbackFn(info)
  end)
end

--- Reports which Cooldown setters take the spell's next cooldown (#681).
--- Arm, then cast: once out of combat, once in combat.
--- ### Example:
--- ```lua
--- dd:CooldownProbe('Hammer of Justice')
--- ```
--- @param spell SpellIdentifier
--- @param itemID ItemID? @Checked for secret cooldown values; default Hearthstone
function o:CooldownProbe(spell, itemID)
  local item = itemID or HEARTHSTONE
  print('Cooldown probe armed, cast:', spell)
  OnNextCooldown(spell, function(info) ReportCooldown(spell, info, item) end)
end

--- Draws the next cooldown on a real ABP spell button (#681).
--- Arm, enter combat, then cast the button's spell.
--- ### Example:
--- ```lua
--- dd:ButtonCooldownProbe(1, 1)
--- ```
--- @param frameIndex Index
--- @param btnIndex Index
function o:ButtonCooldownProbe(frameIndex, btnIndex)
  --- @type Button_ABP_2_0_X
  local btn = _G[('ABP_2_0_F%sButton%s'):format(frameIndex, btnIndex)]
  local typ, spell = btn.widget:GetActionInfo()
  assert(au.IsSpell(typ), 'ButtonCooldownProbe: the button needs a spell')
  print('Button cooldown probe armed, cast:', spell)
  OnNextCooldown(spell, function(info)
    local duration = C_Spell.GetSpellCooldownDuration(spell)
    print('Button cooldown probe:', btn:GetName(), 'in combat:', InCombatLockdown())
    print('  isOnGCD:', info.isOnGCD, 'object secret:', duration and duration:HasSecretValues())
    Try('duration object', function() btn.cooldown:SetCooldownFromDurationObject(duration) end)
  end, true)
end

--- Reports an item's cooldown values and setters, right now (#681).
--- Use the item in combat, then run this while it's on cooldown.
--- ### Example:
--- ```lua
--- dd:ItemCooldownProbe('Minor Healthstone')
--- ```
--- @param item ItemID|ItemName|ItemLink @A name resolves only for an item you carry
function o:ItemCooldownProbe(item)
  local itemID = C_Item.GetItemInfoInstant(item)
  assert(itemID, 'ItemCooldownProbe: item not found: ' .. tostring(item))
  local start, duration, enable = C_Container.GetItemCooldown(itemID)
  local info = C_Spell.GetItemCooldown(itemID)
  local _, spellID = C_Item.GetItemSpell(itemID)
  print('Item cooldown probe:', itemID, 'in combat:', InCombatLockdown())
  print('  start/duration/enable:', scrubsecretvalues(start, duration, enable))
  print('  secret:', issecretvalue(start), issecretvalue(duration), issecretvalue(enable))
  print('  C_Spell.GetItemCooldown isActive:', info and info.isActive)
  print('  C_Spell.GetItemCooldown duration secret:', info and issecretvalue(info.duration))
  print('  item spell:', spellID)
  local object, numbers = ShowProbe(C_Item.GetItemIconByID(itemID))
  Try('numbers', function() numbers:SetCooldown(start, duration) end)
  local spellDuration = spellID and C_Spell.GetSpellCooldownDuration(spellID)
  Try('item spell object', function() object:SetCooldownFromDurationObject(spellDuration) end)
end

--[[-----------------------------------------------------------------------------
Register Events
-------------------------------------------------------------------------------]]
o:RegisterMessage('ActionbarPlus-BarsUI::OnEnable', o.OnBarsEnabled)
