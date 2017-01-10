--[[ FFI utils ]]--

----------------------------------------
--[[ description:
  -- Functions to work with FFI.
  -- Функции для работы с FFI.
--]]
----------------------------------------
--[[ uses:
  LuaFAR.
  -- group: Utils.
--]]
--------------------------------------------------------------------------------

--local type = type
--local pairs = pairs

--local format = string.format

----------------------------------------
--local bit = bit64
--local band, bor = bit.band, bit.bor
--local bshl, bshr = bit.lshift, bit.rshift

----------------------------------------
local ffi = require 'ffi'
local C = ffi.C

----------------------------------------
local win = win

----------------------------------------
--local context = context
local logShow = context.ShowInfo

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- WChar

-- Преобразование строки в WChar.
function unit.StringToWChar (s)

  s = win.Utf8ToUtf16(s)
  local result = ffi.new("wchar_t[?]", #s / 2 + 1)
  ffi.copy(result, s)

  return result

end -- StringToWChar

-- Преобразование WChar в строку.
function unit.WCharToString (s)

  return win.Utf16ToUtf8( ffi.string(s, 2 * C.lstrlenW(s)) )

end -- WCharToString

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
