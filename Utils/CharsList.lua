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

local tonumber = tonumber
local setmetatable = setmetatable

local io_open = io.open

----------------------------------------
--local context = context
local logShow = context.ShowInfo

local utils = require 'context.utils.useUtils'
local strings = require 'context.utils.useStrings'

--------------------------------------------------------------------------------
local unit = {}

----------------------------------------
local PluginPath = utils.PluginPath
local DataPath = "scripts\\Rh_Scripts\\data\\"
local DataName = "NamesList.txt"

----------------------------------------
local Names = {} -- Таблица-список названий
unit.Names = Names

-- Преобразование в читаемый формат
local lower = unicode.utf8.lower
local function _easy (head, tail) --> (string)
  return head..lower(tail)
end --

local function easy (s) --> (string)
  return s:gsub("(%w)(%w+)", _easy)
end -- easy

---------------------------------------- Naming
do
  local CharNames = unit.Names
  
-- Получение имени символа по её кодовой точке.
local function uCPname (c) --> (string)
  local c = CharNames[c]
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
---------------------------------------- __index
-- Make and return subtable for t[k].
local function subTable (t, k) --> (table)
  local u = {
    code = "0000",
    name = "",
  } ---
  t[k] = u
  return u
end
Names.__index = subTable; setmetatable(Names, Names)

---------------------------------------- main
do
  local FileName = string.format("%s%s%s", PluginPath, DataPath, DataName)

  local f = io_open(FileName, 'r')
  if f == nil then return unit end
  --[[
  local f, SError = io_open(FileName, 'r')
  if SError then logShow(SError, "NamesList.txt") end
  --]]

  -- Цикл по строкам файла:

  local last, data = 0, 0

  local s = "@"
  --local sn = 0
  repeat
    --logShow(s, "File line")
    -- Пропуск комментариев, доп. информации и старых названий:
    while s and (s:find("^%@") or
          s:find("^\t[^%=]") or
          s:find("^\t%= .+%(1%.0%)$")) do
      --logShow(s, "File unused line")
      s = f:read('*l')
      --sn = sn + 1
    end
    if s == nil then break end -- Конец файла
    --if sn > 40 then break end -- DEBUG only
    --logShow(s, "File used line")

    -- TODO: Check codepoint ranges!!
    -- Основное название:
    local code, name = s:match("^(%x%x%x%x)\t(.+)$")
    if code then
      --logShow(code, name)
      local cp = tonumber(code, 16)
      --if cp > 0x300 then break end -- DEBUG only
      --if cp > 0xFFFF then break end -- DEBUG only
      last, data = cp, Names[cp]
      data.code = code
      data.name = name:sub(1, 1) == '<' and name or easy(name)
    end

    --[[
    name = s:match("^\t%= (.+)")
    -- Альтернативное название:
    if name then
      data = Names[last]
      if not data.alias then data.alias = {} end
      data.alias[#data.alias+1] = name
    end --
    --]]

    s = f:read('*l')
    --sn = sn + 1
  until s == nil

  f:close()
end -- do

--logShow(Names, "Char Names", 2)

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
