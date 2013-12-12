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
local numbers = require 'context.utils.useNumbers'
local strings = require 'context.utils.useStrings'

local divf = numbers.divf

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

unit.CharNameFmt = "U+%s — %s" -- utf-8 string

local function uCodeName (u)
  return unit.CharNameFmt:format(uCP2s(u, true), uCPname(u))
end -- uCodeName
unit.uCodeName = uCodeName

  local u_byte = strings.u8byte

function unit.uCharName (c)
  return uCodeName(u_byte(c))
end ---- uCharName

  local CharsBlocks = CharsData and CharsData.Blocks

local function uCharBlock (u)
  local Blocks = CharsBlocks

  local l, r = 1, #Blocks

  while l <= r do
    local m = divf(l + r, 2)
    local b = Blocks[m]

    if     u > b.last then
      l = m + 1
    elseif u < b.first then
      r = m - 1
    else
      return b
    end
  end
end ---- uCharBlock
unit.uCharBlock = uCharBlock

unit.CharBlockFmt = "U+%s..U+%s — %s" -- utf-8 string

local function uBlockName (u)
  local b = uCharBlock(u)
  if b then
    return unit.CharBlockFmt:format(uCP2s(b.first, true),
                                    uCP2s(b.last, true),
                                    b.name)
  end
end ---- uBlockName
unit.uBlockName = uBlockName

function unit.uCharBlockName (c)
  return uBlockName(u_byte(c))
end ---- uCharName

end --
---------------------------------------- main

--logShow(unit.Data.Names, "Char Names", "d1")

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
