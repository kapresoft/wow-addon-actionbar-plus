-- GUIDS
-- Corgnelius:  'BattlePet-0-00000541C511'
-- Perky Pug:   'BattlePet-0-000001BA1BF4'

-- Macros
-- # MoP
-- /run C_PetJournal.PickupPet('BattlePet-0-0000001837A4')
-- /run C_PetJournal.PickupPet('BattlePet-0-000000B61178')
-- /summonpet BattlePet-0-0000001837A4
-- /summonpet BattlePet-0-000000B61178
-- /dump C_PetJournal.GetPetSummonInfo('BattlePet-0-0000001837A4')
-- # Retail
-- /run C_PetJournal.PickupPet('BattlePet-0-00000541C511')
-- /run C_PetJournal.PickupPet('BattlePet-0-000001BA1BF4')

GetCursorInfo = function()
  local type, guid = GetCursorInfo()
  if not guid then return end
  return { type=type, guid=guid }
end

SetGameTooltip = function()
   GameTooltip:SetCompanionPet(guid)
   GameTooltip:Show()
end

PickupBattlePet = function()
  C_PetJournal.PickupPet('BattlePet-0-000008C13591')
end

--{ 2779, nil, 1, 0, 50, 93349, true, 'Anima Wyrmling', 3038273, 2, 157969,
--  'Promotion: Shadowlands Epic Edition',
--  'Even the smallest creatures in the Shadowlands rely on anima to survive.',
--  false, true, false, true, true }
PetInfo = function()
  return { C_PetJournal.GetPetInfoByPetID('BattlePet-0-000008C13591') }
end


