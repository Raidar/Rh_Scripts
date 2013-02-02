--[[ LumSVN ]]--

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

---------------------------------------- Custom
local Custom = {
  label = "LumBinds",
  name = "lum",
  path = "Rh_Scripts.LumSVN.config.",
  locale = { kind = 'require', },
  --path = "scripts\\Rh_Scripts\\LumSVN\\config\\",
  --locale = { kind = 'load', },
} ---

---------------------------------------- Locale
local L, e1, e2 = locale.localize(Custom)
if L == nil then
  return locale.showError(e1, e2)
end

---------------------------------------- Data
local Data = {

  ["@"] = {
    Author = "Aidar",
    pack = "Rh_Scripts",
    text = "LumSVN"
  },
  --[[
  ["="] = {
  },
  --]]
  Default = { Caption = L.MainMenu,
              Before = "TortoiseSVN;U_DefSep;UMConfig" },

  --back   = { Menu = "TortoiseSVN;U_DefSep;UMConfig", noDefault = true },

  --dir    = { Menu = "TortoiseSVN" },

} --- Data

return Data
--------------------------------------------------------------------------------
