--[[ Date+Time types ]]--

----------------------------------------
--[[ description:
  -- Handling Date and Time.
  -- Обработка даты и времени.
--]]
----------------------------------------
--[[ uses:
  LF context utils.
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

--local divf  = numbers.divf
--local divm  = numbers.divm
local round = numbers.round

----------------------------------------
local cfgDefault = require "Rh_Scripts.Utils.DateTime.Default"

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Config

function unit.newConfig (Config) --|> Config
  --logShow (Config, "Config", "wA d3")

  local self = cfgDefault.newConfig(Config)

  if Config then
    return unit.fillConfig(self)

  end

  return self

end ---- newConfig

--end -- do
---------------------------------------- ---- Filling
do
-- Fill date constants.
-- Заполнение констант даты.
function unit.fillCfgDate (Config) --|> Config

  Config.MonthPerQuarter  = Config.MonthPerYear / Config.QuarterPerYear
  Config.LeapYear         = Config.BaseYear + 1
  Config.MeanMonth        = Config.MeanYear / Config.MonthPerYear

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

  local divc = numbers.divc

-- Fill month days with additional data.
-- Заполнение дней месяцев дополнительными данными.
function unit.fillMonthDaysData (MonthDays, DayPerWeek) --|> (MonthDays)

  local Min, Max = MonthDays[1], MonthDays[1]
  for k = 2, #MonthDays do
    local v = MonthDays[k]
    if v < Min then Min = v end
    if v > Max then Max = v end

  end

  MonthDays.Min = Min
  MonthDays.Max = Max

  MonthDays.WeekMin = divc(Min, DayPerWeek) + 1
  MonthDays.WeekMax = divc(Max, DayPerWeek) + 1

  return MonthDays

end ---- fillMonthDaysData

-- Find year days by months' days.
-- Нахождение дней в году по дням в месяцах.
function unit.findYearDays (MonthDays) --|> (YearDays)

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

  unit.fillMonthDaysData(Config.MonthDays, Config.DayPerWeek)

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

  if Config.filled then return Config end

  unit.fillCfgDate(Config)

  unit.fillCfgTime(Config)

  unit.fillCfgTables(Config)

  Config.filled = true

  return Config

end ---- FillConfig

end -- do
---------------------------------------- Date class
local TDate = {}

do
  local MDate = { __index = TDate }

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
---------------------------------------- ---- Basic

function TDate:data () --> (y, m, d, config)

  return self.y, self.m, self.d, self.config

end ----

function TDate:put (y, m, d) --| (y, m, d)

  self.y, self.m, self.d = y or self.y, m or self.m, d or self.d

end ----

function TDate:copy () --> (object)

  return unit.newDate(self:data())

end ----

function TDate:is (Date) --> (bool)

  return self.y == Date.y and self.m == Date.m and self.d == Date.d

end ----

---------------------------------------- ---- Zero

function TDate:isZeroYear () --> (boolean)

  return self.config:isZeroYear()

end ----

function TDate:getNegYear () --> (number)

  return self:isZeroYear() and self.y or
         (self.y > 0 and self.y or self.y - 1)
end ----

function TDate:putNegYear (y) --> ()

  self.y = self:isZeroYear() and y or (y > 0 and y or y + 1)

end ----

---------------------------------------- ---- Count

function TDate:getYearMonths () --> (number)

  return self.config:getYearMonths(self.y)

end ----

function TDate:getYearWeeks () --> (bool)

  return self.config:getYearWeeks(self.y)

end ----

function TDate:getYearDays () --> (bool)

  return self.config:getYearDays(self.y)

end ----

function TDate:getMonthWeeks () --> (number)

  return self.config:getMonthWeek(self.y, self.m, self:getMonthDays())

end ----

function TDate:getMonthDays () --> (number)

  return self.config:getMonthDays(self.y, self.m)

end ----

function TDate:getWeekDays () --> (number)

  return self.config:getWeekDays(self.y, self.m)

end ----

function TDate:getWeekMonthDays () --> (number)

  return self.config:getWeekMonthDays(self.y, self.m)

end ---- getWeekMonthDays

function TDate:getWeekMonthOuts () --> (number)

  return self.config:getWeekMonthOuts(self.y, self.m)

end ---- getWeekMonthOuts

---------------------------------------- ---- get+set

function TDate:getYearDay () --> (bool)

  return self.config:getYearDay(self.y, self.m, self.d)

end ----

function TDate:setYearDay (r) --> (m, d)

  local m, d = self.config:divYearDay(self.y, r)
  self.m = m
  self.d = d

  return self

end ---- setYearDay

function TDate:getYearWeek () --> (number)

  return self.config:getYearWeek(self.y, self.m, self.d)

end ----

function TDate:getMonthWeek () --> (number)

  return self.config:getMonthWeek(self.y, self.m, self.d)

end ----

function TDate:getWeekDay () --> (number)

  return self.config:getWeekDay(self.y, self.m, self.d)

end ----

function TDate:getWeekNumDay () --> (number)

  return self.config:getWeekNumDay(self.y, self.m, self.d)

end ----

function TDate:getMonthWeekDay (mw, wd) --> (number)

  return self.config:getMonthWeekDay(self.y, self.m, mw, wd)

end ----

function TDate:setMonthWeekDay (mw, wd) --> (number)

  self.d = self.config:getMonthWeekDay(self.y, self.m, mw, wd)

end ----

function TDate:getEraDay () --> (number)

  return self.config:getEraDay(self.y, self.m, self.d)

end ----

function TDate:setEraDay (r) --> (self)

  local y, m, d = self.config:divEraDay(r)
  self.y = y
  self.m = m
  self.d = d

  return self

end ---- setEraDay

function TDate:getEraMonth () --> (number)

  return self.config:getEraMonth(self.y, self.m)

end ----

function TDate:setEraMonth (r) --> (y, m)

  local y, m = self.config:divEraMonth(r)
  self.y = y
  self.m = m

  return self.config:fixYearMonthDay(self)

end ---- setEraMonth

---------------------------------------- ---- Check

function TDate:fixMonth () --> (self)

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

  local d = self.d
  if d < 0 then
    self.d = 1

  else
    local D = self:getMonthDays()
    if d > D then self.d = D end

  end

  return self

end ---- fixDay

---------------------------------------- ---- Short

function TDate:ymd () --> (number)

  return self:getEraDay()

end ----

-- Shift by specified day count.
-- Сдвиг на заданное число дней.
function TDate:shd (count) --> (self)

  return self:setEraDay(self:getEraDay() + count)

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

  local w, v = modf(v)
  self.y = w + 1
  v = v * self:getYearDays()

  self.m, v = self:divYearDay(v)
  self.d, v = modf(v)

  return self, v

end ----

function TDate:from_m (v) --> (self, rest)

  local w, v = modf(v)
  self.y, self.m = self:divEraMonth(w + 1)
  v = v * self:getMonthDays()

  self.d, v = modf(v)

  return self, v

end ----

function TDate:from_d (v) --> (self, rest)

  local w, v = modf(v)
  self.y, self.m, self.d = self:divEraDay(w)

  return self, v

end ----

---------------------------------------- ---- operations

function TDate:inc_y () --> (self)

  self.y = self.y + 1
  self.config:fixYear(self, 1)

  return self.config:fixYearMonthDay(self)

end ---- inc_y

function TDate:dec_y () --> (self)

  self.y = self.y - 1
  self.config:fixYear(self, -1)

  return self.config:fixYearMonthDay(self)

end ---- dec_y

function TDate:inc_m () --> (self)

  self.m = self.m + 1

  return self.config:fixYearMonth(self)

end ---- inc_m

function TDate:dec_m () --> (self)

  self.m = self.m - 1

  return self.config:fixYearMonth(self)

end ---- dec_m

function TDate:inc_d () --> (self)

  self.d = self.d + 1

  return self.config:fixMonthDay(self)

end ---- inc_d

function TDate:dec_d () --> (self)

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
local TTime = {}

do
  local MTime = { __index = TTime }

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
---------------------------------------- ---- Basic

function TTime:data () --> (h, n, s, z, config)

  return self.h, self.n, self.s, self.z, self.config

end ----

function TTime:put (h, n, s, z) --| (h, n, s, z)

  self.h, self.n = h or self.h, n or self.n
  self.s, self.z = s or self.s, z or self.z

end ----

function TTime:copy () --> (object)

  return unit.newTime(self:data())

end ----

function TTime:is (Time) --> (bool)

  return self.h == Time.h and self.n == Time.n and
         self.s == Time.s and self.z == Time.z
end ----

---------------------------------------- ---- get+set

function TTime:getDaySec () --> (number)

  return self.config:getDaySec(self.h, self.n, self.s)

end ----

---------------------------------------- ---- Short

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

  return round(self.z / self.config.MSecPerDSec)

end ----

-- Количество сотых долей секунды в миллисекундах.
function TTime:cz () --> (number)

  return round(self.z / self.config.MSecPerCSec)

end ----

-- Shift by specified second count.
-- Сдвиг на заданное число cекунд.
function TTime:shs (count) --> (self)

  local count = self:to_s() + count

  return self:from_s(count)

end ---- shs

---------------------------------------- ---- to & from

function TTime:to_h () --> (number)

  local c = self.config
  return ( (self.z / c.MSecPerSec +
            self.s) / c.SecPerMin +
           self.n ) / c.MinPerHour + self.h
end ----

function TTime:to_n () --> (number)

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

  local c = self.config
  return self.z +
         ( self.s +
           (self.n +
            self.h * c.MinPerHour
           ) * c.SecPerMin
         ) * c.MSecPerSec
end ----

function TTime:from_h (v) --> (self)

  local c, v = self.config, v

  self.h, v = modf(v)
  self.n, v = modf(v * c.MinPerHour)
  self.s, v = modf(v * c.SecPerMin)
  self.z = round(v * c.MSecPerSec)

  return self

end ---- from_h

function TTime:from_n (v) --> (self)

  local c = self.config

  local x = c.MinPerHour
  self.h = floor(v / x)
  v = v - self.h * x

  self.n, v = modf(v)
  self.s, v = modf(v * c.SecPerMin)
  self.z = round(v * c.MSecPerSec)

  return self

end ---- from_n

function TTime:from_s (v) --> (self)

  local c = self.config

  local x
  x = c.SecPerHour
  self.h = floor(v / x)
  v = v - self.h * x

  x = c.SecPerMin
  self.n = floor(v / x)
  v = v - self.n * x

  self.s, v = modf(v)
  self.z = round(v * c.MSecPerSec)

  return self

end ---- from_s

function TTime:from_z (v) --> (self)

  local c = self.config

  local x
  x = c.MSecPerHour
  self.h = floor(v / x)
  v = v - self.h * x

  x = c.MSecPerMin
  self.n = floor(v / x)
  v = v - self.n * x

  x = c.MSecPerSec
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

  return self:from_z(self:summ(time))

end ----

function TTime:sub (time) --> (self)

  return self:from_z(self:diff(time))

end ----

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
