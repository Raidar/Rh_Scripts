--[[ flsLUM ]]--

----------------------------------------
--[[ description:
  -- Binding type to menu.
  -- Привязка типа к меню.
--]]
--------------------------------------------------------------------------------
local _G = _G

----------------------------------------
--local context = context

local locale = require 'context.utils.useLocale'

--------------------------------------------------------------------------------

---------------------------------------- Locale
local Custom = {
  label = "LumBinds",
  name = "lum",
  path = "Rh_Scripts.flsLUM.config.",
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
    text = "flsLUM"
  },

  Default = { Caption = L.MainMenu,
              After = "UM_fls;U_DefSep;UMConfig" },

} --- Data

return Data
--------------------------------------------------------------------------------
