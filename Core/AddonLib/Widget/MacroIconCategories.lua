local C = {}
local Categories = {
    'Axe',
    '1H',
    '2H',
    'Ammo',
    'Armor',
    'Banner',
    'Battery',
    'Bow',
    'Belt',
    'Bijou',
    'Boots',
    'Box',
    'Bracer',
    'Cask',
    'Chest',
    'Crate',
    'Crown',
    'DataCrystal',
    'DiabloStone',
    'Drink',
    'Egg',
    'Icon',
    'Elemental',
    'Enchant',
    'Fishing',
    'Food',
    'Fabric',
    'Feather',
    'Gauntlets',
    'Gizmo',
    'Hammer',
    'Helmet',
    'Holiday',
    'Ingot',
    'Jewelcrafting',
    'Jewelry',
    'Knife',
    'Letter',
    'Mace',
    'Mask',
    'Musket',
    'Misc',
    'Mushroom',
    'Netherwhelp',
    'Offhand',
    'Ore',
    'Pants',
    'Pick',
    'Poison',
    'Potion',
    'Qiraj',
    'Relics',
    'Rod',
    'Rose',
    'Scroll',
    'Scarab',
    'Shield',
    'Shirt',
    'Spear',
    'Shoulder',
    'Staff',
    'Stone',
    'Spear',
    'SummerFest',
    'Sword',
    'ThrowingAxe',
    'ThrowingKnife',
    'Torch',
    'TradeskillItem',
    'Trinket',
    'Valentine',
    'Wand',
    'Weapon',
    'ZulGurubTrinket',
}

local function GetDropDownCategories()
    local dropDownList = {}
    for _,cat in ipairs(Categories) do
       dropDownList[cat] = cat
    end
    return dropDownList
end

C.dropDownItems = GetDropDownCategories()

function C:GetCategoryNames()
    return Categories
end

function C:GetDropDownItems()
    return self.dropDownItems
end

local function getCategory(texturePath)
    if not texturePath then return nil end

    for _,cat in ipairs(Categories) do
        local lcat = string.lower('_' .. cat)
        local lpath = string.lower(texturePath)
        if string.find(lpath, lcat) then
            return cat
        end
    end
    return nil
end

function C:GetItemsByCategory(macroIcons, category)
    -- id, category, path
    local items = {}
    for _, iconId in ipairs(macroIcons) do
        --print('iconId: ', iconId)
        local texturePath = ART_TEXTURES[iconId]
        if texturePath then
            local cat = getCategory(texturePath)
            if cat and category == cat then
                --table.insert(items, {
                --    id = iconId,
                --    category = category,
                --    path = texturePath
                --})
                items[iconId] = texturePath
            end
        end
    end

    return items
end

MacroIconCategories = C