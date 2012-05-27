--[[ Unicode char names ]]--

----------------------------------------
--[[ description:
  -- Unicode character names.
  -- Названия Unicode-символов.
--]]
----------------------------------------
--[[ uses:
  LuaFAR.
  -- group: Utils.
--]]
--------------------------------------------------------------------------------
local _G = _G

local tonumber = tonumber
local setmetatable = setmetatable

local io_open = io.open

----------------------------------------
local context = context

local utils = require 'context.utils.useUtils'

----------------------------------------
--local luaUt = require "Rh_Scripts.Utils.luaUtils"
local extUt = require "Rh_Scripts.Utils.extUtils"

local CapitCase = extUt.CapitCase

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

----------------------------------------
local Names = {} -- Таблица-список названий
unit.Names = Names

-- Make and return subtable for t[k].
local function subTable (t, k) --> (table)
  local u = {
    code = "0000",
    name = "",
  } ---
  t[k] = u
  return u
end
Names.__index = subTable
setmetatable(Names, Names)

----------------------------------------
local PluginPath = utils.PluginPath
local DataPath = "scripts\\Rh_Scripts\\Data\\"
local DataName = "NamesList.txt"

---------------------------------------- main
do
  local FileName = ("%s%s%s"):format(PluginPath, DataPath, DataName)
  local f, SError = io_open(FileName, 'r')
  --if SError then logShow(SError, "NamesList.txt") end
  if f == nil then return unit end

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
      data.name = name:sub(1, 1) == '<' and name or CapitCase(name)
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
