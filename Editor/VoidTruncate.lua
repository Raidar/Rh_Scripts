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
   © 2000, Дмитрий Суходоев aka raVen.
   Home: http://raven.elk.ru/
2. TruncateTXT.
   © 1999/2001, Алексей Фирсаков.
   Mail: avfir@mailru.com
---- based on:
*.  killSpaces.lua script
   (Удаление лишних пробелов и пустых строк.)
   © 2008, maxfl.
   Mail: gmaxfl@gmail.com
--]]
--------------------------------------------------------------------------------
local _G = _G

----------------------------------------
local bit = bit64
local band, bor = bit.band, bit.bor

----------------------------------------
local far = far
local F = far.Flags

local EditorGetInfo = editor.GetInfo
local EditorSetPos  = editor.SetPosition
local EditorGetStr  = editor.GetString
local EditorSetStr  = editor.SetString
local EditorDelStr  = editor.DeleteString
local EditorSelect  = editor.Select

----------------------------------------
--local context = context

----------------------------------------
-- [[
local rhlog = require "Rh_Scripts.Utils.Logging"
local logMsg = rhlog.Message
--]]

--------------------------------------------------------------------------------
local unit = {}

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
-- Усечение пробелов в заданной строке.
function Truncate.Spaces (n) --> (number)
  --n = n or -1
  local s, q = EditorGetStr(nil, n, 2)
  s, q = s:gsub(SpaceTruncPat, TruncSub)
  if q > 0 then EditorSetStr(nil, n, s) end
  return q
end ----
local TruncateSpaces = Truncate.Spaces

-- Update cursor position for line end.
-- Обновление позиции курсора для конца строки.
function Truncate.UpdateEnd ()
  local p = EditorGetInfo().CurPos
  local l = (EditorGetStr(nil, -1, 2) or ""):len()
  if p > l then p = l end
  EditorSetPos(nil, { CurPos = p })
end ----
local TruncateUpdateEnd = Truncate.UpdateEnd

-- Truncate spaces in current line.
-- Усечение пробелов в текущей строке.
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
function Truncate.File (keep) --> (number)
  local keep = keep or 1
  local Info = EditorGetInfo()
  local l = Info.TotalLines - 1
  EditorSetPos(nil, { CurLine = l })

  -- Проверка на пустоту строк:
  local q = 0
  for k = l, l - keep + 1, -1 do -- Учёт сохраняемых строк:
    local s = EditorGetStr(nil, k, 2)
    if s and not s:find(EmptyTruncPat) then
      EditorSetPos(nil, Info)
      return -q
    end
    q = q + 1
  end
  --logMsg({ l, keep, -q })

  -- Отсечение пустых строк:
  q = 0
  for k = l - keep, 0, -1 do
    local s = EditorGetStr(nil, k, 2)
    if s and s:find(EmptyTruncPat) then
      EditorDelStr()
      q = q + 1
    else break end
  end
  --logMsg({ l, keep, q })

  EditorSetPos(nil, Info)
  return q
end ----
local TruncateFile = Truncate.File

-- Truncate empty lines in file end and spaces in text lines.
-- Усечение пустых строк в конце файла и пробелов в строках текста.
function Truncate.FileText (keep)
  return TruncateFile(keep), TruncateText(),
         --TruncateUpdateEnd(), editor.Redraw()
         TruncateUpdateEnd(), far.AdvControl(F.ACTL_REDRAWALL)
end ----

---------------------------------------- Process
local STANDARD_KEY_EVENT = F.KEY_EVENT
local FARMACRO_KEY_EVENT = F.FARMACRO_KEY_EVENT

local keyUt = require "Rh_Scripts.Utils.keyUtils"

local VK_END = keyUt.VKEY_Keys.END
local CMods = keyUt.VKEY_Mods
--local Cmask = CMods.BaseMask
local ALT, CTRL, SHIFT = CMods.Alt, CMods.Ctrl, CMods.Shift
--logMsg({ ALT, CTRL, SHIFT }, "Cmod", nil, "#hv4")

--local EType, CState, Info
local BT_Stream, BT_Column = F.BTYPE_STREAM, F.BTYPE_COLUMN

function ProcessEditorInput (rec) --> (bool)
  --if rec.wVirtualKeyCode == 'END' then logMsg(rec, "rec", nil, "#hv4") end
  far.RepairInput(rec)
  --if rec.VirtualKeyCode == VK_END then logMsg(rec, "rec", nil, "#hv4") end

  local EType = rec.EventType
  if (EType == STANDARD_KEY_EVENT or EType == FARMACRO_KEY_EVENT) and
     rec.VirtualKeyCode == VK_END and rec.KeyDown then
    local CState = rec.ControlKeyState
    --CState = band(rec.ControlKeyState, Cmask)
    --logMsg(CState, CTRL, nil, "#hv4")
    --logMsg(rec, "rec", nil, "#hv4")

    if band(CState, CTRL) ~= 0 then -- End of file
      -- TODO: Make block operation!
      TruncateFile(1)
      local Info = EditorGetInfo()
      --logMsg({ CState, Cmod, Info }, "State", 2, "#hv4")
      EditorSetPos(nil, { CurLine = Info.TotalLines - 1 })
      TruncateLine()
      if band(CState, SHIFT) ~= 0 then -- Select
        EditorSelect(nil,
                     band(CState, ALT) ~= 0 and BT_Column or BT_Stream,
                     Info.CurLine, Info.CurPos,
                     (EditorGetStr(nil, -1, 2) or ""):len() - Info.CurPos,
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
--logMsg({ Param1, Param2, f }, "VT Params")

if type(Param1) == 'string' then
  local f = Truncate[Param1]
  if f then return f(Param2) else return unit end
else
  return unit
end
--------------------------------------------------------------------------------
