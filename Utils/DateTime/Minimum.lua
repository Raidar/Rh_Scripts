--[[ DateTime: Minimum ]]--

----------------------------------------
--[[ description:
  -- DateTime config for world: Earth [minimum].
  -- Конфигурация DateTime для мира: Земля [минимум].
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

local tables = require 'context.utils.useTables'
--local numbers = require 'context.utils.useNumbers'
local locale = require 'context.utils.useLocale'

--local divf  = numbers.divf
--local divm  = numbers.divm

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Main data
unit.FileName   = "Minimum"
unit.ScriptName = "Terra"
unit.ScriptPath = "scripts\\Rh_Scripts\\Utils\\DateTime\\"

---------------------------------------- ---- Custom
unit.DefCustom = {
  name = unit.ScriptName,
  path = unit.ScriptPath,

  label = unit.ScriptName,

  help   = { topic = unit.FileName, },
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
local cfgBase = require "Rh_Scripts.Utils.DateTime.Terra"
local TConfig = tables.clone(cfgBase.TConfig, true)

TConfig.Type = "Type.Minimum"

TConfig.OutPerWeek = 1

TConfig.WeekOuts = {
  { m =  2, d = 29, od = 1, },
  { m = 12, d = 31, od = 1, },
} -- WeekOuts

TConfig.LocData = L

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

---------------------------------------- ---- ---- Count

function TConfig:getWeekDays (y, m) --> (number)
  return self.WeekDays[m]
end ---- getWeekDays

function TConfig:getWeekMonthDays (y, m) --> (number)
  local self = self

  if m ~= self.MonthPerYear then
    return self.MonthDays[m]
  else
    return self.MonthDays[m] - 1
  end
end ---- getWeekMonthDays

function TConfig:getWeekMonthOuts (y, m) --> (number)
  local self = self

  if m == 2 then
    return self:getLeapDays(y)
  else
    return m ~= self.MonthPerYear and 0 or 1
  end
end ---- getWeekMonthOuts

---------------------------------------- ---- ---- get+div

-- TODO: Изменить для учёта постоянства! При этом установить OutWeek < 0 ?
function TConfig:getWeekDay (y, m, d) --> (number)
  --local self = self
  return (self:getWeekDays(y, m) + d) % self.DayPerWeek
end ---- getWeekDay

---------------------------------------- ---- ---- Check

---------------------------------------- ---- Time

---------------------------------------- ---- ---- get+div

---------------------------------------- ---- ---- Check

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
