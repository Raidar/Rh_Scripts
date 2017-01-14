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
--local unit.WorkerPath = utils.PluginWorkPath
unit.ScriptPath = "scripts\\Rh_Scripts\\Utils\\"

---------------------------------------- Naming
do --- Преобразование в читаемый формат

  local CharsData = unit.Data
  local CharsNames = CharsData and CharsData.Names or Null

-- Представление кодовой точки символа в виде строки.
local uCP2s = strings.ucp2s
unit.uCP = uCP2s

unit.CharCodeNameFmt = "U+%s — %s" -- utf-8 string

local function uCodeName (u) --< uCode --> Name

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

function unit.uCharCodeName (c) --< uChar --> Name

  return uCodeName(u_byte(c))

end ---- uCharCodeName

  local CharsBlocks = CharsData and CharsData.Blocks or Null

local function uCodeBlock (u) --< uCode --> (uBlock index, uBlock)

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
  end -- while

end ---- uCodeBlock
unit.uCodeBlock = uCodeBlock

unit.CharBlockNameFmt = "U+%s..U+%s — %s" -- utf-8 string

local function uBlockName (u) --< uCode --> Name

  local _, b = uCodeBlock(u)
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

function unit.uCharBlockName (c) --< uChar --> Name

  return uBlockName(u_byte(c))

end ---- uCharBlockName

--end -- do
---------------------------------------- Search
--do

  local NamesStart = unit.Data.NamesStart
  local NamesLimit = unit.Data.NamesLimit

function unit.uFindCode (pattern, base) --< (Name, uCode) --> (uCode)

  for k = base or NamesStart, NamesLimit do
  --for k = base or 0x0000, (base or 0x0000) + 3 do
    local c = CharsNames[k]
    if c then
      local s = c.name
      --logShow({ pattern, base, c }, s and s:lower():match(pattern))
      if s and s:lower():match(pattern) then
        return k

      end
    end
  end -- for

end ---- uFindCode

function unit.uCodeCount (pattern) --< (Name) --> (uCode Count)

  local Result = 0

  -- Fast algo
  for _, c in pairs(CharsNames) do
    local s = c.name
    --logShow({ pattern, base, c }, s and s:lower():match(pattern))
    if s and s:lower():match(pattern) then
      Result = Result + 1

    end
  end -- for

  --[[
  -- Slow algo
  for k = NamesStart, NamesLimit do
    local c = CharsNames[k]
    local s = c and c.name
    --logShow({ pattern, base, c }, s and s:lower():match(pattern))
    if s and s:lower():match(pattern) then
      Result = Result + 1

    end
  end -- for
  --]]

  return Result

end ---- uCodeCount

end -- do
---------------------------------------- main

--logShow(unit.Data.Names, "Char Names", "d1")

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
