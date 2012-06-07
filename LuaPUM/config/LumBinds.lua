--[[ LuaPUM ]]--

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
  path = "Rh_Scripts.LuaPUM.config.",
  locale = { kind = 'require' },
  --path = "scripts\\Rh_Scripts\\LuaPUM\\config\\",
  --locale = { kind = 'load' },
} ---
local L, e1, e2 = locale.localize(Custom)
if L == nil then
  return locale.showError(e1, e2)
end

---------------------------------------- Data
local Data = {

  ["@"] = {
    Author = "Aidar",
    pack = "Rh_Scripts",
    text = "LuaPUM"
  },
  --[[
  ["="] = {
  },
  --]]
  Default = { Caption = L.MainMenu,
              --After = "UScripts;UCommands;U_DefSep;FARMacro;UMConfig" },
              After = "UScripts;UCommands;TortoiseSVN;GitCommands;U_DefSep;FARMacro;UMConfig" },
              --After = "UScripts;U_DefSep;FARMacro;UMConfig", Alias = "LumAlias" },

  --back   = { Menu = "UScripts;TortoiseSVN;U_DefSep;UMConfig", noDefault = true },

  --dir    = { Menu = "TortoiseSVN" },

} --- Data

return Data
--------------------------------------------------------------------------------
