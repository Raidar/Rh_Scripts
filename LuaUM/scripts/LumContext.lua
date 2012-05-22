--[[ LuaUM ]]--

----------------------------------------
--[[ description:
  -- LuaFAR context & LUM: Functions calls.
  -- LuaFAR context и LUM: Вызовы функций.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  [LUM].
  -- group: LF context.
--]]
--------------------------------------------------------------------------------
local _G = _G

local farUt = require "Rh_Scripts.Utils.farUtils"

----------------------------------------
local context, ctxdata = context, ctxdata

local datas = require 'context.utils.useDatas'

----------------------------------------
local rhlog = require "Rh_Scripts.Utils.Logging"
local logMsg = rhlog.Message
local linMsg = rhlog.lineMessage

--------------------------------------------------------------------------------

---------------------------------------- Common

-- Информация по таблице context.
function showInfo (Depth)
  linMsg(context, "context", Depth, "_")
  linMsg(ctxdata, "context data", Depth, "_")
end ----

-- Краткая информация по context.
function briefInfo ()
  showInfo(0)
end ----

-- Детальная информация context.
function detailedInfo ()
  showInfo(1)
end ----

-- [[
local showFileList

-- Список открытых файлов.
function OpenFilesList ()
  if not showFileList then
     if not context then return end
     if not context.manage then
       require 'context.scripts.manageData'
     end
     showFileList = context.manage.showFileList
  end
  --logMsg(context, "context", 2, "_")
  showFileList()
end ----
--]]

---------------------------------------- Types
local types = ctxdata.config.types
local abstypes = ctxdata.abstypes

local cfgpairs = datas.cfgpairs

function typesTable ()
  logMsg(types, "context types", 0, "_", { pairs = cfgpairs })
  if abstypes then
    logMsg(abstypes, "abstract types", 0, "_")
  end
end ----

local typeLineFmt = '%#10s - %s' -- m/b utf-8 string
local typeLineSep = ('-'):rep(10+3+30)
local typeLineCap = typeLineFmt:format('type', 'description')
local typeMrgMode = '_mode_ is: basis = "%s", merge = "%s".'

-- Форматированный список типов.
local function typesList (types)
  if not types then return end
  local t, lvl = { typeLineCap }, -1
  for k, v, l in cfgpairs(types) do
    if l ~= lvl then
      lvl = l
      t[#t+1] = typeLineSep
    end
    if k ~= '_mode_' then
      t[#t+1] = typeLineFmt:format(k, v.desc or "")
    end
  end -- for
  local mode = types._mode_
  if mode then
    t[#t+1] = typeLineSep
    t[#t+1] = typeMrgMode:format(mode.basis or 'none', mode.merge or 'none')
  end
  return t
end --function typesList

-- Информация о типах.
function typesInfo ()
  local t = typesList(types)
  if t then linMsg(t, "context types", 0, "#q") end
  t = typesList(abstypes)
  if t then linMsg(t, "abstract types", 0, "#q") end
end ----

local detArea = context.detect.area
local curFileType = detArea.current

-- Тип текущего файла (detectType).
function detType ()
  local f = { matchcase = false, forceline = true }
  --local f = { matchcase = true }
  local info = { curFileType(f) }

  if #info > 0 then
    linMsg(info, "detType", 2, "_#q")
  else
    logMsg("No types for detect\n\n'LuaFAR context' pack is required\n", "detType")
  end
end ---- detType

-- Тест detectType.
function testType ()
  local f = require "context.test.detType"
  if type(f) == 'table' then f = f.testTypesCfg end
  if type(f) == 'function' then
    return f({ "default" })
    --return f({ "default", "altered" })
  end
end ----

--------------------------------------------------------------------------------
