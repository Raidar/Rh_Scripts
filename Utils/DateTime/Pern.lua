--[[ DateTime: Pern ]]--

----------------------------------------
--[[ description:
  -- DateTime config for world: Pern.
  -- Конфигурация DateTime для мира: Перн.
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
local locale = require 'context.utils.useLocale'

--local divf = numbers.divf
local divm = numbers.divm

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Main data
unit.ScriptName = "Pern"
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
  World         = "Pern",          -- Мир
  Type          = "Type.Pernese",  -- Тип календаря

  PernMin       = 0,
  PernMax       = 9999,

  -- Turn == Year
  -- sevenday == week

  --YearPerAge    =  100,   -- Век:             1 Age       =  100 Years
  MonthPerYear  =   12,     -- Год:             1 Year      =   12 Months
  --DayPerWeek    =    7,   -- Неделя:          1 Week      =    7 Days
  --HourPerDay    =   24,   -- День:            1 Day       =   24 Hours
  --MinPerHour    =   60,   -- Час:             1 Hour      =   60 Minutes
  --SecPerMin     =   60,   -- Минута:          1 Minute    =   60 Seconds

  --MSecPerSec    = 1000,   -- Секунда:         1 Second    = 1000 Milliseconds

  --DSecPerSec    =   10,   -- Число дсек в сек:    1 Sec   =   10 dSecs
  --CSecPerSec    =  100,   -- Число ссек в сек:            =  100 cSecs
  --MSecPerDSec   =  100,   -- Число мсек в дсек:   1 dSec  =  1000 /  10 mSecs
  --MSecPerCSec   =   10,   -- Число мсек в ссек:   1 cSec  =  1000 / 100 mSecs

  --QuarterPerYear  =  4,   -- Квартальный год: 1 Year          = 4 Quarters
  --MonthPerQuarter =  3,   -- Квартал:         1 Quarter       = 12 / 4 Months

  BaseYear      =  362,     -- Обычный год:     1 Base Year     = 362 Days
  LeapYear      =  363,     -- Високосный год:  1 Leap Year     = 362 + 1 Days
  --MoonMonth     =   28,   -- Лунный месяц:    1 Moon Month    = 28 Days
  --MeanYear  =  362.1667,    -- Средний год:     1 Mean Year
  --MeanMonth = 30.180556,    -- Средний месяц:   1 Mean Month

                            -- Множители:               час  мин  сек  мсек
  --MinPerDay     =     1440, -- Число минут в день:       24 * 60
  --SecPerHour    =     3600, -- Число секунд в час:            60 * 60
  --SecPerDay     =    86400, -- Число секунд в день:      24 * 60 * 60
  --MSecPerMin    =    60000, -- Число миллисекунд в минуту:         60 * 1000
  --MSecPerHour   =  3600000, -- Число миллисекунд в час:       60 * 60 * 1000
  --MSecPerDay    = 86400000, -- Число миллисекунд в день: 24 * 60 * 60 * 1000

  -- TODO: Учёт отсчёта начала недели.
  --WeekStartDay     = 2, -- Первый день недели:         понедельник
  -- Учёт отсчёта недели года.
  YearStartWeekDay = 1, -- День первой недели года:    01.01 = first day
  --YearStartWeekDay = 4, -- День первой недели года:    04.01 = ISO 8601
  --YearStartWeekDay = 7, -- День первой недели года:    07.01 = Полная неделя!

  -- Rest week days.
  -- Выходные дни недели.
  RestWeekDays = {
    [0] = true,
  }, -- RestWeekDays

  -- Months' days count.
  -- Количество дней в месяцах.
  MonthDays = {
    30, 30, 30,
    30, 30, 30,
    30, 30, 30,
    30, 30, 32,
    [0] = 0,

    Min = 30,
    Max = 33,
    WeekMin = 5 + 1,
    WeekMax = 5 + 1,
  }, -- MonthDays 

  -- Year' days count by months.
  -- Количество дней в году по месяцам:
  YearDays = {
     30,  60,  90,
    120, 150, 180,
    210, 240, 270,
    300, 330, 362,
    [0] = 0,
  }, -- YearDays

  -- Numbers of week days for last days of previous months
  -- (provided that last day of previous year is Sunday).
  -- Номера дней недели для последних дней предыдущих месяцев
  -- (при условии, что последний день предыдущего года — воскресенье).
  --WeekDays = false,
  WeekDays = {
    0, 2, 4,
    6, 1, 3,
    5, 0, 2,
    4, 6, 1,
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
  
  LocData = L,

  --filled = nil,   -- Признак заполненности
} ---
unit.TConfig = TConfig

do
  local MConfig = { __index = TConfig }

unit.MConfig = MConfig

function unit.newConfig (Config) --|> Config
  local self = Config or {}
  self = setmetatable(self, MConfig)

  return self
end ---- newConfig

end -- do
---------------------------------------- ---- Date

---------------------------------------- ---- ---- Leap
-- Check an year for leap year.
-- Проверка на високосный год.
--[[ @params:
  y (number) - year.
---- @return:
  result (bool) - true if year is a leap year.
--]]
function TConfig:isLeapYear (y) --> (bool)
  return y % 6 == 0
end ----

---------------------------------------- ---- ---- Count
-- Count days in month.
-- Количество дней в месяце.
--[[ @params:
  y (number) - year.
  m (number) - month.
---- @return:
  result (number) - day count in month.
--]]
function TConfig:getMonthDays (y, m) --> (number)
  --local self = self

  if m ~= 12 then
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
  return self.WeekDays[m]
end ---- getWeekDays

---------------------------------------- ---- ---- get+div
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

  if r == 0 then
    return 12, self:getMonthDays(y, 12)
  end

  if r < 0 then r = -r end

  local YearDays = self.YearDays
  for m = 12 - 1, 0, -1 do
    if r > YearDays[m] then
      return m + 1, r - YearDays[m]
    end
  end

  return 12, self:getMonthDays(y, 12)
end ---- divYearDay

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

  local r, s = divm(y - 1, 6)   --   6⋅r + s

  --return (3 * r + 5 * s + self:getYearDay(y, m, d)) % self.DayPerWeek
  return (3 * r + 5 * s +
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

  local r, s = divm(y - 1, 6)   --   6⋅r + s
  --logShow({ r, s }, "getEraDay", "w d2")

  return 2173 * r + 362 * s +
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
  local self = self

  local e, i = e, 1
  if e <= 0 then
    e, i = -e, -1
  end
  --local E = e -- for log only

  if e <= 362 then
    if i > 0 then
      return 1, self:divYearDay(1, e)       -- После высадки
    else
      return 0, self:divYearDay(0, 363 - e) -- До высадки
    end
  end

  e = e - 362

  local r, s
  r, e = divm(e, 2173)
  s, e = divm(e,  362)

  local y = 6 * r + s

  y, e = y + 1, e + 362
  local yd = self:getYearDays(y)
  if e > yd then
    y, e = y + 1, e - yd
  end

  --[[
  logShow({ E, R, r, s, e,
            y, self:isLeapYear(y), },
            "divEraDay", "w d2")
  --]]

  if i > 0 then
    return y, self:divYearDay(y, e)
  else
    y = y - 1
    return -y, self:divYearDay(y, 363 - e)
  end
end ---- divEraDay

---------------------------------------- ---- ---- Check

---------------------------------------- ---- Time

---------------------------------------- ---- ---- get+div

---------------------------------------- ---- ---- Check

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
