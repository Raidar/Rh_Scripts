--[[ Void Truncater ]]--

----------------------------------------
--[[ description:
  -- Void Truncater.
  -- Усекатель пустоты.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils.
  -- areas: editor.
--]]
----------------------------------------
--[[ idea from:
1. Trucer plugin.
   (trail space truncater.)
   © 2000, Дмитрий Суходоев aka raVen.
2. TruncateTXT.
   © 1999/2001, Алексей Фирсаков.
   Mail: avfir@mailru.com
---- based on:
*. killSpaces.lua script
   (Удаление лишних пробелов и пустых строк.)
   © 2008, maxfl.
--]]
----------------------------------------
--[[ @notes:
   A truncation is:
   - deletion spaces at end of lines,
   - deletion empty / spaced lines at end of file.
   Усечение - это:
   - удаление пробелов в конце линий,
   - удаление пустых/пробельных линий в конце файла.
--]]
--------------------------------------------------------------------------------

----------------------------------------
local far = far
local F = far.Flags

local EditorGetInfo = editor.GetInfo
local EditorGetLine = editor.GetString
local EditorSetLine = editor.SetString
local EditorSetPos  = editor.SetPosition
local EditorDelLine = editor.DeleteString
--local EditorSelect  = editor.Select

----------------------------------------
--local context = context
local logShow = context.ShowInfo

--------------------------------------------------------------------------------
local unit = {}

local SpaceTruncPat, EmptyTruncPat, TruncSub = "%s+$", "^%s-$", ""

---------------------------------------- Config

---------------------------------------- Types

---------------------------------------- Configure

---------------------------------------- Locale

---------------------------------------- Dialog

---------------------------------------- Truncate
-- Truncate spaces in specified line.
-- Усечение пробелов в заданной линии.
function unit.TruncateSpaces (n) --> (number)
  --n = n or -1
  local s, q = EditorGetLine(nil, n, 3)
  s, q = s:gsub(SpaceTruncPat, TruncSub)
  --logShow(s, q, "w d2")
  if q > 0 then EditorSetLine(nil, n, s) end
  return q
end ---- TruncateSpaces
local TruncateSpaces = unit.TruncateSpaces

-- Update cursor position for line end.
-- Обновление позиции курсора для конца линии.
function unit.UpdateLineEnd ()
  local Info = EditorGetInfo()
  local p = Info.CurPos
  local l = (EditorGetLine(nil, 0, 3) or ""):len()
  EditorSetPos(nil, 0, p > l and l + 1 or p)
end ----
local UpdateLineEnd = unit.UpdateLineEnd

-- Truncate spaces in current line.
-- Усечение пробелов в текущей линии.
function unit.TruncateLine () --> (number)
  local q = TruncateSpaces(0)
  -- Commented as workaround for FAR3:
  if q == 0 then return 0 end
  UpdateLineEnd()
  return q
end ----
--local TruncateLine = unit.TruncateLine

-- Truncate spaces in all text lines.
-- Усечение пробелов во всех строках текста.
function unit.TruncateText () --> (number)
  local Info, q = EditorGetInfo(), 0
  for k = Info.TotalLines, 1, -1 do
    q = q + TruncateSpaces(k)
  end
  EditorSetPos(nil, Info)

  return q
end ----
local TruncateText = unit.TruncateText

-- Truncate empty lines in end of file.
-- Усечение пустых строк в конце файла.
--[[
  -- @params:
  keep (number) - a number of empty lines to preserve.
--]]
function unit.TruncateFile (keep) --> (number)
  local keep = keep or 1
  local Info = EditorGetInfo()
  local l = Info.TotalLines
  EditorSetPos(nil, l)

  -- Проверка на пустоту линий:
  local q = 0
  for k = l, l - keep + 1, -1 do
    local s = EditorGetLine(nil, k, 3)
    if s and not s:find(EmptyTruncPat) then
      --EditorSetPos(nil, Info)
      return -q
    end
    q = q + 1
  end
  --logShow({ l, keep, -q }, "TruncateFile")

  -- Отсечение пустых линий:
  q = 0
  for k = l - keep, 1, -1 do
    local s = EditorGetLine(nil, k, 2) -- С переходом к линии!
    if s and s:find(EmptyTruncPat) then
      EditorDelLine()
      q = q + 1
    else
      break
    end
  end
  --logShow({ l, keep, q }, "TruncateFile")

  --logShow(Info, "TruncateFile")

  if q > 0 then
    EditorSetPos(nil, Info)
  end

  return q
end ----
local TruncateFile = unit.TruncateFile

-- Truncate empty lines in file end and spaces in text lines.
-- Усечение пустых линий в конце файла и пробелов в линиях текста.
--[[
  -- @params: @see Truncate.File.
--]]
function unit.TruncateFileText (keep)
  TruncateFile(keep)
  TruncateText()
  UpdateLineEnd()

  return far.AdvControl(F.ACTL_REDRAWALL)
end ---- TruncateFileText

---------------------------------------- main
local args = (...)
if type(args) ~= 'table' then return unit end

local Param1, Param2 = args[1], args[2]
--logShow({ Param1, Param2, f }, "VT Params")

if type(Param1) == 'string' then
  local f = unit[Param1]
  if f then return f(Param2) else return unit end
else
  return unit
end
--------------------------------------------------------------------------------
