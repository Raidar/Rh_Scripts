--[[ Character types ]]--

----------------------------------------
--[[ description:
  -- Handling characters.
  -- Обработка символов.
--]]
----------------------------------------
--[[ uses:
  nil.
  -- group: Utils.
--]]
--------------------------------------------------------------------------------

--local type = type
--local pairs = pairs
local setmetatable = setmetatable

local format = string.format

----------------------------------------
--local bit = bit64
--local band, bor = bit.band, bit.bor
--local bshl, bshr = bit.lshift, bit.rshift

----------------------------------------
--local context = context

local lua = require 'context.utils.useLua'

local const = lua.regex

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

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
    cfg       = cfg,
    CharEnum  = CharEnum,
    CharsSet  = ".",
    SeparSet  = "",
  } --- self

  if CharEnum ~= "." then
    self.CharsSet = format(const.CharSetPat, CharEnum) -- Множество символов
    self.SeparSet = format(const.NoneSetPat, CharEnum) -- Множество разделителей
  end

  return setmetatable(self, MCharControl)
end ---- CharControl

end -- do

-- Check character for character of set.
-- Проверка символа на символ из множества.
function TCharControl:isSetChar (Char) --> (bool)
  return Char and Char:find(self.CharsSet) or
         self.cfg.UseMagic and Char:find(const.CardsSet) or
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

  local tconcat = table.concat

-- Get pattern from string.
-- Получение шаблона из строки.
function TCharControl:asPattern (s) --> (string)
  local t, cfg = {}, self.cfg
  --local t = tables.create(s:len())

  local LuaCards = const.Cards
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

  return tconcat(t)
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
    MatchCase  (bool) - Учёт регистра символов (@default = true).
    UseOnes    (bool) - Подсчёт по одиночным символам (@default = true).
    UseSeqs    (bool) - Подсчёт по последовательностям (@default = false).
    UseMagic   (bool) - Подсчёт по "магическим" модификаторам (@default = false).
    --
    Seq      (string) - Неанализируемое начало последовательности.
                        Длина анализируемой последовательности символов:
    SeqMin   (number) - минимальная (@default = 1).
    SeqMax   (number) - максимальная (@default = 1).
--]]
function unit.CharCounter (cfg) --> (object)
  local cfg = cfg or {}
  cfg.UseAlone = cfg.UseAlone == nil and true
  local CharEnum = cfg.CharEnum or "."

  local self = {
    cfg       = cfg,
    CharEnum  = CharEnum,
    CharsSet  = '.',
    Seq       = cfg.Seq or "",
    SeqMax    = cfg.SeqMax or 1,
    SeqMin    = cfg.SeqMin or 1,

    Count = {
      Total = 0,
      Ones  = cfg.Ones or {},
      Seqs  = cfg.Seqs or {},
      --Chars = cfg.Chars or {},
      Magic = cfg.Magic or {},
      Specs = cfg.Specs or {},
    }, -- Count

  } --- self

  if CharEnum ~= '.' then
    self.CharsSet = format(const.CharSetPat, CharEnum) -- Множество символов
  end

  -- Подготовка счётчиков:
  if cfg.UseMagic then
    local Magic = self.Count.Magic 
    local LuaClassList = const.ClassList
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
function TCharCounter:Char (c) --> (bool | nil)
  if c == nil then return end
  local cfg, Count = self.cfg, self.Count

  if cfg.MatchCase == false then c = c:lower() end

  Count.Total = Count.Total + 1
  if cfg.UseOnes then
    Count.Ones[c] = (Count.Ones[c] or 0) + 1
  end

  if cfg.UseMagic then
    -- Подсчёт по "магическим" модификаторам:
    local LuaClassList = const.ClassList
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

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
