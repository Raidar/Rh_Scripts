--[[ LuaUM ]]--

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
  path = "Rh_Scripts.LuaUM.config.",
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
    text = "LuaUM"
  },
  --[[
  ["="] = {
  },
  --]]
  --Default = { Menu = "" },
  Default = { Caption = L.MainMenu,
              Menu = "U_NoMenu", },

} ---

return Data
--------------------------------------------------------------------------------
