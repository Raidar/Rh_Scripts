--[[ DateTime: Millo ]]--

----------------------------------------
--[[ description:
  -- DateTime config for world: Earth-Millenium.
  -- Конфигурация DateTime для мира: Земля-Тысячелетие.
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

local divf = numbers.divf
local divm = numbers.divm

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Main data
unit.ScriptName = "Millo"
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
  World         = "Millo",
  Type          = "Type.Millenium",

  YearMin       = -9998,
  YearMax       =  9999,

  YearPerAge    =  100,     -- Век:             1 Age       =  100 Years
  MonthPerYear  =   10,     -- Год:             1 Year      =   10 Months
  DayPerWeek    =   10,     -- Неделя:          1 Week      =   10 Days
  --OutPerWeek    =    0,     --                              +    0 Outweek days
  HourPerDay    =   12,     -- День:            1 Day       =   12 Hours
  MinPerHour    =   30,     -- Час:             1 Hour      =   30 Minutes
  SecPerMin     =   24,     -- Минута:          1 Minute    =   24 Seconds

  MSecPerSec    = 1000,     -- Секунда:         1 Second    = 1000 Milliseconds

  DSecPerSec    =   10,     -- Число дсек в сек:    1 Sec   =   10 dSecs
  CSecPerSec    =  100,     -- Число ссек в сек:            =  100 cSecs
  MSecPerDSec   =  100,     -- Число мсек в дсек:   1 dSec  =  1000 /  10 mSecs
  MSecPerCSec   =   10,     -- Число мсек в ссек:   1 cSec  =  1000 / 100 mSecs

  QuarterPerYear  =  5,     -- Квартальный год: 1 Year          = 5 Quarters
  MonthPerQuarter =  2,     -- Квартал:         1 Quarter       = 10 / 5 Months

  BaseYear      = 1000,     -- Обычный год:     1 Base Year     = 1000 Days
  LeapYear      = 1000,     -- Високосный год:  1 Leap Year     = 1000 + 0 Days
  MoonMonth     =  100,     -- Лунный месяц:    1 Moon Month    = 100 Days
  MeanYear      = 1000,     -- Средний год:     1 Mean Year
  MeanMonth     =  100,     -- Средний месяц:   1 Mean Month

                            -- Множители:               час  мин  сек  мсек
  MinPerDay     =      360, -- Число минут в день:       12 * 30
  SecPerHour    =      720, -- Число секунд в час:            30 * 24
  SecPerDay     =     8640, -- Число секунд в день:      12 * 30 * 24
  MSecPerMin    =    24000, -- Число миллисекунд в минуту:         24 * 1000
  MSecPerHour   =   720000, -- Число миллисекунд в час:       30 * 24 * 1000
  MSecPerDay    =  8640000, -- Число миллисекунд в день: 12 * 30 * 24 * 1000
  
  --WeekStartDay     = 2, -- Первый день недели:         понедельник
  YearStartWeekDay = 1, -- День первой недели года:    01.01 = in US
  --YearStartWeekDay = 4, -- День первой недели года:    04.01 = ISO 8601
  --YearStartWeekDay = 7, -- День первой недели года:    07.01 = Полная неделя!

  RestWeekDays = {
    [0] = true,
    [5] = true,
  }, -- RestWeekDays

  MonthDays = {
    100, 100, 100, 100, 100,
    100, 100, 100, 100, 100,
    [0] = 0,

    Min = 100,
    Max = 100,
    WeekMin = 10 + 1,
    WeekMax = 10 + 1,
  }, -- MonthDays

  YearDays = {
    100,  200,  300,  400,  500,
    600,  700,  800,  900, 1000,
    [0] = 0,
  }, -- YearDays

  WeekDays = {
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0,
  }, -- WeekDays

  WeekOuts = {
  }, -- WeekOuts

  Formats = {
    World   = "%s",
    Type    = "%s",
    Year    = "%04d",

    Date    = "%04d-%02d-%03d",
    Time    = "%03d:%02d:%02d",
    DateLen = 11,
    TimeLen =  9,

    YearDay   = "%04d",
    YearWeek  = " %03d",
    MonthDay  = "%03d",
    MonthWeek = "%02d",
    WeekDay   = "<%02d>",
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
  return false
end ----

---------------------------------------- ---- ---- Count

---------------------------------------- ---- ---- get+div

---------------------------------------- ---- ---- Check

---------------------------------------- ---- Time

---------------------------------------- ---- ---- get+div

---------------------------------------- ---- ---- Check

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
