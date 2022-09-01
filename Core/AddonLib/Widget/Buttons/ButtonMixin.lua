--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetMacroSpell, GetMacroItem, GetItemInfoInstant =
    GetMacroSpell, GetMacroItem, GetItemInfoInstant
local GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show =
    GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local tostring, format, strlower, tinsert = tostring, string.format, string.lower, table.insert


--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub, M, G = ABP_LibGlobals:LibPack()
local WU = ABP_LibGlobals:LibPack_WidgetUtil()
local _, Table, String, LogFactory = G:LibPackUtils()
local p = LogFactory:NewLogger('ButtonMixin')
local SPELL,ITEM,MACRO = 'spell','item','macro'

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class ButtonMixin : ButtonProfileMixin @ButtonMixin extends ButtonProfileMixin
---@see ButtonUIWidget
local _L = LibStub:NewLibrary(M.ButtonMixin)
G:Mixin(_L, G:LibPack_ButtonProfileMixin())

function _L:_Button() return self.button end
function _L:_Widget() return self end

function _L:GetName() return self:_Button():GetName() end
function _L:GetIndex() return self.index end
function _L:GetFrameIndex() return self.dragFrameWidget:GetIndex() end
function _L:IsParentFrameShown() return self.dragFrame:IsShown() end

function _L:ResetConfig()
    self:_Widget().profile:ResetButtonData(self)
    self:ResetWidgetAttributes()
end

function _L:SetButtonAsEmpty()
    self:ResetConfig()
    self:SetTextureAsEmpty()
end

function _L:Reset()
    self:ResetCooldown()
    self:ClearText()
end

function _L:ResetCooldown() self:SetCooldown(0, 0) end
function _L:SetCooldown(start, duration) self.cooldown:SetCooldown(start, duration) end


---@type BindingInfo
function _L:GetBindings()
    return (self.addon.barBindings and self.addon.barBindings[self.buttonName]) or nil
end

---@param text string
function _L:SetText(text)
    if String.IsBlank(text) then text = '' end
    self:_Button().text:SetText(text)
end
---@param state boolean true will show the button index number
function _L:ShowIndex(state)
    local text = ''
    if true == state then text = self:_Widget().index end
    self:_Button().indexText:SetText(text)
end

---@param state boolean true will show the button index number
function _L:ShowKeybindText(state)
    local text = ''
    local button = self:_Button()
    if not self:HasKeybindings() then
        button.keybindText:SetText(text)
        return
    end

    if true == state then
        local bindings = self:GetBindings()
        if bindings and bindings.key1Short then
            text = bindings.key1Short
        end
    end
    button.keybindText:SetText(text)
end

function _L:HasKeybindings()
    local b = self:GetBindings()
    if not b then return false end
    return b and String.IsNotBlank(b.key1)
end
function _L:ClearText() self:SetText('') end

---@return CooldownInfo
function _L:GetCooldownInfo()
    local btnData = self:GetConfig()
    if btnData == nil or String.IsBlank(btnData.type) then return nil end
    local type = btnData.type

    ---@class CooldownInfo
    local cd = {
        type=type,
        start=nil,
        duration=nil,
        enabled=0,
        details = {}
    }
    if type == SPELL then return self:GetSpellCooldown(cd)
    elseif type == MACRO then return self:GetMacroCooldown(cd)
    elseif type == ITEM then return self:GetItemCooldown(cd)
    end
    return nil
end

---@param cd CooldownInfo The cooldown info
---@return SpellCooldown
function _L:GetSpellCooldown(cd)
    local spell = self:GetSpellData()
    if not spell then return nil end
    local spellCD = _API:GetSpellCooldown(spell.id, spell)
    if spellCD ~= nil then
        cd.details = spellCD
        cd.start = spellCD.start
        cd.duration = spellCD.duration
        cd.enabled = spellCD.enabled
        return cd
    end
    return nil
end

---@param cd CooldownInfo The cooldown info
---@return ItemCooldown
function _L:GetItemCooldown(cd)
    local item = self:GetItemData()
    if not item then return nil end
    local itemCD = _API:GetItemCooldown(item.id, item)
    if itemCD ~= nil then
        cd.details = itemCD
        cd.start = itemCD.start
        cd.duration = itemCD.duration
        cd.enabled = itemCD.enabled
        return cd
    end
    return nil
end

---@param cd CooldownInfo The cooldown info
function _L:GetMacroCooldown(cd)
    local spellCD = self:GetMacroSpellCooldown();

    if spellCD ~= nil then
        cd.details = spellCD
        cd.start = spellCD.start
        cd.duration = spellCD.duration
        cd.enabled = spellCD.enabled
        cd.icon = spellCD.spell.icon
        return cd
    else
        local itemCD = self:GetMacroItemCooldown()
        if itemCD ~= nil then
            cd.details = itemCD
            cd.start = itemCD.start
            cd.duration = itemCD.duration
            cd.enabled = itemCD.enabled
            return cd
        end
    end

    return nil;
end

---@return SpellCooldown
function _L:GetMacroSpellCooldown()
    local macro = self:GetMacroData();
    if not macro then return nil end
    local spellId = GetMacroSpell(macro.index)
    if not spellId then return nil end
    return _API:GetSpellCooldown(spellId)
end

---@return number The spellID for macro
function _L:GetMacroSpellId()
    local macro = self:GetMacroData();
    if not macro then return nil end
    return GetMacroSpell(macro.index)
end

---@return ItemCooldown
function _L:GetMacroItemCooldown()
    local macro = self:GetMacroData();
    if not macro then return nil end

    local itemName = GetMacroItem(macro.index)
    if not itemName then return nil end

    local itemID = GetItemInfoInstant(itemName)
    return _API:GetItemCooldown(itemID)
end

function _L:HasActionAssigned()
    local d = self:GetConfig()
    local type = d.type
    if String:IsBlank(type) then return false end
    local spellDetails = d[type]
    if Table.size(spellDetails) <= 0 then return false end
    return true
end

function _L:ResetWidgetAttributes()
    local button = self:_Button()
    for _, v in pairs(self.buttonAttributes) do
        button:SetAttribute(v, nil)
    end
end

function _L:UpdateItemState()
    self:ClearText()
    local btnData = self:GetConfig()
    if self:invalidButtonData(btnData, ITEM) then return end
    local itemID = btnData.item.id
    local itemInfo = _API:GetItemInfo(itemID)
    if itemInfo == nil then return end
    local stackCount = itemInfo.stackCount or 1
    btnData.item.count = itemInfo.count
    btnData.item.stackCount = stackCount
    if stackCount > 1 then self:SetText(btnData.item.count) end
end

function _L:UpdateUsable() WU:UpdateUsable(self) end

function _L:UpdateState()
    self:UpdateCooldown()
    self:UpdateItemState()
    self:UpdateUsable()
end
function _L:UpdateStateDelayed(inSeconds) C_Timer.After(inSeconds, function() self:UpdateState() end) end
function _L:UpdateCooldown()
    local cd = self:GetCooldownInfo()
    if not cd or cd.enabled == 0 then return end
    -- Instant cast spells have zero duration, skip
    if cd.duration <= 0 then
        self:ResetCooldown()
        return
    end
    self:SetCooldown(cd.start, cd.duration)
end
function _L:UpdateCooldownDelayed(inSeconds) C_Timer.After(inSeconds, function() self:UpdateCooldown() end) end


---@return ActionBarInfo
function _L:GetActionbarInfo()
    local index = self.index
    local dragFrame = self.dragFrame;
    local frameName = dragFrame:GetName()
    local btnName = format('%sButton%s', frameName, tostring(index))

    ---@class ActionBarInfo
    local info = {
        name = frameName, index = dragFrame:GetFrameIndex(),
        button = { name = btnName, index = index },
    }
    return info
end

---@param spellID string The spellID to match
function _L:IsMatchingMacroOrSpell(spellID)
    ---@type ProfileButton
    local conf = self:GetConfig()
    if not conf and (conf.spell or conf.macro) then return false end
    if self:IsSpellConfig(conf) then
        return spellID == conf.spell.id
    elseif self:IsMacroConfig(conf) and conf.macro.index then
        local macroSpellId =  GetMacroSpell(conf.macro.index)
        return spellID == macroSpellId
    end

    return false;
end

