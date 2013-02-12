--[[ Keys utils ]]--

----------------------------------------
--[[ description:
  -- Processing keys.
  -- Обработка клавиш.
--]]
----------------------------------------
--[[ uses:
  [LuaFAR],
  Rh Utils.
  -- group: Keys.
--]]
--------------------------------------------------------------------------------

local tconcat = table.concat

----------------------------------------
local bit = bit64
local band = bit.band
--local band, bor = bit.band, bit.bor
--local bnot, bxor = bit.bnot, bit.bxor
--local bshl, bshr = bit.lshift, bit.rshift

----------------------------------------
--local context = context

--local utils = require 'context.utils.useUtils'
--local tables = require 'context.utils.useTables'

--local far23 = context.use.far23

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
local hex = dbg.hex8
--]]

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Mod names
-- Основные модификаторы
unit.SKEY_Base = { "CTRL", "ALT", "SHIFT" }
unit.SKEY_Text = { -- Используемые модификаторы
   C =  "Ctrl",  A =  "Alt",  S =  "Shift",
  LC = "LCtrl", LA = "LAlt", LS = "LShift",
  RC = "RCtrl", RA = "RAlt", RS = "RShift", }
unit.SKEY_Mods = { -- Обозначения модификаторов
   CTRL =  "C",  ALT =  "A",  SHIFT =  "S",
  LCTRL = "LC", LALT = "LA", LSHIFT = "LS",
  RCTRL = "RC", RALT = "RA", RSHIFT = "RS", }

---------------------------------------- VK_ mods
-- ControlKeyState.
local VKCS_ = {
  RIGHT_ALT_PRESSED  = 0x0001,
  LEFT_ALT_PRESSED   = 0x0002,
  RIGHT_CTRL_PRESSED = 0x0004,
  LEFT_CTRL_PRESSED  = 0x0008,
  SHIFT_PRESSED = 0x0010,
  NUMLOCK_ON    = 0x0020,
  SCROLLLOCK_ON = 0x0040,
  CAPSLOCK_ON   = 0x0080,
  ENHANCED_KEY  = 0x0100,
} --- VKCS_ / VKEY_State
unit.VKEY_State = VKCS_

-- ControlKeyState mods.
local VM_ = {
  LCtrl  = VKCS_.LEFT_CTRL_PRESSED,
  RCtrl  = VKCS_.RIGHT_CTRL_PRESSED,

  LAlt   = VKCS_.LEFT_ALT_PRESSED,
  RAlt   = VKCS_.RIGHT_ALT_PRESSED,

  Shift  = VKCS_.SHIFT_PRESSED,

  Ctrl   = VKCS_.LEFT_CTRL_PRESSED + VKCS_.RIGHT_CTRL_PRESSED,
  Alt    = VKCS_.LEFT_ALT_PRESSED  + VKCS_.RIGHT_ALT_PRESSED,

  LCtrlShift = VKCS_.LEFT_CTRL_PRESSED  + VKCS_.SHIFT_PRESSED,
  RCtrlShift = VKCS_.RIGHT_CTRL_PRESSED + VKCS_.SHIFT_PRESSED,

  LAltShift = VKCS_.LEFT_ALT_PRESSED  + VKCS_.SHIFT_PRESSED,
  RAltShift = VKCS_.RIGHT_ALT_PRESSED + VKCS_.SHIFT_PRESSED,

  LCtrlLAlt = VKCS_.LEFT_CTRL_PRESSED  + VKCS_.LEFT_ALT_PRESSED,
  RCtrlLAlt = VKCS_.RIGHT_CTRL_PRESSED + VKCS_.LEFT_ALT_PRESSED,

  LCtrlRAlt = VKCS_.LEFT_CTRL_PRESSED  + VKCS_.RIGHT_ALT_PRESSED,
  RCtrlRAlt = VKCS_.RIGHT_CTRL_PRESSED + VKCS_.RIGHT_ALT_PRESSED,

  CtrlAltShift = 0,

  --NumLock    = 0x0020,
  --ScrollLock = 0x0040,
  --CapsLock   = 0x0080,
  --Enhanced   = 0x0100,

  BaseMask = 0xFF, -- Маска базовой части
} -- VKC_ / VKEY_Mods
unit.VKEY_Mods = VM_

VM_.CtrlAltShift = VM_.Ctrl + VM_.Alt + VM_.Shift -- Any key pressed

---------------------------------------- VK_ keys
-- Коды VK_ клавиш по их названию.
local VK_ = {
  -- Mouse buttons
  LBUTTON   = 0x01,
  RBUTTON   = 0x02,
  CANCEL    = 0x03, -- Ctrl-Break
  MBUTTON   = 0x04,
  XBUTTON1  = 0x05,
  XBUTTON2  = 0x06,
  -- Some characters
  -- 0x07 -- Undefined
  BACK      = 0x08, -- BS
  TAB       = 0x09, -- Tab
  -- 0x0A - 0x0B -- Reserved
  CLEAR     = 0x0C,
  RETURN    = 0x0D, -- Enter
  -- 0x0E - 0x0F -- Undefined
  -- Modifiers
  SHIFT     = 0x10, -- Shift
  CONTROL   = 0x11, -- Ctrl
  MENU      = 0x12, -- Alt
  -- Other keys
  PAUSE     = 0x13,
  CAPITAL   = 0x14, -- Caps Lock
  -- IME keys
  KANA      = 0x15, HANGUL = 0x15, HANGUEL = 0x15,
  -- 0x16 -- Undefined
  JUNJA     = 0x17,
  FINAL     = 0x18,
  HANJA     = 0x19, KANJI  = 0x19,
  -- 0x1A -- Undefined
  ESCAPE    = 0x1B, -- Esc
  CONVERT   = 0x1C,
  NONCONVERT= 0x1D,
  ACCEPT    = 0x1E,
  MODECHANGE= 0x1F,
  SPACE     = 0x20,
  -- Arrow keys
  PRIOR     = 0x21, -- PgUp
  NEXT      = 0x22, -- PgDn
  END       = 0x23,
  HOME      = 0x24,
  LEFT      = 0x25,
  UP        = 0x26,
  RIGHT     = 0x27,
  DOWN      = 0x28,
  -- Other keys
  SELECT    = 0x29,
  PRINT     = 0x2A,
  EXECUTE   = 0x2B,
  SNAPSHOT  = 0x2C, -- Print Screen
  INSERT    = 0x2D, -- Ins
  DELETE    = 0x2E, -- Del
  HELP      = 0x2F,
  -- 0x30 - 0x39 -- Digits
  -- 0x3A - 0x40 -- Undefined
  -- 0x41 - 0x5A -- Letters
  -- Modifiers
  LWIN      = 0x5B,
  RWIN      = 0x5C,
  APPS      = 0x5D,
  -- 0x5E -- Reserved
  SLEEP     = 0x5F,
  -- Numpad keys
  NUMPAD0   = 0x60,
  NUMPAD1   = 0x61, NUMPAD2   = 0x62, NUMPAD3   = 0x63,
  NUMPAD4   = 0x64, NUMPAD5   = 0x65, NUMPAD6   = 0x66,
  NUMPAD7   = 0x67, NUMPAD8   = 0x68, NUMPAD9   = 0x69,
  MULTIPLY  = 0x6A, ADD       = 0x6B, SEPARATOR = 0x6C,
  SUBTRACT  = 0x6D, DECIMAL   = 0x6E, DIVIDE    = 0x6F,
  -- Function keys
  F1  = 0x70, F2  = 0x71, F3  = 0x72, F4  = 0x73,
  F5  = 0x74, F6  = 0x75, F7  = 0x76, F8  = 0x77,
  F9  = 0x78, F10 = 0x79, F11 = 0x7A, F12 = 0x7B,
  F13 = 0x7C, F14 = 0x7D, F15 = 0x7E, F16 = 0x7F,
  F17 = 0x80, F18 = 0x81, F19 = 0x82, F20 = 0x83,
  F21 = 0x84, F22 = 0x85, F23 = 0x86, F24 = 0x87,
  -- 0x88 - 0x8F -- Not used
  NUMLOCK   = 0x90,
  SCROLL    = 0x91,
  -- OEM keys
  OEM_NEC_EQUAL  = 0x92,
  OEM_FJ_MASSHOU = 0x93,
  OEM_FJ_TOUROKU = 0x94,
  OEM_FJ_LOYA    = 0x95,
  OEM_FJ_ROYA    = 0x96,
  -- 0x97 - 0x9F -- Not used
  -- Modifiers
  LSHIFT    = 0xA0,
  RSHIFT    = 0xA1,
  LCONTROL  = 0xA2,
  RCONTROL  = 0xA3,
  LMENU     = 0xA4,
  RMENU     = 0xA5,
  -- Multimedia
  BROWSER_BACK      = 0xA6,
  BROWSER_FORWARD   = 0xA7,
  BROWSER_REFRESH   = 0xA8,
  BROWSER_STOP      = 0xA9,
  BROWSER_SEARCH    = 0xAA,
  BROWSER_FAVORITES = 0xAB,
  BROWSER_HOME      = 0xAC,
  VOLUME_MUTE       = 0xAD,
  VOLUME_DOWN       = 0xAE,
  VOLUME_UP         = 0xAF,
  MEDIA_NEXT_TRACK  = 0xB0,
  MEDIA_PREV_TRACK  = 0xB1,
  MEDIA_STOP        = 0xB2,
  MEDIA_PLAY_PAUSE  = 0xB3,
  LAUNCH_MAIL       = 0xB4,
  LAUNCH_MEDIA_SELECT = 0xB5,
  LAUNCH_APP1       = 0xB6,
  LAUNCH_APP2       = 0xB7,
  -- 0xB8 - 0xB9 -- Reserved
  -- OEM standard keys
  OEM_1         = 0xBA, -- ";:"
  OEM_PLUS      = 0xBB, -- "=+"
  OEM_COMMA     = 0xBC, -- ",<"
  OEM_MINUS     = 0xBD, -- "-_"
  OEM_PERIOD    = 0xBE, -- ".>"
  OEM_2         = 0xBF, -- "/?"
  OEM_3         = 0xC0, -- "`~"
  -- 0xC1 - 0xD7 -- Reserved
  -- 0xD8 - 0xDA -- Not used
  OEM_4         = 0xDB, -- "[{"
  OEM_5         = 0xDC, -- "\\|"
  OEM_6         = 0xDD, -- "]}"
  OEM_7         = 0xDE, -- "'"'"'
  OEM_8         = 0xDF, -- Miscellaneous chars
  -- 0xE0 -- Reserved
  -- Other keys
  -- 0xE1 -- OEM specific
  OEM_102       = 0xE2, -- "<>" / "\\|"
  -- 0xE3 - 0xE4 -- OEM specific
  PROCESSKEY    = 0xE5,
  -- 0xE6 -- OEM specific
  PACKET        = 0xE7,
  -- 0xE8 -- Not used
  -- Only used by Nokia
  OEM_RESET     = 0xE9,
  OEM_JUMP      = 0xEA,
  OEM_PA1       = 0xEB,
  OEM_PA2       = 0xEC,
  OEM_PA3       = 0xED,
  OEM_WSCTRL    = 0xEE,
  OEM_CUSEL     = 0xEF,
  OEM_ATTN      = 0xF0,
  OEM_FINNISH   = 0xF1,
  OEM_COPY      = 0xF2,
  OEM_AUTO      = 0xF3,
  OEM_ENLW      = 0xF4,
  OEM_BACKTAB   = 0xF5,
  ATTN      = 0xF6,
  CRSEL     = 0xF7,
  EXSEL     = 0xF8,
  EREOF     = 0xF9,
  PLAY      = 0xFA,
  ZOOM      = 0xFB,
  NONAME    = 0xFC,
  PA1       = 0xFD,
  OEM_CLEAR = 0xFE,
  -- 0xFF -- Multimedia keys using ScanCode
} --- VK_ / VKEY_Keys
unit.VKEY_Keys = VK_

---------------------------------------- VK_ scan codes
unit.VKEY_ScanCodes = {
  -- Character keys
  [VK_.ESCAPE]      = 0x01, -- Esc / Escape

  [0x31] = 0x02, [0x32] = 0x03, [0x33] = 0x04, [0x34] = 0x05, [0x35] = 0x06, -- 1 2 3 4 5
  [0x36] = 0x07, [0x37] = 0x08, [0x38] = 0x09, [0x39] = 0x0A, [0x30] = 0x0B, -- 6 7 8 9 0

  [VK_.OEM_MINUS]   = 0x0C, -- -
  [VK_.OEM_PLUS]    = 0x0D, -- =
  [VK_.BACK]        = 0x0E, -- BS / BackSpace
  [VK_.TAB]         = 0x0F, -- Tab

  [0x51] = 0x10, [0x57] = 0x11, [0x45] = 0x12, [0x52] = 0x13, [0x54] = 0x14, -- q w e r t
  [0x59] = 0x15, [0x55] = 0x16, [0x49] = 0x17, [0x4F] = 0x18, [0x50] = 0x19, -- y u i o p

  [VK_.OEM_4]       = 0x1A,
  [VK_.OEM_6]       = 0x1B, -- p [ ]
  [VK_.RETURN]      = 0x1C, -- Enter / Return
  --[VK_.RETURN]      = 0x11C,-- Num Enter
  [VK_.CONTROL]     = 0x1D, -- Left Ctrl
  --[VK_.LCONTROL]    = 0x1D, -- Left Ctrl
  [VK_.RCONTROL]    = 0x11D,-- Right Ctrl

  [0x41] = 0x1E, [0x53] = 0x1F, [0x44] = 0x20, [0x46] = 0x21, [0x47] = 0x22, -- a s d f g
  [0x48] = 0x23, [0x4A] = 0x24, [0x4B] = 0x25, [0x4C] = 0x26,                -- h j k l

  [VK_.OEM_1]       = 0x27, -- ;
  [VK_.OEM_7]       = 0x28, -- '
  [VK_.OEM_3]       = 0x29, -- `
  [VK_.SHIFT]       = 0x2A, -- Left Shift
  --[VK_.LSHIFT]      = 0x2A, -- Left Shift
  [VK_.RSHIFT]      = 0x36, -- Right Shift
  [VK_.OEM_5]       = 0x2B, -- \

  [0x5A] = 0x2C, [0x58] = 0x2D, [0x43] = 0x2E, [0x56] = 0x2F, [0x42] = 0x30, -- z x c v b
  [0x4E] = 0x31, [0xDA] = 0x32,                                              -- n m

  [VK_.OEM_COMMA]   = 0x33, -- ,
  [VK_.OEM_PERIOD]  = 0x34, -- .
  [VK_.OEM_2]       = 0x35, -- /
  [VK_.SNAPSHOT]    = 0x37, -- Print Screen
  [VK_.MENU]        = 0x38, -- Alt
  [VK_.SPACE]       = 0x39, -- Space
  [VK_.CAPITAL]     = 0x3A, -- Caps Lock

  -- Function keys
  [VK_.F1]  = 0x3B, [VK_.F2]  = 0x3C, [VK_.F3]  = 0x3D, -- F1 F2 F3
  [VK_.F4]  = 0x3E, [VK_.F5]  = 0x3F, [VK_.F6]  = 0x40, -- F4 F5 F6
  [VK_.F7]  = 0x41, [VK_.F8]  = 0x42, [VK_.F9]  = 0x43, -- F7 F8 F9
  [VK_.F10] = 0x44, -- F10

  [VK_.PAUSE]       = 0x45, -- Pause
  [VK_.SCROLL]      = 0x46, -- Scroll Lock

  -- Numpad keys
  [VK_.NUMPAD7] = 0x47, -- 7
  [VK_.NUMPAD8] = 0x48, -- 8
  [VK_.NUMPAD9] = 0x49, -- 9
  [VK_.SUBTRACT]    = 0x4A, -- Num -
  [VK_.NUMPAD4] = 0x4B, -- 4
  [VK_.NUMPAD5] = 0x4C, -- 5
  [VK_.NUMPAD6] = 0x4D, -- 6
  [VK_.ADD]         = 0x4E, -- Num +
  [VK_.NUMPAD1] = 0x4F, -- 1
  [VK_.NUMPAD2] = 0x50, -- 2
  [VK_.NUMPAD3] = 0x51, -- 3

  [VK_.NUMPAD0] = 0x52, -- 0
  [VK_.DECIMAL] = 0x53, -- Dot
  -- 0x54 - 0x56

  [VK_.DIVIDE]      = 0x135, -- Num /
  [VK_.MULTIPLY]    = 0x137, -- Num *

  -- Function keys
  [VK_.F11] = 0x57, [VK_.F12] = 0x58, -- F11, F12

  -- 0x59 - 0x5A
  [VK_.LWIN]        = 0x5B, -- Left Win
  [VK_.RWIN]        = 0x5C, -- Right Win
  [VK_.APPS]        = 0x5D, -- Apps key
  ACPI_POWER        = 0x5E, -- ACPI Power
  ACPI_SLEEP        = 0x5F, -- ACPI Sleep
  -- 0x60 - 0x62
  ACPI_WAKE         = 0x63, -- ACPI Wake
  -- 0x64 - 0x6F
  DBE_KATAKANA      = 0x70, -- Katakana
  -- 0x71--0x76
  DBE_SBCSCHAR      = 0x77, -- SBCS char
  -- 0x78
  [VK_.CONVERT]     = 0x79,
  -- 0x7A
  [VK_.NONCONVERT]  = 0x7B,
  -- 0x7C - 0x7E

  -- Additional keys
  [VK_.NUMLOCK] = 0x145, -- Num Lock
  -- 0x146
  [VK_.HOME]    = 0x147, -- Home
  [VK_.UP]      = 0x148, -- Up
  [VK_.PRIOR]   = 0x149, -- PgUp
  -- 0x14A
  [VK_.LEFT]    = 0x14B, -- Left
  [VK_.CLEAR]   = 0x14C, -- Clear
  [VK_.RIGHT]   = 0x14D, -- Right
  -- 0x14E
  [VK_.END]     = 0x14F, -- End
  [VK_.DOWN]    = 0x150, -- Down
  [VK_.NEXT]    = 0x151, -- PgDn
  [VK_.INSERT]  = 0x152, -- Insert
  [VK_.DELETE]  = 0x153, -- Delete
} -- VKEY_ScanCodes

---------------------------------------- VKEY
-- Клавиши перемещения курсора.
unit.VKEY_ArrowNavs = {
  [VK_.LEFT]  = true,
  [VK_.UP]    = true,
  [VK_.RIGHT] = true,
  [VK_.DOWN]  = true,
  [VK_.HOME]  = true,
  [VK_.END]   = true,
  [VK_.PRIOR] = true,
  [VK_.NEXT]  = true,
  [VK_.CLEAR] = true,
} -- VKEY_ArrowNavs

-- Клавиши цифровой клавиатуры для перемещения курсора.
unit.VKEY_NumpadNavs = {
  [VK_.NUMPAD0] = VK_.INS,
  [VK_.NUMPAD1] = VK_.END,
  [VK_.NUMPAD2] = VK_.DOWN,
  [VK_.NUMPAD3] = VK_.NEXT,
  [VK_.NUMPAD4] = VK_.LEFT,
  [VK_.NUMPAD5] = VK_.CLEAR,
  [VK_.NUMPAD6] = VK_.RIGHT,
  [VK_.NUMPAD7] = VK_.HOME,
  [VK_.NUMPAD8] = VK_.UP,
  [VK_.NUMPAD9] = VK_.PRIOR,
} -- VKEY_NumpadNavs

---------------------------------------- SKEY
-- Клавиши перемещения курсора.
unit.SKEY_ArrowNavs = {
  Left  = true,
  Up    = true,
  Right = true,
  Down  = true,
  Home  = true,
  End   = true,
  PgUp  = true,
  PgDn  = true,
  Clear = true,
} -- SKEY_ArrowNavs

-- Клавиши цифровой клавиатуры для перемещения курсора.
unit.SKEY_NumpadNavs = {
  Num0 = "Ins",
  Num1 = "End",
  Num2 = "Down",
  Num3 = "PgDn",
  Num4 = "Left",
  Num5 = "Clear",
  Num6 = "Right",
  Num7 = "Home",
  Num8 = "Up",
  Num9 = "PgUp",
} -- SKEY_NumpadNavs

-- "Клавиши" прокрутки мышью для перемещения курсора.
unit.SKEY_MSWheelNavs = {
  MSWheelUp     = "Up",
  MSWheelDown   = "Down",
  MSWheelLeft   = "Left",
  MSWheelRight  = "Right",
  --MSWheelUp     = "PgUp",
  --MSWheelDown   = "PgDn",
} -- SKEY_MSWheelNavs

unit.SKEY_SymNames = {
  [' '] = "Space",
  --[[
  --['\127'] = ""
  [';'] = "Colon",
  ['/'] = "Slash",
  ['`'] = "`",
  ['['] = "Bracket",
  --]]
 --['\\'] = "BackSlash",
  --[[
  [']'] = "BackBracket",
  ["'"] = "Quote",
  ['-'] = "-",
  ['='] = "=",
  [','] = "Comma",
  ['.'] = "Dot",
  --]]
} -- SKEY_SymNames

-- Различие символов для клавиш с Shift.
do
  local SKEY_SymShifts = {
    ['!'] = '1', ['@'] = '2', ['#'] = '3', ['$'] = '4', ['%%'] = '5',
    ['^'] = '6', ['&'] = '7', ['*'] = '8', ['('] = '9', [')']  = '0',
    ['_'] = '-', ['+'] = '=', ['~'] = '`',
    ['{'] = '[', ['}'] = ']', ['|'] = '\\',
    [':'] = ';', ['"'] = "'",
    ['<'] = ',', ['>'] = '.', ['?'] = '/',
  } -- SKEY_SymShifts

  local SKEY_SymInvers = {}
  for k, v in pairs(SKEY_SymShifts) do
    SKEY_SymInvers[v] = k
  end

  unit.SKEY_SymShifts = SKEY_SymShifts
  unit.SKEY_SymInvers = SKEY_SymInvers
end -- do

---------------------------------------- Modifier
-- Проверка модификатора в наборе.
function unit.ismod (modset, mod) --> (bool)
  return band(modset, mod) ~= 0
end

do
-- "Чистая" проверка.

function unit.IsModCtrl (VMod) --> (bool)
  return VMod == VM_.LCtrl or VMod == VM_.RCtrl
end --

function unit.IsModAlt (VMod) --> (bool)
  return VMod == VM_.LAlt or VMod == VM_.RAlt
end --

function unit.IsModShift (VMod) --> (bool)
  return VMod == VM_.Shift
end --

function unit.IsModCtrlShift (VMod) --> (bool)
  return VMod == VM_.LCtrlShift or VMod == VM_.RCtrlShift
end --

function unit.IsModAltShift (VMod) --> (bool)
  return VMod == VM_.LAltShift or VMod == VM_.RAltShift
end --

-- "Смешанная" проверка.

  local ismod = unit.ismod

function unit.LikeModCtrl (VMod) --> (bool)
  return ismod(VMod, VM_.LCtrl) or ismod(VMod, VM_.RCtrl)
end --

function unit.LikeModAlt (VMod) --> (bool)
  return ismod(VMod, VM_.LAlt) or ismod(VMod, VM_.RAlt)
end --

function unit.LikeModShift (VMod) --> (bool)
  return ismod(VMod, VM_.Shift)
end --

end -- do
---------------------------------------- Checking
-- Проверка значения v в [a; b].
local function inseg (v, a, b) --> (bool)
  return v >= a and v <= b
end

-- Проверка VK_ на цифру.
function unit.isKeyDigit (key) --> (bool)
  return inseg(key, 0x30, 0x39)
end

-- Проверка VK_ на латинскую букву.
function unit.isVKeyLat (key) --> (bool)
  return inseg(key, 0x41, 0x5A)
end

-- Проверка VK_ на "символьность".
function unit.isVKeyChar (key) --> (bool)
  return key == 0x20 or
         inseg(key, 0x30, 0x39) or
         inseg(key, 0x41, 0x5A) or
         inseg(key, 0xBA, 0xC0) or
         inseg(key, 0xDB, 0xDF) or
         key == 0xE2
end ----

-- Проверка VK_ на "расширенность".
function unit.isVKeyExt (key) --> (bool)
  return inseg(key, 0x10, 0x2F) or
         inseg(key, 0x5B, 0x87) or
         inseg(key, 0xA0, 0xA5) or
         inseg(key, 0xA6, 0xB7)
end ----

function unit.GetModBase (VMod) --> (bool)
  return band(VMod, VM_.CtrlAltShift)
end ----

---------------------------------------- VirKey <--> Char
unit.VirKeyToChar = string.char
unit.CharToVirKey = string.byte

---------------------------------------- StrKey <--> Name
do
  local farMatch = regex.match

-- Разбор имени клавиши на модификаторы и собственно имя.
function unit.ParseKeyName (KeyName) --> (mod, key)
  return farMatch(KeyName, "((?:R?Ctrl)?(?:R?Alt)?(?:Shift)?)(.*)", 1)
end --

function unit.ParseFullName (KeyName) --> (mod, c, a, s, key)
  return farMatch(KeyName, "((R?Ctrl)?(R?Alt)?(Shift)?)(.*)", 1)
end --

function unit.ParseStrKey (StrKey, KeySep) --> (mod, c, a, s, key)
  return farMatch(StrKey, "((R?C)?(R?A)?(S)?)\\"..(KeySep or '+').."(.*)", 1)
end --

end -- do

do
  local ParseStrKey = unit.ParseStrKey

-- Полное название комбо из краткого названия.
--[[ 
  -- @params:
  StrKey  -- строка с кратким названием клавиши.
  KeySep  -- разделитель модификаторов и самой клавиши.
--]]
function unit.SKeyToName (StrKey, KeySep) --> (string)
  local mod, c, a, s, key = ParseStrKey(StrKey, KeySep or '+')
  --logShow({ mod, c, a, s, key }, StrKey)
  if not mod or mod == "" then return key or StrKey end

  local t = {
    "", -- c
    "", -- a
    "", -- s
    key or "",
  } ---

  if c and c ~= "" then t[1] = c == "RC" and "RCtrl" or "Ctrl" end
  if a and a ~= "" then t[2] = a == "RA" and "RAlt"  or "Alt"  end
  if s and s ~= "" then t[3] = "Shift" end

  return tconcat(t)
end ---- SKeyToName

  local ParseFullName = unit.ParseFullName

-- Краткое название комбо из полного названия.
--[[
  -- @params:
  KeyName -- строка с полным названием клавиши.
  KeySep  -- разделитель модификаторов и самой клавиши.
--]]
function unit.NameToSKey (KeyName, KeySep) --> (string)
  local mod, c, a, s, key = ParseFullName(KeyName)
  if not mod or mod == "" then return key or KeyName end

  local t = {
    "", -- c
    "", -- a
    "", -- s
    KeySep or '+',
    key or "",
  } ---

  if c and c ~= "" then t[1] = c == "RCtrl" and "RC" or "C" end
  if a and a ~= "" then t[2] = a == "RAlt"  and "RA" or "A" end
  if s and s ~= "" then t[3] = "S" end

  return tconcat(t)
end ---- NameToSKey

end -- do

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
