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

----------------------------------------
local context, ctxdata = context, ctxdata

local datas = require 'context.utils.useDatas'

----------------------------------------
--local farUt = require "Rh_Scripts.Utils.FarUtils"

----------------------------------------
-- [[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------

---------------------------------------- Common
local format = string.format

-- Информация по таблице context.
function showInfo (Depth)
  logShow(context, "context", format("d%d %s", Depth, "_w"))
  logShow(ctxdata, "context data", format("d%d %s", Depth, "_w"))
end ----

-- Краткая информация по context.
function briefInfo ()
  showInfo(1)
end ----

-- Детальная информация context.
function detailedInfo ()
  showInfo(2)
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
  --logShow(context, "context", "d2 _")
  showFileList()
end ----
--]]

---------------------------------------- Types
local types = ctxdata.config.types
local abstypes = ctxdata.abstypes

local cfgpairs = datas.cfgpairs

function typesTable ()
  logShow(types, "context types", "d1 _w", { pairs = cfgpairs })
  if abstypes then
    logShow(abstypes, "abstract types", "d1 _w")
  end
end ----

local typeLineFmt = '%#10s - %s' -- m/b utf-8 string
local typeLineSep = ('─'):rep(10+3+30)
local typeLineCap = typeLineFmt:format('type', 'description')

-- Форматированный список типов.
local function typesList (types)
  if not types then return end

  local t, lvl = { typeLineCap }, -1

  for k, v, l in cfgpairs(types) do
    if l ~= lvl then
      lvl = l -- next:
      t[#t+1] = typeLineSep
    end
    if k ~= '_meta_' then -- value:
      t[#t+1] = format(typeLineFmt, k, v.desc or "")
    end
  end

  local meta = types._meta_
  if meta then -- meta:
    t[#t+1] = typeLineSep
    t[#t+1] = "_meta_ is:"
    t[#t+1] = format("basis = '%s',", meta.basis or 'none')
    t[#t+1] = format("merge = '%s'.", meta.merge or 'none')
  end
  t[#t+1] = typeLineSep

  return t
end -- typesList

-- Информация о типах.
function typesInfo ()
  local t = typesList(types)
  if t then logShow(t, "context types", "d1 w a1") end
  t = typesList(abstypes)
  if t then logShow(t, "abstract types", "d1 w a1") end
end ----

local detArea = context.detect.area
local curFileType = detArea.current

-- Тип текущего файла (detectType).
function detType ()
  local f = { matchcase = false, forceline = true }
  --local f = { matchcase = true }
  local info = { curFileType(f) }

  if #info > 0 then
    logShow(info, "detType", "d2 _")
  else
    logShow("No types for detect\n\n'LuaFAR context' pack is required\n", "detType")
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
