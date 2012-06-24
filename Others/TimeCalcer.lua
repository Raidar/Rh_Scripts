--[[ Time Calculator ]]--

----------------------------------------
--[[ description:
  -- Time values Calculator.
  -- Калькулятор значений времени.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils.
  -- group: Common.
  -- areas: any.
--]]
--------------------------------------------------------------------------------

local unpack = unpack
local setmetatable = setmetatable

local modf = math.modf
local floor = math.floor

local format = string.format

----------------------------------------
--local bit = bit64

----------------------------------------
--local far = far
--local F = far.Flags

----------------------------------------
--local context = context

----------------------------------------
local useTime = require "Rh_Scripts.Others.useTime"
local newTime = useTime.newTime

----------------------------------------
-- [[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- information
local TplsInfo = { -- Информация о шаблонах:
  sub_assa  = { start = 2, stop = 4 },
  sub_srt   = { start = 1, stop = 3 },
} ---

local LineTpls = { -- Шаблоны линий:
  sub_assa  = "^(.-%,)(.-)(%,)(.-)(%,.*)$", -- (нч,)(вр1)(,)(вр2)(,кц)
  sub_srt   = "^(.-)( %-%-%> )(.-)\s*$",    -- (вр1)( --> )(вр2)
} ---

local LineFmts = { -- Форматы линий:
  sub_assa  = "%s%s%s%s%s",
  sub_srt   = "%s%s%s",
} ---

local TimeTpls = { -- Шаблоны времени:
  sub_assa  = "(%d)%:(%d%d)%:(%d%d)%.(%d%d)",       --  ч:нн:сс.зз
  sub_srt   = "(%d%d)%:(%d%d)%:(%d%d)%,(%d%d%d)",   -- чч:нн:сс,ззз
} ---

local TimeFmts = { -- Форматы времени:
  sub_assa  = "%*d:%2d:%2d.%2d",
  sub_srt   = "%2d:%2d:%2d,%3d",
} ---

-- Функции разбора времени:
local ParseTime = {
  sub_assa  = function (s) --> (time)
    local h, n, s, cz = s:match(TimeTpls.sub_assa)
    return newTime(h, n, s, (cz or 0) * 10)
  end,
  sub_srt   = function (s) --> (time)
    return newTime(s:match(TimeTpls.sub_srt))
  end,
} --- ParseTime

-- Функции заполнения времени:
local StoreTime = {
  sub_assa  = function (time) --> (string)
    return format(TimeFmts.sub_assa, time.h, time.n, time.s, time:cz())
  end,
  sub_srt   = function (time) --> (string)
    return format(TimeFmts.sub_srt, time.h, time.n, time.s, time.z)
  end,
} --- StoreTime

---------------------------------------- parse & store
-- Разбор линии.
function unit.parseLine (s, tp) --> (data | nil)
  tp = tp or "sub_assa"

  -- Разбор линии на части.
  local t = { s:match(LineTpls[tp]) }
  if t[1] == nil then return end

  t.type = tp

  -- Разбор времён на части.
  local info = TplsInfo[tp]
  t.start = unit.parseTime(t[info.start], tp)
  t.stop  = unit.parseTime(t[info.stop], tp)

  return t
end ---- parseLine

-- Заполнение линии.
function unit.storeLine (data) --> (string)
  -- Заполнение времён.
  local tp = data.type
  local info = TplsInfo[tp]
  t[info.start] = unit.storeTime(t.start, tp)
  t[info.stop]  = unit.storeTime(t.stop, tp)

  -- Заполнение линии.
  local s = format(LineFmts[tp], unpack(t))

  return s
end ---- storeLine

-- Разбор времени.
function unit.parseTime (s, tp) --> (time | nil)
  return ParseTime[tp](s)
end ----

-- Заполнение времени.
function unit.storeTime (time, tp) --> (string)
  return StoreTime[tp](time)
end ----

---------------------------------------- make
local context, ctxdata = context, ctxdata
local configType = context.detect.use.configType

function unit.getType () --> (string)
  local ctype = ctxdata.editors.current.type -- current editor file type
  return configType(ctype, TplsInfo) -- existing config type for ctype
end ----

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
