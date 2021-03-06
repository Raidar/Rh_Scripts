--[[ DateTime: Terra ]]--

----------------------------------------
--[[ description:
  -- DateTime config for world: Earth.
  -- Конфигурация DateTime для мира: Земля.
--]]
----------------------------------------
--[[ uses:
  LF context utils.
  -- group: Utils, DateTime.
  -- areas: any.
--]]
--------------------------------------------------------------------------------

--local setmetatable = setmetatable

----------------------------------------
--local context = context
local logShow = context.ShowInfo

local numbers = require 'context.utils.useNumbers'
local locale = require 'context.utils.useLocale'

--local divf  = numbers.divf
local divm  = numbers.divm

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Main data
unit.ScriptName = "Terra"
unit.ScriptPath = "scripts\\Rh_Scripts\\Utils\\DateTime\\"

---------------------------------------- ---- Custom
unit.DefCustom = {

  name = unit.ScriptName,
  path = unit.ScriptPath,

  label = unit.ScriptName,

  help   = { topic = unit.ScriptName, },
  locale = {
    kind = 'load',

  }, --

} -- DefCustom

-- [[
local L, e1, e2 = locale.localize(nil, unit.DefCustom)
if L == nil then
  return locale.showError(e1, e2)

end

--logShow(L, "L", "wM")
--]]
---------------------------------------- Config class
local TConfig = {

  World         = "Terra",
  Type          = "Type.Terra",

  YearMin       = 1583,
  YearMax       = 9999,

  YearPerAge    =  100,     -- Век:             1 Age       =  100 Years
  MonthPerYear  =   12,     -- Год:             1 Year      =   12 Months
  DayPerWeek    =    7,     -- Неделя:          1 Week      =    7 Days
  --OutPerWeek    =    0,     --                              +    0 Outweek days
  HourPerDay    =   24,     -- День:            1 Day       =   24 Hours
  MinPerHour    =   60,     -- Час:             1 Hour      =   60 Minutes
  SecPerMin     =   60,     -- Минута:          1 Minute    =   60 Seconds

  MSecPerSec    = 1000,     -- Секунда:         1 Second    = 1000 Milliseconds

  DSecPerSec    =   10,     -- Число дсек в сек:    1 Sec   =   10 dSecs
  CSecPerSec    =  100,     -- Число ссек в сек:            =  100 cSecs
  MSecPerDSec   =  100,     -- Число мсек в дсек:   1 dSec  =  1000 /  10 mSecs
  MSecPerCSec   =   10,     -- Число мсек в ссек:   1 cSec  =  1000 / 100 mSecs

  QuarterPerYear  =  4,     -- Квартальный год: 1 Year          = 4 Quarters
  MonthPerQuarter =  3,     -- Квартал:         1 Quarter       = 12 / 4 Months

  ZeroYear      = false,    -- Наличие нулевого года
  BaseYear      =  365,     -- Обычный год:     1 Base Year     = 365 Days
  LeapYear      =  366,     -- Високосный год:  1 Leap Year     = 365 + 1 Days
  MoonMonth     =   28,     -- Лунный месяц:    1 Moon Month    = 28 Days
  MeanYear  =  365.2425,    -- Средний год:     1 Mean Year
  MeanMonth = 30.436875,    -- Средний месяц:   1 Mean Month

                            -- Множители:               час  мин  сек  мсек
  MinPerDay     =     1440, -- Число минут в день:       24 * 60
  SecPerHour    =     3600, -- Число секунд в час:            60 * 60
  SecPerDay     =    86400, -- Число секунд в день:      24 * 60 * 60
  MSecPerMin    =    60000, -- Число миллисекунд в минуту:         60 * 1000
  MSecPerHour   =  3600000, -- Число миллисекунд в час:       60 * 60 * 1000
  MSecPerDay    = 86400000, -- Число миллисекунд в день: 24 * 60 * 60 * 1000

  --WeekStartDay     = 2, -- Первый день недели:         понедельник
  --YearStartWeekDay = 1, -- День первой недели года:    01.01 = in US
  YearStartWeekDay = 4, -- День первой недели года:    04.01 = ISO 8601
  --YearStartWeekDay = 7, -- День первой недели года:    07.01 = Полная неделя!

  RestWeekDays = {
    [0] = true,
    [6] = true,

  }, -- RestWeekDays

  MonthDays = {
    31, 28, 31,
    30, 31, 30,
    31, 31, 30,
    31, 30, 31,
    [0] = 0,

    Min = 28,
    Max = 31,
    WeekMin = 4 + 1,
    WeekMax = 5 + 1,

  }, -- MonthDays

  YearDays = {
     31,  59,  90,
    120, 151, 181,
    212, 243, 273,
    304, 334, 365,
    [0] = 0,

  }, -- YearDays

  WeekDays = {
    0, 3, 3,
    6, 1, 4,
    6, 2, 5,
    0, 3, 5,

  }, -- WeekDays

  WeekOuts = {

  }, -- WeekOuts

  Formats = {
    World       = "%s",
    Type        = "%s",
    Year        = "%04d",

    Date        = "%04d-%02d-%02d",
    Time        = "%02d:%02d:%02d",
    DateLen     = 10,
    TimeLen     =  8,

    YearDay     = "%03d",
    YearWeek    = " %02d",
    --YDayLen     =  3,

    MonthDay    = "%02d",
    MonthWeek   = "%1d",
    WeekDay     = "<%1d>",
    DayWeek     = "%02d",

  }, -- Formats

  LocData = L,

  --filled = nil,   -- Признак заполненности

} ---
unit.TConfig = TConfig

--[[
do
  local MConfig = { __index = TConfig }

unit.MConfig = MConfig

function unit.newConfig (Config) --|> Config

  local self = Config or {}

  if Config and getmetatable(self) == MConfig then return self end

  return setmetatable(self, MConfig)

end ---- newConfig

end -- do
--]]
---------------------------------------- ---- Date

---------------------------------------- ---- ---- Leap

function TConfig:isLeapYear (y) --> (bool)

  return y % 4 == 0 and (y % 100 ~= 0 or y % 400 == 0)

end ----

---------------------------------------- ---- ---- Count

function TConfig:getMonthDays (y, m) --> (number)

  if m ~= 2 then
    return self.MonthDays[m]

  else
    return self.MonthDays[m] + self:getLeapDays(y)

  end
end ---- getMonthDays

function TConfig:getWeekDays (y, m) --> (number)

  if m <= 2 then
    return self.WeekDays[m]

  else
    return (self.WeekDays[m] + self:getLeapDays(y)) % self.DayPerWeek

  end
end ---- getWeekDays

function TConfig:getWeekMonthDays (y, m) --> (number)

  return self:getMonthDays(y, m)

end ---- getWeekMonthDays

---------------------------------------- ---- ---- get+div

function TConfig:getYearDay (y, m, d) --> (number)

  if m == 1 then
    return d

  elseif m == 2 then
    return d + self.YearDays[1]

  end

  return d + self.YearDays[m - 1] + self:getLeapDays(y)

end ---- getYearDay

function TConfig:divYearDay (y, r) --> (m, d)

  local LastMonth = self:getYearMonths()

  --if r == 0 then
  --  return LastMonth, self:getMonthDays(y, LastMonth)
  --end

  if r < 0 then r = -r end

  local YearDays = self.YearDays
  local LeapDays = self:getLeapDays(y)

  if r <= YearDays[1] then
    return 1, r

  elseif r <= YearDays[2] + LeapDays then
    return 2, r - YearDays[1]

  end

  r = r - LeapDays
  for m = LastMonth - 1, 2, -1 do
    if r > YearDays[m] then
      return m + 1, r - YearDays[m]

    end
  end

  return LastMonth, self:getMonthDays(y, LastMonth)

end ---- divYearDay

function TConfig:getWeekDay (y, m, d) --> (number)

  local P, R = divm(y - 1, 100) -- 100⋅P + R
  local p, q = divm(P, 4)       --   4⋅p + q
  local r, s = divm(R, 4)       --   4⋅r + s

  --return (5 * (q + r) + s + self:getYearDay(y, m, d)) % self.DayPerWeek
  return (5 * (q + r) + s +
          self:getWeekDays(y, m) + d) % self.DayPerWeek

end ---- getWeekDay

function TConfig:getEraDay (y, m, d) --> (number)

  local P, R = divm(y - 1, 100) -- 100⋅P + R
  --local P, R = divm(y - i, 100) -- 100⋅P + R
  local p, q = divm(P, 4)       --   4⋅p + q
  local r, s = divm(R, 4)       --   4⋅r + s
  --logShow({ P, R, p, q, r, s }, "getEraDay", "w d2")

  return 146097 * p + 36524 * q +
           1461 * r +   365 * s +
         self:getYearDay(y, m, d)

end ---- getEraDay

function TConfig:divEraDay (e) --> (y, m, d)

  local i = 1
  if e <= 0 then
    e, i = -e, -1

  end
  --local E = e -- for log only

  local BaseYear = self.BaseYear

  if e <= BaseYear then
    if i > 0 then
      return 1, self:divYearDay(1, e)                   -- н.э.

    else
      return 0, self:divYearDay(0, BaseYear + 1 - e)    -- до н.э.

    end
  end

  e = e - BaseYear

  local p, q
  p, e = divm(e, 146097)
  q, e = divm(e,  36524)
  local P = 4 * p + q

  local r, s
  r, e = divm(e,   1461)
  s, e = divm(e,    365)

  local R = 4 * r + s

  local y = 100 * P + R

  y, e = y + 1, e + BaseYear
  local yd = self:getYearDays(y)
  if e > yd then
    y, e = y + 1, e - yd

  end

  --[[
  logShow({ E, P, R, p, q, r, s, e,
            y, self:isLeapYear(y), },
            "divEraDay", "w d2")
  --]]

  if i > 0 then
    return y, self:divYearDay(y, e)

  else
    y = y - 1

    return -y, self:divYearDay(y, BaseYear + 1 - e)

  end
end ---- divEraDay

---------------------------------------- ---- ---- Check

---------------------------------------- ---- Time

---------------------------------------- ---- ---- get+div

---------------------------------------- ---- ---- Check

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
