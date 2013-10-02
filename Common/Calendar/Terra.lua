--[[ Fetes: Terra ]]--
--[[ Отмечаемые даты: Земля ]]--

----------------------------------------
--[[ description:
  -- Feast and memorial days.
  -- Праздничные и памятные дни.
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
  -- Common fests:
  { y = false, m = 1, d = 1,
    --format = "m-d",
    Kind = "fest", Rest = true,
    Note = L.NewYear, },
  { y = false, m = 2, d = 14,
    --format = "m-d",
    Kind = "fest",
    Note = L.SaintValentineDay, },
  { y = 1918, m = 2, d = 23,
    start = { y = 1922, m = 2, d = 23, },
    --format = "m-d",
    Kind = "fest", Rest = true,
    Note = L.FatherlandDayDefender, },
  { y = 1917, m = 3, d = 8,
    --format = "m-d",
    Kind = "fest", Rest = true,
    Note = L.InternationalWomensDay, },
  { y = false, m = 4, d = 1,
    start = { y = 1686, },
    --format = "m-d",
    Kind = "fest",
    Note = L.AllFoolsDay, },
  { y = 1892, m = 10, d = 28,
    start = { y = 2002, },
    --format = "m-d",
    Kind = "fest",
    Note = L.InterAnimationDay, },
  { y = 1999, m = 11, d = 19,
    --format = "m-d",
    Kind = "fest",
    Note = L.InternationalMensDay, },
  { y = false, m = 12, d = 31,
    --format = "m-d",
    Kind = "fest",
    Note = L.NewYearsEve, },

  -- Special days:
  { y = 1945, m = 5, d = 9,
    --format = "m-d",
    Kind = "memo", Rest = true,
    Note = L.GPW_VictoryDay, },
  { y = 1941, m = 6, d = 22,
    --format = "m-d",
    Kind = "memo",
    Note = L.GPW_MemorialDay, },

  -- Professional days:
  { y = 1961, m = 4, d = 12,
    --format = "m-d",
    Kind = "memo",
    Note = L.WorldCosmonauticsDay, },
  { y = false, m = 7, mweek = -1, wday = 5,
    start = { y = 2000, m = 7, d = 28, },
    format = "mwd",
    Kind = "prof",
    Note = L.SystemAdminsDay, },
  { yday = 256, -- 2^8:
    -- y = false, m = 9, d = 12 or 13,
    start = { y = 1996, m = 7, d = 15, },
    format = "yday",
    Kind = "prof",
    Note = L.ProgrammersDay, },
  { y = 2013, m = 9, d = 18,
    --format = "m-d",
    Kind = "memo", Rest = true,
    Note = L.RussiaObscurantismDay, },
  { y = 1863, m = 9, d = 27,
    start = { y = 2004, m = 9, d = 27, },
    --format = "m-d",
    Kind = "prof",
    Note = L.UpbringersDay, },
  { y = 1966, m = 10, d = 5,
    --format = "m-d",
    Kind = "prof",
    Note = L.WorldTeachersDay, },
  { y = 1494, m = 11, d = 10,
    --format = "m-d",
    Kind = "prof",
    Note = L.InterAccountantsDay, },
} --- Data

return Data
--------------------------------------------------------------------------------
