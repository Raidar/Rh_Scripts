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
local tables = require 'context.utils.useTables'

local divf = numbers.divf

local Null = tables.Null

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
  local CharsNames = CharsData and CharsData.Names or Null

-- Представление кодовой точки символа в виде строки.
local uCP2s = strings.ucp2s
unit.uCP = uCP2s

unit.CharCodeNameFmt = "U+%s — %s" -- utf-8 string

local function uCodeName (u)
  local c = CharsNames[u]
  if not c then
    return unit.CharCodeNameFmt:format(uCP2s(u, true), "")
  end
  local s = c.fullname
  if not s then
    s = unit.CharCodeNameFmt:format(uCP2s(u, true), c.name or "")
    c.fullname = s
  end
  return s
end -- uCodeName
unit.uCodeName = uCodeName

  local u_byte = strings.u8byte

function unit.uCharCodeName (c)
  return uCodeName(u_byte(c))
end ---- uCharCodeName

  local CharsBlocks = CharsData and CharsData.Blocks or Null

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
      return m, b
    end
  end
end ---- uCharBlock
unit.uCharBlock = uCharBlock

unit.CharBlockNameFmt = "U+%s..U+%s — %s" -- utf-8 string

local function uBlockName (u)
  local _, b = uCharBlock(u)
  if not b then return end

  local s = b.fullname
  if not s then
    s = unit.CharBlockNameFmt:format(uCP2s(b.first, true),
                                     uCP2s(b.last, true),
                                     b.name or "")
    b.fullname = s
  end
  return s
end ---- uBlockName
unit.uBlockName = uBlockName

function unit.uCharBlockName (c)
  return uBlockName(u_byte(c))
end ---- uCharBlockName

end --
---------------------------------------- main

--logShow(unit.Data.Names, "Char Names", "d1")

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
