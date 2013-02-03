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
local bit = bit64
local band = bit.band

----------------------------------------
local far = far
local F = far.Flags

local EditorGetInfo = editor.GetInfo
local EditorGetLine = editor.GetString
local EditorSetLine = editor.SetString
local EditorSetPos  = editor.SetPosition
local EditorDelLine = editor.DeleteString
local EditorSelect  = editor.Select

----------------------------------------
--local context = context

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

-- A table of functions for truncation.
-- Таблица для функций усечения.
local Truncate = {}
unit.Truncate = Truncate

local SpaceTruncPat, EmptyTruncPat, TruncSub = "%s+$", "^%s-$", ""

---------------------------------------- Config

---------------------------------------- Types

---------------------------------------- Configure

---------------------------------------- Locale

---------------------------------------- Dialog

---------------------------------------- Truncate
-- Truncate spaces in specified line.
-- Усечение пробелов в заданной линии.
function Truncate.Spaces (n) --> (number)
  --n = n or -1
  local s, q = EditorGetLine(nil, n, 2)
  s, q = s:gsub(SpaceTruncPat, TruncSub)
  if q > 0 then EditorSetLine(nil, n, s) end

  return q
end ----
local TruncateSpaces = Truncate.Spaces

-- Update cursor position for line end.
-- Обновление позиции курсора для конца линии.
function Truncate.UpdateEnd ()
  local Info = EditorGetInfo()
  local p = Info.CurPos
  local l = (EditorGetLine(nil, -1, 2) or ""):len()
  EditorSetPos(nil, -1, p > l and l or p)
end ----
local TruncateUpdateEnd = Truncate.UpdateEnd

-- Truncate spaces in current line.
-- Усечение пробелов в текущей линии.
function Truncate.Line () --> (number)
  local q = TruncateSpaces(-1)
  if q == 0 then return 0 end
  TruncateUpdateEnd()
  return q
end ----
local TruncateLine = Truncate.Line

-- Truncate spaces in all text lines.
-- Усечение пробелов во всех строках текста.
function Truncate.Text () --> (number)
  local Info, q = EditorGetInfo(), 0
  for k = Info.TotalLines - 1, 0, -1 do
    q = q + TruncateSpaces(k)
  end
  EditorSetPos(nil, Info)

  return q
end ----
local TruncateText = Truncate.Text

-- Truncate empty lines in end of file.
-- Усечение пустых строк в конце файла.
--[[
  -- @params:
  keep (number) - a number of empty lines to preserve.
--]]
function Truncate.File (keep) --> (number)
  local keep = keep or 1
  local Info = EditorGetInfo()
  local l = Info.TotalLines - 1
  EditorSetPos(nil, l)

  -- Проверка на пустоту линий:
  local q = 0
  for k = l, l - keep + 1, -1 do
    local s = EditorGetLine(nil, k, 2)
    if s and not s:find(EmptyTruncPat) then
      EditorSetPos(nil, Info)
      return -q
    end
    q = q + 1
  end
  --logShow({ l, keep, -q }, "TruncateFile")

  -- Отсечение пустых линий:
  q = 0
  for k = l - keep, 0, -1 do
    local s = EditorGetLine(nil, k, 2)
    if s and s:find(EmptyTruncPat) then
      EditorDelLine()
      q = q + 1
    else
      break
    end
  end
  --logShow({ l, keep, q }, "TruncateFile")

  EditorSetPos(nil, Info)
  return q
end ----
local TruncateFile = Truncate.File

-- Truncate empty lines in file end and spaces in text lines.
-- Усечение пустых линий в конце файла и пробелов в линиях текста.
--[[
  -- @params: @see Truncate.File.
--]]
function Truncate.FileText (keep)
  return TruncateFile(keep), TruncateText(),
         --TruncateUpdateEnd(), editor.Redraw()
         TruncateUpdateEnd(), far.AdvControl(F.ACTL_REDRAWALL)
end ----

---------------------------------------- Process
local STANDARD_KEY_EVENT = F.KEY_EVENT
local FARMACRO_KEY_EVENT = F.FARMACRO_KEY_EVENT

local keyUt = require "Rh_Scripts.Utils.Keys"

local VK_END = keyUt.VKEY_Keys.END
local CMods = keyUt.VKEY_Mods
--local Cmask = CMods.BaseMask
local ALT, CTRL, SHIFT = CMods.Alt, CMods.Ctrl, CMods.Shift
--logShow({ ALT, CTRL, SHIFT }, "Cmod", "#xv4")

--local EType, CState, Info
local BT_Stream, BT_Column = F.BTYPE_STREAM, F.BTYPE_COLUMN

function ProcessEditorInput (rec) --> (bool)
  --if rec.wVirtualKeyCode == 'END' then logShow(rec, "rec", "xv4") end
  far.RepairInput(rec)
  --if rec.VirtualKeyCode == VK_END then logShow(rec, "rec", "xv4") end

  local EType = rec.EventType
  if (EType == STANDARD_KEY_EVENT or EType == FARMACRO_KEY_EVENT) and
     rec.VirtualKeyCode == VK_END and rec.KeyDown then
    local CState = rec.ControlKeyState
    --CState = band(rec.ControlKeyState, Cmask)
    --logShow(CState, CTRL, "xv4")
    --logShow(rec, "rec", "xv4")

    if band(CState, CTRL) ~= 0 then -- End of file
      -- TODO: Make block operation!
      TruncateFile(1)
      local Info = EditorGetInfo()
      --logShow({ CState, Cmod, Info }, "State", "d2 xv4")
      EditorSetPos(nil, Info.TotalLines - 1)
      TruncateLine()
      if band(CState, SHIFT) ~= 0 then -- Select
        EditorSelect(nil,
                     band(CState, ALT) ~= 0 and BT_Column or BT_Stream,
                     Info.CurLine, Info.CurPos,
                     (EditorGetLine(nil, -1, 2) or ""):len() - Info.CurPos,
                     Info.TotalLines - Info.CurLine)
      end
    else -- End of line
      TruncateLine()
    end
  end -- if
  return false
end ----

---------------------------------------- main
local args = (...)
if type(args) ~= 'table' then return unit end

local Param1, Param2 = args[1], args[2]
--logShow({ Param1, Param2, f }, "VT Params")

if type(Param1) == 'string' then
  local f = Truncate[Param1]
  if f then return f(Param2) else return unit end
else
  return unit
end
--------------------------------------------------------------------------------
