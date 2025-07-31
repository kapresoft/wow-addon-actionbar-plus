--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GameTooltip = GameTooltip

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub
local E, String, WMX = GC.E, ns:String(), O.WidgetMixin
local api, compat = O.API, O.Compat
local IsEmpty = String.IsEmpty

local itemLabelC = YELLOW_FONT_COLOR
local countC = WHITE_FONT_COLOR
local totalC = GREEN_FONT_COLOR

local RIGHT_TEXT_FORMAT = ' |cff8e8e8e(%s)|r'

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return TooltipUtil, Kapresoft_CategoryLogger
local function CreateLib()
    local libName = M.TooltipUtil
    --- @class TooltipUtil : BaseLibraryObject
    local newLib = LibStub:NewLibrary(libName); if not newLib then return nil end
    local logger = ns:CreateDefaultLogger(libName)
    return newLib, logger
end; local L, p = CreateLib(); if not L then return end

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param util TooltipUtil
local function InitButtonGameTooltipHooksLegacy(util)
    GameTooltip:HookScript(E.OnShow, function(tooltip, ...)
        util:Tooltip_OnShow(tooltip)
    end)
end
--- @param util TooltipUtil
local function InitButtonGameTooltipHooksUsingTooltipDataProcessor(util)
    GameTooltip:HookScript("OnShow", function(tooltip, ...)
        util:Tooltip_OnShow(tooltip)
    end)
end

--- @return FontString
local function Tooltip_RightText() return GameTooltipTextRight1 end
--- @return FontString
local function Tooltip_LeftText() return GameTooltipTextLeft1 end

local function Tooltip_SetRightText(tooltip, text)
    if IsEmpty(text) then return end

    local right = Tooltip_RightText()
    if not right then return tooltip:AppendText(text) end

    -- use the right text component
    right:SetText(text)
    right:Show()
end

--- @param tooltip GameTooltip
--- @param leftText string
--- @param rightText string
--- @param leftColor Color
--- @param rightColor Color
local function Tooltip_AddDoubleLine(tooltip, leftText, rightText, leftColor, rightColor)
    local l = leftColor or YELLOW_FONT_COLOR
    local r = rightColor or WHITE_FONT_COLOR
    tooltip:AddDoubleLine(leftText, rightText, l.r, l.g, l.b, r.r, r.g, r.b);
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local o = L

--- Automatically called
--- @see ModuleV2Mixin#Init
--- @private
--function o:OnAddOnInitialized() local ttUtil = self; InitButtonGameTooltipHooks(ttUtil) end

function o:OnLoad_InitButtonGameTooltipHooks()
    local util = self
    if TooltipDataProcessor then
        InitButtonGameTooltipHooksUsingTooltipDataProcessor(util)
        return
    end
    InitButtonGameTooltipHooksLegacy(util)
end

function o:Tooltip_OnShow(tooltip)
    --- @type ButtonUI
    local button = tooltip:GetOwner()
    if not (button and button.widget and button.widget.buttonName) then return end

    --- @type ButtonUIWidget
    local bw = button.widget
    local c  = bw:conf(); if c:IsEmpty() then return end
    if c:IsItem() then
        self:Tooltip_AddItemInfo(tooltip, c.item.id)
    elseif c:IsSpell() then
        self:Tooltip_AddSpellInfo(tooltip, c.spell.id)
    elseif c:IsMacro() then
        GameTooltip_AddBlankLinesToTooltip(tooltip, 1)
        self:Tooltip_AddMacroInfo(tooltip, bw, c)
    end
    self:Tooltip_AddKeybindingInfo(tooltip, bw, c)
    tooltip:Show()
end

--- @param tooltip GameTooltip
--- @param bw ButtonUIWidget
--- @param c ButtonProfileConfigMixin
function o:Tooltip_AddKeybindingInfo(tooltip, bw, c)
    if not bw.kbt:HasKeybindings() then return end

    local bindings = bw.kbt:GetBindings()
    if not bindings.key1 then return end
    tooltip:AddDoubleLine('Keybind ::', bindings.key1, 1, 0.5, 0, 0 , 0.5, 1);
end

--- @param tooltip GameTooltip
--- @param spid SpellID
---@param highestRank boolean defaults to true
function o:Tooltip_AddSpellInfo(tooltip, spid, highestRank)
    if not spid then return end

    if highestRank == false then
        -- the specific rank for the SpellID (in case of macros)
        local rankText = api:GetSpellRankFormatted(spid)
        return rankText and Tooltip_SetRightText(tooltip, rankText)
    end

    local spell = api:GetSpellInfoBasic(spid); if not spell then return end

    -- use the highest rank for now, because this is what's set
    -- in the attribute
    local highestRankSpell = api:GetSpellInfoBasic(spell.name)
    local rankText = highestRankSpell and api:GetSpellHighestRankFormatted(spell.name)
    if not rankText then return end

    Tooltip_SetRightText(tooltip, rankText)
end

--- @param tooltip GameTooltip
--- @param itemID ItemID
function o:Tooltip_AddItemInfo(tooltip, itemID)
    local bagCount = compat:GetItemCount(itemID, false, false, false)
    local item = api:GetItemInfoInstant(itemID)
    local cid = item and item.classID
    local itc = Enum.ItemClass

    local showTotal = not (cid == itc.Miscellaneous or cid == itc.Armor or cid == itc.Profession)
    if showTotal and bagCount > 0 then
        GameTooltip_AddBlankLinesToTooltip(tooltip, 1)
        Tooltip_AddDoubleLine(tooltip, 'Total In Bags', bagCount, itemLabelC, countC)
    end

    local totalInclBank = compat:GetItemCount(itemID, true, true, true)
    local bankCount = totalInclBank - bagCount
    if bankCount > 0 then
        local total = totalInclBank
        Tooltip_AddDoubleLine(tooltip, 'Bank Total', bankCount, itemLabelC, countC)
        Tooltip_AddDoubleLine(tooltip, 'Inventory Total', total, itemLabelC, totalC)
    end

    if item.className then
        Tooltip_SetRightText(tooltip, ns.sformat(RIGHT_TEXT_FORMAT, item.className))
    end
end

--- @param tooltip GameTooltip
--- @param bw ButtonUIWidget
--- @param c ButtonProfileConfigMixin
function o:Tooltip_AddMacroInfo(tooltip, bw, c)
    local macro = c.macro

    local itid = bw:GetEffectiveItemID()
    if itid then
        self:Tooltip_AddItemInfo(tooltip, itid)
    else
        local spid = bw:GetEffectiveSpellID()
        if spid then
            self:Tooltip_AddSpellInfo(tooltip, spid, false)
        end
    end

    tooltip:AddDoubleLine('Macro ::', macro.name, 1, 1, 1, 1, 1, 1);
end

--- This will setup the tooltip for the highest spell rank -- this is how ABP works now.
--- Called by Attribute Setters
--- @param bw ButtonUIWidget
function o:ShowTooltip_Spell(bw)
    local c = bw:conf(); if not c:IsSpell() then return end
    local highestRankSpell = api:GetSpellInfoBasic(c.spell.name)
    if not highestRankSpell then return GameTooltip:SetSpellByID(c.spell.id) end
    GameTooltip:SetSpellByID(highestRankSpell.id)
end

--- This will setup the tooltip for the highest spell rank -- this is how ABP works now.
--- Called by Attribute Setters
--- @param tooltip GameTooltip
--- @param bw ButtonUIWidget
function o:ShowTooltip_Macro(tooltip, bw)
    local c = bw:conf(); if not c:IsMacro() then return end

    local itid = bw:GetEffectiveItemID()
    if itid then
        return tooltip:SetItemByID(itid)
    end

    local spid = bw:GetEffectiveSpellID(); if not spid then return end
    tooltip:SetSpellByID(spid)

end

--- Called by Attribute Setters
--- @param tooltip GameTooltip
--- @param bw ButtonUIWidget
function o:ShowTooltip_Item(tooltip, bw)
    local c = bw:conf(); if not c:IsItem() then return end

    local itid = c.item.id
    if api:IsToyItem(itid) then return tooltip:SetToyByItemID(itid) end

    tooltip:SetItemByID(itid)
end
