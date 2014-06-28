--[[ UniUtf ]]--

----------------------------------------
--[[ description:
  -- UniUtf: Упаковка данных.
  -- UniUtf: Data packing.
--]]
----------------------------------------
--[[ uses:
  nil.
  -- group: UniUtf.
--]]
--------------------------------------------------------------------------------
--[[
# uniParse.tcl --
#
#	This program parses the UnicodeData file and generates the
#	corresponding tclUniData.c file with compressed character
#	data tables.  The input to this program should be the latest
#	UnicodeData file from:
#	    ftp://ftp.unicode.org/Public/UNIDATA/UnicodeData-Latest.txt
#
# Copyright (c) 1998-1999 by Scriptics Corporation.
# All rights reserved.
#
# RCS: @(#) $Id: uniParse.tcl,v 1.1.1.1 2003-03-14 06:53:37 santhosh Exp $
--]]
--------------------------------------------------------------------------------

local format = string.format

----------------------------------------
local bit = bit64
local band, bor = bit.band, bit.bor
--local bnot, bxor = bit.bnot, bit.bxor
local bshl = bit.lshift
--local bshl, bshr = bit.lshift, bit.rshift

local tostring = tostring
local io_open = io.open
local t_concat = table.concat

--------------------------------------------------------------------------------
--[[
    Используемый метод сжатия основан на следующем:
  В Unicode символы можно объединить в последовательности — страницы —
  в соответствии с выбранными правилами их обработки / использования.
  Поэтому, задав оптимальный размер страницы, можно сжать таблицу символов.
--]]
--------------------------------------------------------------------------------
local unit = {}

-- TODO: ???? Тест по всем символам Unicode: CP char toupper tolower totitle(?)!

---------------------------------------- Adds
-- Позиция элементов строки данных line
-- и её табличного представления items.
unit.udpos = {
  cp_string  = -1, -- * * -- Code Point string      -- строковое значение
  codepoint  =  1, -- N N -- Code Point (default)   -- № символа в Unicode
  charname   =  2, -- S N -- Name (<reserved>)
  category   =  3, -- E N -- General_Category (Cn)

  canoncomb  =  4, -- N N -- Canonical_Combining_Class (0)
  bidiclass  =  5, -- E N -- Bidi_Class (L, AL, R)

                   -- E N -- Decomposition_Type (None)
                   -- S   -- Decomposition_Mapping (=)
  decompose  =  6,

                   -- E N -- Numeric_Type (None)
                   -- N   -- Numeric_Value (Not a Number)
  numdecimal =  7,
  numandigit =  8,
  numnumeric =  9,

  bidimirror = 10, -- B N -- Bidi_Mirrored (N)
  uc10name   = 11, -- S I -- Unicode_1_Name (<none>)
  iso10646   = 12, -- S I -- ISO_Comment (<none>)

  toupper    = 13, -- S N -- Simple_Uppercase_Mapping (=)
  tolower    = 14, -- S N -- Simple_Lowercase_Mapping (=)
  totitle    = 15, -- S N -- Simple_Titlecase_Mapping (=)
} --

-- Параметры форматирования:
unit.format = {
  -- Вывод результата:
  indexshift = -1,     -- Сдвиг индекса
  lineindent = "    ", -- Отступ в строке
  valuesepar = ", ",   -- Разделитель значений
  maxlinelen = 70,     -- Максимальная длина строки
  maxlintlen = 65,     -- Максимальная длина строки для случая int
  newlinestr = "\n",   -- Переход на новую строку
} --

--[[
-- Hexadecimal string presentation of number.
-- 16-ричное строковое представление числа.
-- Default width for: Ox12345
local function hex (number, width) --> (string)
  return ("%#0"..tostring(width or 7).."x"):format(number or 0)
end
--]]

---------------------------------------- Code
--[[
    Number of bits of data within a page
  This value can be adjusted to find the best split to minimize table size.
    Число бит для данных внутри страницы.
  Может быть изменено для лучшего разбиения и минимизации размера таблицы.
--]]
--unit.shift = 5 -- Default 5
unit.shift = 5

--unit.NullLine = "FFFF;;Cn;0;ON;;;;;N;;;;;"
unit.NullLine = "10FFFF;;Co;0;L;;;;;N;;;;;"

--[[
    Map from page to page index.
  Each entry is an index into the pages table, indexed by page number.
    Карта отображения страницы на индекс страницы.
  Каждый элемент — индекс таблицы pages. Индекс элемента — номер страницы.
--]]
unit.pMap = {} -- Карта страниц

--[[
    Map from page index to page info.
  Each entry is a list of indices into the groups table,
  the list is indexed by the offset.
    Карта отображения индекса страницы на информацию о странице.
  Каждый элемент — список индексов таблицы groups.
  Индекс элемента — смещение (внутри страницы).
--]]
unit.pages = {} -- Страницы

--[[
    List of character info values, 
  indexed by group number,
  initialized with the unassigned character group.
    Список значений, задающих информацию о символе.
  Индекс элемента — номер группы.
  Список инициализируется группой для неназначенных символов.
--]]
unit.groups = {} -- Группы
unit.glists = {} -- Соответствующие им группы-списки разобранных значений

-- Сдвиг в Case Delta Type
unit.caseshift  =  5 -- для Case
unit.deltashift = 22 -- для Delta
--unit.typeshift  =  0 -- для Type

unit.UnassignedGroup = "1,0,0,0" -- Группа для неназначенных символов
unit.UnassignedGlist = { 1, 0, 0, 0 } -- Соответствующая ей группа-список

--[[
    Ordered list of character categories,
  must match the enumeration in the header file.
    Упорядоченный список категорий символов.
  Должен соответствовать перечислению в заголовочном файле.
--]]
unit.categories = {
  'Cn',
  'Lu', 'Ll', 'Lt', 'Lm', 'Lo',
  'Mn', 'Me', 'Mc',
  'Nd', 'Nl', 'No',
  'Zs', 'Zl', 'Zp',
  'Cc', 'Cf', 'Co', 'Cs',
  'Pc', 'Pd', 'Ps', 'Pe', 'Pi', 'Pf', 'Po',
  'Sm', 'Sc', 'Sk', 'So',
} --

do
  local cats = unit.categories
  for k = 1, #cats do cats[cats[k]] = k end
end -- do

--[[
    Count of the number of title case characters.
  This value is used in the regular expression code
  to allocate enough space for the title case variants.
    Количество символов в заголовочном регистре.
  Это значение используется в коде регулярного выражения
  при выделении достаточного места для вариантов заголовочного регистра.
--]]
unit.TitleCount = 0
----------------------------------------
--local NumberFmt = '%4d'

-- Получение только необходимой информации о символе.
--[[
  -- @params:
  items  (table) - элементы разобранной строки с информацией о символе.
  index (number) - "кодовая точка" символа (Code Point).
  -- @return:
  (string) - строка с необходимой информацией.
  (table)  - таблица с необходимой информацией:
    (string) - категория символа.
    (number) - delta для символа в верхнем регистре.
    (number) - delta для символа в нижнем регистре.
    (number) - delta для символа в заголовочном регистре.
--]]
do
  local cats = unit.categories

function unit.getValue (items, index)
  local udpos = unit.udpos

  local category = items[udpos.category]
  local catIndex = cats[category] or 1
  --far.Show(index, category, catIndex)
  --[[
  if catIndex == nil then
    --error(("Unexpected character category: %d(%s)"):
    --format(index, category or ""))
    catIndex = 1
  else
  --]]
  if category == 'Lt' then
    unit.TitleCount = unit.TitleCount + 1
  end
  --end

  local ToUpper = items[udpos.toupper]
  ToUpper = ToUpper and index - ToUpper or 0
  local ToLower = items[udpos.tolower]
  ToLower = ToLower and ToLower - index or 0
  local ToTitle = items[udpos.totitle]
  ToTitle = ToTitle and index - ToTitle or 0

  local Result = {
    catIndex,
    tostring(ToUpper),
    tostring(ToLower),
    tostring(ToTitle),
  } ---
  return t_concat(Result, ','),
         { catIndex, ToUpper, ToLower, ToTitle }
end ---- getValue

end -- do

-- Формирование/Получение только необходимой информации о символе.
--[[
  -- @params:
  value (string) - строка с необходимой информацией.
  list   (table) - таблица с необходимой информацией.
  -- @return:
  (number) - индекс строки в groups.
--]]
function unit.getGroup (value, list)
  local groups = unit.groups
  local index = groups[value]

  if index == nil then
    index = #groups + 1
    groups[value] = index
    groups[index] = value
    unit.glists[index] = list

    --[[ -- DEBUG only
    if index < 0xF then
      far.Show(index, value, unpack(list))
    end
    --]]
  end

  return index
end ---- getGroup

-- Поэлементное сравнение таблиц.
--[[
  -- @params:
  t  (table) - первая таблица.
  u  (table) - вторая таблица.
  n (number) - количество сравниваемых элементов.
  -- @return:
  res (bool) - результат сравнения.
--]]
local min = math.min
local function cmpTable (t, u, n)
  for k = 1, n or min(#t, #u) do
    if t[k] ~= u[k] then
      return false
    end
  end

  return true
end -- cmpTable

-- Добавление/Получение страницы по информации.
--[[
  -- @params:
  info (table) - информация о символах на странице.
  -- @return:
  (number) - индекс инфрмации в pages.
--]]
function unit.addPage (info)
  local pMap  = unit.pMap
  local pages = unit.pages
  local index = -1

  -- Поиск по pages.
  for k = 1, #pages do
    if cmpTable(pages[k], info) then
      index = k
      break
    end
  end

  if index == -1 then
    index = #pages + 1
    pages[index] = info
  end

  pMap[#pMap + 1] = index
  return index
end ---- addPage

-- Очистка.
function unit.clearParse ()
  unit.pMap   = {}
  unit.pages  = {}
  unit.groups = { unit.UnassignedGroup; [unit.UnassignedGroup] = 1 }
  unit.glists = { unit.UnassignedGlist }
  unit.TitleCount = 0
  unit.twosh = bshl(1, unit.shift) -- 2^shift
  -- Маска для отбора символов на странице.
  unit.mask  = unit.twosh - 1      -- 2^shift - 1
end ---- clearParse

-- Преобразование строки с числом в число.
--[[
  -- @params:
  s (string) - строка с возможным числом.
  -- @return:
  (number) - полученное число.
--]]
local function toNumber (s) --> (number|string)
  if s and s:find("^%x%x%x%x") then
    return tonumber(s, 16)
  end
end --

-- Разбор строки данных в таблицу.
--[[
  -- @params:
  line (string) - строка файла данных.
  -- @return:
  (table) - таблица из элементов строки.
--]]
function unit.splitLine (line)
  local udpos = unit.udpos

  -- Поэлементный разбор строки.
  local items = { ( line:match("^([^;]+);") ), }
  for s in line:gmatch(";([^;]*)") do items[#items + 1] = s end

  -- Строковое представление Code Point.
  items[udpos.cp_string] = items[udpos.codepoint]
  -- Преобразование некоторых элементов в число.
  items[udpos.codepoint] = toNumber(items[udpos.codepoint])
  items[udpos.toupper]   = toNumber(items[udpos.toupper])
  items[udpos.tolower]   = toNumber(items[udpos.tolower])
  items[udpos.totitle]   = toNumber(items[udpos.totitle])

  return items
end ---- splitLine

do
  local addPage = unit.addPage

-- Построение таблиц.
--[[
  -- @params:
  data (string) - содержимое файла данных.
--]]
function unit.buildTables (data)
  unit.clearParse()

  local udpos = unit.udpos
  --local shift = unit.shift
  local mask  = unit.mask
  local NullLine = unit.NullLine

  -- Информация о символах на странице.
  local info = {} -- temporary page info
  -- Последний необработанный символ.
  local cpgap = 0 -- next

  local sn = -1
  -- Построчный разбор кодовых точек.
  for s in data:gmatch("([^\n]*)\n") do
    local line = (s == nil or s == "") and NullLine or s
    sn = sn + 1
    local items = unit.splitLine(line)
    --far.Show(unpack(items))
    --far.Show(line, items[udpos.cp_string], unpack(items))

    local index = items[udpos.codepoint]
    local gIndex = unit.getGroup(unit.getValue(items, index))

    --[[
        Since the input table omits unassigned characters,
      these will show up as gaps in the index sequence.
      There are a few special cases where the gaps
      correspond to a uniform block of assigned characters.
      These are indicated as such in the character name.
        Так как в исходной таблице пропущены неназначенные символы,
      они будут показаны как провалы в последовательности index.
      Кроме того, есть случаи, когда "провалы" соответствуют
      единообразному блоку назначенных символов.
      Это специально указывается в названии символа.
    --]]

    -- Enter all unassigned characters up to the current character.
    -- Ввод всех неназначенных символов выше текущего символа.
    if index > cpgap and not items[udpos.charname]:find("Last>$") then
       while cpgap < index do
         info[#info + 1] = 1
         -- Учёт перехода на следующую страницу.
         if band(cpgap, mask) == mask then
            addPage(info)
            info = {}
         end
         cpgap = cpgap + 1
       end
    end

    -- Enter all assigned characters up to the current character
    -- Ввод всех назначенных символов выше текущего символа.
    local k = cpgap
    while k <= index do
      info[#info + 1] = gIndex
      -- Учёт перехода на следующую страницу.
      if band(k, mask) == mask then
         addPage(info)
         info = {}
      end
      k = k + 1
    end

    cpgap = index + 1

    -- TODO: Check code:
    --if index >  0xFFFC then addPage(info); break end -- OK
    --if index >  0xFFFD then addPage(info); break end -- NO
    --if index >= 0xFFFF then addPage(info); break end -- NO
    --if index >  0xFFFF then addPage(info); break end -- NO
    --if index >  0x0FFFF then addPage(info); break end -- NO
    --if index >  0x10300 then addPage(info); break end -- NO
    --if index >= 0x10301 then addPage(info); break end -- NO
    --if index >= 0x10400 then addPage(info); break end -- NO
    --if index >= 0x1D000 then addPage(info); break end -- NO
    --if index >= 0x20000 then addPage(info); break end -- NO
    --if index >= 0xE0000 then addPage(info); break end -- NO
    --if index >= 0xF0000 then addPage(info); break end -- NO
  end
  --[[ -- DEBUG only
  --far.Show(unpack(unit.pMap))
  --for k = 1, #unit.pages do far.Show(k, unpack(unit.pages[k])) end
  --far.Show(unpack(unit.groups))
  --for k = 1, #unit.pages do far.Show(k, unpack(unit.glists[k])) end
  --]]
end ---- buildTables

end -- do

-- Загрузка данных из файла.
--[[
  -- @params:
  filename (string) - полный путь файла данных.
  -- @return:
  (string) - содержимое файла.
--]]
function unit.loadData (filename) --> (string|nil)
  local f = io_open(filename, 'r')
  if f == nil then return end
  local data = f:read('*a')

  f:close()
  return data
end ---- loadData

-- Формирование pageMap.
function unit.make_pageMap ()
  local fmt = unit.format
  local indexshift = fmt.indexshift
  local lineindent = fmt.lineindent
  local valuesepar = fmt.valuesepar
  local maxlinelen = fmt.maxlinelen

  local indlen = lineindent:len()
  local seplen = valuesepar:len()

  local pMap = unit.pMap

  local t = { lineindent }
  local len = indlen
  local last = #pMap

  for k = 1, last do
    local s = tostring(pMap[k] + indexshift)
    len = len + s:len()
    t[#t + 1] = s

    -- Разделитель значений.
    if k ~= last then
      len = len + seplen
      t[#t + 1] = valuesepar
    end

    -- Переход на новую строку.
    if len > maxlinelen then
      len = indlen
      t[#t + 1] = fmt.newlinestr
      t[#t + 1] = lineindent
    end
  end

  return t_concat(t)
end ---- make_pageMap

-- Формирование groupMap.
function unit.make_groupMap ()
  local fmt = unit.format
  local indexshift = fmt.indexshift
  local lineindent = fmt.lineindent
  local valuesepar = fmt.valuesepar
  local maxlinelen = fmt.maxlinelen

  local indlen = lineindent:len()
  local seplen = valuesepar:len()

  local pages = unit.pages

  local t = { lineindent }
  local len = indlen
  local last_i = #pages

  for i = 1, last_i do
    local page = pages[i]
    local last_j = #page

    for j = 1, last_j do
       local s = tostring(page[j] + indexshift)
       len = len + s:len()
       t[#t + 1] = s

       -- Разделитель значений.
       if i ~= last_i or j ~= last_j then
         len = len + seplen
         t[#t + 1] = valuesepar
       end

       -- [[
       -- Переход на новую строку.
       if len > maxlinelen then
         len = indlen
         t[#t + 1] = fmt.newlinestr
         t[#t + 1] = lineindent
       end
       --]]
    end
    --[[ -- DEBUG only
    -- Переход на новую строку.
    len = indlen
    t[#t + 1] = fmt.newlinestr
    t[#t + 1] = lineindent
    --]]
  end

  return t_concat(t)
end ---- make_groupMap

-- Формирование частей элемента groups.
--[[
  -- @params:
  list (table) - таблица с необходимой информацией (см. unit.getValue).
  -- @return:
  (number) - значение Case.
  (number) - значение Delta.
--]]
function unit.make_gitempart (list)
  local _, ToUpper, ToLower, ToTitle = unpack(list)

  if ToTitle ~= 0 then
    if ToTitle == ToUpper then
      return 4, ToUpper -- 100 -- subtract delta for title or upper
    elseif ToUpper ~= 0 then
      return 5, ToUpper -- 101 -- subtract delta for upper, subtract 1 for title
    else
      return 3, ToLower -- 011 -- add delta for lower, add 1 for title
    end
  else
    if ToUpper ~= 0 then
      return 6, ToUpper -- 110 -- subtract delta for upper, add delta for lower
    elseif ToLower ~= 0 then
      return 2, ToLower -- 010 -- add delta for lower
    else
      return 0, 0       -- 000 -- noop
    end
  end
end ---- make_gitempart

do
  local fmt = unit.format
  local indexshift = fmt.indexshift

  local caseshift  = unit.caseshift
  local deltashift = unit.deltashift
  --local typeshift  = unit.typeshift
  local make_gitempart = unit.make_gitempart

-- Формирование элемента groups.
--[[
  -- @params:
  list (table) - таблица с необходимой информацией (см. unit.getValue).
  -- @return:
  (number) - значение Case Delta Type.
--]]
function unit.make_gitem (list)
  local Type = list[1] + indexshift
  local Case, Delta = make_gitempart(list)
  return bor(bshl(Delta, deltashift),
             bshl(Case, caseshift),
             --bshl(Type, typeshift),
             Type) -- no shift for type
end ---- make_gitem

end -- do

-- Формирование groups.
function unit.make_groups ()
  local fmt = unit.format
  local lineindent = fmt.lineindent
  local valuesepar = fmt.valuesepar
  local maxlinelen = fmt.maxlintlen

  local indlen = lineindent:len()
  local seplen = valuesepar:len()

  local glists = unit.glists
  local make_gitem = unit.make_gitem

  local t = { lineindent }
  local len = indlen
  local last = #glists

  for k = 1, last do
    local s = tostring(make_gitem(glists[k]))
    len = len + s:len()
    t[#t + 1] = s

    -- Разделитель значений.
    if k ~= last then
      len = len + seplen
      t[#t + 1] = valuesepar
    end

    -- [[
    -- Переход на новую строку.
    if len > maxlinelen then
      len = indlen
      t[#t + 1] = fmt.newlinestr
      t[#t + 1] = lineindent
    end
    --]]
  end

  return t_concat(t)
end ---- make_groups

-- Сохранение результата.
--[[
  -- @params:
  filename (string) - полный путь файла-результата.
  text      (table) - общий текст файла-результата.
--]]
function unit.saveResult (filename, text)
  local f = io_open(filename, 'w')
  if f == nil then return end

  -- Начало.
  f:write(text.license)
  f:write(text.start)
  -- Вывод shift.
  f:write(tostring(unit.shift))
  f:write(unit.format.newlinestr)
  -- Вывод pageMap по pMap.
  f:write(text.pageMap)
  f:write(unit.make_pageMap())
  -- Вывод groupMap по pages.
  f:write(text.groupMap)
  f:write(unit.make_groupMap())
  -- Вывод groups по groups.
  f:write(text.groups)
  f:write(unit.make_groups())
  -- Конец.
  f:write(text.categories)
  f:write(text.finis)

  f:close()
  return true
end ---- saveResult

do
  --far.Show(...)
  --local args = { ... }

  local utils = require 'context.utils.useUtils'
  local BasePath = utils.ProfilePath

  local DataPath = "data\\scripts\\Rh_Scripts\\data\\"
  local DataName = "UnicodeData.txt"
  local CodeName = "slnudata.c"

function unit.main ()
  -- Загрузка данных.
  local FileName = format("%s%s%s", BasePath, DataPath, DataName)
  local data = unit.loadData(FileName)
  if data == nil then
    error(("File not found: %s"):format(FileName))
  end
  --far.Show(data)

  -- Построение таблиц.
  unit.buildTables(data.."\n")

  --[[ -- Result information
  local size = #unit.pMap + #unit.pages * unit.twosh
  local info = {
    "#pMap   = "..tostring(#unit.pMap),
    "#pages  = "..tostring(#unit.pages),
    "#groups = "..tostring(#unit.groups),
    "shift = "..tostring(unit.shift),
    "2^sh… = "..tostring(unit.twosh),
    "size  = "..tostring(size),
    "title case count = "..tostring(unit.TitleCount),
  } ---
  far.Show(unpack(info))
  --]]

  -- Сохранение результата.
  FileName = format("%s%s%s", BasePath, DataPath, CodeName)
  unit.saveResult(FileName, unit.text.c)

  return
end ----

end -- do

---------------------------------------- text
-- Общий текст файла-результата.
local text = {}
unit.text = text

---------------------------------------- C language
local _c = {}

_c.license = [[
/* license.terms
This software is copyrighted by the Regents of the University of
California, Sun Microsystems, Inc., Scriptics Corporation, ActiveState
Corporation and other parties.  The following terms apply to all files
associated with the software unless explicitly disclaimed in
individual files.

The authors hereby grant permission to use, copy, modify, distribute,
and license this software and its documentation for any purpose, provided
that existing copyright notices are retained in all copies and that this
notice is included verbatim in any distributions. No written agreement,
license, or royalty fee is required for any of the authorized uses.
Modifications to this software may be copyrighted by their authors
and need not follow the licensing terms described here, provided that
the new terms are clearly indicated on the first page of each file where
they apply.

IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
MODIFICATIONS.

GOVERNMENT USE: If you are acquiring this software on behalf of the
U.S. government, the Government shall have only "Restricted Rights"
in the software and related documentation as defined in the Federal 
Acquisition Regulations (FARs) in Clause 52.227.19 (c) (2).  If you
are acquiring the software on behalf of the Department of Defense, the
software shall be classified as "Commercial Computer Software" and the
Government shall have only "Restricted Rights" as defined in Clause
252.227-7013 (c) (1) of DFARs.  Notwithstanding the foregoing, the
authors grant the U.S. Government and others acting in its behalf
permission to use and distribute the software in accordance with the
terms specified in this license. 
*/
]] --

_c.start = [[
 * tclUniData.c --
 *
 *	Declarations of Unicode character information tables.  This file is
 *	automatically generated by the tools/uniParse.tcl script.  Do not
 *	modify this file by hand.
 *
 * Copyright (c) 1998 by Scriptics Corporation.
 * All rights reserved.
 *
 * RCS: @(#) $Id$
 */

/*
 * A 16-bit Unicode character is split into two parts in order to index
 * into the following tables.  The lower OFFSET_BITS comprise an offset
 * into a page of characters.  The upper bits comprise the page number.
 */

#define OFFSET_BITS ]]

_c.pageMap = [[
/*
 * The pageMap is indexed by page number and returns an alternate page number
 * that identifies a unique page of characters.  Many Unicode characters map
 * to the same alternate page number.
 */

static unsigned char pageMap[] = {
]] --

_c.groupMap = [[

};

/*
 * The groupMap is indexed by combining the alternate page number with
 * the page offset and returns a group number that identifies a unique
 * set of character attributes.
 */

static unsigned char groupMap[] = {
]] --

_c.groups = [[

};

/*
 * Each group represents a unique set of character attributes.  The attributes
 * are encoded into a 32-bit value as follows:
 *
 * Bits 0-4	Character category: see the constants listed below.
 *
 * Bits 5-7	Case delta type: 000 = identity
 *				 010 = add delta for lower
 *				 011 = add delta for lower, add 1 for title
 *				 100 = sutract delta for title/upper
 *				 101 = sub delta for upper, sub 1 for title
 *				 110 = sub delta for upper, add delta for lower
 *
 * Bits 8-21	Reserved for future use.
 *
 * Bits 22-31	Case delta: delta for case conversions.  This should be the
 *			    highest field so we can easily sign extend.
 */

static int groups[] = {
]] --

_c.categories = [[

};

/*
 * The following constants are used to determine the category of a
 * Unicode character.
 */

#define UNICODE_CATEGORY_MASK 0X1F

enum {
    UNASSIGNED,
    UPPERCASE_LETTER,
    LOWERCASE_LETTER,
    TITLECASE_LETTER,
    MODIFIER_LETTER,
    OTHER_LETTER,
    NON_SPACING_MARK,
    ENCLOSING_MARK,
    COMBINING_SPACING_MARK,
    DECIMAL_DIGIT_NUMBER,
    LETTER_NUMBER,
    OTHER_NUMBER,
    SPACE_SEPARATOR,
    LINE_SEPARATOR,
    PARAGRAPH_SEPARATOR,
    CONTROL,
    FORMAT,
    PRIVATE_USE,
    SURROGATE,
    CONNECTOR_PUNCTUATION,
    DASH_PUNCTUATION,
    OPEN_PUNCTUATION,
    CLOSE_PUNCTUATION,
    INITIAL_QUOTE_PUNCTUATION,
    FINAL_QUOTE_PUNCTUATION,
    OTHER_PUNCTUATION,
    MATH_SYMBOL,
    CURRENCY_SYMBOL,
    MODIFIER_SYMBOL,
    OTHER_SYMBOL
};
]] --

_c.finis = [=[

/*
 * The following macros extract the fields of the character info.  The
 * GetDelta() macro is complicated because we can't rely on the C compiler
 * to do sign extension on right shifts.
 */

#define GetCaseType(info) (((info) & 0xE0) >> 5)
#define GetCategory(info) ((info) & 0x1F)
#define GetDelta(info) (((info) > 0) ? ((info) >> 22) : (~(~((info)) >> 22)))

/*
 * This macro extracts the information about a character from the
 * Unicode character tables.
 */

#define GetUniCharInfo(ch) (groups[groupMap[(pageMap[(((int)(ch)) & 0xffff) >> OFFSET_BITS] << OFFSET_BITS) | ((ch) & ((1 << OFFSET_BITS)-1))]])

]=] --

text.c = _c
--------------------------------------------------------------------------------
--return unit
unit.main()
--------------------------------------------------------------------------------
