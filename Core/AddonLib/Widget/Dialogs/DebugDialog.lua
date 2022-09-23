local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local Mixin, WMX = O.Mixin, O.WidgetMixin
local AceLibFactory = O.AceLibFactory

local L = LibStub:NewLibrary(Core.M.DebugDialog)
---@type LoggerTemplate
local p = L:GetLogger()
local FRAME_NAME = 'DebugDialog'

---@param o DebugDialog
---@return DebugDialogFrame
local function CreateDialog(o)
    local AceGUI = AceLibFactory:GetAceGUI()
    ---@class DebugDialogFrame
    local frame = AceGUI:Create("Frame")
    -- The following makes the "Escape" close the window
    WMX:ConfigureFrameToCloseOnEscapeKey(FRAME_NAME, frame)
    frame:SetTitle("Debug Frame")
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

    frame:Hide()
    return frame
end

---@return DebugDialog
function L:Constructor()
    ---@class DebugDialog : DebugDialogFrame
    local dialog = { }
    ---@see "AceGUIContainer-Frame.lua"
    local frameWidget = CreateDialog()
    Mixin:Mixin(dialog, L, frameWidget)

    return dialog
end

L.mt.__call = L.Constructor
