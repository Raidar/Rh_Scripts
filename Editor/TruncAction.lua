--[[ Truncater action ]]--

----------------------------------------
--[[ description:
  -- Void truncater action.
  -- Действие усекателя пустоты.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils.
  -- areas: editor.
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
local logShow = context.ShowInfo

----------------------------------------
local trunc = require "Rh_Scripts.Editor.VoidTruncate"

local TruncateLine = trunc.TruncateLine
local TruncateFile = trunc.TruncateFile

--------------------------------------------------------------------------------

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
end ---- ProcessEditorInput
--------------------------------------------------------------------------------
