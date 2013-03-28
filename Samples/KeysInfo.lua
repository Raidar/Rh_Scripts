--[[ Key info ]]--

----------------------------------------
--[[ description:
  -- Key information.
  -- Информация о клавише.
--]]
----------------------------------------
--[[ uses:
  LuaFAR, far2.dialog,
  -- group: Samples.
--]]
--------------------------------------------------------------------------------
--[[ Readme:
В окне выводится информация о нажатой клавише. Закрытие окна - по ESC !
--]]
--------------------------------------------------------------------------------

----------------------------------------
local bit = bit64
local band = bit.band
local bshr = bit.rshift
--local band, bor = bit.band, bit.bor
--local bnot, bxor = bit.bnot, bit.bxor
--local bshl, bshr = bit.lshift, bit.rshift

----------------------------------------
local far = far
local F = far.Flags

----------------------------------------
--local context = context
local logShow = context.ShowInfo

--local utils = require 'context.utils.useUtils'
local tables = require 'context.utils.useTables'
local numbers = require 'context.utils.useNumbers'

local tconcat, tfind = table.concat, tables.find

local hex = numbers.hex8

----------------------------------------
local fkeys = require "far2.keynames"

local keyUt = require "Rh_Scripts.Utils.Keys"

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Dialog
local dialog = require "far2.dialog"

local DI_DBox, DI_Text = F.DI_DOUBLEBOX, F.DI_TEXT
local DIF_Ampersand    = F.DIF_SHOWAMPERSAND
local DIF_HelpText     = F.DIF_SHOWAMPERSAND + F.DIF_CENTERGROUP

-- Форма окна диалога нажатия клавиши.
function unit.DlgForm ()
  local W, H = 48 - 4, 10 - 2 -- Width, Height
  local I, M = 3, bshr(W, 1) -- Indent, Width/2
  local Q = bshr(M, 1) -- Width/4
  local A, K = I + 1, I + 6
  local C = M + Q + 1
  --local B, C = M + 1, M + Q + 1

  local D = dialog.NewDialog() -- Форма окна:
             -- 1         2  3    4  5  6  7  8  9  10
             -- Type     X1 Y1   X2 Y2  L  H  M  F  Data
  D._      = {DI_DBox,    I, 1, W+2, H, 0, 0, 0, 0, "Key information"}
  D.Key    = {DI_Text,    A, 2,   M, 0, 0, 0, 0, 0, "Key :"}
  D.KCode  = {DI_Text,  K+1, 2, M-1, 0, 0, 0, 0, 0, "Key Code"}
  D.KName  = {DI_Text,    M, 2,   C, 0, 0, 0, 0, 0, "Key Name"}
  D.VKey   = {DI_Text,  C+1, 2,   W, 0, 0, 0, 0, 0, "VKey"}

  D.Ctrl   = {DI_Text,    A, 3,   M, 0, 0, 0, 0, 0, "Ctrl:"}
  D.CCode  = {DI_Text,  K+1, 3, M-1, 0, 0, 0, 0, 0, "CtrlState"}
  D.CName  = {DI_Text,    M, 3,   C, 0, 0, 0, 0, 0, "Ctrl Name"}
  D.KChar  = {DI_Text,  C+1, 3,   W, 0, 0, 0, 0, DIF_Ampersand, "Char"}

  D.Scan   = {DI_Text,    A, 4,   M, 0, 0, 0, 0, 0, "Scan:"}
  D.SCode  = {DI_Text,  K+1, 4, M-1, 0, 0, 0, 0, 0, "Scan Code"}
  D.SName  = {DI_Text,    M, 4,   C, 0, 0, 0, 0, 0, "Scan Name"}
  D.AlNum  = {DI_Text,  C+1, 4,   W, 0, 0, 0, 0, 0, "AlNum"}

  D.fKey   = {DI_Text,    A, 5,   M, 0, 0, 0, 0, 0, "far2:"}
  D.fCode  = {DI_Text,  K+1, 5, M-1, 0, 0, 0, 0, 0, "ToKeyName"}
  D.fName  = {DI_Text,    M, 5,   C, 0, 0, 0, 0, 0, "farKey Name"}

  -- Additional fields
  D.help   = {DI_Text,    0, H-1, 0, 0, 0, 0, 0, DIF_HelpText, "Press 'Escape' key to exit!"}
  --D.help   = {DI_Text,    0, H-1, 0, 0, 0, 0, 0, DIF_HelpText, "Press 'Enter' or 'Escape' key to exit!"}

  return D
end -- unit.DlgForm

----------------------------------------
local VKCS_Name = {
  RIGHT_ALT_PRESSED  = "RA",
  LEFT_ALT_PRESSED   = "LA",
  RIGHT_CTRL_PRESSED = "RC",
  LEFT_CTRL_PRESSED  = "LC",
  SHIFT_PRESSED = "Sh",
  NUMLOCK_ON    = "Num",
  SCROLLLOCK_ON = "Scr",
  CAPSLOCK_ON   = "Cap",
  ENHANCED_KEY  = "Enh",
} --- VKCS_Name

local VKeys   = keyUt.VKEY_Keys
local VState  = keyUt.VKEY_State
local VScans  = keyUt.VKEY_ScanCodes

local function VK_KeyToName (Key) --> (string)
  local Key = Key or 0
  if (Key >= 0x30 and Key <= 0x39) or
     (Key >= 0x41 and Key <= 0x5A) then
    return string.char(Key)
  end

  return tfind(VKeys, Key)
end -- VK_StateToName

local function VK_StateToName (State) --> (string)
  local State, t = State or 0, {}
  for k, v in pairs(VKCS_Name) do
    if band(State, VState[k]) ~= 0 then
      t[#t+1] = v
    end
  end

  return tconcat(t, "+")
end -- VK_StateToName

---------------------------------------- main
local SendMsg = far.SendDlgMessage

local function SendText (hDlg, Param1, Param2)
  return SendMsg(hDlg, F.DM_SETTEXT, Param1, Param2)
end --

local Guid = win.Uuid("f218e7ec-b782-4746-a188-952d6231afbb")

-- Показ нажатой клавиши в диалоге.
function unit.Dialog ()
  local D = unit.DlgForm()

  --logShow(D, "Dlg", "d2 n")

  -- Закрытие диалога.
  local function DlgClose (hDlg)
    SendMsg(hDlg, F.DM_CLOSE, -1, 0)
  end

  -- Обработчик событий диалога.
  local function DlgProc (hDlg, msg, param1, param2)
    if msg == F.DN_CONTROLINPUT then
      local Input = param2
      --logShow{ Input = Input }

      local EventType = Input.EventType
      if EventType ~= F.KEY_EVENT and
         EventType ~= F.FARMACRO_KEY_EVENT then
        return
      end

      local StrKey = far.InputRecordToName(Input) or ""
      --logShow{ StrKey = StrKey, Input = Input }

      -- Выход по ENTER / ESC:
      if StrKey == "Esc" then
      --if StrKey == "Enter" or StrKey == "Esc" then
        DlgClose(hDlg); return true
      end
      --logShow{ "FarKey", hex(FarKey) }

      -- USED KEY NAME
      local mCode = Input.VirtualKeyCode
      SendText(hDlg, D.KCode.id, hex(mCode))
      SendText(hDlg, D.KName.id, StrKey)
      SendText(hDlg, D.VKey.id, VK_KeyToName(mCode) or "")
      SendText(hDlg, D.fName.id, fkeys.InputRecordToName(Input))

      local mState = Input.ControlKeyState
      SendText(hDlg, D.CCode.id, hex(mState))
      SendText(hDlg, D.CName.id, VK_StateToName(mState) or "")
      local mChar = Input.UnicodeChar or ""
      if type(mChar) == 'number' then
        mChar = ("").char(mChar)
        --mChar = unicode.utf8.char(mChar)
      end
      SendText(hDlg, D.KChar.id, '"'..(mChar or "")..'"')

      local mScan = Input.VirtualScanCode
      SendText(hDlg, D.SCode.id, hex(mScan))
      local k = tfind(VScans, mScan)
      SendText(hDlg, D.SName.id, k and VK_KeyToName(k) or "")

      local asChar = "none"
      if mChar ~= "" then
        --logShow{ "mChar", tostring(mChar)}
        asChar = tostring(mChar:find("[%w_]") and "true" or "false")
      end
      SendText(hDlg, D.AlNum.id, asChar)

      return true
    --elseif msg == F.DN_DRAWDLGITEM then return false
    end
    --return false
  end -- DlgProc

  return far.Dialog(Guid, -1, -1, D._[4]+4, D._[5]+2, nil, D, 0, DlgProc)
end -- Dialog

--------------------------------------------------------------------------------
return unit.Dialog()
--------------------------------------------------------------------------------
