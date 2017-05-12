--[[ Characters' data ]]--

----------------------------------------
--[[ description:
  -- Parsing Unicode characters' Data.
  -- Разбор данных по Unicode‑символам.
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
--local strings = require 'context.utils.useStrings'

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Main data
unit.ScriptName = "CharsList"
unit.ScriptPath = "scripts\\Rh_Scripts\\Utils\\"

---------------------------------------- ---- Config

unit.DefCfgData = { -- Конфигурация по умолчанию:

  PluginWorkPath    = utils.PluginWorkPath,
  PluginDataPath    = utils.PluginDataPath,
  FilePath          = "scripts\\Rh_Scripts\\data\\",
  NamesFile         = "NamesList.txt",
  BlocksFile        = "Blocks.txt",

  DataFile          = "CharsData.lua",
  DataPath          = "Rh_Scripts.data.CharsData",

} -- DefCfgData

---------------------------------------- Main class

---------------------------------------- Naming
do --- Преобразование в читаемый формат

  local lower = unicode.utf8.lower
  local function _EasyName (head, tail) --> (string)

    return head..lower(tail)

  end --

  local supper = string.upper

function unit.EasyName (s, cp) --> (string)

  return s:gsub("(%w)(%w+)", _EasyName):
           gsub("([%dA-F][%da-f][%da-f][%da-f])",
                function (s)

                  if supper(s) == cp then return cp end

                end)

end -- EasyName

end --
---------------------------------------- Parse
-- Load and parse NamesList.txt.
-- Загрузка и разбор NamesList.txt.
--[[
  -- @params:
  FileName (string) - name of loaded text file.
  -- @return:
  (bool|nil) - result of data parsing.
--]]
function unit:ParseNames (FileName) --> (bool | nil)

  local f = io_open(FileName, 'r')
  if f == nil then return end
  --[[
  local f, SError = io_open(FileName, 'r')
  if SError then logShow(SError, "NamesList.txt") end
  --]]

  -- Цикл по строкам файла:

  local limit, count = 0, 0

  local t = self.Data.Names
  local easy = unit.EasyName

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

      t[cp] = {
        code = code,
        name = name:sub(1, 1) == '<' and name or easy(name),
      } ---

      limit = cp
      count = count + 1

    end -- if

    self.Data.NamesCount = count
    self.Data.NamesStart = 0x0
    self.Data.NamesLimit = limit

    --[[
    name = s:match("^\t%= (.+)")
    -- Альтернативное название:
    if name then
      data = t[limit]
      if not data.alias then data.alias = {} end
      data.alias[#data.alias + 1] = name

    end --
    --]]

    s = f:read('*l')
    --sn = sn + 1

  until s == nil

  f:close()

  return true

end ---- ParseNames

-- Load and parse Blocks.txt.
-- Загрузка и разбор Blocks.txt.
--[[
  -- @params:
  FileName (string) - name of loaded text file.
  -- @return:
  (bool|nil) - result of data parsing.
--]]
function unit:ParseBlocks (FileName) --> (bool | nil)

  local f = io_open(FileName, 'r')
  if f == nil then return end
  --[[
  local f, SError = io_open(FileName, 'r')
  if SError then logShow(SError, "NamesList.txt") end
  --]]

  -- Цикл по строкам файла:

  local t = self.Data.Blocks

  local s = "#"
  local k = 0
  --local sn = 0
  repeat
    --logShow(s, "File line")
    -- Пропуск комментариев, доп. информации и старых названий:
    while s and s:find("^%#") do
      --logShow(s, "File unused line")
      s = f:read('*l')
      --sn = sn + 1

    end

    if s == nil then break end -- Конец файла
    --if sn > 40 then break end -- DEBUG only
    --logShow(s, "File used line")

    -- TODO: Check codepoint ranges!!
    -- Основное название:
    local code1, code2, name = s:match("^(%x%x%x%x)%.%.(%x%x%x%x)%; (.+)$")
    if code1 and code2 then
      k = k + 1
      --logShow(code, name)
      local cp1 = tonumber(code1, 16)
      local cp2 = tonumber(code2, 16)
      --if cp > 0x300 then break end -- DEBUG only
      --if cp > 0xFFFF then break end -- DEBUG only

      t[k] = {
        first = cp1,
        last  = cp2,
        --code1 = code1,
        --code2 = code2,
        name = name,
      } ---

    end -- if

    self.Data.BlocksCount = k

    s = f:read('*l')
    --sn = sn + 1

  until s == nil

  f:close()

  return true

end ---- ParseBlocks
---------------------------------------- Load / Save
do  
  local farUt = require "Rh_Scripts.Utils.Utils"

-- Load Data.
-- Загрузка данных.
--[[
  -- @params:
  FilePath (string) - path to loaded lua file.
  -- @return:
  (bool|nil) - result of data loading.
--]]
function unit:LoadData (FilePath) --> (bool | nil)

  local Data = farUt.prequire(FilePath)
  if Data then
    self.Data = Data

    return true

  end
end ---- LoadData

-- Save Data.
-- Сохранение данных.
--[[
  -- @params:
  FileName (string) - name of loaded lua file.
  -- @return:
  (bool|nil) - result of data saving.
--]]
function unit:SaveData (FileName) --> (bool | nil)

  --local tables = require 'context.utils.useTables'
  local datas = require 'context.utils.useDatas'
  local serial = require 'context.utils.useSerial'

  local kind = {

    --localret = true,
    --tnaming = true,
    astable = true,
    --nesting = 0,

    lining = "all",

    serialize = serial.prettyize,

  } ---

  return datas.save(FileName, "Data", self.Data, kind)

end ---- SaveData

end --
---------------------------------------- main
do
  local sformat = string.format

function unit:Execute (Data) --> (bool | nil)

  local CfgData = Data or {}
  local CfgMeta = { __index = self.DefCfgData }
  setmetatable(CfgData, CfgMeta)

  -- Загрузка данных
  if self:LoadData(CfgData.DataPath) then
    return true

  end

  -- Данные по символам
  self.Data = {

    Names   = {}, --< NamesList

    Blocks  = {}, --< Blocks

  } --

  local FileName

  -- Разбор имён
  FileName = sformat("%s%s%s", CfgData.PluginDataPath,
                     CfgData.FilePath, CfgData.NamesFile)
  --logShow(unit.DefCfgData, FileName, "d1")
  self:ParseNames(FileName)

  -- Разбор блоков
  FileName = sformat("%s%s%s", CfgData.PluginDataPath,
                     CfgData.FilePath, CfgData.BlocksFile)
  --logShow(unit.DefCfgData, FileName, "d1")
  self:ParseBlocks(FileName)

  FileName = sformat("%s%s%s", CfgData.PluginWorkPath,
                     CfgData.FilePath, CfgData.DataFile)

  return self:SaveData(FileName)

end -- Execute

end --

---------------------------------------- run
if not unit.Data then

  unit:Execute()

end

--logShow(unit.Data.Names, "Char Names", "d1")
--logShow(unit.Data.Blocks, "Char Blocks", "d1")

--------------------------------------------------------------------------------
return unit.Data
--------------------------------------------------------------------------------
