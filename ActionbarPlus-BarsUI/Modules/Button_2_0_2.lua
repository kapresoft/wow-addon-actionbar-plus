--[[-----------------------------------------------------------------------------
@see BarFrame.xml
@see also Blizzard_FrameXML/Classic/SecureTemplates.xml#SecureActionButtonTemplate

Enable by:
<Script file="Button_2_0_2.lua"/>

<CheckButton name="ABP_ButtonTemplate_2_0_2"
             inherits="ABP_ButtonTemplate_2_0"
             mixin="ABP_ButtonMixin_2_0_2" virtual="true">
    <Scripts>
        <OnLoad method="OnLoad"/>
        <OnClick method="OnClick"/>
        <PostClick method="OnPostClick"/>
        <OnAttributeChanged method="OnAttributeChanged"/>
        <OnEvent method="OnEvent"/>
    </Scripts>
</CheckButton>
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
ns.buttonTemplate = 'ABP_ButtonTemplate_2_0_2'

local seedID = 999

--[[-----------------------------------------------------------------------------
New Instance
/run print("Protected:", GetMouseFocus():IsProtected())
/run print("Protected:", GetMouseFoci():IsProtected())
-------------------------------------------------------------------------------]]
--- @alias ABP_Button_2_0_2 ABP_ButtonMixin_2_0_2 | CheckButtonObj
--
--
local libName = 'ABP_ButtonMixin_2_0_2'
--- @class ABP_ButtonMixin_2_0_2
local S = {}; ABP_ButtonMixin_2_0_2 = S
local p = ns:log(libName)

local function NextID() seedID = seedID + 1; return seedID end

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]
--- @type ABP_ButtonMixin_2_0_2 | ABP_Button_2_0_2
local o = S

function o:OnLoad()
    self:SetID(NextID())

    self:SetAttribute("action", self:GetID())
    self.action = self:GetID()
    self:EnableMouse(true)
    self:GetNormalTexture():SetDrawLayer("BACKGROUND", 0)

    --self:SetAttribute("checkselfcast", true);
    --self:SetAttribute("checkfocuscast", true);
    --self:SetAttribute("checkmouseovercast", true);
    self:RegisterForDrag("LeftButton", "RightButton");
    self:RegisterForClicks("AnyDown", "LeftButtonDown", "RightButtonDown");
    --self:RegisterForClicks("AnyUp", "LeftButtonUp", "RightButtonUp");
    
    --local header = CreateFrame("Frame", nil, UIParent, "SecureHandlerBaseTemplate")
    --self:SetParent(header)
    
    if self:GetID() ~= 1000 then return end
    
    --- @type BarFrameObj_ABP_2_0
    --local barFrame = self:GetParent()
    --local header = barFrame.Handler
    --local proxy    = barFrame.SecureProxy
    --proxy:SetAttribute('type', 'spell')
    ----
    ----print('header:', header)
    ----print('proxy:', proxy)
    --SecureHandlerSetFrameRef(header, "proxy", proxy)
    ----
    ------/dump ABP_2_0_F1.Handler:Click()
    --SecureHandlerWrapScript(
    --        self,
    --        "OnClick",
    --        header,
    --        [[
    --            print('xx here')
    --            local proxy = self:GetFrameRef("proxy")
    --            print('proxy:', proxy)
    --            self:SetScript("OnClick", function()
    --                header:SetAttribute("spell", "holy light")
    --                header:Click()
    --            end)
    --            return true, 'ok'
    --        ]],
    --        [[
    --            print("xx Post click snippet: clicked.")
    --        ]]
    --)
end

function o:OnClick(button, down)
    --- @type BarFrameObj_ABP_2_0
    local barFrame = self:GetParent()
    local header, proxy = barFrame.Handler, barFrame.SecureProxy
    header:SetAttribute('spell_abp', 'holy light')
    --proxy:SetAttribute('type', 'spell')
    --proxy:SetAttribute('spell', 'holy light')
    --proxy:Click()
    p(('OnClick[%s::%s]: button=%s, down=%s'):format(self:GetName(), self:GetID(), button, tostring(down)))
end

function o:_SaveOldStuff()
    --/dump GetSpellInfo('mend pet') 136
    --/dump GetSpellInfo("Hunter's Mark") 1130
    --/dump GetSpellInfo('Aspect of the iron hawk') -- 109260
    --/dump GetSpellInfo('Aspect of the pack') -- 13159
    local mendPet = GetSpellInfo(136)
    local ironHawk = GetSpellInfo(109260)
    local huntersMark = GetSpellInfo(1130)
    self:SetAttribute('ABP_2_0_spellName1', mendPet)
    self:SetAttribute('ABP_2_0_spellName2', huntersMark)
    self:SetAttribute('type', 'spell')
    p('name=', self:GetName(), 'id=', self:GetID())
    -- btn: frame to wrap
    -- header: -- header with restricted environment
    -- /dump GetSpellInfo(109260) 'Aspect of the Hawk'
    --SecureHandlerWrapScript(
    --        self,
    --        "OnClick",
    --        header,
    --        [[
    --            if button == "RightButton" then
    --                local spellName = self:GetAttribute('ABP_2_0_spellName1')
    --                print("xx RIGHT click secure snippet: sp=", spellName)
    --                self:SetAttribute("spell", spellName)
    --                return true, 'ok'
    --            elseif button == "LeftButton" then
    --                local spellName = self:GetAttribute('ABP_2_0_spellName2')
    --                print("xx LEFT click secure snippet: sp=", spellName)
    --                self:SetAttribute("spell", spellName)
    --                return true, 'ok'
    --            else
    --                self:SetAttribute("spell", nil)
    --            end
    --        ]],
    --        [[
    --            print("xx Post click snippet: clicked.")
    --        ]]
    --)
    
    --self:WrapScript(self, "OnClick", [[
    --if button == "RightButton" then
    --    self:SetAttribute("type", "macro")
    --    self:SetAttribute("macrotext", "/say Hello")
    --end
    --]])
end


function o:OnPostClick(button, down)
    --p(('OnPostClick[%s::%s]: button=%s, down=%s'):format(self:GetName(), self:GetID(), button, tostring(down)))
    self:UpdateState(button, down)
end

function o:OnAttributeChanged(name, val)
    --p(('OnAttributeChanged[%s]: name=%s, val=%s'):format(self:GetID(), name, val))
    self:UpdateAction(name, val)
end

function o:OnEvent(event, ...)
    local args = { ... }
    p(('OnEvent[%s::%s]: name=%s, val=%s'):format(self:GetName(), self:GetID(), event, args))
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param button ButtonName
function o:UpdateState(button, down)
    self:SetChecked(false)
end

function o:UpdateAction(name, val)
    --p('UpdateAction:: called...')
    -- empty for now
end

