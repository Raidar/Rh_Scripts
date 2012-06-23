--[[ ini/lua-files ]]--

----------------------------------------
--[[ description:
  -- Working with ini/lua-files.
  -- Работа с ini/lua-файлами.
--]]
----------------------------------------
--[[ uses:
  Rh Utils.
  -- used in: LUM.
  -- group: Utils.
--]]
--------------------------------------------------------------------------------

local type = type
local pairs, ipairs = pairs, ipairs
local loadfile = loadfile
local setfenv, setmetatable = setfenv, setmetatable

local io_open = io.open

----------------------------------------
local OemToUtf8 = win.OemToUtf8

----------------------------------------
--local context = context

local datas = require 'context.utils.useDatas'

----------------------------------------
local luaUt = require "Rh_Scripts.Utils.luaUtils"
local extUt = require "Rh_Scripts.Utils.extUtils"

----------------------------------------
--[[
local numbers = require 'context.utils.useNumbers'
local strings = require 'context.utils.useStrings'

local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

----------------------------------------
local Nameless = datas.Nameless -- Name for section/key without name

local SpaceTrim = "^%s*(.-)%s*$" -- Паттерн исключения пробелов

local Msgs = {
  FileCannotOpen    = "Cannot open file:\n",
  FileNameNotFound  = "File name not found",
  FileDataNotFound  = "File data not found",
  --ContinuationError = "Continuation error:\n",
  ContErrorFileLine = "\nError file line: ",
} --- Msgs

---------------------------------------- Merge
-- Слияние полей таблиц.
--[[
  -- @params:
  Field  -- исходное поле.
  Merged -- присоединяемое поле.
  Props  -- свойства формирования таблицы.
    MergeKind -- тип слияния: добавление в конец массива / слияние полей.
--]]
local function MergeField (Field, Merged, Props) --> (Field | nil, error)
  if not Field then return Merged end
  if not Merged then return Field end
  local IlkSep = Props.IlkSep
  local MergeKind = Props.MergeKind or "array"
  local typeF, typeM = type(Field), type(Merged)

  -- Соединение строк:
  -- TODO: Special MergeKind?!
  --if typeF == "string" and typeM == "string" and MergeKind == "string" then
  if typeF == 'string' and typeM == 'string' then
    return (Merged == "" or not IlkSep) and Field or Field..IlkSep..Merged
  end

  -- Соединение таблиц / как таблиц
  if typeF ~= 'table' then Field = { Field } end
  if typeM ~= 'table' then Merged = { Merged } end

  if MergeKind == "array" then
    for _, v in ipairs(Merged) do
      Field[#Field+1] = v end -- Добавление в конец
  else -- MergeKind == "record"
    for n, v in pairs(Merged) do -- Слияние полей:
      Field[n] = MergeField(Field[n], v, Props) end
  end
  --logShow(Field, "AddIniData")

  return Field
end ---- MergeField
unit.MergeField = MergeField

-- Слияние таблиц.
--[[
  -- @params:
  Table  -- исходная таблица.
  Merged -- присоединяемая таблица.
  Props  -- свойства формирования таблицы.
--]]
local function MergeTable (Table, Merged, Props) --> (Table | nil, error)
  if not Table then return Merged end
  if not Merged then return Table end

  for s, d in pairs(Merged) do
    local Field = Table[s]
    if Field then
      for k, v in pairs(Merged[s]) do
        Field[k] = MergeField(Field[k], v, Props)
      end -- for
    else Table[s] = d end
  end
  --logShow(Table, "AddIniData")

  return Table
end ---- MergeTable
unit.MergeTable = MergeTable

---------------------------------------- INI
-- Чтение данных из ini-файла в таблицу.
--[[
  -- @notes:
-. Параметры функции:
  1. Name должен содержать полный путь к файлу.
  2. Содержимое таблицы Info.Table не сбрасывается в {}.
-. Формат файла с разделами:
  1. В имени раздела не должно быть ']'.
  2. В имени ключа не должно быть '='.
  3. Комментарии должны быть на отдельных строках.
  4. Признаком комментария в строке является ';'.
-. Разбор файла:
  0. Строка файла перед выполнением обработки
     очищается от начальных и конечных пробельных символов.
  1. Порядок разделов и ключей в разделах не сохраняется.
  2. Ключи в начале файла без раздела помещаются в раздел '@'.
  3. При отсутствии имени ключа ему задаётся имя '@'.
  4. При отсутствии значения ключа его значением становится "".
  5. При отсутствии '=' значением служит вся строка, а ключом -- '@'.
  5. Ключи одноимённых разделов объединяются в один раздел.
  6. Значения одноимённых ключей объединяются через IlkSep (по умолчанию ';').
  7. Символы ' \' в конце строки означают её продолжение на следующей строке.
     При объединении строки с продолжением символ '\' заменяется на '\n'.
--]]

-- Разбор одной строки данных в таблицу.
--[[
  -- @params:
  Str   -- строка с данными.
  Info  -- информация для разбора.
  Props -- свойства формирования таблицы.
--]]
local function ParseString (Str, Info, Props) --> (true | nil, error)

  local Table = Info.Table -- Таблица данных
  local TblSec -- Таблица раздела для ключа
  -- Раздел, ключ и значение
  local Sec, Key, Value = Info.Sec, Info.Key, Info.Value
  local PosB, PosE -- Начальная и конечная позиции в строке

  local Line = Props._CP_ == "OEM" and OemToUtf8(Str) or Str
  --if Line:find("[Insert.S", 1, true) then far.Message(Line) end
  --if Line:find("[Main]", 1, true) then logShow(Line) end
  Line = Line:match(SpaceTrim) -- Очистка строки
  -- Пропуск пустых/пробельных строк.
  if #Line < 1 then Info.ContFlag = false; return true end -- :len() ?
  -- Пропуск строк-комментариев.
  if Line:match("^%;") and not Info.ContFlag then return true end
  -- Проверка на раздел -- Разбор [Sec]
  --PosB, PosE = Line:cfind("^%[.+%]")
  PosB, PosE = Line:cfind("^%[[^=%]]+%]")
  --if Line:cfind("[Main]", 1, true) then logShow({PosB, PosE, Line}, "[Sec]") end
  --[[
  if PosB and Info.ContFlag then -- Продолжение последнего ключа
    return nil, Msgs.ContinuationError..Name..
                Msgs.ContErrorFileLine..tostring(Info.LineCtr)
  end 
  --]]
  if PosB then --[[ Работа с разделом ]]
    -- Формирование раздела в таблице.
    Sec = Line:sub(PosB+1, PosE-1) -- Очистка от конца
    if not Table[Sec] then Table[Sec] = {} end -- Раздел
    Info.Sec = Sec; return true
  end -- if PosB

  --[[ Работа с ключом и значением ]]
  if Info.ContFlag then -- Продолжение:
    Value = Value:sub(1, -3)..'\n'..Line
    Info.ContFlag = false
  else -- Новый ключ со значением:
    -- Проверка на ключ -- Разбор Key = Data.
    Key, Value = Line:match("([^=]*)%=(.*)")
    if not Key and not Value then Key, Value = Nameless, Line end
    -- Очистка строк от пробельных символов.
    --Key = Key and Key:match(SpaceTrim)
    --Value = Value and Value:match(SpaceTrim)
    -- Ключ и значение по умолчанию.
    if not Key or Key == "" then Key = Nameless end
    if not Value or Value == "" then Value = "" end
  end -- if ContFlag

  if Value:find(" \\$") then -- ("[^\\]\\$")
    Info.ContFlag = true -- Есть продолжение
    Info.Key, Info.Value = Key, Value
  else
    if not Sec then
      Sec = Nameless -- Раздел по умолчанию:
      if not Table[Sec] then Table[Sec] = {} end
    end
    TblSec = Table[Sec] -- Формирование ключа в таблице:
    TblSec[Key] = MergeField(TblSec[Key], Value, Props)
  end -- if Value:find

  Info.Sec = Sec
  return true
end ---- ParseString

-- Чтение данных из ini-файла напрямую в таблицу.
--[[
  -- @params:
  Name  -- имя файла с данными.
  Table -- таблица с данными.
  Props -- свойства формирования таблицы.
    IlkSep -- разделитель значений одноимённых ключей.
--]]
function unit.GetStrIniData (Name, Table, Props) --> (Table | nil, error)
  if not Name then return nil, Msgs.FileNameNotFound end

  local Props = Props or {}
  if not Props._CP_ then
    Props._CP_ = extUt.CheckFileCP(Name) -- Примерная кодировка файла
    if Props._CP_ == nil then return nil, Msgs.FileCannotOpen..Name end
  end
  --logShow(Props._CP_, Name)

  local f = io_open(Name, 'r')
  local Info = {
    Table = Table or {},    -- Таблица
    LineCtr = 0,            -- Номер текущей строки
    ContFlag = false,       -- Признак продолжения строки
    Sec = nil, Key = nil, Value = nil, -- Начальные значения
  } --- Info

  local isOk, SError
  for s in f:lines() do
    Info.LineCtr = Info.LineCtr + 1
    isOk, SError = ParseString(s, Info, Props)
    --logShow(Info.Table, s)
    if not isOk then break end
  end

  f:close()
  if not isOk then return nil, SError end

  --[[
  if Info.ContFlag then -- Продолжение последней строки
    return nil, Msgs.ContinuationError..Name..
                Msgs.ContErrorFileLine..tostring(Info.LineCtr)
  end
  --]]
  --logShow(Info.Table, "Info.Table")

  return Info.Table
end ---- GetStrIniData

-- Разбор строки-буфера данных в таблицу.
--[[
  -- @params:
  Str   -- строка-буфер с данными.
  Table -- таблица с данными.
  Props -- свойства формирования таблицы.
    IlkSep -- разделитель значений одноимённых ключей.
--]]
local function ParseBuffer (Str, Table, Props) --> (Table | nil, error)
  if not Str then return nil end
  --[[
  local SecCtr = numbers.b2n(Str:find("^%s*[^\n]-%[")) + -- Раздел в 1-й строке
                 strings.gsubcount(Str, "\n%s*[^\n]-%[") -- + остальные разделы
  logShow(Str, SecCtr)
  --]]

  local Info = {
    Table = Table or {},    -- Таблица
    LineCtr = 0,            -- Номер текущей строки
    ContFlag = false,       -- Признак продолжения строки
    Sec = nil, Key = nil, Value = nil, -- Начальные значения
  } --- Info

  local isOk, SError
  for s in Str:gmatch("([^\n]+)") do
    Info.LineCtr = Info.LineCtr + 1
    isOk, SError = ParseString(s, Info, Props)
    --logShow(Info.Table, s)
    if not isOk then break end
  end

  if not isOk then return nil, SError end

  --[[
  if Info.ContFlag then -- Продолжение последней строки
    return nil, Msgs.ContinuationError..Name..
                Msgs.ContErrorFileLine..tostring(Info.LineCtr)
  end
  --]]
  --logShow(Info.Table, "Info.Table")

  return Info.Table
end ---- ParseBuffer

-- Чтение данных из ini-файла через буфер в таблицу.
--[[
  -- @params:
  Name  -- имя файла с данными.
  Table -- исходная таблица с данными.
  Props -- свойства формирования таблицы.
    IlkSep -- разделитель значений одноимённых ключей.
--]]
function unit.GetBufIniData (Name, Table, Props) --> (Table | nil, error)
  if not Name then return nil, Msgs.FileNameNotFound end

  -- Работа с файлом:
  local f = io_open(Name, 'r')
  if not f then return nil, Msgs.FileCannotOpen..Name end
  local Str = f:read('*a')
  f:close()

  -- Получение кодировки:
  Props = Props or {}
  if not Props._CP_ then
    Props._CP_ = extUt.CheckLineCP(Str) -- Примерная кодировка файла
  end
  --logShow(Props._CP_, Name)
  --logShow(Str, Name)

  return ParseBuffer(Str, Table, Props)
end ---- GetBufIniData

----------------------------------------
-- Функция чтения данных из ini-файла по умолчанию.

--unit.GetIniData = unit.GetStrIniData
unit.GetIniData = unit.GetBufIniData

---------------------------------------- LUA
-- Чтение данных из lua-файла в таблицу.
--[[
  -- @notes:
-. Параметры функции:
  1. Name должен содержать полный путь к файлу.
  2. Содержимое таблицы ATable не сбрасывается в {}.
-. Формат lua-файла:
  1. Должен быть правильным lua-скриптом.
  2. Должен возращать правильную таблицу данных
     или содержать переменную Data с этой таблицей.
-. Разбор файла:
  1. Файл загружается с помощью функции loadfile().
  2. Таблица данных должна иметь такой же вид,
     как если бы эти данные считались из ini-файла.
     Подменю могут оформляться как поля в таблице Items.
--]]

-- Чтение данных из lua-файла в таблицу.
--[[
  -- @params:
  Name  -- имя файла с данными.
  Table -- исходная таблица с данными.
  Props -- свойства чтения данных и формирования таблицы.
    IlkSep -- разделитель значений одноимённых ключей.
--]]
function unit.GetLuaData (Name, Table, Props) --> (Table | nil, error)
  --logShow({ Name, Table, Props }, "GetLuaData", 2)
  if not Name then return nil, Msgs.FileNameNotFound end

  -- Загрузка файла:
  local Chunk, SError = loadfile(Name)
  if not Chunk then return nil, SError end

  -- Получение данных:
  local Env = { __index = _G }; setmetatable(Env, Env)
  local t = setfenv(Chunk, Env)()
  if not t then t = luaUt.getvalue(Env, "Data") end
  if not t then return nil, Msgs.FileDataNotFound end

  return MergeTable(Table, t, Props)
end ---- GetLuaData

---------------------------------------- Check
-- Check file for Lua-script.
-- Проверка файла на скрипт Lua.
local function isLuaFile (Name) --> (bool)
  local f = io_open(Name)
  if not f then return nil, Msgs.FileCannotOpen end

  local line = f:read("*l")
  f:close()

  return line:find("local", 1, true) == 1 or line:find("--", 1, true) == 1
end -- isLuaFile

-- Чтение данных из ini/lua-файла в таблицу.
--[[
  -- @params:
  Name  -- имя файла с данными.
  Table -- исходная таблица с данными.
  Props -- свойства формирования таблицы.
    IlkSep -- разделитель значений одноимённых ключей.
--]]
function unit.GetFileData (Name, Table, Props) --> (table | nil, error)
  if not Name then return nil, Msgs.FileNameNotFound end

  if Name:match("%.lua$") or isLuaFile(Name) then
    return unit.GetLuaData(Name, Table, Props)
  else
    return unit.GetIniData(Name, Table, Props)
  end
end ---- GetFileData

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
