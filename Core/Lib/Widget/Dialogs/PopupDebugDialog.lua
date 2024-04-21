-- TODO NEXT: Remove this unused library.
--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, LibStub = ns.O, ns.LibStub

local WMX = O.WidgetMixin
local Ace = ns:KO().AceLibrary.O
local AceGUI = Ace.AceGUI
local LuaEvaluator = ns:KO().LuaEvaluator

local libName = 'PopupDebugDialog'
local L = LibStub:NewLibrary(libName)
local p = ns:CreateDefaultLogger(libName)
local FRAME_NAME = 'ABP_DebugDialog'
local FRAME_TITLE = 'Popup Debug Dialog'

---@return PopupDebugDialogFrame
local function CreateDialog()
    ---@class PopupDebugDialogFrame
    local frame = AceGUI:Create("Frame")
    -- The following makes the "Escape" close the window
    WMX:ConfigureFrameToCloseOnEscapeKey(FRAME_NAME, frame)
    frame:SetTitle(FRAME_TITLE)
    frame:SetStatusText('')
    frame:SetCallback("OnClose", function(widget)
        widget:SetTextContent('')
        widget:SetStatusText('')
    end)
    frame:SetLayout("Flow")
    --frame:SetWidth(800)

    -- ABP_PrettyPrint.format(obj)
    local editbox = AceGUI:Create("MultiLineEditBox")
    editbox:SetLabel('')
    editbox:SetText('')
    editbox:SetFullWidth(true)
    editbox:SetFullHeight(true)
    editbox.button:Hide()
    frame:AddChild(editbox)
    frame.editBox = editbox

    function frame:SetTextContent(text)
        self.editBox:SetText(text)
    end
    function frame:SetIcon(iconPathOrId)
        if not iconPathOrId then return end
        self.iconFrame:SetImage(iconPathOrId)
    end

    ---@param str string
    function frame:EvalThenShow(str)
        local strVal = LuaEvaluator:Eval(str)
        self:SetTextContent(pformat:A()(strVal))
        self:SetStatusText(sformat('Var: %s type: %s', str, type(strVal)))
        self:Show()
    end
    ---@param o table
    ---@param objectName string
    function frame:EvalObjectThenShow(o, objectName)
        local strVal = pformat:A()(o)
        self:SetTextContent(strVal)
        self:SetStatusText(sformat('Showing variable value for [%s]', objectName))
        self:Show()
    end

    frame:Hide()
    return frame
end


---@return PopupDebugDialog
function L:Constructor()
    ---@class PopupDebugDialog : PopupDebugDialogFrame
    local dialog = { }
    ---@see "AceGUIContainer-Frame.lua"
    local frameWidget = CreateDialog()
    ns:K():Mixin(dialog, L, frameWidget)

    return dialog
end

L.mt.__call = L.Constructor
