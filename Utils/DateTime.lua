--[[ Date+Time types ]]--

----------------------------------------
--[[ description:
  -- Date and Time classes.
  -- Классы даты и времени.
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

local modf = math.modf
local floor = math.floor

----------------------------------------
--local context = context

local numbers = require 'context.utils.useNumbers'

--local divf  = numbers.divf
local round = numbers.round

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Constants
local TConsts = {
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
  --LeapYear      =  366, -- Високосный год:  1 Leap Year     = 365 + 1 Days
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

  -- Количество дней в месяцах
  MonthDays = {
    31, 28, 31,
    30, 31, 30,
    31, 31, 30,
    31, 30, 31,
  }, --
  YearDays = {
     31,  59,  90,
    120, 151, 181,
    212, 243, 273,
    304, 334, 365,
  }, --

  --filled = nil,         -- Признак заполненности
} ---
unit.DefConsts = TConsts

function unit.getYearDays (MonthDays) --|> (YearDays)
  local YearDays, Sum = {}, 0
  local MonthDays = MonthDays
  for k = 1, #MonthDays do
     Sum = Sum + MonthDays[k]
     YearDays[k] = Sum
  end
  return YearDays
end ---- getYearDays

function unit.fillConsts (Consts) --|> Consts
  Consts.MonthPerQuarter    = Consts.MonthPerYear / Consts.QuarterPerYear
  Consts.LeapYear           = Consts.BaseYear + 1
  Consts.MeanMonth          = Consts.MeanYear / Consts.MonthPerYear

  local HourPerDay  = Consts.HourPerDay
  local MinPerHour  = Consts.MinPerHour
  local SecPerMin   = Consts.SecPerMin

  Consts.MinPerDay      =        MinPerHour  * HourPerDay
  Consts.SecPerHour     =        SecPerMin   * MinPerHour
  Consts.SecPerDay      = Consts.SecPerHour  * HourPerDay
  Consts.MSecPerMin     = Consts.MSecPerSec  * SecPerMin
  Consts.MSecPerHour    = Consts.MSecPerMin  * MinPerHour
  Consts.MSecPerDay     = Consts.MSecPerHour * HourPerDay

  if not Consts.YearDays then
    Consts.YearDays = unit.getYearDays(Consts.MonthDays)
  end

  Consts.filled = true

  return Consts
end ---- FillConsts

do
  local MConsts = { __index = TConsts, }

function unit.newConsts (Consts) --|> Consts
  local self = Consts or {}
  self = setmetatable(self, MConsts)

  if Consts then
    return unit.fillConsts(self)
  end

  return self
end ---- newConsts

end -- do
---------------------------------------- ---- operations
-- Check an year for leap year.
-- Проверка на високосный год.
function TConsts:isLeapYear (y) --> (bool)
  return y % 4 == 0 and (y % 100 ~= 0 or y % 400 == 0)
end ----

-- Count extra days of leap year.
-- Количество лишних дней високосного года.
function TConsts:getLeapDays (y) --> (bool)
  return self:isleapyear(y) and 1 or 0
end ----

-- Count days in month.
-- Количество дней в месяце.
function TConsts:getMonthDays (y, m) --> (number)
  if m ~= 2 then
    return self.MonthDays[m]
  else
    return self.MonthDays[m] + self:getLeapDays(y)
  end
end ---- getMonthDays

-- Get day number in year.
-- Получение номера дня в году.
function TConsts:getYearDay (y, m, d) --> (number)
  if m == 1 then
    return d
  elseif m == 2 then
    return d + self.YearDays[1]
  end

  return d + self.YearDays[m] + self:getLeapDays(y)
end ---- getYearDay

---------------------------------------- Date class
local TDate = {} -- Класс даты

do
  local MDate = { __index = TDate, }

-- Создание объекта класса.
function unit.newDate (y, m, d, c) --> (object)
  local self = {
    y = y or 0, -- Количество лет
    m = m or 0, -- Количество месяцев
    d = d or 0, -- Количество дней

    c = c or unit.newConsts();
  } --- self

  return setmetatable(self, MDate)
end -- newDate

end -- do
---------------------------------------- ---- handling
function TDate:data () --> (d, m, y, c)
  return self.y, self.m, self.d, self.c
end ----

function TDate:copy () --> (object)
  return unit.newDate(self:data())
end ----

---------------------------------------- ---- to & from
function TDate:to_y () --> (number)
  local c = self.c
  return 0 -- TODO
  --return ( (self.d / c.MSecPerSec +
  --          self.s) / c.SecPerMin +
  --         self.n ) / c.MinPerHour + self.h
end ----

function TDate:to_m () --> (number)
  return 0 -- TODO
end ----

function TDate:to_d () --> (number)
  return 0 -- TODO
end ----

function TDate:from_y (v) --> (self)
  -- TODO

  return self
end ----

function TDate:from_m (v) --> (self)
  -- TODO

  return self
end ----

function TDate:from_d (v) --> (self)
  -- TODO

  return self
end ----

---------------------------------------- ---- operations

---------------------------------------- Time class
local TTime = {} -- Класс времени

do
  local MTime = { __index = TTime, }

-- Создание объекта класса.
function unit.newTime (h, n, s, z, c) --> (object)
  local self = {
    h = h or 0, -- Количество часов
    n = n or 0, -- Количество минут
    s = s or 0, -- Количество секунд
    z = z or 0, -- Количество миллисекунд

    c = c or unit.newConsts();
  } --- self

  return setmetatable(self, MTime)
end -- newTime

end -- do
---------------------------------------- ---- handling
function TTime:data () --> (h, n, s, z, c)
  return self.h, self.n, self.s, self.z, self.c
end ----

function TTime:copy () --> (object)
  return unit.newTime(self:data())
end ----

-- Количество секунд без долей секунд.
function TTime:hns () --> (number)
  local c = self.c
  return self.s + (self.n + self.h * c.MinPerDay) * c.SecPerMin
end ----

-- Количество миллисекунд как доля секунды.
function TTime:msec () --> (number)
  return self.z / self.c.MSecPerSec
end ----

-- Количество десятых долей секунды в миллисекундах.
function TTime:dz () --> (number)
  return round(self.z / self.c.MSecPerDSec)
end ----

-- Количество сотых долей секунды в миллисекундах.
function TTime:cz () --> (number)
  return round(self.z / self.c.MSecPerCSec)
end ----

---------------------------------------- ---- to & from
function TTime:to_h () --> (number)
  local c = self.c
  return ( (self.z / c.MSecPerSec +
            self.s) / c.SecPerMin +
           self.n ) / c.MinPerHour + self.h
end ----

function TTime:to_n () --> (number)
  local c = self.c
  return (self.z / c.MSecPerSec +
          self.s) / c.SecPerMin +
          self.n +
          self.h * c.MinPerHour
end ----

function TTime:to_s () --> (number)
  local c = self.c
  return self.z / c.MSecPerSec +
         self.s +
         (self.n +
          self.h * c.MinPerHour
         ) * c.SecPerMin
end ----

function TTime:to_z () --> (number)
  local c = self.c
  return self.z +
         ( self.s +
           (self.n +
            self.h * c.MinPerHour
           ) * c.SecPerMin
         ) * c.MSecPerSec
end ----

function TTime:from_h (v) --> (self)
  local c = self.c

  self.h, v = modf(v)
  self.n, v = modf(v * c.MinPerHour)
  self.s, v = modf(v * c.SecPerMin)
  self.z = round(v * c.MSecPerSec)

  return self
end ---- from_h

function TTime:from_n (v) --> (self)
  local c = self.c

  local x = c.MinPerHour
  self.h = floor(v / x)
  v = v - self.h * x

  self.n, v = modf(v)
  self.s, v = modf(v * c.SecPerMin)
  self.z = round(v * c.MSecPerSec)

  return self
end ---- from_n

function TTime:from_s (v) --> (self)
  local c = self.c

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
  local c = self.c

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
function TTime:summ (time) --> (number)
  return self:to_z() + time:to_z()
end ----

function TTime:diff (time) --> (number)
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
