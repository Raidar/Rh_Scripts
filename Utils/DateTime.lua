--[[ Date+Time types ]]--

----------------------------------------
--[[ description:
  -- Handling Date and Time.
  -- Обработка даты и времени.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils.
  -- group: Utils, DateTime.
  -- areas: any.
--]]
----------------------------------------
--[[ idea from:
1. RhMathTypes.pas.
   © 1997+, A.I. Rakhmatullin.
2. date.lua.
   © 2006, Jas Latrix.
---- based on:
*. RhLib package for Delphi.
   © 1999+, A.I. Rakhmatullin.
--]]
--------------------------------------------------------------------------------

local setmetatable = setmetatable

local modf  = math.modf
local floor = math.floor

----------------------------------------
--local context = context

local numbers = require 'context.utils.useNumbers'

local divf  = numbers.divf
local divm  = numbers.divm
local round = numbers.round

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Config class
local TConfig = {
  Name          = "Terra",
  Note          = "Gregorean Calendar",

  YearMin       = 1583,
  YearMax       = 9999,

  YearPerAge    =  100, -- Век:             1 Age       =  100 Years
  MonthPerYear  =   12, -- Год:             1 Year      =   12 Monthes
  DayPerWeek    =    7, -- Неделя:          1 Week      =    7 Days
  HourPerDay    =   24, -- День:            1 Day       =   24 Hours
  MinPerHour    =   60, -- Час:             1 Hour      =   60 Minutes
  SecPerMin     =   60, -- Минута:          1 Minute    =   60 Seconds

  MSecPerSec    = 1000, -- Секунда:         1 Second    = 1000 Milliseconds

  DSecPerSec    =   10, -- Число дсек в сек:    1 Sec   =   10 dSecs
  CSecPerSec    =  100, -- Число ссек в сек:            =  100 cSecs
  MSecPerDSec   =  100, -- Число мсек в дсек:   1 dSec  =  1000 /  10 mSecs
  MSecPerCSec   =   10, -- Число мсек в ссек:   1 cSec  =  1000 / 100 mSecs

  QuarterPerYear  =  4, -- Квартальный год: 1 Year          = 4 Quarters
  MonthPerQuarter =  3, -- Квартал:         1 Quarter       = 12 / 4 Monthes

  BaseYear      =  365, -- Обычный год:     1 Base Year     = 365 Days
  LeapYear      =  366, -- Високосный год:  1 Leap Year     = 365 + 1 Days
  MoonMonth     =   28, -- Лунный месяц:    1 Moon Month    = 28 Days
  MeanYear    =  365.4, -- Средний год:     1 Mean Year     ~ 365.4 Days
  MeanMonth   =  30.45, -- Средний месяц:   1 Mean Month    ~ 365.4 / 12 Days

                            -- Множители:               час  мин  сек  мсек
  MinPerDay     =     1440, -- Число минут в день:       24 * 60
  SecPerHour    =     3600, -- Число секунд в час:            60 * 60
  SecPerDay     =    86400, -- Число секунд в день:      24 * 60 * 60
  MSecPerMin    =    60000, -- Число миллисекунд в минуту:         60 * 1000
  MSecPerHour   =  3600000, -- Число миллисекунд в час:       60 * 60 * 1000
  MSecPerDay    = 86400000, -- Число миллисекунд в день: 24 * 60 * 60 * 1000

  -- TODO: Константы и функции для правильного учёта недели года и начала недели.
  --WeekStartDay  = 2, -- Первый день недели:         понедельник
  --YearStartWeek = 1, -- День первой недели года:    1-я января
  --YearStartWeek = 4, -- День первой недели года:    4-я января
  --YearStartWeek = 7, -- День первой недели года:    Первая полная неделя ??

  -- Количество дней в месяцах:
  MonthDays = {
    31, 28, 31,
    30, 31, 30,
    31, 31, 30,
    31, 30, 31,
    [0] = 0,
    Min = 28,
    Max = 31,
    WeekMin = 4,
    WeekMax = 5,
  }, --
  -- Количество дней в году по месяцам:
  YearDays = {
     31,  59,  90,
    120, 151, 181,
    212, 243, 273,
    304, 334, 365,
    [0] = 0,
  }, --
  -- Номера дней недели для последних дней предыдущих месяцев
  -- (при условии, что 31 декабря предыущего года — воскресение):
  WeekDays = {
    0, 3, 3,
    6, 1, 4,
    6, 2, 5,
    0, 3, 5,
  }, --

  --filled = nil,         -- Признак заполненности
} ---
unit.DefConfig = TConfig

-- Fill month days with additional data.
-- Заполнение дней месяцев дополнительными данными.
function unit.fillMonthDaysData (MonthDays, DayPerWeek) --|> (MonthDays)
  local MonthDays = MonthDays
  local Min, Max = MonthDays[1], MonthDays[1]
  for k = 2, #MonthDays do
     local v = MonthDays[k]
     if v < Min then Min = v end
     if v > Max then Max = v end
  end

  MonthDays.Min = Min
  MonthDays.Max = Max

  MonthDays.WeekMin = numbers.divc(Min, DayPerWeek)
  MonthDays.WeekMax = numbers.divc(Max, DayPerWeek)

  return MonthDays
end ---- fillMonthDaysData

-- Find year days by months' days.
-- Нахождение дней в году по дням в месяцах.
function unit.findYearDays (MonthDays) --|> (YearDays)
  local MonthDays = MonthDays
  local Sum = 0
  local YearDays = { [0] = 0, }
  for k = 1, #MonthDays do
     Sum = Sum + MonthDays[k]
     YearDays[k] = Sum
  end
  return YearDays
end ---- findYearDays

-- Find week days for last days of prior months.
-- Нахождение дней недели для последних дней предыдущих месяцев.
function unit.findWeekDays (YearDays, DayPerWeek) --|> (YearDays)
  local YearDays, DayPerWeek = YearDays, DayPerWeek
  local WeekDays = {}
  for k = 1, #YearDays do
    WeekDays[k] = YearDays[k - 1] % DayPerWeek
  end
  return WeekDays
end ---- findWeekDays

-- Fill derived constants.
-- Заполнение производных констант.
function unit.fillConfig (Config) --|> Config
  if Config.filled then return end

  Config.MonthPerQuarter    = Config.MonthPerYear / Config.QuarterPerYear
  Config.LeapYear           = Config.BaseYear + 1
  Config.MeanMonth          = Config.MeanYear / Config.MonthPerYear

  local HourPerDay  = Config.HourPerDay
  local MinPerHour  = Config.MinPerHour
  local SecPerMin   = Config.SecPerMin

  Config.MinPerDay      =        MinPerHour  * HourPerDay
  Config.SecPerHour     =        SecPerMin   * MinPerHour
  Config.SecPerDay      = Config.SecPerHour  * HourPerDay
  Config.MSecPerMin     = Config.MSecPerSec  * SecPerMin
  Config.MSecPerHour    = Config.MSecPerMin  * MinPerHour
  Config.MSecPerDay     = Config.MSecPerHour * HourPerDay

  unit.fillMonthDaysData(Config.MonthDays)

  if not Config.YearDays then
    Config.YearDays = unit.findYearDays(Config.MonthDays)
  end

  if not Config.WeekDays then
    Config.WeekDays = unit.findWeekDays(Config.YearDays, Config.DayPerWeek)
  end

  Config.filled = true

  return Config
end ---- FillConfig

do
  local MConfig = { __index = TConfig, }

function unit.newConfig (Config) --|> Config
  local self = Config or {}
  self = setmetatable(self, MConfig)

  if Config then
    return unit.fillConfig(self)
  end

  return self
end ---- newConfig

end -- do
---------------------------------------- ---- Date
-- Check an year for leap year.
-- Проверка на високосный год.
--[[ @params:
  y (number) - year.
---- @return:
  result (bool) - true if year is a leap year.
--]]
function TConfig:isLeapYear (y) --> (bool)
  return y % 4 == 0 and (y % 100 ~= 0 or y % 400 == 0)
end ----

-- Count extra days of leap year.
-- Количество лишних дней високосного года.
--[[ @params:
  y (number) - year.
---- @return:
  result (number) - extra days in leap year.
--]]
function TConfig:getLeapDays (y) --> (bool)
  return self:isLeapYear(y) and 1 or 0
end ----

-- Count days in month.
-- Количество дней в месяце.
--[[ @params:
  y (number) - year.
  m (number) - month.
---- @return:
  result (number) - day count in month.
--]]
function TConfig:getMonthDays (y, m) --> (number)
  local self = self

  if m ~= 2 then
    return self.MonthDays[m]
  else
    return self.MonthDays[m] + self:getLeapDays(y)
  end
end ---- getMonthDays

-- Count days in year.
-- Количество дней в году.
--[[ @params:
  y (number) - year.
---- @return:
  result (number) - days count in year.
--]]
function TConfig:getYearDays (y) --> (number)
  return self.BaseYear + self:getLeapDays(y)
end ---- getYearDays

-- Get week day for last day of prior month.
-- Получение дня недели для последнего дня предыдущего месяца.
--[[ @params:
  y (number) - year.
  m (number) - month.
---- @return:
  result (number) - day of week for last day of prior month.
--]]
function TConfig:getWeekDays (y, m) --> (number)
  local self = self

  if m <= 2 then
    return self.WeekDays[m]
  else
    return (self.WeekDays[m] + self:getLeapDays(y)) % self.DayPerWeek
  end
end ---- getWeekDays

-- Get day number in year.
-- Получение номера дня в году.
--[[ @params:
  y (number) - year.
  m (number) - month.
  d (number) - day.
---- @return:
  result (number) - day of year.
--]]
function TConfig:getYearDay (y, m, d) --> (number)
  if m == 1 then
    return d
  elseif m == 2 then
    return d + self.YearDays[1]
  end

  return d + self.YearDays[m - 1] + self:getLeapDays(y)
end ---- getYearDay

-- Divide day number in year into date.
-- Выделение даты из номера дня в году.
--[[ @params:
  y (number) - year.
  r (number) - day of year.
---- @return:
  m (number) - month.
  d (number) - day.
--]]
function TConfig:divYearDay (y, r) --> (m, d)
  local self = self
  local YearDays = self.YearDays

  if r <= YearDays[1] then
    return 1, r
  elseif r <= YearDays[2] then
    return 2, r - YearDays[1]
  end

  local r = r - self:getLeapDays(y)
  local MonthPerYear = self.MonthPerYear
  for m = MonthPerYear - 1, 2, -1 do
    if r > YearDays[m] then
      return m + 1, r - YearDays[m]
    end
  end

  return MonthPerYear, self.MonthDays[MonthPerYear]
end ---- divYearDay

-- Get week number in year.
-- Получение номера недели в году.
--[[ @params:
  y (number) - year.
  m (number) - month.
  d (number) - day.
  f (number) - first day for first week (@default = 0).
---- @return:
  result (number) - week of year.
---- @notes:
  The first week is a week with January 1 by default.
---- @notes:rus:
  По умолчанию 1-й неделей считается неделя с 1-м января.
--]]
function TConfig:getYearWeek (y, m, d, f) --> (number)
  local self = self
  local YearStartDay = self:getWeekDay(y, 01, 01)

  return divf((f or 0) +
              self:getYearDay(y, m, d) - 1 +
              (YearStartDay == 0 and self.DayPerWeek or YearStartDay) - 1,
              self.DayPerWeek) + 1
end ---- getYearWeek

-- Get day number of the week.
-- Получение номера дня недели.
--[[ @params:
  y (number) - year.
  m (number) - month.
  d (number) - day.
---- @return:
  result (number) - day of week.
---- @notes:
  1 - Monday, 2 - Tuesday, 3 - Wednesday,
  4 - Thursday, 5 - Friday, 6 - Saturday, 0 - Sunday.
---- @notes:rus:
  1 - понедельник, 2 - вторник, 3 - среда,
  4 - четверг, 5 - пятница, 6 - суббота, 0 - воскресенье.
--]]
function TConfig:getWeekDay (y, m, d) --> (number)

  local P, R = divm(y - 1, 100) -- 100⋅P + R
  local p, q = divm(P, 4)       --   4⋅p + q
  local r, s = divm(R, 4)       --   4⋅r + s

  --return (5 * (q + r) + s + self:getYearDay(y, m, d)) % self.DayPerWeek
  return (5 * (q + r) + s + self:getWeekDays(y, m) + d) % self.DayPerWeek
end ---- getWeekDay

-- Get day number of the common era.
-- Получение номера дня нашей эры.
--[[ @params:
  y (number) - year.
  m (number) - month.
  d (number) - day.
---- @return:
  result (number) - day of common era.
--]]
function TConfig:getEraDay (y, m, d) --> (number)

  local P, R = divm(y - 1, 100) -- 100⋅P + R
  local p, q = divm(P, 4)       --   4⋅p + q
  local r, s = divm(R, 4)       --   4⋅r + s

  return 146097 * p + 36524 * q +
           1461 * r +   365 * s +
         self:getYearDay(y, m, d)
end ---- getEraDay

-- Divide day number of the common era into date.
-- Выделение даты из номера дня нашей эры.
--[[ @params:
  e (number) - day of common era.
---- @return:
  y (number) - year.
  m (number) - month.
  d (number) - day.
--]]
function TConfig:divEraDay (e) --> (y, m, d)
  -- TODO: Реализовать и прроверить!
  local e = e

  local p, q
  p, e = divm(e, 146097)
  q, e = divm(e,  36524)
  local P = 4 * p + q

  local r, s
  r, e = divm(e,   1461)
  s, e = divm(e,    365)
  local R = 4 * r + s

  local y = 100 * P + R + 1

  return y, self:divYearDay(y, e)
end ---- divEraDay

-- Get month number of the common era.
-- Получение номера месяца нашей эры.
--[[ @params:
  y (number) - year.
  m (number) - month.
---- @return:
  result (number) - month of common era.
--]]
function TConfig:getEraMonth (y, m) --> (number)
  return y * self.MonthPerYear + m
end ---- getEraMonth

-- Divide month number of the common era.
-- Выделение даты из номера месяца нашей эры.
--[[ @params:
  r (number) - month of common era.
---- @return:
  y (number) - year.
  m (number) - month.
--]]
function TConfig:divEraMonth (r) --> (y, m)
  local MonthPerYear = self.MonthPerYear
  local y, m = divm(r, MonthPerYear)

  if m ~= 0 then return y, m end
  return y - 1, MonthPerYear
end ---- divEraMonth

-- Check date.
-- Проверка даты.
--[[ @params:
  y (number) - year.
  m (number) - month.
  d (number) - day.
---- @return:
  result (bool) - true if date is correct.
--]]
function TConfig:isDate (y, m, d) --> (y, m, d)
  local self = self

  return (m > 0) and (m <= self.MonthPerYear) and
         (d > 0) and (d <= self:getMonthDays(y, m))
end ---- isDate

---------------------------------------- ---- Time
-- Count seconds without milliseconds.
-- Количество секунд без долей секунд.
--[[ @params:
  h (number) - hour.
  n (number) - minute.
  s (number) - second.
---- @return:
  result (number) - second count in day.
--]]
function TConfig:getDaySec (h, n, s) --> (number)
  --local self = self
  return s + (n + h * self.MinPerHour) * self.SecPerMin
end ----

-- Check time.
-- Проверка времени.
--[[ @params:
  h (number) - hour.
  n (number) - minute.
  s (number) - second.
  z (number) - millisecond.
---- @return:
  result (bool) - true if time is correct.
--]]
function TConfig:isTime (h, n, s, z) --> (y, m, d)
  local self = self

  return (h >= 0) and (h <= self.HourPerDay) and
         (n >= 0) and (n <= self.MinPerHour) and
         (s >= 0) and (s <= self.SecPerHour) and
         (not z or (z >= 0) and (z <= self.MSecPerSec))
end ---- isTime

---------------------------------------- Date class
local TDate = {} -- Класс даты

do
  local MDate = { __index = TDate, }

-- Создание объекта класса.
function unit.newDate (y, m, d, config) --> (object)
  local self = {
    y = y or 0, -- Количество лет
    m = m or 0, -- Количество месяцев
    d = d or 0, -- Количество дней

    config = config or unit.newConfig(),
  } --- self

  return setmetatable(self, MDate)
end -- newDate

end -- do
---------------------------------------- ---- handling
function TDate:data () --> (d, m, y, config)
  local self = self
  return self.y, self.m, self.d, self.config
end ----

function TDate:copy () --> (object)
  return unit.newDate(self:data())
end ----

function TDate:getMonthDays () --> (bool)
  local self = self
  return self.config:getMonthDays(self.y, self.m)
end ----

function TDate:getYearDays () --> (bool)
  --local self = self
  return self.config:getYearDays(self.y)
end ----

function TDate:getYearDay () --> (bool)
  local self = self
  return self.config:getYearDay(self.y, self.m, self.d)
end ----

function TDate:divYearDay (r) --> (m, d)
  --local self = self
  return self.config:divYearDay(self.y, r)
end ----

function TDate:getYearWeek () --> (number)
  local self = self
  return self.config:getYearWeek(self.y, self.m, self.d)
end ----

function TDate:getWeekDay () --> (number)
  local self = self
  return self.config:getWeekDay(self.y, self.m, self.d)
end ----

function TDate:getEraDay () --> (number)
  local self = self
  return self.config:getEraDay(self.y, self.m, self.d)
end ----

function TDate:divEraDay (r) --> (y, m, d)
  local self = self
  return self.config:divEraDay(r)
end ----

function TDate:getEraMonth () --> (number)
  local self = self
  return self.config:getEraMonth(self.y, self.m)
end ----

function TDate:getEraMonth () --> (number)
  local self = self
  return self.config:getEraMonth(self.y, self.m)
end ----

function TDate:divEraMonth (r) --> (y, m)
  return self.config:divEraMonth(r)
end ----

function TDate:ymd () --> (number)
  return self:getEraDay()
end ----

---------------------------------------- ---- to & from
function TDate:to_y () --> (number)
  return self.y - 1 + self:getYearDay() / self:getYearDays()
end ----

function TDate:to_m () --> (number)
  return self:getEraMonth() - 1 + self.d / self:getMonthDays()
end ----

function TDate:to_d () --> (number)
  return self:getYearDay()
end ----

function TDate:from_y (v) --> (self, rest)
  local self = self

  local w, v = modf(v)
  self.y = w + 1
  v = v * self:getYearDays()

  self.m, v = self:divYearDay(v)
  self.d, v = modf(v)

  return self, v
end ----

function TDate:from_m (v) --> (self, rest)
  local self = self

  local w, v = modf(v)
  self.y, self.m = self:divEraMonth(w + 1)
  v = v * self:getMonthDays()

  self.d, v = modf(v)

  return self, v
end ----

function TDate:from_d (v) --> (self, rest)
  local self = self

  local w, v = modf(v)
  self.y, self.m, self.d = self:divEraDay(w)

  return self, v
end ----

---------------------------------------- ---- operations

---------------------------------------- Time class
local TTime = {} -- Класс времени

do
  local MTime = { __index = TTime, }

-- Создание объекта класса.
function unit.newTime (h, n, s, z, config) --> (object)
  local self = {
    h = h or 0, -- Количество часов
    n = n or 0, -- Количество минут
    s = s or 0, -- Количество секунд
    z = z or 0, -- Количество миллисекунд

    config = config or unit.newConfig(),
  } --- self

  return setmetatable(self, MTime)
end -- newTime

end -- do
---------------------------------------- ---- handling
function TTime:data () --> (h, n, s, z, config)
  local self = self
  return self.h, self.n, self.s, self.z, self.config
end ----

function TTime:copy () --> (object)
  return unit.newTime(self:data())
end ----

function TTime:getDaySec () --> (number)
  local self = self
  return self.config:getDaySec(self.h, self.n, self.s)
end ----

function TTime:hns () --> (number)
  return self:getDaySec()
end ----

-- Get milliseconds as second fraction.
-- Получение миллисекунд как доля секунды.
--[[ @return:
  result (number) - milliseconds as fraction of second.
--]]
function TTime:msec () --> (number)
  return self.z / self.config.MSecPerSec
end ----

-- Количество десятых долей секунды в миллисекундах.
function TTime:dz () --> (number)
  --local self = self
  return round(self.z / self.config.MSecPerDSec)
end ----

-- Количество сотых долей секунды в миллисекундах.
function TTime:cz () --> (number)
  --local self = self
  return round(self.z / self.config.MSecPerCSec)
end ----

---------------------------------------- ---- to & from
function TTime:to_h () --> (number)
  local self = self
  local c = self.config
  return ( (self.z / c.MSecPerSec +
            self.s) / c.SecPerMin +
           self.n ) / c.MinPerHour + self.h
end ----

function TTime:to_n () --> (number)
  local self = self
  local c = self.config
  return (self.z / c.MSecPerSec +
          self.s) / c.SecPerMin +
          self.n +
          self.h * c.MinPerHour
end ----

function TTime:to_s () --> (number)
  local c = self.config
  return self.z / c.MSecPerSec +
         self.s +
         (self.n +
          self.h * c.MinPerHour
         ) * c.SecPerMin
end ----

function TTime:to_z () --> (number)
  local self = self
  local c = self.config
  return self.z +
         ( self.s +
           (self.n +
            self.h * c.MinPerHour
           ) * c.SecPerMin
         ) * c.MSecPerSec
end ----

function TTime:from_h (v) --> (self)
  local self = self
  local c, v = self.config, v

  self.h, v = modf(v)
  self.n, v = modf(v * c.MinPerHour)
  self.s, v = modf(v * c.SecPerMin)
  self.z = round(v * c.MSecPerSec)

  return self
end ---- from_h

function TTime:from_n (v) --> (self)
  local self = self
  local c, v = self.config, v

  local x = c.MinPerHour
  self.h = floor(v / x)
  v = v - self.h * x

  self.n, v = modf(v)
  self.s, v = modf(v * c.SecPerMin)
  self.z = round(v * c.MSecPerSec)

  return self
end ---- from_n

function TTime:from_s (v) --> (self)
  local c, v = self.config, v

  local x = c.SecPerHour
  self.h = floor(v / x)
  v = v - self.h * x

  local x = c.SecPerMin
  self.n = floor(v / x)
  v = v - self.n * x

  self.s, v = modf(v)
  self.z = round(v * c.MSecPerSec)

  return self
end ---- from_s

function TTime:from_z (v) --> (self)
  local self = self
  local c, v = self.config, v

  local x = c.MSecPerHour
  self.h = floor(v / x)
  v = v - self.h * x

  local x = c.MSecPerMin
  self.n = floor(v / x)
  v = v - self.n * x

  local x = c.MSecPerSec
  self.s = floor(v / x)
  self.z = v - self.s * x

  return self
end ---- from_z

---------------------------------------- ---- operations
function TTime:sum (time) --> (number)
  return self:to_z() + time:to_z()
end ----

function TTime:dif (time) --> (number)
  return self:to_z() - time:to_z()
end ----

function TTime:add (time) --> (self)
  --local self = self
  return self:from_z(self:summ(time))
end ----

function TTime:sub (time) --> (self)
  --local self = self
  return self:from_z(self:diff(time))
end ----

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
