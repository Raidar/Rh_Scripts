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

local TimeTpls = { -- Шаблоны времени:
  sub_assa  = "(%d)%:(%d%d)%:(%d%d)%.(%d%d)",       --  ч:нн:сс.зз
  sub_srt   = "(%d%d)%:(%d%d)%:(%d%d)%,(%d%d%d)",   -- чч:нн:сс,ззз
} ---

local TimeFmts = { -- Форматы времени:
  sub_assa  = "%*d:%2d:%2d.%2d",
  sub_srt   = "%2d:%2d:%2d,%3d",
} ---

local TimePats = { -- Шаблоны без захватов:
  sub_assa  = TimeTpls.sub_assa:gsub("[%(%)]", ""),
  sub_srt   = TimeTpls.sub_srt:gsub("[%(%)]", ""),
} ---

local LineTpls = { -- Шаблоны линий:
  --sub_assa  = "^(.-%,)(.-)(%,)(.-)(%,.*)$", -- (нч,)(вр1)(,)(вр2)(,кц)
  --sub_srt   = "^(.-)( %-%-%> )(.-)(%s.*)$", -- (вр1)( --> )(вр2)( кц)
  sub_assa  = format("^%s(%s)%s(%s)%s$",
                     "(.-%: %d%,)",
                     TimePats.sub_assa, --"(.-)",
                     "(%,)",
                     TimePats.sub_assa, --"(.-)",
                     "(%,.*)"),
  sub_srt   = format("^(%s)%s(%s)%s$",
                     TimePats.sub_srt, --"(.-)",
                     "( %-%-%> )",
                     TimePats.sub_srt, --"(.-)",
                     "(.*)"),
} ---

local LineFmts = { -- Форматы линий:
  sub_assa  = "%s%s%s%s%s",
  sub_srt   = "%s%s%s",
} ---

local tonumber = tonumber

-- Функции разбора времени:
local ParseTime = {
  sub_assa  = function (s) --> (time)
    local h, n, s, cz = s:match(TimeTpls.sub_assa)
    return newTime(tonumber(h), tonumber(n),
                   tonumber(s), (tonumber(cz) or 0) * 10)
  end,
  sub_srt   = function (s) --> (time)
    local h, n, s, z = s:match(TimeTpls.sub_srt)
    return newTime(tonumber(h), tonumber(n),
                   tonumber(s), tonumber(z))
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
-- Разбор времени.
function unit.parseTime (s, tp) --> (time | nil)
  return ParseTime[tp](s)
end ----

-- Заполнение времени.
function unit.storeTime (time, tp) --> (string)
  return StoreTime[tp](time)
end ----

-- Разбор линии.
function unit.parseLine (s, tp) --> (data | nil)
  tp = tp or "sub_assa"

  -- Разбор линии на части.
  local t = { s:match(LineTpls[tp]) }
  --logShow(t, tp)
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

---------------------------------------- make
local context, ctxdata = context, ctxdata
local configType = context.detect.use.configType

-- Получение поддерживаемого типа файла субтитров.
function unit.getFileType () --> (string)
  local ctype = ctxdata.editors.current.type -- current editor file type
  return configType(ctype, TplsInfo) -- existing config type for ctype
end ----

do
  local EditorGetStr = editor.GetString

-- Получение данных по линии файла (по умолчанию).
local function DefGetLineData (tp, line, shift) --> (data)
  local line = (line or 0) + (shift and 0 or -1)
  local shift = shift or 1
  local data
  repeat
    line = line + shift
    if line < 0 then break end

    local s = EditorGetStr(nil, line, 2)
    if s == nil then break end

    logShow({ line, shift, s })
    data = unit.parseLine(s, tp)
  until data

  if data then
    data.line = line

    return data
  end
end -- DefGetLineData

-- Функции получения данных по линии:
local GetLineData = {
  sub_assa  = function (line, shift) --> (data)
    return DefGetLineData("sub_assa", line, shift)
  end,

  sub_srt   = function (line, shift) --> (data)
    return DefGetLineData("sub_srt", line, shift)
  end,
} --- GetLineData

-- Получение данных по линии файла.
function unit.getLineData (tp, line, shift) --> (number)
  local Info = editor.GetInfo()
  if not Info then return end

  local data = GetLineData[tp](line or Info.CurLine, shift)

  editor.SetPosition(nil, Info) -- Restore cursor pos!

  return data
end ----

end -- do

-- Получение длины отрезка времени на линии файла.
function unit.getClauseLen (tp) --> (number | nil)
  local data = unit.getLineData(tp)
  if not data then return end

  return data.stop:diff(data.start)
end ----

-- Получение длины паузы перед отрезком времени на линии файла.
function unit.getClauseGap (tp) --> (number | nil)
  local curr = unit.getLineData(tp)
  if not curr then return end

  local prev = unit.getLineData(tp, curr.line, -1)
  if not prev or curr.line == prev.line then
    return curr.start:to_z()
  end

  return curr.start:diff(prev.stop)
end ----

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
