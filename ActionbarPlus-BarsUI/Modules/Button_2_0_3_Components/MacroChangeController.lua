--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns, O = ns:cns()
local comp = O.Compat

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'MacroChangeController'

---@class MacroChangeController: AceEvent-3.0
local o = cns:NewAceEvent()
local p, t = ns:log(libName)

local function Init()
  -- todo next: add handling on MODIFIER_STATE_CHANGED for macros that depend on mod keys
  o:RegisterEvent('UPDATE_MACROS')
end

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]
function o:UPDATE_MACROS()
  ns:a():ForEach(function (module)
    module:ForEachMacro(function (btn, w, conf)
      comp:IfMacro(conf.id, function (name, icon, body)
        btn:UpdateTexture()
      end).OrElse(function (...)
        comp:IfMacroByBodyHash(conf.hash, function (name, icon, body)
          conf.id = name
          w:SetAttribute(conf.type, conf.id)
          btn:UpdateTexture()
        end).OrElse(function ()
          btn.Btn_ResetAll(btn)
        end)
      end)
    end)
  end)
end

--[[-----------------------------------------------------------------------------
Initialize
-------------------------------------------------------------------------------]]
Init()
