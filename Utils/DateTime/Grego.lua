--[[ DateTime: Hekso ]]--

----------------------------------------
--[[ description:
  -- DateTime config for world: Earth [gregorean].
  -- Конфигурация DateTime для мира: Земля [григорианский].
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

local tables = require 'context.utils.useTables'
--local numbers = require 'context.utils.useNumbers'
local locale = require 'context.utils.useLocale'

--local divf  = numbers.divf
--local divm  = numbers.divm

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Main data
unit.FileName   = "Grego"
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
--logShow(TConfig, "TConfig", "wM")

TConfig.Type = "Type.Gregorean"

TConfig.Formats = {
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
} -- Formats

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

---------------------------------------- ---- Time

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
