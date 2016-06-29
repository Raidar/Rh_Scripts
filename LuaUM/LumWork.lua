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

local pairs = pairs
local require = require

----------------------------------------
--local context = context
local logShow = context.ShowInfo

local utils = require 'context.utils.useUtils'

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
  local FullName = FullNameFmt:format(Args.Base, Args.Path, Name)
  if fexists(FullName) then return FullName end
  local FullExtName = FullName..".example"
  if fexists(FullExtName) then return FullExtName end
  FullExtName = FullName..Args.DefExt
  if fexists(FullExtName) then return FullExtName end
  if Args.LuaExt ~= Args.DefExt then
    local FullExtName = FullName..Args.LuaExt
    if fexists(FullExtName) then return FullExtName end
  end

  if Args.DefPath ~= Args.Path then
    local FullName = FullNameFmt:format(Args.Base, Args.DefPath, Name)
    if fexists(FullName) then return FullName end
    local FullExtName = FullName..Args.DefExt
    if fexists(FullExtName) then return FullExtName end

    if Args.LuaExt ~= Args.DefExt then
      local FullExtName = FullName..Args.LuaExt
      if fexists(FullExtName) then return FullExtName end
    end
  end
end ---- GetFileName

end -- do

---------------------------------------- File join
-- Чтение данных из перечня lua-файлов в таблицу.
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
  local MergeTable, GetFileData = rhini.MergeTable, rhini.GetLuaData

-- Чтение с учётом внешнего объединения:
function unit.GetFileOuterJoin (Args, Props) --> (table | nil, error)
  local t, isItem = {}
  -- Учёт внешнего объединения:
  t.Menu = { Title = Args.Title or "Main Menu", Items = {}, }
  local Items = t.Menu.Items
  --local Items, SubKey = t.Menu.Items, Props.SubKey or "^UM%_([^%.]+)$"

  for Name in Args.CurEnum:gmatch("([^;]+)") do -- Цикл по файлам перечня
    -- Чтение данных (во временную таблицу).
    local FullName = GetFileName(Name, Args)
    --if not FullName then return nil, Msgs.FileNotFound:format(Name) end
    if FullName then
      local u, SError = GetFileData(FullName, nil, Props)
      --if not u then return nil, SError end
      if not isItem and u then isItem = true end
      if u.Menu then
        for k, v in pairs(u.Menu) do u[k] = v end
      end
      Items[#Items+1] = u
    end -- if
  end -- for

  --logShow(t, "Table", 3)
  if isItem then return t end

  return nil, Msgs.EnumNotFound:format(Args.CurEnum)
end ---- GetFileOuterJoin

-- Чтение с учётом внутреннего объединения:
function unit.GetFileInnerJoin (Args, Props) --> (table | nil, error)
  local t, isItem = {}

  for Name in Args.CurEnum:gmatch("([^;]+)") do -- Цикл по файлам перечня
    --logShow(Args, Name)
    local FullName = GetFileName(Name, Args)
    --if not FullName then return nil, Msgs.FileNotFound:format(Name) end
    --if not FullName then FullName = GetFileName(Name..".example", Args) end
    if FullName then
      local u, SError = GetFileData(FullName, nil, Props)
      --if not u then return nil, SError end
      --logShow(u, FullName)
      if not isItem and u then isItem = true end
      --if Args.DefExt == ".lum" then logShow(u, "GetFileInnerJoin: "..Name, "w d1") end
      MergeTable(t, u, Props)
      --if Args.DefExt == ".lum" then logShow(t, "GetFileInnerJoin: Result", "w d1") end
    end -- if

  end -- for Name

  if isItem then return t end

  return nil, Msgs.EnumNotFound:format(Args.CurEnum)
end ---- GetFileInnerJoin

end -- do

-- Чтение с учётом внутреннего и внешнего объединения:
function unit.GetFileJoinEnumData (Args, Props) --> (table | nil, error)
  Args.DefExt = Args.DefExt or ".lum"
  Args.LuaExt = ".lua"
  Props = Props or {}

  local t, SError
  --logShow({ Args = Args, Props = Props }, "GetFileJoinEnumData", "w d2")
  if Props.Join then -- Внешнее объединение:
    t, SError = unit.GetFileOuterJoin(Args, Props)
  else -- Внутреннее объединение (по умолчанию):
    t, SError = unit.GetFileInnerJoin(Args, Props)
  end

  if t then return t end
  return nil, SError
end ---- GetFileJoinEnumData

-- Чтение данных из ini/lua-файлов в таблицу (учёт по умолчанию).
--[[
  -- @notes: Порядок поиска:
  1. Получаются данные из Enum по пути Base..Path/DefPath.
  2. Если данных нет, используется DefEnum по пути Base..Path/DefPath.
--]]
function unit.GetFileEnumData (Args, Props) --> (table | nil, error)
  local SError, MError

  if Args.Enum and Args.Enum ~= "" then
    Args.CurEnum = Args.Enum
    --logShow({ Args, Props }, "Args and Props", 2)
    local t, MError = unit.GetFileJoinEnumData(Args, Props)
    if t then return t end
    --logShow(Args.CurEnum, MError)

  else
    MError = "File enum not specified."
  end

  if Args.DefEnum and Args.DefEnum ~= "" then
    Args.CurEnum = Args.DefEnum
    --logShow({ Args, Props }, "Args and Props", 2)
    local t, SError = unit.GetFileJoinEnumData(Args, Props)
    if t then return t end
    --logShow(Args.CurEnum, SError)
  else
    SError = "Default enum not specified."
  end

  return nil, (MError or "")..'\n'..(SError or "")
end ---- GetFileEnumData

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
