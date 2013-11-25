--[[ Characters' list ]]--

----------------------------------------
--[[ description:
  -- Unicode characters' list.
  -- Список Unicode‑символов.
--]]
----------------------------------------
--[[ uses:
  LuaFAR.
  -- group: Utils.
--]]
--------------------------------------------------------------------------------

----------------------------------------
--local context = context
local logShow = context.ShowInfo

--local utils = require 'context.utils.useUtils'
local strings = require 'context.utils.useStrings'

--------------------------------------------------------------------------------
local unit = {}

unit.Data = require "Rh_Scripts.Utils.CharsData"

---------------------------------------- Main data
unit.ScriptName = "CharsList"
unit.ScriptPath = "scripts\\Rh_Scripts\\Utils\\"
--local PluginPath = utils.PluginPath

---------------------------------------- Naming
do --- Преобразование в читаемый формат

  local CharsData = unit.Data
  local CharsNames = CharsData and CharsData.Names

-- Получение имени символа по её кодовой точке.
local function uCPname (c) --> (string)
  local c = CharsNames and CharsNames[c]
  return c and c.name or ""
end -- uCPname
unit.uCPname = uCPname

-- Представление кодовой точки символа в виде строки.
local uCP2s = strings.ucp2s
unit.uCP = uCP2s

local CharNameFmt = "U+%s — %s" -- utf-8 string
unit.CharNameFmt = CharNameFmt

local function uCodeName (u)
  return CharNameFmt:format(uCP2s(u, true), uCPname(u))
end ---- uCodeName
unit.uCodeName = uCodeName

  local u_byte = strings.u8byte

function unit.uCharName (c)
  return uCodeName(u_byte(c))
end ---- uCharName

end --
---------------------------------------- main

--logShow(unit.Data.Names, "Char Names", "d1")

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
