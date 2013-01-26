--[[ LuaEUM ]]--

----------------------------------------
--[[ description:
  -- Binding type to menu.
  -- Привязка типа к меню.
--]]
--------------------------------------------------------------------------------

----------------------------------------
--local context = context

local locale = require 'context.utils.useLocale'

--------------------------------------------------------------------------------

---------------------------------------- Locale
local Custom = {
  label = "LumBinds",
  name = "lum",
  path = "Rh_Scripts.LuaEUM.config.",
  locale = { kind = 'require' },
} ---
local L, e1, e2 = locale.localize(Custom)
if L == nil then
  return locale.showError(e1, e2)
end

---------------------------------------- Data
local Data = {

  ["@"] = { -- Информация
    Author = "Aidar",
    pack = "Rh_Scripts",
    text = "LuaEUM"
  },

  ["="] = { -- Замены:
    ini = "none",
    tzt = "none",
  },

  Default = { Caption = L.MainMenu,
              After = "EQuoting;EScripts;UScripts;UCommands;"..
                      "U_DefSep;FARMacro;UMConfig" },

  back   = { Menu = "UScripts;U_DefSep;UMConfig", noDefault = true },

  --none   = { Menu = "Characters" },
  none   = { Menu = "J_None;Characters" },
  --text   = { Menu = "Characters" },
  html   = { Menu = "J_Html;Characters" },
  c      = { Menu = "J_C_Cpp" },
  pascal = { Menu = "J_Pascal" },
  lua    = { Menu = "J_Lua;Characters" },

  sub    = { Menu = "Subtitles;Characters" },
} ---

return Data
--------------------------------------------------------------------------------
