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
local logShow = context.ShowInfo

local numbers = require 'context.utils.useNumbers'

local divf  = numbers.divf
local divm  = numbers.divm
local round = numbers.round

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Config class
local TConfig = {
  World         = "Terra",          -- Мир
  Type          = "Type.Gregorean", -- Тип календаря

  YearMin       = 1583,
  YearMax       = 9999,

  YearPerAge    =  100, -- Век:             1 Age       =  100 Years
  MonthPerYear  =   12, -- Год:             1 Year      =   12 Months
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
  MonthPerQuarter =  3, -- Квартал:         1 Quarter       = 12 / 4 Months

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

  -- TODO: Учёт отсчёта начала недели.
  --WeekStartDay     = 2, -- Первый день недели:         понедельник
  -- Учёт отсчёта недели года.
  --YearStartWeekDay = 1, -- День первой недели года:    01.01 = in US
  YearStartWeekDay = 4, -- День первой недели года:    04.01 = ISO 8601
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

  -- Year' days count by months.
  -- Количество дней в году по месяцам:
  YearDays = {
     31,  59,  90,
    120, 151, 181,
    212, 243, 273,
    304, 334, 365,
    [0] = 0,
  }, -- YearDays

  -- Numbers of week days for last days of previous months
  -- (provided that December 31 of previous year is Sunday).
  -- Номера дней недели для последних дней предыдущих месяцев
  -- (при условии, что 31 декабря предыущего года — воскресенье).
  WeekDays = {
    0, 3, 3,
    6, 1, 4,
    6, 2, 5,
    0, 3, 5,
  }, -- WeekDays

  -- Formats to output.
  -- Форматы для вывода.
  Formats = {
    World   = "%s",
    Type    = "%s",
    Year    = "%04d",

    Date    = "%04d-%02d-%02d",
    Time    = "%02d:%02d:%02d",
    DateLen = 10,
    TimeLen =  8,

    YearDay   = "%03d",
    YearWeek  = "%02d",
    MonthDay  = "%02d",
    MonthWeek = "%1d",
    WeekDay   = "<%1d>",
  }, -- Formats

  --filled = nil,   -- Признак заполненности
} ---
unit.DefConfig = TConfig

do
  local MConfig = { __index = TConfig }

function unit.newConfig (Config) --|> Config
  local self = Config or {}
  self = setmetatable(self, MConfig)

  if Config then
    return unit.fillConfig(self)
  end

  return self
end ---- newConfig

---------------------------------------- ---- Filling
-- Fill date constants.
-- Заполнение констант даты.
function unit.fillCfgDate (Config) --|> Config

  Config.MonthPerQuarter    = Config.MonthPerYear / Config.QuarterPerYear
  Config.LeapYear           = Config.BaseYear + 1
  Config.MeanMonth          = Config.MeanYear / Config.MonthPerYear

  return Config
end ---- fillCfgDate

-- Fill time constants.
-- Заполнение констант времени.
function unit.fillCfgTime (Config) --|> Config

  local HourPerDay  = Config.HourPerDay
  local MinPerHour  = Config.MinPerHour
  local SecPerMin   = Config.SecPerMin

  Config.MinPerDay      =        MinPerHour  * HourPerDay
  Config.SecPerHour     =        SecPerMin   * MinPerHour
  Config.SecPerDay      = Config.SecPerHour  * HourPerDay
  Config.MSecPerMin     = Config.MSecPerSec  * SecPerMin
  Config.MSecPerHour    = Config.MSecPerMin  * MinPerHour
  Config.MSecPerDay     = Config.MSecPerHour * HourPerDay

  return Config
end ---- fillCfgTime

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

  MonthDays.WeekMin = numbers.divc(Min, DayPerWeek) + 1
  MonthDays.WeekMax = numbers.divc(Max, DayPerWeek) + 1

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

-- Fill table constants.
-- Заполнение табличных констант.
function unit.fillCfgTables (Config) --|> Config

  if not Config.RestWeekDays then
    Config.RestWeekDays = {}
  end

  unit.fillMonthDaysData(Config.MonthDays)

  if not Config.YearDays then
    Config.YearDays = unit.findYearDays(Config.MonthDays)
  end

  if not Config.WeekDays then
    Config.WeekDays = unit.findWeekDays(Config.YearDays, Config.DayPerWeek)
  end

  if not Config.Formats then
    Config.Formats = {} -- TODO: Сделать генерацию форматов на основе констант.
  end

  return Config
end ---- fillCfgTables

-- Fill derived constants.
-- Заполнение производных констант.
function unit.fillConfig (Config) --|> Config
  if Config.filled then return end

  unit.fillCfgDate(Config)

  unit.fillCfgTime(Config)

  unit.fillCfgTables(Config)

  Config.filled = true

  return Config
end ---- FillConfig

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
  local self = self

  if m ~= 2 then
    return self.MonthDays[m]
  else
    return self.MonthDays[m] + self:getLeapDays(y)
  end
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
  local self = self

  if m <= 2 then
    return self.WeekDays[m]
  else
    return (self.WeekDays[m] + self:getLeapDays(y)) % self.DayPerWeek
  end
end ---- getWeekDays

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
  local self = self
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

  if r == 0 then
    local MonthPerYear = self.MonthPerYear
    return MonthPerYear, self.MonthDays[MonthPerYear]
  end

  if r < 0 then r = -r end

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
  f (number) - day for week start of year: 1..7,
               @default = YearStartWeekDay.
---- @return:
  result (number) - week of year.
--]]
function TConfig:getYearWeek (y, m, d, f) --> (number)
  local self = self
  
  local DayPerWeek = self.DayPerWeek
  local YearStartDay = self:getWeekDay(y, 1, 1)
  if YearStartDay == 0 then YearStartDay = DayPerWeek end
  local YearStartShift = DayPerWeek - (f or self.YearStartWeekDay) + 1

  return divf(self:getYearDay(y, m, d) - 1 +
              DayPerWeek + YearStartDay - 1 -
              (YearStartDay > YearStartShift and DayPerWeek or 0),
              DayPerWeek)
end ---- getYearWeek

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
  return (5 * (q + r) + s +
          self:getWeekDays(y, m) + d) % self.DayPerWeek
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
  --local P, R = divm(y - i, 100) -- 100⋅P + R
  local p, q = divm(P, 4)       --   4⋅p + q
  local r, s = divm(R, 4)       --   4⋅r + s
  --logShow({ P, R, p, q, r, s }, "getYearDay", "w d2")

  return 146097 * p + 36524 * q +
           1461 * r +   365 * s +
         self:getYearDay(y, m, d)
end ---- getEraDay

--local abs, sign = math.abs, numbers.sign

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

  if e <= 365 then
    if i > 0 then
      return 1, self:divYearDay(1, e)       -- н.э.
    else
      return 0, self:divYearDay(0, 366 - e) -- до н.э.
    end
  end

  e = e - 365

  local p, q
  p, e = divm(e, 146097)
  q, e = divm(e,  36524)
  local P = 4 * p + q

  local r, s
  r, e = divm(e,   1461)
  s, e = divm(e,    365)

  local R = 4 * r + s

  local y = 100 * P + R

  y, e = y + 1, e + 365
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
    return -y, self:divYearDay(y, 366 - e)
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
    local MonthDays = self.MonthDays[date.m]

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
    date.d = self.MonthDays.Max + 1
    date.m = date.m - 1

  elseif date.d == self:getMonthDays(date.y, date.m) + 1 then
    date.d = 1
    date.m = date.m + 1
  end

  return self:fixYearMonth(date)
end ---- fixMonthDay

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
  local MDate = { __index = TDate }

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

function TDate:getYearMonths () --> (number)
  --local self = self
  return self.config:getYearMonths(self.y)
end ----

function TDate:getMonthDays () --> (number)
  local self = self
  return self.config:getMonthDays(self.y, self.m)
end ----

function TDate:getYearWeeks () --> (bool)
  --local self = self
  return self.config:getYearWeeks(self.y)
end ----

function TDate:getYearDays () --> (bool)
  --local self = self
  return self.config:getYearDays(self.y)
end ----

function TDate:getYearDay () --> (bool)
  local self = self
  return self.config:getYearDay(self.y, self.m, self.d)
end ----

function TDate:setYearDay (r) --> (m, d)
  local self = self

  local m, d = self.config:divYearDay(self.y, r)
  self.m = m
  self.d = d

  return self
end ---- setYearDay

function TDate:getYearWeek () --> (number)
  local self = self
  return self.config:getYearWeek(self.y, self.m, self.d)
end ----

function TDate:getMonthWeek () --> (number)
  local self = self
  return self.config:getMonthWeek(self.y, self.m, self.d)
end ----

function TDate:getWeekDay () --> (number)
  local self = self
  return self.config:getWeekDay(self.y, self.m, self.d)
end ----

function TDate:getEraDay () --> (number)
  local self = self
  return self.config:getEraDay(self.y, self.m, self.d)
end ----

function TDate:setEraDay (r) --> (self)
  local self = self

  local y, m, d = self.config:divEraDay(r)
  self.y = y
  self.m = m
  self.d = d

  return self
end ---- setEraDay

function TDate:getEraMonth () --> (number)
  local self = self
  return self.config:getEraMonth(self.y, self.m)
end ----

function TDate:setEraMonth (r) --> (y, m)
  local self = self

  local y, m, d = self.config:divEraMonth(r)
  self.y = y
  self.m = m

  return self.config:fixYearMonthDay(self)
end ---- setEraMonth

function TDate:fixMonth () --> (self)
  local self = self
  local m = self.m
  if m < 0 then
    self.m = 1
  else
    local M = self:getYearMonths()
    if m > M then self.m = M end
  end

  return self
end ---- fixMonth

function TDate:fixDay () --> (self)
  local self = self
  local d = self.d
  if d < 0 then
    self.d = 1
  else
    local D = self:getMonthDays()
    if d > D then self.d = D end
  end

  return self
end ---- fixDay

function TDate:ymd () --> (number)
  return self:getEraDay()
end ----

-- Shift by specified day count.
-- Сдвиг на заданное число дней.
function TDate:shd (count) --> (self)
  local self = self

  local e = self:getEraDay()
  local f = e + count
  --[[
  if e > 0 and f < 0 then
    f = f + 1
  elseif e < 0 and f > 0 then
    f = f - 1
  end
  --]]

  return self:setEraDay(f)
end ---- shd

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
function TDate:inc_y () --> (self)
  local self = self

  self.y = self.y + 1
  self.config:fixYear(self, 1)

  return self.config:fixYearMonthDay(self)
end ---- inc_y

function TDate:dec_y () --> (self)
  local self = self

  self.y = self.y - 1
  self.config:fixYear(self, -1)

  return self.config:fixYearMonthDay(self)
end ---- dec_y

function TDate:inc_m () --> (self)
  local self = self

  self.m = self.m + 1

  return self.config:fixYearMonth(self)
end ---- inc_m

function TDate:dec_m () --> (self)
  local self = self

  self.m = self.m - 1

  return self.config:fixYearMonth(self)
end ---- dec_m

function TDate:inc_d () --> (self)
  local self = self

  self.d = self.d + 1

  return self.config:fixMonthDay(self)
end ---- inc_d

function TDate:dec_d () --> (self)
  local self = self

  self.d = self.d - 1

  return self.config:fixMonthDay(self)
end ---- dec_d

function TDate:inc_w () --> (self)
  return self:shd(self.config.DayPerWeek)
end ---- inc_w

function TDate:dec_w () --> (self)
  return self:shd(-self.config.DayPerWeek)
end ---- inc_w

---------------------------------------- Time class
local TTime = {} -- Класс времени

do
  local MTime = { __index = TTime }

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

-- Shift by specified second count.
-- Сдвиг на заданное число cекунд.
function TTime:shs (count) --> (self)
  local self = self

  local count = self:to_s() + count

  return self:from_s(count)
end ---- shs

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
