--- @alias BagController __BagController | ActionBarHandlerMixin
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, E, MSG = ns.O, ns.GC, ns.GC.E, ns.GC.M

local libName = ns.M.BagController
local safecall = ns:CreateSafecall(libName)
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class __BagController : BaseActionBarController
local L = ns:NewActionBarHandler(libName, O.ActionBarHandlerMixin)
local p = ns:CreateDefaultLogger(libName)
local pb = ns:LC().BAG:NewLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o __BagController | BagController
local function PropsAndMethods(o)

    local function extAPI() return O.ActionbarPlusAPI  end

    --- @private
    function o:RegisterMessageCallbacks()
        self:RegisterAddonMessage(E.BAG_UPDATE, function(evt, source) self:OnBagUpdate(evt, source) end)
    end

    -- Update Items and Macros referencing items
    function o:OnBagUpdate(evt)
        pb:f3( function() return 'OnBagU(): called...' end)
        self:ForEachItemButton(function(bw)
            local success, itemInfo = safecall(function() return bw:GetItemData() end)
            if not (success and itemInfo) then return end
            bw:UpdateItemOrMacroState()
        end)

        --- @param handlerFn ButtonHandlerFunction
        local function CallbackFn(handlerFn) extAPI():UpdateM6Macros(handlerFn) end
        self:SendMessage(MSG.OnBagUpdateExt, libName, CallbackFn)
    end

    o:RegisterMessageCallbacks()

end; PropsAndMethods(L)

