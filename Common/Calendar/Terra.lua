--[[ Fetes: Terra ]]--
--[[ Праздники: Земля ]]--

----------------------------------------
--[[ description:
  -- .
  -- .
--]]
--------------------------------------------------------------------------------

----------------------------------------
--local context = context
local logShow = context.ShowInfo

local locale = require 'context.utils.useLocale'

--------------------------------------------------------------------------------

---------------------------------------- Locale
local Custom = {
  label = "Terra",
  name = "Terra",
  path = "Rh_Scripts.Common.Calendar.",
  locale = { kind = 'require' },
} ---
local L, e1, e2 = locale.localize(Custom)
if L == nil then
  return locale.showError(e1, e2)
end
--logShow(L, "L", "wM")

---------------------------------------- Data
local Data = {
  { y = 1945, m = 5, d = 9,
    --format = "m-d",
    Kind = "fest",
    Note = L.VictoryDay, },
  { y = 1941, m = 6, d = 22,
    --format = "m-d",
    Kind = "memo",
    Note = L.GreatPatrioticWarStart, },
} --- Data

return Data
--------------------------------------------------------------------------------
