--[[ LuaUM ]]--

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

--local utils = require 'context.utils.useUtils'
local numbers = require 'context.utils.useNumbers'
--local tables = require 'context.utils.useTables'
local locale = require 'context.utils.useLocale'

local n2s = numbers.n2s

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Show
local debugs

local function doShow (...)

  debugs = debugs or require "context.utils.useDebugs"

  return debugs.Show(...)

end -- doShow

local function datShow (...)

  debugs = debugs or require "context.utils.useDebugs"

  return debugs.ShowData(...)

end -- datShow

---------------------------------------- Datim
local SubsDatim = require "Rh_Scripts.LuaUM.scripts.SubsDatim"
--local TplKit = SubsDatim.TplKit

local Datim = require "Rh_Scripts.Utils.DateTime"
local newTime = Datim.newTime

---------------------------------------- Main data
unit.ScriptName = "Subtitles"
--unit.WorkerPath = utils.PluginWorkPath
unit.ScriptPath = "scripts\\Rh_Scripts\\LuaUM\\scripts\\"

---------------------------------------- ---- Custom
local DefCustom = {

  name = unit.ScriptName,
  path = unit.ScriptPath,
  locale = { kind = 'load', },

} --- DefCustom

---------------------------------------- ---- Locale
local L, e1, e2 = locale.localize(DefCustom)
if L == nil then
  return locale.showError(e1, e2)

end

unit.Locale = L

---------------------------------------- Configure

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

  return doShow(data, L.cap_CurClauseData)

end ----

-- Показ данных по разнице как времени.
function unit.getClauseShowData (dif, mode) --> (table, table)

  dif = dif or 0
  local time = newTime():from_z(dif)

  mode = mode == nil and 4 or mode

  local show = {
    L.TimeLenAssaFmt:format(time.h, time.n, time.s, time:cz()),
    mode >= 1 and L.TimeLenDataFmt:format(time:data()) or nil,
    mode >= 2 and L.TimeLenMsecFmt:format(n2s(dif)) or nil,
    mode >= 2 and L.TimeLenTextFmt:format(time:data()) or nil,

  } ---

  local kind = {
    ShowLineNumber = false,
    --ChosenToClip   = true,

  } ---

  return show, kind

end ---- getClauseShowData

-- Показ начала отрезка времени на линии файла.
function unit.CurClauseStart (mode) --| (window)

  local tp = SubsDatim.getFileType()
  if not tp then return end

  local difStart = SubsDatim.getClauseStart(tp)

  local show = L.TimeLenDataFmt:format(difStart:data())

  local kind = {
    ShowLineNumber = false,
    --ChosenToClip   = true,

  } ---

  return datShow(show, L.cap_CurClauseStart, kind)

end ---- CurClauseStart

-- Показ длины отрезка времени на линии файла.
function unit.CurClauseLen (mode) --| (window)

  local tp = SubsDatim.getFileType()
  if not tp then return end

  local dif = SubsDatim.getClauseLen(tp)
  local show, kind = unit.getClauseShowData(dif, mode)

  return datShow(show, L.cap_CurClauseLen, kind)

end ---- CurClauseLen

-- Показ длины паузы перед отрезком времени на линии файла.
function unit.CurClauseGap (mode) --| (window)

  local tp = SubsDatim.getFileType()
  if not tp then return end

  local dif = SubsDatim.getClauseGap(tp)
  local show, kind = unit.getClauseShowData(dif, mode)

  return datShow(show, L.cap_CurClauseLen, kind)

end ---- CurClauseGap

--local unpack = unpack

function unit.ShowClauseAll (title, ...)

  --doShow({...}, title)

  local args = {...}
  local items = {}

  for a = 1, #args do
    local t = args[a]

    if type(t) == 'table' then
      for k = 1, #t do
        items[#items + 1] = { text = t[k], }

      end
    else
      items[#items + 1] = { text = t, separator = true, }

    end
  end -- for

  local props = {
    Title = title,
    Flags = 'FMENU_SHOWAMPERSAND',

  } ---

  debugs = debugs or require "context.utils.useDebugs"

  return far.Menu(props, items, debugs.BKeys)

end -- ShowClauseAll

-- Показ длины отрезка времени на линии файла и паузы перед ним.
function unit.CurClauseAll () --| (window)

  local tp = SubsDatim.getFileType()
  if not tp then return end

  local difStart    = SubsDatim.getClauseStart(tp)
  local difLen      = SubsDatim.getClauseLen(tp)
  local difGap      = SubsDatim.getClauseGap(tp)

  local showStart   = L.TimeLenDataFmt:format(difStart:data())
  local showLen     = unit.getClauseShowData(difLen, 1)
  local showGap     = unit.getClauseShowData(difGap, 1)

  return unit.ShowClauseAll(L.cap_CurClauseAll,
                            L.cap_CurClauseStart, showStart,
                            L.cap_CurClauseLen,   showLen,
                            L.cap_CurClauseGap,   showGap)

end ---- CurClauseAll

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
