--[[ Date+Time ]]--

----------------------------------------
--[[ description:
  -- Date and Time classes.
  -- Классы даты и времени.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils.
  -- group: Utils, DateTime.
  -- areas: any.
--]]
--------------------------------------------------------------------------------

local setmetatable = setmetatable

local modf = math.modf
local floor = math.floor

----------------------------------------
--local context = context

local numbers = require 'context.utils.useNumbers'

local round = numbers.round

----------------------------------------
-- [[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Date class
local TDate = {} -- Класс даты
local MDate = { __index = TDate }

-- Создание объекта класса.
function unit.newDate (d, m, y) --> (object)
  local self = {
    d = d or 0, -- количество дней
    m = m or 0, -- количество месяцев
    y = y or 0, -- количество лет
  } --- self

  return setmetatable(self, MDate)
end -- newDate

---------------------------------------- handling
function TDate:data () --> (d, m, y)
  return self.d, self.m, self.y
end ----

function TDate:copy () --> (object)
  return unit.newDate(self:data())
end ----

---------------------------------------- Time class
local TTime = {} -- Класс времени
local MTime = { __index = TTime }

-- Создание объекта класса.
function unit.newTime (h, n, s, z) --> (object)
  local self = {
    h = h or 0, -- количество часов
    n = n or 0, -- количество минут
    s = s or 0, -- количество секунд
    z = z or 0, -- количество миллисекунд
  } --- self

  return setmetatable(self, MTime)
end -- newTime

---------------------------------------- handling
function TTime:data () --> (h, n, s, z)
  return self.h, self.n, self.s, self.z
end ----

function TTime:copy () --> (object)
  return unit.newTime(self:data())
end ----

-- Количество секунд без долей секунд.
function TTime:hns () --> (number)
  return self.s + (self.n + self.h * 60) * 60
end ----

-- Количество миллисекунд как доля секунды.
function TTime:msec () --> (number)
  return self.z / 1000
end ----

-- Количество десятых долей секунды в миллисекундах.
function TTime:dz () --> (number)
  return round(self.z / 100)
end ----

-- Количество сотых долей секунды в миллисекундах.
function TTime:cz () --> (number)
  return round(self.z / 10)
end ----

---------------------------------------- to & from
function TTime:to_h () --> (number)
  return ((self.z / 1000 + self.s) / 60 + self.n) / 60 + self.h
end ----

function TTime:to_n () --> (number)
  return (self.z / 1000 + self.s) / 60 + self.n + self.h * 60
end ----

function TTime:to_s () --> (number)
  return self.z / 1000 + self.s + (self.n + self.h * 60) * 60
end ----

function TTime:to_z () --> (number)
  return self.z + (self.s + (self.n + self.h * 60) * 60) * 1000
end ----

function TTime:from_h (v) --> (self)
  self.h, v = modf(v)
  self.n, v = modf(v * 60)
  self.s, v = modf(v * 60)
  self.z = round(v * 1000)

  return self
end ----

function TTime:from_n (v) --> (self)
  self.h = floor(v / 60)
  v = v - self.h * 60
  self.n, v = modf(v)
  self.s, v = modf(v * 60)
  self.z = round(v * 1000)

  return self
end ----

function TTime:from_s (v) --> (self)
  self.h = floor(v / 3600)
  v = v - self.h * 3600
  self.n = floor(v / 60)
  v = v - self.n * 60
  self.s, v = modf(v)
  self.z = round(v * 1000)

  return self
end ----

function TTime:from_z (v) --> (self)
  self.h = floor(v / 3600 / 1000)
  v = v - self.h * 3600 * 1000
  self.n = floor(v / 60 / 1000)
  v = v - self.n * 60 * 1000
  self.s = floor(v / 1000)
  self.z = v - self.s * 1000

  return self
end ----

---------------------------------------- operations
function TTime:summ (time) --> (number)
  return self:to_z() + time:to_z()
end ----

function TTime:diff (time) --> (number)
  return self:to_z() - time:to_z()
end ----

function TTime:add (time) --> (self)
  return self:from_z(self:summ(time))
end ----

function TTime:sub (time) --> (self)
  return self:from_z(self:diff(time))
end ----

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
