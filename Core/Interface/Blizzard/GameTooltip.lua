---@class _GameTooltip : _Frame
local A = {}

function A:AddAtlas(atlas, minx, maxx, miny, maxy) end
function A:AddDoubleLine(textL, textR, rL, gL, bL, rR, gR, bR) end
--- Dynamically expands the size of a tooltip - New in 1.11.
function A:AddFontStrings(leftstring, rightstring) end
--- Appends the new line to the tooltip.
function A:AddLine(tooltipText , r, g, b , wrapText) end

function A:AddSpellByID(spellID) end
function A:AdvanceSecondaryCompareItem() end

--- Add a texture to the last line added.
function A:AddTexture(texture) end
--- Append text to the end of the first line of the tooltip.
function A:AppendText(text) end

--- Clear all lines of tooltip (both left and right ones)
function A:ClearLines() end

function A:CopyTooltip() end
function A:FadeOut() end

--- Returns the current anchoring type.
function A:GetAnchorType() end

function A:GetAzeritePowerID() end
function A:GetCustomLineSpacing() end
function A:GetMinimumWidth() end
function A:GetPadding() end
function A:IsEquippedItem() end
function A:IsOwned(frame) end
function A:ResetSecondaryCompareItem() end
function A:SetAchievementByID(id) end
function A:SetAllowShowWithNoLines(bool) end
function A:SetAnchorType(anchorType, Xoffset, Yoffset) end
function A:SetArtifactItem() end
function A:SetArtifactPowerByID() end
function A:SetAzeriteEssence(essenceID) end
function A:SetAzeriteEssenceSlot(slot) end
function A:SetAzeritePower(itemID, itemLevel, powerID, owningItemLink) end
function A:SetBackpackToken(id) end
function A:SetBagItem(bag, slot) end
function A:SetBagItemChild() end
function A:SetBuybackItem(slot) end
function A:SetCompanionPet() end
function A:SetConduit(id, rank) end
function A:SetCurrencyByID(id) end
function A:SetCompareAzeritePower(itemID, itemLevel, powerID, owningItemLink) end

--- Returns name, link.
function A:GetItem() end
--- Returns owner frame, anchor.
function A:GetOwner() end
--- Returns name, rank, id.
function A:GetSpell() end
--- Returns unit name, unit id.
function A:GetUnit() end
--- Get the number of lines in the tooltip.
function A:NumLines() end

--- Returns bool.
function A:IsUnit(unit) end
--- Shows the tooltip for the specified action button.
function A:SetAction(slot) end
--- Shows details for the equipment manager set identified by "name".
function A:SetEquipmentSet(name) end
--- Shows the mouseover frame stack, used for debugging.
function A:SetFrameStack(showhidden) end
--- Shows the tooltip for the specified token
function A:SetCurrencyToken(tokenId) end
--- Shows the tooltip for the specified guild bank item
function A:SetGuildBankItem(tab, id) end

function A:SetCompareItem(shoppingTooltipTwo, primaryMouseover) end
function A:SetCurrencyTokenByID(currencyID) end
function A:SetCustomLineSpacing(spacing) end
function A:SetEnhancedConduit(conduitID, conduitRank) end
function A:SetExistingSocketGem(index, toDestroy) end
function A:SetHeirloomByItemID(itemID) end
function A:SetInstanceLockEncountersComplete(index) end
function A:SetInventoryItem(unit, slot, nameOnly, hideUselessStats) end
function A:SetInventoryItemByID(itemID) end
function A:SetItemKey(itemID, itemLevel, itemSuffix) end
function A:SetLFGDungeonReward(dungeonID, lootIndex) end
function A:SetLFGDungeonShortageReward(dungeonID, shortageSeverity, lootIndex) end
function A:SetLootCurrency(lootSlot) end
function A:SetLootItem(lootSlot) end
function A:SetMerchantCostItem(index, item) end
function A:SetMerchantItem(merchantSlot) end
function A:SetMountBySpellID() end
function A:SetOwnedItemByID(ID) end
function A:SetOwner(owner, anchor, x, y) end
function A:SetPadding(width, height) end
function A:SetPossession(slot) end
function A:SetPvpBrawl() end
function A:SetPvpTalent(talentID, talentIndex) end
function A:SetQuestCurrency(type, index) end
function A:SetQuestItem(type, index) end
function A:SetQuestLogCurrency(type, index) end
function A:SetQuestLogItem(type, index) end
function A:SetQuestLogRewardSpell(rewardSpellIndex, questID) end
function A:SetQuestLogSpecialItem(index) end
function A:SetQuestPartyProgress(questID, omitTitle, ignoreActivePlayer) end
function A:SetQuestRewardSpell(rewardSpellIndex) end
function A:SetRecipeRankInfo(recipeID, learnedRank) end
function A:SetRecipeReagentItem(recipeID, reagentIndex) end
function A:SetRecipeResultItem(recipeID) end
function A:SetRuneforgeResultItem(itemID, itemLevel , powerID, modifiers) end
function A:SetSendMailItem() end
function A:SetShrinkToFitWrapped() end
function A:SetSocketedItem() end
function A:SetSocketedRelic(relicSlotIndex) end
function A:SetSocketGem(index) end
function A:SetSpecialPvpBrawl() end

--- itemString or itemLink; Changes the item which is displayed in the tooltip according to the passed argument.
function A:SetHyperlink(itemString) end
--- Shows the tooltip for the specified mail inbox item.
function A:SetInboxItem(index) end
--- Shows the tooltip for a specified Item ID. (added in 4.2.0.14002 along with the Encounter Journal)
function A:SetItemByID(itemID) end
--- Shows the tooltip for the specified loot roll item.
function A:SetLootRollItem(id) end
--- Formerly SetMoneyWidth
function A:SetMinimumWidth(width) end
--- Shows the tooltip for the specified pet action.
function A:SetPetAction(slot) end
--- Shows the tooltip for the specified shapeshift form.
function A:SetShapeshift(slot) end
--- Shows the tooltip for the specified spell in the spellbook.
function A:SetSpellBookItem(spellId, bookType) end
--- Shows the tooltip for the specified spell by global spell ID.
function A:SetSpellByID(spellId) end
--- Shows the tooltip for the specified talent.
function A:SetTalent(talentIndex , isInspect, talentGroup, inspectedUnit, classId) end
--- Set the text of the tooltip
function A:SetText(text, r, g, b, alphaValue, textWrap) end

function A:SetTotem(slot) end
function A:SetToyByItemID(itemID) end
function A:SetTradePlayerItem(tradeSlot) end
function A:SetTradeTargetItem(tradeSlot) end
function A:SetTrainerService(index) end
function A:SetUnit(unit, hideStatus) end
function A:SetUpgradeItem() end

--- Shows the tooltip when there is a pending (de)transmogrification
function A:SetTransmogrifyItem(slotId) end
--- Shows the tooltip for a unit's aura. (Exclusive to 3.x.x / WotLK)
function A:SetUnitAura(unit, auraIndex , filter) end
--- Shows the tooltip for a unit's buff.
function A:SetUnitBuff(unit, buffIndex, raidFilter) end
--- Shows the tooltip for a unit's debuff.
function A:SetUnitDebuff(unit, buffIndex, raidFilter) end
--- Shows the tooltip for the specified Void Transfer deposit slot (added in 4.3.0)
function A:SetVoidDepositItem(slotIndex) end
--- Shows the tooltip for the specified Void Storage slot (added in 4.3.0)
function A:SetVoidItem(slotIndex) end
--- Shows the tooltip for the specified Void Transfer withdrawal slot (added in 4.3.0)
function A:SetVoidWithdrawalItem(slotIndex) end

function A:SetWeeklyReward(itemDBID) end

--[[-----------------------------------------------------------------------------
WoW Classic Only
-------------------------------------------------------------------------------]]
--- Shows the tooltip for the specified auction item.
--- Classic version only
function A:SetAuctionItem(type, index) end
--- Classic version only
function A:SetAuctionSellItem() end
--- Classic version only
function A:SetCraftItem(index, reagent) end
--- Classic version only
function A:SetCraftSpell(index) end
--- Classic version only
function A:SetTrackingSpell() end
--- Classic version only
function A:SetTradeSkillItem(index , reagent) end
