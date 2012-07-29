--[[ LuaEUM ]]--

----------------------------------------
--[[ description:
  -- Edit of subtitles.
  -- Правка субтитров.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils.
  -- group: Subtitles, DateTime.
--]]
--------------------------------------------------------------------------------

----------------------------------------
--local context, ctxdata = context, ctxdata

local types = ctxdata.config.types

local utils = require 'context.utils.useUtils'
local numbers = require 'context.utils.useNumbers'
local tables = require 'context.utils.useTables'
local locale = require 'context.utils.useLocale'

local n2s = numbers.n2s

----------------------------------------
local dbg = require "context.utils.useDebugs"
local logShow, datShow = dbg.Show, dbg.ShowData

--------------------------------------------------------------------------------
local unit = {}

----------------------------------------
local SubsDatim = require "Rh_Scripts.LuaUM.scripts.SubsDatim"

local Datim = require "Rh_Scripts.Utils.DateTime"
local newTime = Datim.newTime

---------------------------------------- Configure
local ScriptName = "Subtitles"
local PluginPath = utils.PluginPath
local ScriptPath = "scripts\\Rh_Scripts\\LuaUM\\"

local addNewData = tables.extend

local DefCustom = {
  name = ScriptName,
  path = ScriptPath,

  locale = { kind = 'load' },
} ---

local L, e1, e2 = locale.localize(DefCustom)
if L == nil then
  return locale.showError(e1, e2)
end

unit.Locale = L

---------------------------------------- Show
-- Показ типа файла субтитров.
function unit.SubtitleType () --| (window)
  local SubType = SubsDatim.getFileType()
  local SubDesc = ""
  if SubType then SubDesc = types[SubType].desc or "" end
  if SubDesc ~= "" then SubDesc = "\n"..SubDesc end

  return far.Message((SubType or L.SubtitleUnknownType)..SubDesc,
                     L.cap_SubtitleType)
end ----

-- Показ данных по линии файла.
function unit.CurClauseData () --| (window)
  local tp = SubsDatim.getFileType()
  if not tp then return end

  local data = SubsDatim.getLineData(tp)

  return logShow(data, L.cap_CurClauseData)
end ----

-- Показ данных по разнице как времени.
function unit.getClauseShowData (diff) --> (table, table)
  local diff = diff or 0
  local time = newTime():from_z(diff)

  local show = {
    L.TimeLenAssaFmt:format(time.h, time.n, time.s, time:cz()),
    L.TimeLenDataFmt:format(time:data()),
    L.TimeLenMsecFmt:format(n2s(diff)),
    L.TimeLenTextFmt:format(time:data()),
  } ---
  local kind = {
    ShowLineNumber = false,
  }

  return show, kind 
end ---- getClauseShowData

-- Показ длины отрезка времени на линии файла.
function unit.CurClauseLen () --| (window)
  local tp = SubsDatim.getFileType()
  if not tp then return end

  local diff = SubsDatim.getClauseLen(tp)

  local show, kind = unit.getClauseShowData(diff)

  return datShow(show, L.cap_CurClauseLen, kind)
end ----

-- Показ длины паузы перед отрезком времени на линии файла.
function unit.CurClauseGap () --| (window)
  local tp = SubsDatim.getFileType()
  if not tp then return end

  local diff = SubsDatim.getClauseGap(tp)

  local show, kind = unit.getClauseShowData(diff)

  return datShow(show, L.cap_CurClauseLen, kind)
end ----

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
