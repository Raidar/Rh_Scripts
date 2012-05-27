--[[ LUM ]]--

----------------------------------------
--[[ description:
  -- LUM menu: Working with whole menu.
  -- Меню LUM: Работа с меню в целом.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils.
  -- group: LUM.
--]]
--------------------------------------------------------------------------------
local _G = _G

local pairs = pairs
local require = require

----------------------------------------
local context = context

local utils = require 'context.utils.useUtils'

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

----------------------------------------
local Msgs = {
  FileNotFound = "File with base name '%s' not found",
  EnumNotFound = "Files in enumeration '%s' not found",
} --- Msgs

---------------------------------------- File name
do
  local fexists = utils.fexists
  local FullNameFmt = "%s%s%s"

--[[ Порядок поиска:
  1. Поиск файла Name по пути Base..Path.
  2. Поиск файла Name по пути Base..DefPath.
--]]
-- TODO: Упростить код?!
function unit.GetFileName (Name, Args) --> (string | nil, error)
  local FullName, FullExtName
  FullName = FullNameFmt:format(Args.Base, Args.Path, Name)
  if fexists(FullName) then return FullName end
  FullExtName = FullName..Args.DefExt
  if fexists(FullExtName) then return FullExtName end
  FullExtName = FullName..Args.LuaExt
  if fexists(FullExtName) then return FullExtName end
  FullName = FullNameFmt:format(Args.Base, Args.DefPath, Name)
  if fexists(FullName) then return FullName end
  FullExtName = FullName..Args.DefExt
  if fexists(FullExtName) then return FullExtName end
  FullExtName = FullName..Args.LuaExt
  if fexists(FullExtName) then return FullExtName end
end ---- GetFileName

end -- do

---------------------------------------- File join
-- Чтение данных из перечня ini/lua-файлов в таблицу.
--[[
  -- @params:
  Args (table):
    Enum -- перечень имён файлов, разделённых символом ";".
    DefExt  -- расширение по умолчанию для файлов перечня.
    Base -- общая часть пути к файлу / файлам.
    Path -- основной путь к файлу / файлам.
    FullPath -- общий + один из основных путей к файлу / файлам.
    DefEnum -- перечень имён файлов, используемых по умолчанию.
    DefPath -- основной путь к файлу / файлам по умолчанию.
  -- @params:
  Props (table):
    Join -- тип объединения таблиц разных файлов перечня:
      true -- внешнее объединение (объединение таблиц).
      false/nil -- внутреннее объединение (объединение полей).
    SubKey -- формат-шаблон для генерации имён подтаблиц.
    IlkSep -- строка-разделитель значений одноимённых ключей.
--]]
-- -- TEMP: Don't work properly.
do
  local GetFileName = unit.GetFileName

  local rhini = require "Rh_Scripts.Utils.IniFile"
  local MergeTable, GetFileData = rhini.MergeTable, rhini.GetFileData

-- Чтение с учётом внешнего объединения:
function unit.GetFileOuterJoin (Args, Props) --> (table | nil, error)
  local t, SError, FullName, isItem = {}
  -- Учёт внешнего объединения:
  t.Menu = { Title = Args.Title or "Main Menu", Items = {} }
  local Items, SubKey = t.Menu.Items, Props.SubKey or "^UM%_([^%.]+)$"
  local u -- Временная таблица для данных
  for Name in Args.CurEnum:gmatch("([^;]+)") do -- Цикл по файлам перечня
    -- Чтение данных (во временную таблицу).
    FullName = GetFileName(Name, Args)
    --if not FullName then return nil, Msgs.FileNotFound:format(Name) end
    if FullName then
      u, SError = GetFileData(FullName, nil, Props)
      --if not u then return nil, SError end
      if not isItem and u then isItem = true end
      for k, v in pairs(u.Menu) do u[k] = v end
      Items[#Items+1] = u
    end -- if
  end -- for
  if not isItem then return nil, Msgs.EnumNotFound:format(Args.CurEnum) end
  --logShow(t, "Table", 3)
  return t
end ---- GetFileOuterJoin

-- Чтение с учётом внутреннего объединения:
function unit.GetFileInnerJoin (Args, Props) --> (table | nil, error)
  local t, SError, FullName, isItem = {}
  local u -- Временная таблица для данных
  for Name in Args.CurEnum:gmatch("([^;]+)") do -- Цикл по файлам перечня
    FullName = GetFileName(Name, Args)
    --if not FullName then return nil, Msgs.FileNotFound:format(Name) end
    if FullName then
      u, SError = GetFileData(FullName, nil, Props)
      --if not u then return nil, SError end
      if not isItem and u then isItem = true end
      MergeTable(t, u, Props)
    end -- if
  end -- for Name
  if not isItem then return nil, Msgs.EnumNotFound:format(Args.CurEnum) end
  return t
end ---- GetFileInnerJoin

end -- do

-- Чтение с учётом внутреннего и внешнего объединения:
function unit.GetFileJoinEnumData (Args, Props) --> (table | nil, error)
  local t, SError
  Args.DefExt = Args.DefExt or ".ini"
  Args.LuaExt = ".lua"
  Props = Props or {}

  if Props.Join then -- Внешнее объединение:
    t, SError = unit.GetFileOuterJoin(Args, Props)
  else -- Внутреннее объединение (по умолчанию):
    t, SError = unit.GetFileInnerJoin(Args, Props)
  end

  if not t then return nil, SError end
  return t
end ---- GetFileJoinEnumData

-- Чтение данных из ini/lua-файлов в таблицу (учёт по умолчанию).
--[[
  -- @notes: Порядок поиска:
  1. Получаются данные из Enum по пути Base..Path/DefPath.
  2. Если данных нет, используется DefEnum по пути Base..Path/DefPath.
--]]
function unit.GetFileEnumData (Args, Props) --> (table | nil, error)
  local t, SError, MError

  if Args.Enum and Args.Enum ~= "" then
    Args.CurEnum = Args.Enum
    --logShow({ Args, Props }, "Args and Props", 2)
    t, MError = unit.GetFileJoinEnumData(Args, Props)
    if t then return t end
    --logShow(Args.CurEnum, SError)
  else
    MError = "File enum not specified."
  end

  if Args.DefEnum and Args.DefEnum ~= "" then
    Args.CurEnum = Args.DefEnum
    --logShow({ Args, Props }, "Args and Props", 2)
    t, SError = unit.GetFileJoinEnumData(Args, Props)
    if t then return t end
    --logShow(Args.CurEnum, SError)
  else
    SError = "Default enum not specified."
  end

  return nil, MError..'\n'..SError
end ---- GetFileEnumData

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
