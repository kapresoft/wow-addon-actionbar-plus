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
--- @class BagController
local L = ns:NewController(libName)
local p = ns:CreateDefaultLogger(libName)
local pb = ns:LC().BAG:NewLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o BagController | ControllerV2
local function PropsAndMethods(o)

    local function extAPI() return O.ActionbarPlusAPI  end

    --- @private
    function o:OnAddOnReady()
        -- TODO next: Could we migrate this to BAG_UPDATE_DELAYED?
        self:RegisterBucketAddOnMessage(E.BAG_UPDATE, 0.2,
                function(evt, source) self:OnBagUpdate(evt, source) end)
    end

    --- Update Items and Macros referencing items
    function o:OnBagUpdate(evt)
        pb:f3( function() return 'OnBagU(): called...' end)
        self:ForEachItemButton(function(bw)
            -- todo next: how to migrate?
            bw:UpdateItemOrMacroState()
            bw:UpdateUsable()
        end)

        --- @param handlerFn ButtonHandlerFunction
        local function CallbackFn(handlerFn) extAPI():UpdateM6Macros(handlerFn) end
        self:SendMessage(MSG.OnBagUpdateExt, libName, CallbackFn)
    end

end; PropsAndMethods(L)

