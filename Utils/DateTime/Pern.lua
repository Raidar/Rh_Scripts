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
  World         = "Pern",
  Type          = "Type.Pernese",

  YearMin       = 0,
  YearMax       = 9999,

  -- Year = "Turn"
  -- week = "sevenday"

  --YearPerAge    =  100,   -- Век:             1 Age       =  100 Years
  MonthPerYear  =   12,     -- Год:             1 Year      =   12 Months
  --DayPerWeek    =    7,   -- Неделя:          1 Week      =    7 Days
  --OutPerWeek    =    2,     --                              +    0 Outweek days
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
  MeanYear  =  362.1667,    -- Средний год:     1 Mean Year
  MeanMonth = 30.180556,    -- Средний месяц:   1 Mean Month

                            -- Множители:               час  мин  сек  мсек
  --MinPerDay     =     1440, -- Число минут в день:       24 * 60
  --SecPerHour    =     3600, -- Число секунд в час:            60 * 60
  --SecPerDay     =    86400, -- Число секунд в день:      24 * 60 * 60
  --MSecPerMin    =    60000, -- Число миллисекунд в минуту:         60 * 1000
  --MSecPerHour   =  3600000, -- Число миллисекунд в час:       60 * 60 * 1000
  --MSecPerDay    = 86400000, -- Число миллисекунд в день: 24 * 60 * 60 * 1000

  --WeekStartDay     = 2, -- Первый день недели:         понедельник
  YearStartWeekDay = 1, -- День первой недели года:    01.01 = first day
  --YearStartWeekDay = 4, -- День первой недели года:    04.01 = ISO 8601
  --YearStartWeekDay = 7, -- День первой недели года:    07.01 = Полная неделя!

  RestWeekDays = {
    [0] = true,
  }, -- RestWeekDays

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

  YearDays = {
     30,  60,  90,
    120, 150, 180,
    210, 240, 270,
    300, 330, 362,
    [0] = 0,
  }, -- YearDays

  --WeekDays = false,
  WeekDays = {
    0, 2, 4,
    6, 1, 3,
    5, 0, 2,
    4, 6, 1,
  }, -- WeekDays

  WeekOuts = {
    --{ m = 12, d = 31 } = 8,
    --{ m = 12, d = 32 } = 9,
  }, -- WeekOuts

  Formats = {
    World   = "%s",
    Type    = "%s",
    Year    = "%04d",

    Date    = "%04d-%02d-%02d",
    Time    = "%02d:%02d:%02d",
    DateLen = 10,
    TimeLen =  8,

    YearDay   = "%03d",
    YearWeek  = " %02d",
    MonthDay  = "%02d",
    MonthWeek = "%1d",
    WeekDay   = "<%1d>",
    DayWeek   = "%02d",
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
  return y % 6 == 0
end ----

---------------------------------------- ---- ---- Count

function TConfig:getMonthDays (y, m) --> (number)
  --local self = self

  if m ~= 12 then
    return self.MonthDays[m]
  else
    return self.MonthDays[m] + self:getLeapDays(y)
  end
end ---- getMonthDays

function TConfig:getWeekMonthDays (y, m) --> (number)
  return self:getMonthDays(y, m)
end ---- getWeekMonthDays

---------------------------------------- ---- ---- get+div

function TConfig:getWeekDay (y, m, d) --> (number)
  local self = self

  local r, s = divm(y - 1, 6)   --   6⋅r + s

  --return (3 * r + 5 * s + self:getYearDay(y, m, d)) % self.DayPerWeek
  return (3 * r + 5 * s +
          self:getWeekDays(y, m) + d) % self.DayPerWeek
end ---- getWeekDay

function TConfig:getEraDay (y, m, d) --> (number)

  local r, s = divm(y - 1, 6)   --   6⋅r + s
  --logShow({ r, s }, "getEraDay", "w d2")

  return 2173 * r + 362 * s +
         self:getYearDay(y, m, d)
end ---- getEraDay

function TConfig:divEraDay (e) --> (y, m, d)
  local self = self

  local e, i = e, 1
  if e <= 0 then
    e, i = -e, -1
  end
  --local E = e -- for log only

  local BaseYear = self.BaseYear
  --logShow(e, BaseYear, "w d2")

  if e <= BaseYear then
    if i > 0 then
      return 1, self:divYearDay(1, e)                 -- После высадки
    else
      return 0, self:divYearDay(0, BaseYear + 1 - e)  -- До высадки
    end
  end

  e = e - BaseYear

  local r, s
  r, e = divm(e, 2173)
  s, e = divm(e,  362)

  local y = 6 * r + s

  y, e = y + 1, e + BaseYear
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
