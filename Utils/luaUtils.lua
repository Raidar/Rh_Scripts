--[[ Lua utils ]]--

----------------------------------------
--[[ description:
  -- Elementary functions.
  -- Элементарные функции.
--]]
----------------------------------------
--[[ uses:
  nil.
  -- group: Utils.
  -- from:
  something from stdlib project.
--]]
--------------------------------------------------------------------------------

--local format = string.format

----------------------------------------
--local bit = bit64
--local band, bor = bit.band, bit.bor
--local bshl, bshr = bit.lshift, bit.rshift

----------------------------------------
--local far = far -- DEBUG ONLY

----------------------------------------
--local context = context

local strings = require 'context.utils.useStrings'

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

----------------------------------------
--[[
  The most part of functions haven't value & type checking for arguments.
  Большинство функций не выполняют проверки значений и типов для параметров.
--]]
---------------------------------------- Number

---------------------------------------- String
do
  local tonumber = tonumber

-- Convert a string to required type value.
-- Преобразование строки к значению нужного типа.
--[[
  -- @params:
  s  (string) - converted string.
  tp (string) - required type.
  def   (any) - default value (type(default) == required type).
--]]
function unit.s2v (s, tp, def, ...) --< (string) --> (value)
  if tp == 'nil' then return nil end
  local v = tp == 'string' and s or
            tp == 'number' and (tonumber(s, ...) or def) or
            tp == 'boolean' and strings.s2b(s, def) or
            nil
  if v ~= nil then return v else return def end
end ---- s2v

end -- do

do
  local sfind = ("").cfind or ("").find

-- Count of occurrences with find.
-- Подсчёт числа вхождений по find.
function unit.findcount (s, pat, init, plain)
  local count, pos = 0, init or 1
  local fpos, fend = sfind(s, pat, pos, plain)
  while fpos do
    count, pos = count + 1, fend + 1
    fpos, fend = sfind(s, pat, pos, plain)
  end
  return count
end ---- findcount

end -- do

-- Count of lines in string.
-- Количество линий в строке.
function unit.slinecount (s) --> (number)
  return strings.gsubcount(s, "\n") + 1
  --return findcount(s, "\n", 1, true) + 1
end ----

-- Maximal length (and line) in string.
-- Максимальная длина (и линия) в строке.
function unit.slinemax (s) --> (number, string | 0, nil)
  local max, x = 0, -1

  for line in s:gmatch("([^\n]+)") do -- Цикл по линиям строки:
    local len = line:len()
    if len > max then max, x = len, line end
  end

  return max, x
end ---- slinemax

---------------------------------------- Tables

---------------------------------------- Package
do
  local getevar = function (env, name) return env[name] end

-- Get value of variable 'name' from env.
-- Получение значения переменной name из env.
function unit.getvalue (env, name) --> (value)
  local isOk, var = pcall(getevar, env, name)
  if isOk then return var end
end ----

-- Get a global variable (with possible creation)
-- when using a "strict" mode of work (strict.lua).
-- Получение (с возможным созданием) глобальной переменной
-- при использовании "строгого" режима работы (strict.lua).
function unit.getglobal (varname, default) --> (var)
  default = default == nil and {} or default
  if getevar(_G, varname) == nil then
    _G[varname] = default
  end

  return _G[varname]
end ---- getglobal

  local require = require
  local pkg_loaded = package.loaded

-- Variant of require with mandatory reloading of a chunk.
-- Вариант require с обязательной перезагрузкой chunk'а.
local function newrequire (modname, dorequire)
  if pkg_loaded[modname] then
    pkg_loaded[modname] = nil
  end

  return (dorequire or require)(modname)
end ----
unit.newrequire = newrequire

  local pcall = pcall

-- Variant of require with protected mode call.
-- Вариант require с вызовом в защищённом режиме.
local function prequire (modname)
  local isOk, res = pcall(require, modname)
  --far.Message(Result, tostring(isOk))
  return isOk and res
end ----
unit.prequire = prequire

-- Variant of require with mandatory reloading and protected mode call.
-- Вариант require с обязательной перезагрузкой в защищённом режиме.
function unit.newprequire (modname)
  return newrequire(modname, prequire)
end --

end -- do

---------------------------------------- Functions
-- Call function.
-- Вызов функции.
function unit.fcall (f, ...)
  return f(...)
end ----

-- Check pcall function result.
-- Проверка результата функции pcall.
function unit.pcheck (isOk, ...)
  if isOk then return ... end
end ----

do
  local pcall = pcall

-- Protected call function.
-- Защищённый вызов функции.
function unit.pfcall (f, ...)
  return unit.pcheck(pcall(f, ...))
end ----

end -- do
do
  local getvalue = unit.getvalue
  local sFieldNotFoundError = "No field %s\n of %s"

-- Find function with compound name in environment env (and _G).
-- Поиск функции с составным именем name в окружении env (и _G).
function unit.ffind (env, name) --> (function | nil, error)
  local f = getvalue(env, name)
  if f then return f end

  -- Проверка первой компоненты имени.
  f = name:match("^[^.]+")
  --logShow(env, f, 1)
  --logShow(_G, f, "d3 _ns")
  --logShow(rawget(_G, name), f, "d2 _ns")
  --logShow(package.loaded[f], f, "d2 _ns")
  if getvalue(env, f) then
    f = env
  elseif getvalue(_G, f) then
    f = _G
  else
    return nil, sFieldNotFoundError:format(f, name) -- Ошибка
  end

  -- Разбор всех компонент имени.
  for s in name:gmatch("([^.]+)") do
    --logShow(s, Name)
    if not getvalue(f, s) then
      return nil, sFieldNotFoundError:format(s, name) -- Ошибка
    end
    f = f[s]
    --logShow(f, s)
  end
  --logShow(f, name)

  return f
end ---- ffind

end -- do

---------------------------------------- System

---------------------------------------- Common
do
  local type = type
-- Value Length.
-- Длина значения.
function unit.length (v) --> (number)
  local tp = type(v)
  if tp == 'string' then return v:len() end
  if tp == 'table' then return #v end

  return v ~= nil and 1 or 0
end ---- length

end -- do

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
