--[[-----------------------------------------------------------------------------
@see BarFrame.xml
@see also Blizzard_FrameXML/Classic/SecureTemplates.xml#SecureActionButtonTemplate

Enable by:
<Script file="Button_2_0_1_1.lua"/>
<CheckButton name="ABP_ButtonTemplate_2_0_1_1"
             inherits="SecureActionButtonTemplate, ABP_ButtonTemplate_2_0"
             mixin="ABP_ButtonMixin_2_0_1_1" virtual="true">
    <Scripts>
        <OnLoad method="OnLoad"/>
        <PostClick method="PostClick"/>
        <OnDragStop method="OnDragStop"/>
        <OnAttributeChanged method="OnAttributeChanged"/>
    </Scripts>
</CheckButton>
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
ns.buttonTemplate = 'ABP_ButtonTemplate_2_0_1_1'

--- @type Compat_ABP_2_0
local c = ns:cns().O.Compat

-- Starting ButtonID
local seedID = 1000

-- attributes are converted to lower case
local SPELL_ID_ATTR = 'abp_2_0_spellid'
local SPELL_ID_TX_ATTR = 'abp_2_0_tx_spellid'

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @alias ABP_Button_2_0_1_1 ABP_ButtonMixin_2_0_1_1 | SecureCheckButtonObj | AceEvent_3_0
--
--
local libName = 'ABP_ButtonMixin_2_0_1_1'
--- @class ABP_ButtonMixin_2_0_1_1
--- @field icon TextureObj
--- @field GetParent fun(self:ABP_ButtonMixin_2_0_1_1) : BarFrameObj_ABP_2_0
local S = ns:cns():NewAceEvent(); ABP_ButtonMixin_2_0_1_1 = S
local p, pd, t, tf = ns:log(libName)

--- @type boolean
local lockActionBars

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]
--- @type ABP_ButtonMixin_2_0_1_1 | ABP_Button_2_0_1_1
local o = S

--- we need SecureHandlerBaseTemplate for prev (previous) frame
--- @type SecureHandlerBaseTemplateObj
local prev = CreateFrame('Frame',  nil, UIParent, "SecureHandlerBaseTemplate")
prev:SetAttribute('abp_2_0_spellid_name', SPELL_ID_ATTR)
prev:SetAttribute('abp_2_0_tx_spellid_name', SPELL_ID_TX_ATTR)

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
local function NextSeedID() local current = seedID; seedID = seedID + 1; return current end

--- @param self ABP_Button_2_0_1_1
--- @param spell SpellIdentifier
local function Btn_SetSpell(self, spell)
    local sp = c:GetSpellInfo(spell)
    if not sp then return end
    
    self.icon:SetTexture(sp.iconID)
    self:SetAttribute('type', 'spell')
    self:SetAttribute('spell', sp.spellID)
end

--- @param self ABP_Button_2_0_1_1
local function Btn_WrapScript_OnDragStart(self)
    local handler = self:GetParent().handler
    --SecureHandlerSetFrameRef(self, 'prev', prev)
    handler:WrapScript(self, 'OnDragStart', [[
        local prev = self:GetFrameRef('prev')
        local isDragAllowed = prev:GetAttribute('abp_is_drag_allowed') or false
        local actionType = self:GetAttribute('type')
        local action = actionType and self:GetAttribute(actionType)
        print('ODStart:: isDragAllowed=', isDragAllowed, 'type=',
            actionType, 'action=', action, 'btnID=', self:GetID())
        if not isDragAllowed then return false end
        if not (actionType and action) then return end
        
        -- 1: Pickup Action
        self:SetAttribute('type', nil)
        self:SetAttribute(actionType, nil)

        prev:SetAttribute('ondragstart_to_onleave_type', actionType)
        prev:SetAttribute('ondragstart_to_onleave_' .. actionType, action)
        
        return 'clear', actionType, action
    ]])
end

--- Signature (implicit vars): self,button,kind,value, ...
--- Given an example return values of GetCursorInfo() of a Spell Type:
--- ```
---  [1] = "spell"   -- kind (var: kind)
---  [2] = 17        -- bookIndex (var: value)
---  [3] = "spell"   -- bookType (var: ... arg1, GetCursorInfo()[3])
---  [4] = 635       -- spellID (var: ... arg2, GetCursorInfo()[4])
--- ```
--- arg
--- ```
--- local bookType, spellID = ...
--- ```
--- Possible kind values: spell, item, equipment
--- value(spell) ~ SpellBook?
--- @see FrameXML/SecureHandlers.lua#Wrapped_Drag
--- @param self ABP_Button_2_0_1_1
local function Btn_WrapScript_OnReceiveDrag(self)
    local handler = self:GetParent().handler
    --SecureHandlerSetFrameRef(self, "prev", prev)
    handler:WrapScript(self, "OnReceiveDrag", [[
        local prev = self:GetFrameRef('prev')
        local bookType, action = ...
        
        local rcvActionType = kind
        print('ORDrag:: rcvActionType=', rcvActionType, 'action=', action)
        if not action then return 'clear' end
        
        self:SetAttribute('abp_2_0_start_drag_spell', nil)
        
        local prevActionType = self:GetAttribute('type')
        local prevActionID = self:GetAttribute(prevActionType)
        prev:SetAttribute('abp_on_receive_drag_previous_type', prevActionType)
        prev:SetAttribute('abp_on_receive_drag_previous_action', prevActionID)
        print('ORDrag:: id=', self:GetID(), 'prevActionType=', prevActionType, 'prevActionID=', prevActionID)

        -- overwrite B immediately
        self:SetAttribute('type', rcvActionType)
        self:SetAttribute(rcvActionType, action)
        
        if prevActionType and prevActionID then
            return 'clear', prevActionType, prevActionID
        else
            return 'clear'
        end
    ]])
end

--- @param self ABP_Button_2_0_1_1
local function Btn_WrapScript_PreClick(self)
    local handler = self:GetParent().handler
    --SecureHandlerSetFrameRef(self, "prev", prev)
    handler:WrapScript(self, "PreClick", [[
        local prev = self:GetFrameRef('prev')
        local current = self:GetAttribute("spell")
        print('PreC:: current=', current)
        -- this will change when it fires (up or down key)
        local shouldFire = down == true
        
        local isDragAllowed = false
        local lockedInSettings = prev:GetAttribute('abp_lock_actionbars')
        if shouldFire then
            if lockedInSettings == true then
                local modifiedClick = IsModifiedClick("PICKUPACTION")
                if lockedInSettings and modifiedClick then
                    isDragAllowed = true
                end
            else
                isDragAllowed = true
            end
        end
        prev:SetAttribute('abp_is_drag_allowed', isDragAllowed)
        if not isDragAllowed then return end
        
        --self:SetAttribute("abp_drag_spellid", current)

        -- drag happens on 'up' and shift
        --if not down then
        --    -- restore spell saved on previous cursor (virtually)
        --    local prevType = prev:GetAttribute('abp_previous_type')
        --    local prevSpellID = prev:GetAttribute('abp_previous_spell')
        --    if prevType and prevSpellID then
        --        print(('PreC:: prevT=%s, prevSpellID=%s'):format(tostring(prevType), tostring(prevSpellID)))
        --        self:SetAttribute('type', prevType)
        --        self:SetAttribute('spell', prevSpellID)
        --    end
        --    return
        --end
        --
        --local lockedInSettings = prev:GetAttribute('abp_lock_actionbars')
        --local modifiedClick = IsModifiedClick("PICKUPACTION")
        --if down and lockedInSettings and modifiedClick then
        --    prev:SetAttribute('abp_is_drag_allowed', true)
        --end
        --if not modifiedClick then return end
        --
        --print('PreClick:: xx no op, spell=', current)
        --self:SetAttribute("abp_2_0_start_drag_spell", current)
        ----self:SetAttribute("spell", nil)
    ]])
end

--- @param self ABP_Button_2_0_1_1
local function Btn_WrapScript_OnEnter(self)
    local handler = self:GetParent().handler
    --SecureHandlerSetFrameRef(self, "prev", prev)
    handler:WrapScript(self, "OnEnter", [[
        --print('OnEnter...')
        local prev = self:GetFrameRef('prev')

        -- OnEnter, save existing spell; a cursor may exists
        --local currentType = self:GetAttribute('type')
        --local currentSpell = self:GetAttribute('spell')
        --if currentType and currentSpell then
        --    -- save
        --
        --end
        
        -- restore spell saved on previous cursor (virtually)
        --local prevType = prev:GetAttribute('abp_previous_type')
        --local prevSpellID = prev:GetAttribute('abp_previous_spell')
        --if prevType and prevSpellID then
        --    print(('OnEnter:: prevT=%s, prevSpellID=%s'):format(tostring(prevType), tostring(prevSpellID)))
        --    self:SetAttribute('type', prevType)
        --    self:SetAttribute('spell', prevSpellID)
        --end
    ]])
end

--- @param self ABP_Button_2_0_1_1
local function Btn_WrapScript_OnLeave(self)
    local handler = self:GetParent().handler
    --SecureHandlerSetFrameRef(self, "prev", prev)
    handler:WrapScript(self, "OnLeave", [[
        print('OnL... id=', self:GetID())
        local prev = self:GetFrameRef('prev')
        
        local actionType = prev:GetAttribute('ondragstart_to_onleave_type')
        if actionType then
            local action = prev:GetAttribute('ondragstart_to_onleave_' .. actionType)
            if actionType and action then
                print('OnL:: type=', actionType, 'action=', action)
              -- TODO NEXT??? Process 'OnClick'
            end
        end
        
        local prevType = prev:GetAttribute('abp_on_receive_drag_previous_type')
        local prevAction = prev:GetAttribute('abp_on_receive_drag_previous_action')
        print('OnL... prevType=', prevType, 'prevAction=', prevAction)
        --if not (prevType and prevAction) then
        --    prev:SetAttribute('abp_on_receive_drag_previous_type', nil)
        --    prev:SetAttribute('abp_on_receive_drag_previous_action', nil)
        --    return
        --end
        prev:SetAttribute('abp_cursor_type', prevType)
        prev:SetAttribute('abp_cursor_action', prevAction)
        prev:SetAttribute('abp_on_receive_drag_previous_type', nil)
        prev:SetAttribute('abp_on_receive_drag_previous_action', nil)

    ]])
end

--- @param self ABP_Button_2_0_1_1
local function Btn_WrapScript_OnClick(self)
    local handler = self:GetParent().handler
    --SecureHandlerSetFrameRef(self, "prev", prev)
    handler:WrapScript(self, "OnClick", [[
        print('OnC:: down=', down, 'btn=', button)
        local prev = self:GetFrameRef('prev')

        -- virtual cursor,
        -- state: has cursor, then mouse up will place the current cursor here
        -- action is on mouse up so that it doesn't trigger the spell
        local cursorPrevType = prev:GetAttribute('abp_cursor_type')
        local cursorPrevAction = prev:GetAttribute('abp_cursor_action')
        --prev:SetAttribute('abp_onup_cursor_type', cursorPrevType)
        --prev:SetAttribute('abp_onup_cursor_action', cursorPrevAction)
        if cursorPrevType and cursorPrevAction then
            if down then
                -- set type to nil so it won't execute
                self:SetAttribute('type', nil)
                self:SetAttribute('type', nil)
                self:SetAttribute(cursorPrevType, nil)
                return nil
            end
            
            --cursorPrevType = prev:GetAttribute('abp_onup_cursor_type')
            --cursorPrevAction = prev:GetAttribute('abp_onup_cursor_action')
            -- executed on 'up'
            self:SetAttribute('type', cursorPrevType)
            self:SetAttribute(cursorPrevType, cursorPrevAction)
        end
        prev:SetAttribute('abp_on_receive_drag_previous_type', nil)
        prev:SetAttribute('abp_on_receive_drag_previous_action', nil)
        print('OnC:: cursorPrevType=', cursorPrevType, 'cursorPrevAction=', cursorPrevAction)
        
        local isDragAllowed = prev:GetAttribute('abp_is_drag_allowed')
        print('OnC:: isDragAllowed=', isDragAllowed)
        if isDragAllowed then return false end
        

    ]])
end

--- @param self ABP_Button_2_0_1_1
local function Btn_WrapScript_PostClick(self)
    local handler = self:GetParent().handler
    --SecureHandlerSetFrameRef(self, "prev", prev)
    handler:WrapScript(self, "PostClick", [[
        print('PostC:: called...down=', down)
        local prev = self:GetFrameRef("prev")
        --prev:SetAttribute("abp_2_0_tx_spellid", nil)
    ]])
end

--- @param self ABP_Button_2_0_1_1
local function Btn_AddTempSpells(self)
    local tmpBtnSpells = {
        [1000] = 'holy light(rank 1)',
        [1001] = 'seal of the crusader',
        --[1002] = 'seal of righteousness',
        [1002] = 'jewelcrafting',
    }
    local id = self:GetID()
    local spell = tmpBtnSpells[id]
    if not spell then return end
    Btn_SetSpell(self, spell)
end

function o:OnLoad()
    self:SetID(NextSeedID())
    self.__name = ('%s:%s)'):format(self:GetName(), self:GetID())
    
    --self:SetAttribute("action", self:GetID())
    self.action = self:GetID()
    self:EnableMouse(true)
    self:GetNormalTexture():SetDrawLayer("BACKGROUND", 0)
    
    self:SetAttribute("checkselfcast", true);
    self:SetAttribute("checkfocuscast", true);
    self:SetAttribute("checkmouseovercast", true);
    
    self:RegisterForDrag("LeftButton", "RightButton");
    self:RegisterForClicks('AnyDown', 'AnyUp');
    self:RegisterEvent('PLAYER_ENTERING_WORLD', 'OnPlayerEnteringWorld')
    --RegisterStateDriver(self, "abp_shift", "[mod:shift] shift; [mod:ctrl] ctrl; [mod:alt] alt; none")
end

function o:OnPlayerEnteringWorld()
    prev:SetAttribute('abp_lock_actionbars', ns:cns().lockActionBars)
    
    Btn_AddTempSpells(self)
    
    SecureHandlerSetFrameRef(self, "prev", prev)
    Btn_WrapScript_OnDragStart(self)
    Btn_WrapScript_OnReceiveDrag(self)
    Btn_WrapScript_PreClick(self)
    Btn_WrapScript_OnClick(self)
    --Btn_WrapScript_PostClick(self)
    -- OnEnter/OnLeave has to be both turned on
    Btn_WrapScript_OnEnter(self)
    Btn_WrapScript_OnLeave(self)
    self:SetAttribute("_onenter", [[
        local prev = self:GetFrameRef('prev')
        print('XX OnEnter... prev=', prev)
    ]])
    self:SetAttribute("_onleave", [[
        print('XX OnLeave...')
    ]])
end

function o:OnDragStop()
    --local kind, _, _, spellID = GetCursorInfo()
    --p('OnDragStop...spellID=', spellID)
    p('OnDStop:: btnID=', self:GetID())
end

function o:PostClick(button, down)
    --p(('OnPostClick[%s::%s]: button=%s, down=%s'):format(self:GetName(), self:GetID(), button, tostring(down)))
    self:UpdateState(button, down)
end

function o:OnAttributeChanged(name, val)
    --p(('OnAttributeChanged[%s]: name=%s, val=%s'):format(self:GetID(), tostring(name), tostring(val)))
    self:UpdateAction(name, val)
end

--function o:OnEvent(event, ...)
--    local args = { ... }
--    p(('OnEvent[%s::%s]: name=%s, val=%s'):format(self:GetName(), self:GetID(), event, pf(args)))
--end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param button ButtonName
function o:UpdateState(button, down)
    self:SetChecked(false)
end

function o:UpdateAction(name, val)
    --p('UpdateAction:: attr name=', name, 'val=', val)
    --if name ~= SPELL_ID_ATTR then return end
    if name ~= 'spell' then return end
    if not val then
        self.icon:SetTexture(nil)
        return
    end
    
    local info = c:GetSpellInfo(val)
    if not info and not info.iconID then return end
    ClearCursor()
    -- Retail vs Classic safe
    self.icon:SetTexture(info.iconID)
end

