--[[ Types utils ]]--

----------------------------------------
--[[ description:
  -- Working with user data types.
  -- Работа с пользовательскими типами данных.
--]]
----------------------------------------
--[[ uses:
  LF context.
  -- group: Utils.
--]]
----------------------------------------
--[[ idea + some code from:
---- 'object' based on:
---- 'class' based on:
  Simple Educative Class System.
  © 2009, Bart Bes.
--]]
--------------------------------------------------------------------------------

--local type = type
--local pairs = pairs
local getmetatable, setmetatable = getmetatable, setmetatable

----------------------------------------
--local bit = bit64
--local bor = bit.bor
--local bshl, bshr = bit.lshift, bit.rshift

----------------------------------------
--local context = context

--local utils = require 'context.utils.useUtils'

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- object model
-- Объект.
local object = {
  _type_ = 'object',
  _name_ = "object",
} ---
unit.object = object
setmetatable(object, object)

-- Конструктор.
function object:new (...)
  local t = { ... }
  t.__index = self

  return setmetatable(t, t)
end ---- new

--[[
function object:new (...)
  local tp = type(self)
  if tp == 'table' or tp == 'function' then
    local t = { ... }
    t.__index = self
    return setmetatable(t, t)

  elseif tp == 'string' then
    local t = {...}
    t.__index = object
    t.name = self
    return function (...)
      return t:new()
    end
  end
end ---- new
--]]
---------------------------------------- class model
-- Метакласс.
local class_mt = {
  _type_ = 'metaclass',
} ---
unit.class_mt = class_mt

-- Доступ к полям базового класса.
function class_mt:__index (key)
  if rawget(self, "_base_") then
    return self._base_[key]
  end
end ---- __index

-- Класс.
local class = {
  _type_ = 'class',
  _base_ = {},  -- Базовый класс
} ---
unit.class = class
setmetatable(class, class_mt)

-- Конструктор.
function class:new (...)
  local init = self.init
  local t
  if init then
    t = {}
  else
    -- TODO: Если параметр один и он - таблица, использовать его?!
    t = {...}
  end

  t._base_ = self
  setmetatable(t, getmetatable(self))

  if init then
    init(t, ...)
  end

  return t
end ---- new

-- Преобразование таблицы в класс.
function class:convert (t)
  t._base_ = self
  setmetatable(t, getmetatable(self))

  return t
end ---- convert

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
