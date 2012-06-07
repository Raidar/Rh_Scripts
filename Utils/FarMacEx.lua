--[[ FAR Macros Extension ]]--

----------------------------------------
--[[ description:
  -- Working with FAR macro aliases.
  -- Работа с псевдонимами макросов FAR.
--]]
----------------------------------------
--[[ based on:
  FarMacEx.
  (FAR manager Macros using Extension utility.)
  (c) 2009+, A.I. Rakhmatullin.
  Home: http://pmi-rai.narod.ru/Programs/FarUtils.htm
--]]
--[[ uses:
  Rh Utils.
  -- used in: LUM.
  -- group: Macros, Utils.
--]]
--------------------------------------------------------------------------------

local ipairs, pairs = ipairs, pairs

----------------------------------------
--local context = context

local strings = require 'context.utils.useStrings'

----------------------------------------
--local luaUt = require "Rh_Scripts.Utils.luaUtils"

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Unqoute
-- Раскавычивание строки.
--[[ При UnEscape == true выполняется
     исключение escape-последовательностей вида \\ и \". ]]
function unit.UnQuoteRegStr (s, UnEscape, QuoteChar) --> (string)
  UnEscape = UnEscape == nil and true or UnEscape
  QuoteChar = QuoteChar or '"'
  if not s then return nil end -- Нет строки

  local r = s
  -- Исключение внешних кавычек ('"').
  if r:sub( 1,  1) == QuoteChar then r = r:sub(2, -1) end -- в начале
  if r:sub(-1, -1) == QuoteChar then r = r:sub(1, -2) end -- в конце

  -- Исключение escape-последовательностей вида \\ и \".
  if UnEscape then r = r:gsub('\\([\\"])', "%1") end
  return r
end ----

do
  local UnQuoteRegStr = unit.UnQuoteRegStr

-- Раскавычивание поля таблицы: имени ключа и его значения.
function unit.UnQuoteRegField (t, f) --| "Key"="Value" --> Key=Value
  if not t or not f or not t[f] then return t end -- Нет поля

  -- Раскавычивание ключа.
  local Key = UnQuoteRegStr(f, false)
  if not Key or Key == "" then return t end -- Нет ключа

  -- Раскавычивание значения ключа.
  local Value = UnQuoteRegStr(t[f], true)

  -- Замена поля в таблице.
  t[Key], t[f] = Value, nil -- Замена
end ----

end -- do

do
  local UnQuoteRegField = unit.UnQuoteRegField

-- Раскавычивание всех полей таблицы.
function unit.UnQuoteRegTable (t) --> (table)
  if not t then return end -- Нет таблицы

  -- Выборка полей по имени ключа.
  local f = {} -- Поля
  for k, _ in pairs(t) do f[#f+1] = k end

  -- Раскавычивание полей таблицы.
  for _, v in ipairs(f) do UnQuoteRegField(t, v) end
end ----

end -- do

---------------------------------------- Parse
-- Позиция Delim в S с учётом наличия завершающей скобки.
--[[ nil -- если достигнут конец строки (возможно, ошибка).]]
local function TailStrDelimPos (s, Delim) --> (number | nil)
  return s:cfind(Delim, 1, true) or s:cfind(")", 1, true)
end --

-- Позиция Delim в s с позиции Pos с учётом вложенных скобок,
-- строк в кавычках, escape-символа и завершающей скобки.
--[[ nil -- если достигнут конец строки (возможно, ошибка).]]
local function DataStrDelimPos (s, Delim, Pos) --> (number | nil)
  local Result = Pos -- Результат поиска
  local SLen = s:len() -- Длина строки
  local PairNestLevel = 0 -- Уровень вложенности скобок
  local QuotePresence = false -- Признак строки в кавычках
  local Char -- Текущий обрабатываемый символ

  while Result <= SLen do -- Цикл по строке
    Char = s:sub(Result, Result) -- Подстрока

    -- Анализ текущего символа
    if Char == '\\' then -- Escape: \
      Result = Result + 1 -- Пропуск escape
      if Result > SLen then return nil end
    elseif Char == '"' then -- Парные кавычки: "
      QuotePresence = not QuotePresence
    elseif Char == '(' then -- Открывающая скобка: (
      if not QuotePresence then PairNestLevel = PairNestLevel + 1 end
    elseif Char == ')' then -- Закрывающая скобка: )
      if not QuotePresence then
        if PairNestLevel > 0 then PairNestLevel = PairNestLevel - 1
        else return Result end -- Завершающая скобка
      end
    elseif Char == Delim then -- Требуемый разделитель
      if PairNestLevel == 0 and not QuotePresence then return Result end
    end -- if

    Result = Result + 1 -- Следующий символ
  end -- Цикл по строке

  if Result <= SLen then return Result end
end -- DataStrDelimPos

---------------------------------------- Specify
do
  local makeplain = strings.makeplain

-- Replace a plain-pattern in string.
-- Замена plain-шаблона в строке.
local function replace (s, pat, repl, n) --> (string)
  return s:gsub(makeplain(pat), makeplain(repl), n)
end ----

-- Конкретизация упрощённого псевдонима.
function unit.SpecifySimpledAlias (s, Name, Value) --> (string)
  return replace(s, Name, Value) -- Замена всех вхождений
end ----

-- Конкретизация параметризованного псевдонима.
function unit.SpecifyParamedAlias (s, Name, Value, Index) --> (string)
  --logShow({ s = s, pat = Name, repl = Value }, Index)
  -- Поиск первого вхождения псевдонима.
  local Alias = {} -- Информация для работы с псевдонимом
  Alias.Name = Name:sub(1, Index) -- Имя псевдонима (без параметров)
  Alias.Pos = s:cfind(Alias.Name, 1, true) -- Позиция псевдонима в строке
  if not Alias.Pos then return s end -- Нет псевдонима.

  local Actual = {} -- Информация для работы с целевой строкой
  local Formal = {} -- Информация для работы по конкретизации
  Actual.Str = s -- Обрабатываемая строка
  local Result = "" -- Результат конкретизации

  while Alias.Pos do -- Цикл по вхождениям
    Alias.Data = Value
    Alias.Tail = Name:sub(Index + 1, -1)
    -- Определение позиции начала первых параметров.
    Formal.Pos = TailStrDelimPos(Alias.Tail, ',')
    Actual.Pos = Alias.Pos + Alias.Name:len() - 1
    if Actual.Pos >= Actual.Str:len() then break end -- Ошибка ?!
    Actual.Present = false -- Признак наличия фактических параметров

    while Formal.Pos do -- Цикл по формальным параметрам
      -- Получение формального параметра.
      Formal.Par = (Alias.Tail:sub(1, Formal.Pos - 1)):match("^%s*(.-)%s*$")
      -- Исключение выделенного параметра.
      Alias.Tail = Alias.Tail:sub(Formal.Pos + 1, -1)
      -- Получение фактического параметра.
      if not Actual.Present then
        Actual.Old = Actual.Pos + 1 -- Старая позиция параметра
        Actual.Pos = DataStrDelimPos(Actual.Str, ",", Actual.Old);
        if not Actual.Pos then Actual.Pos = 0; break end -- Ошибка ?!
        Actual.Present = Actual.Str:sub(Actual.Pos, Actual.Pos) ~= ','
        Actual.Par = Actual.Str:sub(Actual.Old, Actual.Pos - 1)
      else -- Значение по умолчанию
        Actual.Par = "0"
      end -- if
      -- Замена формального параметра на фактический.
      --[[
      if s == '$Tpl.PairTagX(\"<a href=\\\"\", \"\\\"></a>\",4)' then
        logShow({ s, Name, Value, Alias, Formal, Actual,
                  strings.makeplain(Formal.Par),
                  strings.makeplain(Actual.Par) }, "Paramed")
      end
      --]]
      Alias.Data = replace(Alias.Data, Formal.Par, Actual.Par)
      -- Поиск следующего формального параметра.
      Formal.Pos = TailStrDelimPos(Alias.Tail, ",")
    end -- while

    -- Выполнение замены конкретизированного псевдонима.
    -- DONE: Вариант srSource
    Result = Result..Actual.Str:sub(1, Alias.Pos - 1)..Alias.Data
    Actual.Str = Actual.Str:sub(Actual.Pos + 1, -1)
    -- Поиск следующего вхождения псевдонима.
    Alias.Pos = Actual.Str:cfind(Alias.Name, 1, true)
  end -- while

  return Result..Actual.Str
end ---- SpecifyParamedAlias

end -- do

-- Конкретизация заданного псевдонима.
function unit.SpecifyDefinedAlias (s, Name, Value) --> (string)
  local Index = Name:cfind("(", 1, true)
  if Index then
    return unit.SpecifyParamedAlias(s, Name, Value, Index)
  else
    return unit.SpecifySimpledAlias(s, Name, Value)
  end
end ---- SpecifyDefinedAlias

----------------------------------------
do
  local SpecifyDefinedAlias = unit.SpecifyDefinedAlias

-- Конкретизация псевдонимов Aliases.
function unit.SpecifyAliases (s, Aliases) --> (string)
  local r = s
  for k, v in pairs(Aliases) do
    --logShow({ r, k, v }, "SpecifyAliases")
    r = SpecifyDefinedAlias(r, k, v)
  end

  return r
end ---- SpecifyAliases

-- Конкретизация псевдонимов Aliases в самих псевдонимах.
function unit.SpecifyAliasesItself (Aliases)
  for i, v in pairs(Aliases) do -- Цикл по псевдонимам
    for j, w in pairs(Aliases) do -- Перебор в других псевдонимах
      -- Конкретизация заданного псевдонима:
      if j ~= i then Aliases[j] = SpecifyDefinedAlias(w, i, v) end
    end
  end
end --- SpecifyAliasesItself

end -- do

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
