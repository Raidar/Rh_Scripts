--[[ Extension ]]--

----------------------------------------
--[[ description:
  -- Extended Lua-functions.
  -- Расширенные Lua-функции.
--]]
----------------------------------------
--[[ uses:
  nil.
  -- group: Utils.
  -- from:
  something from stdlib project.
--]]
--------------------------------------------------------------------------------
local _G = _G

local type, assert = type, assert
local next, pairs, ipairs = next, pairs, ipairs
local tonumber, tostring = tonumber, tostring
local setmetatable, getmetatable = setmetatable, getmetatable

local table, string = table, string
local io, package = io, package

----------------------------------------
local bit = bit64
local band, bor = bit.band, bit.bor
local bshl, bshr = bit.lshift, bit.rshift

----------------------------------------
local far = far

----------------------------------------
local context = context

local strings = require 'context.utils.useStrings'
local utils = require 'context.utils.useUtils'
local tables = require 'context.utils.useTables'

----------------------------------------
local luaUt = require "Rh_Scripts.Utils.luaUtils"

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

--[[
  The most part of functions haven't type checking for received arguments.
  Большинство функций не выполняют проверки типов для получаемых параметров.
--]]
---------------------------------------- Specials

---------------------------------------- Numbers

---------------------------------------- Strings

---------------------------------------- const
local const = {}
unit.const = const

const.CharSetPat = "[%s]"
const.NoneSetPat = "[^%s]"

-- Lua wildcard characters:
const.LuaCardsList = { '?', '*', '+', '-' }
-- Lua character %-classes:
const.LuaClassList = { '%c', '%a', '%d', '%s', '%p',
                       '%l', '%u', '%w', '%x', '%z' }

const.LuaCards    = table.concat(const.LuaCardsList)
const.LuaCardsSet = const.CharSetPat:format(
                      const.LuaCards:gsub("(.)", "%%%1"))
--const.LuaMagic = ""

const.DefCharEnum = "%w_"

--logShow(const.LuaCardsSet, const.LuaCards)

---------------------------------------- CharControl
local TCharControl = {} -- Char control class
do
  local MCharControl = { __index = TCharControl }

-- Character control.
-- Управление символами.
--[[
  -- @params
  cfg (table):
    CharEnum (string) - Допустимые символы слова.
    UseMagic   (bool) - Использование "магических" модификаторов.
    UsePoint   (bool) - Использование символа '.' как "магического".
    --
    UseInside  (bool) - Использование внутри слов.
    UseOutside (bool) - Использование вне слов.
    CharsMin (number) - Минимальное число набранных символов слова.
    --
    MatchCase  (bool) - Учёт регистра символов.
--]]
function unit.CharControl (cfg) --> (object)
  local cfg = cfg or {}
  local CharEnum = cfg.CharEnum or const.DefCharEnum
  local self = {
    cfg = cfg,
    CharEnum = CharEnum,
    CharsSet = ".",
    SeparSet = "",
  } --- self

  if CharEnum ~= "." then
    self.CharsSet = const.CharSetPat:format(CharEnum) -- Множество символов
    self.SeparSet = const.NoneSetPat:format(CharEnum) -- Множество разделителей
  end

  return setmetatable(self, MCharControl)
end ---- CharControl

end -- do

-- Check character for character of set.
-- Проверка символа на символ из множества.
function TCharControl:isSetChar (Char) --> (bool)
  return Char and Char:find(self.CharsSet) or
         self.cfg.UseMagic and Char:find(const.LuaCardsSet) or
         self.cfg.UsePoint and Char == '.' -- dot
end ---- isSetChar

-- Get word at specified position (and word part leftward of it).
-- Получение слова в указанной позиции (и части слова слева от него).
function TCharControl:atPosWord (s, pos) --> (string), (string)
  if pos > s:len() + 1 then return "", "" end

  --logShow({ s, L, pos, P }, "atPosWord", "#")
  self.Slab = pos > 1 and s:sub(1, pos - 1):match(self.CharsSet..'+$') or ""
  self.Tail = s:sub(pos):match('^'..self.CharsSet..'+') or ""

  return self.Slab..self.Tail, self.Slab
end ---- atPosWord

-- Check word by parameters.
-- Проверка слова на параметры.
function TCharControl:isWordUse (Word, Slab) --> (bool | nil)
  local cfg = self.cfg
  --Word, Slab = Word or self.Word, Slab or self.Slab
  --logShow({ Word, Slab, Word:len(), Slab:len(),
  --          cfg.UseInside, cfg.UseOutside, cfg.CharsMin }, cfg.CharEnum, 0)
  -- Проверки: внутри слова, вне слова, мин. число символов:
  if not cfg.UseInside and Word:len() > Slab:len() then return end
  if not cfg.UseOutside and Slab == "" and Word == "" then return end

  if cfg.CharsMin and cfg.CharsMin > 0 and Slab:len() < cfg.CharsMin then
    return
  end

  return true
end ---- isWordUse

-- Get pattern from string.
-- Получение шаблона из строки.
function TCharControl:asPattern (s) --> (string)
  local t, cfg = {}, self.cfg
  --local t = tables.create(s:len())

  local LuaCards = const.LuaCards
  for c in s:gmatch('.') do
    if c:find('%a') then -- Учёт регистра символов:
      t[#t+1] = cfg.MatchCase and c or
                ("[%s%s]"):format(c:upper(), c:lower())
    elseif c == '.' then -- Учёт '.' как "магического":
      t[#t+1] = (cfg.UseMagic and cfg.UsePoint) and self.CharsSet or '%.'
    elseif cfg.UseMagic and LuaCards:find(c, 1, true) then
                         -- Учёт "магических" модификаторов:
      t[#t+1] = cfg.UsePoint and c or self.CharsSet..c
    else
      t[#t+1] = c:find('[%p&]') and ("%%%s"):format(c) or c
      --t[#t+1] = c:find('[%p^$&]') and ("%%%s"):format(c) or c
    end -- if
  end

  return table.concat(t)
end ---- asPattern

---------------------------------------- CharCounter
local TCharCounter = {} -- Character counting class
do
  local MCharCounter = { __index = TCharCounter }

-- Char counting.
-- Подсчёт символов.
--[[
  -- @params:
  cfg (table):
    CharEnum (string) - Анализируемые символы слова.
    SpecEnum  (table) - Список специальных комбинаций.
    --      
    MatchCase  (bool) - Учёт регистра символов (true).
    UseOnes    (bool) - Подсчёт по одиночным символам (по умолчанию = true).
    UseSeqs    (bool) - Подсчёт по последовательностям (по умолчанию = false).
    UseMagic   (bool) - Подсчёт по "магическим" модификаторам (false).
    --
    Seq      (string) - Неанализируемое начало последовательности.
                        Длина анализируемой последовательности символов:
    SeqMin   (number) - минимальная (1).
    SeqMax   (number) - максимальная (1).
--]]
function unit.CharCounter (cfg) --> (object)
  local cfg = cfg or {}
  cfg.UseAlone = cfg.UseAlone == nil and true
  local CharEnum = cfg.CharEnum or "."

  local self = {
    cfg = cfg,
    CharEnum = CharEnum,
    CharsSet = '.',
    Seq    = cfg.Seq or "",
    SeqMax = cfg.SeqMax or 1,
    SeqMin = cfg.SeqMin or 1,
    Count = {
      Total = 0,
      Ones  = cfg.Ones or {},
      Seqs  = cfg.Seqs or {},
      --Chars = cfg.Chars or {},
      Magic = cfg.Magic or {},
      Specs = cfg.Specs or {},
    } --
  } --- self

  if CharEnum ~= '.' then
    self.CharsSet = const.CharSetPat:format(CharEnum) -- Множество символов
  end

  -- Подготовка счётчиков:
  if cfg.UseMagic then
    local Magic = self.Count.Magic 
    local LuaClassList = const.LuaClassList
    for k = 1, #LuaClassList do
      local v = LuaClassList[k]
      Magic[v] = Magic[v] or 0
    end
  end

  return setmetatable(self, MCharCounter)
end ---- CharCounter

end -- do

-- Count for next character c.
-- Подсчёт для очередного символа c.
function TCharControl:Char (c) --> (bool | nil)
  if c == nil then return end
  local cfg, Count = self.cfg, self.Count

  if cfg.MatchCase == false then c = c:lower() end

  Count.Total = Count.Total + 1
  if cfg.UseOnes then
    Count.Ones[c] = (Count.Ones[c] or 0) + 1
  end

  if cfg.UseMagic then
    -- Подсчёт по "магическим" модификаторам:
    local LuaClassList = const.LuaClassList
    local Count_Magic = Count.Magic
    for k = 1, #LuaClassList do
      local v = LuaClassList[k]
      if c:match(v) then
        Count_Magic[v] = Count_Magic[v] + 1
      end
    end
  end

  local Seq = self.Seq
  if self.SeqMax <= 1 then return true end -- MAYBE: ниже?!
  -- Добавление в последовательность
  Seq = (Seq:len() >= self.SeqMax and -- с учётом длины
         Seq:sub(-self.SeqMax + 1, -1) or Seq)..c
  if Seq:len() < self.SeqMin then return false end -- MAYBE: ниже?!
  -- Анализ последовательности:
  if cfg.UseSeqs then
    Count.Seqs[Seq] = (Count.Seqs[Seq] or 0) + 1
  end

  if cfg.SpecEnum then
    -- Перебор специальных комбинаций:
    local SpecEnum = cfg.SpecEnum
    local Count_Specs = Count.Specs
    for k = 1, #SpecEnum do
      local v = SpecEnum[k]
      if Seq:match(v) then
        Count_Specs[v] = (Count_Specs[v] or 0) + 1
      end
    end
  end

  return true
end ---- Char

---------------------------------------- Tables
local function _isEqual (t, u) --> (bool)
  if t == nil and u == nil then return true end
  if t == nil or u == nil then return false end

  local typeT, typeU, equal = type(t), type(u)
  if typeT ~= 'table' or typeU ~= 'table' then
    return typeT == typeU and t == u
  end

  for k, v in pairs(t) do
    if u[k] == nil then return false end
    equal = _isEqual(v, u[k])
    if not equal then return false end
  end

  for k, v in pairs(u) do
    if t[k] == nil then return nil end
  end

  return true
end --function _isEqual
unit.isEqual = _isEqual

-- Выполнение gsub для значений ключей таблицы строк.
function unit.t_gsub (t, name, pattern, replace) --> (table)
  for k, v in pairs(t) do
    if not name or (name and k:find(name)) then
      t[k] = v:gsub(pattern, replace)
    end
  end

  return t
end ---- t_gsub

-- Maximum of field values for table array-part.
-- Максимум значений полей для части-массива таблицы.
function unit.t_imax (t, count) --> (number)
  local m, i = 0, 0

  -- Find first value.
  for k = 1, count or #t do
    local v = t[k]
    if v then
      m, i = v, k
      break
    end
  end
  if i == 0 then return end

  -- Check next values.
  for k = i+1, count or #t do
    local v = t[k]
    if v and v > m then m = v end
  end

  return m
end ---- t_imax

-- Sum of field values for table array-part.
-- Сумма значений полей для части-массива таблицы.
function unit.t_isum (t, first, last, step) --> (number)
  local s = 0

  for k = first or 1, last or #t, step or 1 do
    s = s + (t[k] or 0)
  end

  return s
end ---- t_isum

-- Преобразование значения в таблицу с полем [0].
function unit.valtotab (v, key, default) --> (table)
  if type(v) == 'table' then return v end

  if key == nil then key = 0 end

  if v == nil then
    if default == nil then return end
    v = default
  end

  return { [key] = v }
end ---- valtotab

---------------------------------------- Package

---------------------------------------- Unicode

---------------------------------------- System

---------------------------------------- Path
-- Приведение пути к формату Windows.
function unit.FileWPath (path) --> (string)
  return path:gsub("/", "\\")
end ----
-- Приведение пути к формату Unix.
function unit.FileUPath (path) --> (string)
  return path:gsub("\\", "/")
end ----

-- Adding a trailing slash to path.
-- Добавление завершающего слэша к пути.
function unit.ChangeSlash (path, slash) --> (string)
  local path  = path or ""
  local slash = slash or '\\' -- Windows
  --slash = slash or '/' -- Unix like
  path = path:gsub("\\", slash)
  if path:find("[/\\]", -1) then return path else return path..slash end
end ---- ChangeSlash

-- Разбор произвольного пути файла.
function unit.ParseFileName (filepath) --> (path, fullname, name, ext)
   -- Разделение полного пути на собственно путь и полное имя.
  local path, fullname = filepath:match("^(.*[/\\])([^/\\]*)$")
  if not path then fullname = filepath end -- Нет пути к файлу
  -- Разделение полного имени на собственно имя и расширение.
  if fullname == "" then fullname = nil end -- Нет полного имени
  if not fullname then return path, nil, nil, nil end -- Только путь
  local name, ext = fullname:match("^(.*)%.([^%.]*)$")
  if not name and not ext then name = fullname end -- Только имя
  if ext == "" then ext = nil end -- Нет расширения файла
  -- Путь к файлу, Имя с расширением, Имя файла, Расширение файла.
  return path, fullname, name, ext
end ---- ParseFileName

-- Разбор полного пути файла: с наличием пути и файла с расширением.
function unit.ParseFullName (fullpath) --> (path, fullname, name, ext)
  -- Путь к файлу, Имя с расширением, Имя файла, Расширение файла.
  return fullpath:match("^(.-[/\\])(([^/\\]*)%.([^/\\%.]*))$")
end ---- ParseFullName

-- Adding a path of modules to EnvPath.
-- Добавление пути к модулям в EnvPath.
function unit.AddEnvPath (BasePath, ModulePath, ModuleName, EnvPath) --> (string)
  for CurPath in ModulePath:gmatch("([^;]+)") do
    local Path = ChangeSlash(BasePath..CurPath)..ModuleName -- Полный путь.
    -- Настройка путей для поиска модулей.
    if not EnvPath:find(Path, 1, true) then EnvPath = Path..';'..EnvPath end
  end -- for
  return EnvPath
end ---- AddEnvPath

-- Adding a path of used lua-modules.
-- Добавление пути к используемым lua-модулям.
function unit.AddLuaPath (BasePath, ModulePath) --> (bool)
  package.path = AddEnvPath(BasePath, ModulePath, "?.lua", package.path)
end
-- Adding a path of used dll-modules.
-- Добавление пути к используемым dll-модулям.
function unit.AddLibPath (BasePath, ModulePath) --> (bool)
  package.cpath = AddEnvPath(BasePath, ModulePath, "?.dll", package.cpath)
end

---------------------------------------- Files
do
  local ssub = string.sub -- Byte cut! for check CP

-- Проверка строки файла на признаки Unicode.
function unit.CheckLineCP (s) --> (string)
  if #s < 2 then return "OEM" end
  local s = ssub(s, 1, 3)
  if s == '\239\187\191' then return "UTF-8" end -- EF BB BF
  s = ssub(s, 1, 2)
  return s == '\255\254' and "UTF-16 BE" or -- FF FE
         s == '\254\255' and "UTF-16 LE" or -- FE FF
         "OEM" -- by default
end ---- CheckLineCP

end -- do

do
  local io_open = io.open

-- Проверка файла на признаки Unicode.
function unit.CheckFileCP (filename) --> (string)
  local f = io_open(filename, 'r')
  if not f then return nil end
  local s = f:read('*l')
  f:close()
  return CheckLineCP(s)
end ---- CheckFileCP

end -- do

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
