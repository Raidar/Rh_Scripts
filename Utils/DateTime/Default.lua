--[[ DateTime: Default ]]--

----------------------------------------
--[[ description:
  -- DateTime config for world: Default.
  -- Конфигурация DateTime для мира: Умолчание.
--]]
----------------------------------------
--[[ uses:
  LF context utils.
  -- group: Utils, DateTime.
  -- areas: any.
--]]
--------------------------------------------------------------------------------

local setmetatable = setmetatable

----------------------------------------
--local context = context
local logShow = context.ShowInfo

local numbers = require 'context.utils.useNumbers'
--local locale = require 'context.utils.useLocale'

local divf  = numbers.divf
local divm  = numbers.divm

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Main data
unit.ScriptName = "Default"
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

--[[
local L, e1, e2 = locale.localize(nil, unit.DefCustom)
if L == nil then
  return locale.showError(e1, e2)
end

--logShow(L, "L", "wM")
--]]
---------------------------------------- Config class
local TConfig = {
  World         = "Default",        -- Мир
  Type          = "Type.Default",   -- Тип календаря

  YearMin       = -9998,
  YearMax       =  9999,

  YearPerAge    =  100,     -- Век:             1 Age       =  100 Years
  MonthPerYear  =   13,     -- Год:             1 Year      =   12 Months
  DayPerWeek    =    7,     -- Неделя:          1 Week      =    7 Days
  OutPerWeek    =    0,     --                              +    0 Outweek days
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
  BaseYear      =  364,     -- Обычный год:     1 Base Year     = 364 Days
  LeapYear      =  364,     -- Високосный год:  1 Leap Year     = 364 + 0 Days
  MoonMonth     =   28,     -- Лунный месяц:    1 Moon Month    = 28 Days
  MeanYear      =  364,     -- Средний год:     1 Mean Year
  MeanMonth     =   28,     -- Средний месяц:   1 Mean Month

                            -- Множители:               час  мин  сек  мсек
  MinPerDay     =     1440, -- Число минут в день:       24 * 60
  SecPerHour    =     3600, -- Число секунд в час:            60 * 60
  SecPerDay     =    86400, -- Число секунд в день:      24 * 60 * 60
  MSecPerMin    =    60000, -- Число миллисекунд в минуту:         60 * 1000
  MSecPerHour   =  3600000, -- Число миллисекунд в час:       60 * 60 * 1000
  MSecPerDay    = 86400000, -- Число миллисекунд в день: 24 * 60 * 60 * 1000

  -- TODO: Учёт отсчёта начала недели.
  --WeekStartDay     = 2, -- Первый день недели:         понедельник
  -- Учёт отсчёта недели года.
  YearStartWeekDay = 1, -- День первой недели года:    01.01 = in US
  --YearStartWeekDay = 4, -- День первой недели года:    04.01 = ISO 8601
  --YearStartWeekDay = 7, -- День первой недели года:    07.01 = Полная неделя!

  -- Rest week days.
  -- Выходные дни недели.
  RestWeekDays = {
    [0] = true,
    [6] = true,
  }, -- RestWeekDays

  -- Months' days count.
  -- Количество дней в месяцах.
  MonthDays = {
    28, 28, 28,
    28, 28, 28,
    28, 28, 28,
    28, 28, 28,
    28,
    [0] = 0,

    Min = 28,
    Max = 28,
    WeekMin = 4 + 2,             WeekMax = 4 + 2,
  }, -- MonthDays

  -- Year' days count by months.
  -- Количество дней в году по месяцам:
  YearDays = {
     28,  56,  84,
    112, 140, 168,
    196, 224, 252,
    280, 308, 336,
    364,
    [0] = 0,
  }, -- YearDays

  -- Week days for last days of previous months
  -- (providing that last day of previous year is Sunday).
  -- Дни недели для последних дней предыдущих месяцев
  -- (при условии, что последний день предыдущего года — воскресенье).
  WeekDays = {
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
  }, -- WeekDays

  -- Outweek days with "outweekday" number.
  -- Вненедельные дни с номерами дней "вненедели".
  WeekOuts = {
    --{ m = 12, d = 32, od = 1, },
  }, -- WeekOuts

  -- Formats to output.
  -- Форматы для вывода.
  Formats = {
    World       = "%s",
    Type        = "%s",
    Year        = "%04d",

    Date        = "%04d-%02d-%02d",
    Time        = "%02d:%02d:%02d",
    DateLen     = 10,
    TimeLen     =  8,

    YearDay     = "%03d",
    YearWeek    = "%02d",
    --YDayLen     =  3,

    MonthDay    = "%02d",
    MonthWeek   = "%1d",
    WeekDay     = "<%1d>",
  }, -- Formats

  --LocData = L,

  --filled = nil,   -- Признак заполненности
} ---
unit.TConfig = TConfig

do
  local MConfig = { __index = TConfig }

unit.MConfig = MConfig

function unit.newConfig (Config) --|> Config
  local self = Config or {}

  if Config and getmetatable(self) == MConfig then return self end

  return setmetatable(self, MConfig)
end ---- newConfig

end -- do
---------------------------------------- ---- Date

---------------------------------------- ---- ---- Zero

function TConfig:isZeroYear (y) --> (bool)
  return self.ZeroYear
end ----

---------------------------------------- ---- ---- Leap
-- Check an year for leap year.
-- Проверка на високосный год.
--[[ @params:
  y (number) - year.
---- @return:
  result (bool) - true if year is a leap year.
--]]
function TConfig:isLeapYear (y) --> (bool)
  return false
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

---------------------------------------- ---- ---- Count
-- Count months in year.
-- Количество месяцев в годе.
--[[ @params:
  y (number) - year.
---- @return:
  result (number) - month count in year.
--]]
function TConfig:getYearMonths (y) --> (number)
  return self.MonthPerYear
end ---- getYearMonths

-- Count weeks in year.
-- Количество недель в году.
--[[ @params:
  y (number) - year.
---- @return:
  result (number) - weeks count in year.
--]]
function TConfig:getYearWeeks (y) --> (number)
  local self = self
  return self:getYearWeek(self:getYearLastDay(y)) -
         self:getYearWeek(y + 1, 1, 1)
end ---- getYearWeeks

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

-- Count days in month.
-- Количество дней в месяце.
--[[ @params:
  y (number) - year.
  m (number) - month.
---- @return:
  result (number) - day count in month.
--]]
function TConfig:getMonthDays (y, m) --> (number)
  return self.MonthDays[m]
end ---- getMonthDays

-- Get week day for last day of prior month.
-- Получение дня недели для последнего дня предыдущего месяца.
--[[ @params:
  y (number) - year.
  m (number) - month.
---- @return:
  result (number) - day of week for last day of prior month.
--]]
function TConfig:getWeekDays (y, m) --> (number)
  return self.WeekDays[m]
end ---- getWeekDays

-- Count days in month for weekdays.
-- Количество дней в месяце для дней недели.
--[[ @params:
  y (number) - year.
  m (number) - month.
---- @return:
  result (number) - day count in month.
--]]
function TConfig:getWeekMonthDays (y, m) --> (number)
  return self.MonthDays[m]
end ---- getWeekMonthDays

-- Count days in month for weekouts.
-- Количество дней в месяце для вненедельных дней.
--[[ @params:
  y (number) - year.
  m (number) - month.
---- @return:
  result (number) - day count in month.
--]]
function TConfig:getWeekMonthOuts (y, m) --> (number)
  return 0
end ---- getWeekMonthOuts

---------------------------------------- ---- ---- get+div
-- Get last day in year.
-- Получение последнего дня в году.
--[[ @params:
  y (number) - year.
---- @return:
  y (number) - year.
  m (number) - month.
  d (number) - day.
--]]
function TConfig:getYearLastDay (y) --> (number)
  --local self = self
  local m = self:getYearMonths(y)
  return y, m, self:getMonthDays(y, m)
end ---- getYearLastDay

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
  return d + self.YearDays[m - 1]
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

  local LastMonth = self:getYearMonths(y)

  if r == 0 then
    return LastMonth, self:getMonthDays(y, LastMonth)
  end

  if r < 0 then r = -r end

  local YearDays = self.YearDays
  for m = LastMonth - 1, 0, -1 do
    if r > YearDays[m] then
      return m + 1, r - YearDays[m]
    end
  end

  return LastMonth, self:getMonthDays(y, LastMonth)
end ---- divYearDay

-- Get week number in year.
-- Получение номера недели в году.
--[[ @params:
  y (number) - year.
  m (number) - month.
  d (number) - day.
  f (number) - day for week start of year
               (@default = YearStartWeekDay): 1..DayPerWeek.
---- @return:
  result (number) - week of year.
--]]
function TConfig:getYearWeek (y, m, d, f) --> (number)
  local self = self

  local DayPerWeek = self.DayPerWeek
  local YearStartDay = self:getWeekNumDay(y, 1, 1)
  local YearStartShift = DayPerWeek - (f or self.YearStartWeekDay) + 1

  return divf(self:getYearDay(y, m, d) - 1 +
              DayPerWeek + YearStartDay - 1 -
              (YearStartDay > YearStartShift and DayPerWeek or 0),
              DayPerWeek)
end ---- getYearWeek

-- Get week number in month.
-- Получение номера недели в месяце.
--[[ @params:
  y (number) - year.
  m (number) - month.
  d (number) - day.
---- @return:
  result (number) - week of month.
--]]
function TConfig:getMonthWeek (y, m, d) --> (number)
  local self = self
  return self:getYearWeek(y, m, d, 1) - self:getYearWeek(y, m, 1, 1) + 1
end ---- getMonthWeek

-- Get day number of the week.
-- Получение номера дня недели.
--[[ @params:
  y (number) - year.
  m (number) - month.
  d (number) - day.
---- @return:
  result (number) - day of week.
---- @notes:
  1 - first weekday, ..., 0 - last weekday.
---- @notes:rus:
  1 - первый день недели, ..., 0 - последний день недели.
--]]
function TConfig:getWeekDay (y, m, d) --> (number)
  local self = self
  return (self:getWeekDays(y, m) + d) % self.DayPerWeek
end ---- getWeekDay

-- Get day number of the week in 1..DayPerWeek range.
-- Получение номера дня недели в диапазоне 1..DayPerWeek.
--[[ @params:
  y (number) - year.
  m (number) - month.
  d (number) - day.
---- @return:
  result (number) - day of week as 1..DayPerWeek.
--]]
function TConfig:getWeekNumDay (y, m, d) --> (number)
  local self = self
  local wday = self:getWeekDay(y, m, d)
  return wday == 0 and self.DayPerWeek or wday
end ---- getWeekNumDay

-- Get day from month week day.
-- Получение дня из дня недели месяца.
--[[ @params:
  y (number) - year.
  m (number) - month.
  mw (number) - month week.
  wd (number) - week day.
---- @return:
  d (number) - day.
--]]
-- WARN: Не упрощать, т.к. универсальный алгоритм!
-- TODO: Учесть OutPerWeek и вненедельные дни!
-- Посмотреть, что лучше: -1 или DeyPerWeek + 1 !
function TConfig:getMonthWeekDay (y, m, mw, wd) --> (number)
  local self = self

  local DayPerWeek = self.DayPerWeek

  if mw < 0 then
    local Day = self:getWeekMonthDays(y, m)       -- LastDay
    local WeekDay = self:getWeekNumDay(y, m, Day) -- LastWeekDay
    local Shift = WeekDay >= wd and 1 or 0
    return Day + DayPerWeek * (mw + Shift) + (wd - WeekDay)
  else
    local Day = 1                                 -- StartDay
    local WeekDay = self:getWeekNumDay(y, m, Day) -- StartWeekDay
    local Shift = WeekDay <= wd and 1 or 0
    return Day + DayPerWeek * (mw - Shift) + (wd - WeekDay)
  end

  return 0
end ---- getMonthWeekDay

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
  local self = self
  return (y - 1) * self.BaseYear + self:getYearDay(y, m, d)
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
  local e, i = e, 1
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

  local y
  y, e = divm(e, BaseYear)

  y, e = y + 1, e + BaseYear
  local yd = self:getYearDays(y)
  if e > yd then
    y, e = y + 1, e - yd
  end

  --logShow({ E, e, y, self:isLeapYear(y), }, "divEraDay", "w d2")

  if i > 0 then
    return y, self:divYearDay(y, e)
  else
    y = y - 1
    return -y, self:divYearDay(y, BaseYear + 1 - e)
  end
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
  return (y - 1) * self.MonthPerYear + m
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

  if m ~= 0 then return y + 1, m end

  return y, MonthPerYear
end ---- divEraMonth

---------------------------------------- ---- ---- Check
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

-- Fix year for year ±1.
-- Исправление года для года ±1.
function TConfig:fixYear (date, shift) --> (date)
  return date
end ---- fixYear

-- Fix month day for year ±1.
-- Исправление дня месяца для года ±1.
function TConfig:fixYearMonthDay (date) --> (date)
  local date = date

  if date.d < 1 then
    date.d = 1
  else
    local MonthDays = self:getMonthDays(date.y, date.m)

    if date.d > MonthDays then
      date.d = MonthDays
    end
  end

  return date
end ---- fixYearMonthDay

-- Fix year and month for month ±1.
-- Исправление месяца и года для месяца ±1.
function TConfig:fixYearMonth (date) --> (date)
  local self = self
  local date = date
  local MonthPerYear = self.MonthPerYear

  if date.m == 0 then
    date.m = MonthPerYear
    date.y = date.y - 1

    self:fixYear(date, -1)

  elseif date.m == MonthPerYear + 1 then
    date.m = 1
    date.y = date.y + 1

    self:fixYear(date, 1)
  end

  return self:fixYearMonthDay(date)
end ---- fixYearMonth

-- Fix month day for day ±1.
-- Исправление дня месяца для дня ±1.
function TConfig:fixMonthDay (date) --> (date)
  local self = self
  local date = date

  --logShow(date, self:getMonthDays(date.y, date.m))

  if date.d == 0 then
    date.d = self.MonthDays.Max + 1 --> fixed in fixYearMonth
    date.m = date.m - 1

  elseif date.d == self:getMonthDays(date.y, date.m) + 1 then
    date.d = 1
    date.m = date.m + 1
  end

  return self:fixYearMonth(date)
end ---- fixMonthDay

---------------------------------------- ---- Time

---------------------------------------- ---- ---- get+div
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
end ---- getDaySec

---------------------------------------- ---- ---- Check
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

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
