--[[ Menu utils ]]--

----------------------------------------
--[[ description:
  -- Working with menus and menu items.
  -- Работа с меню и пунктами меню.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils.
  -- group: Menus, Utils.
--]]
--------------------------------------------------------------------------------

local type = type
local pairs = pairs

----------------------------------------
--local bit = bit64

----------------------------------------
local far = far
local F = far.Flags

local farColors = far.Colors

----------------------------------------
--local context = context

local strings = require 'context.utils.useStrings'
local numbers = require 'context.utils.useNumbers'
local utils = require 'context.utils.useUtils'
local tables = require 'context.utils.useTables'
local colors = require 'context.utils.useColors'

local isFlag, addFlag, delFlag = utils.isFlag, utils.addFlag, utils.delFlag

local t_create, t_concat = tables.create, table.concat

----------------------------------------
--local luaUt = require "Rh_Scripts.Utils.luaUtils"
local farUt = require "Rh_Scripts.Utils.farUtils"
local keyUt = require "Rh_Scripts.Utils.keyUtils"

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Flags
local ShowAmper = F.FMENU_SHOWAMPERSAND
local DirAutoHL = F.FMENU_AUTOHIGHLIGHT
local RevAutoHL = F.FMENU_REVERSEAUTOHIGHLIGHT

---------------------------------------- Menu Item
-- Проверки на специфические пункты меню.

local isItem = {
  -- Недоступный (для управления) пункт меню.
  Dimmed = function (item) return item.separator or item.disable end,
  -- Доступный (для навигации, но не выбора) пункт меню.
  Passed = function (item) return item.grayed end,
  -- Доступный (для выбора, но не навигации) пункт меню.
  Picked = function (item) return item.hidden or item.dummy end,
  Unused = 0,
  Speced = 0,
} --- isItem
unit.isItem = isItem

-- Недоступный (для выбора) пункт меню.
isItem.Unused = function (item)
  return isItem.Dimmed(item) or isItem.Passed(item)
end
local isItemUnused = isItem.Unused

-- Специфический (произвольный) пункт меню.
isItem.Speced = function (item)
  return isItem.Dimmed(item) or
         isItem.Passed(item) or
         isItem.Picked(item) -- Все!
end ----
local isItemSpeced = isItem.Speced

local defnocheck = " " -- space
local defchecked = "√" -- 0x221A

-- Item check character.
-- Символ метки пункта.
--[[
  -- @params:
  checked   (b|s) - признак / символ метки.
  default (c|nil) - символ метки по умолчанию.
  nocheck (c|nil) - символ неметки по умолчанию.
--]]
function unit.checkedChar (checked, default, nocheck) --> (char)
  if not checked then return nocheck or defnocheck end
  return checked ~= true and checked:sub(1, 1) or default or defchecked
end ----

---------------------------------------- Menu Keys
local SKeyToName = keyUt.SKeyToName
local NameToSKey = keyUt.NameToSKey

-- Form key for item.
-- Формирование клавиши для пункта.
--[[
  -- @params:
  Item        - пункт меню.
  StrKey      - полное имя клавиши.
  AbbrKey     - краткое имя клавиши.
  isFullName  - признак полного имени.
  -- @return:
  Item[StrKey]   - полное строковое представление.
  Item[AbbrKey]  - полное / краткое строковое представление.
--]]
function unit.MakeItemKey (Item, StrKey, AbbrKey, isFullName)
  if Item[StrKey] then
    --if Item[AbbrKey] then return end -- TEST:
    if Item[AbbrKey] or Item[StrKey] == "" then return end
    Item[AbbrKey] = isFullName and Item[StrKey] or NameToSKey(Item[StrKey])
    --if Item[AbbrKey] == "" then Item[AbbrKey] = nil; return end -- TEST

  else -- no StrKey
    local SKey = Item[AbbrKey]
    if SKey == "" then Item[AbbrKey] = nil end -- TEST
    if not SKey then Item[StrKey] = ""; return end
    Item[StrKey] = SKeyToName(SKey)
    if isFullName then Item[AbbrKey] = Item[StrKey] end
  end  -- if StrKey

  --logShow(Item[AbbrKey], Item[StrKey], "xv8")
end ---- MakeItemKey

-- Формирование AccelKey для пункта.
function unit.MakeAccelKey (Item, isFullName) --| AccelKey & AccelStr
  if Item.AccelStr == "" then return end
  unit.MakeItemKey(Item, "AccelKey", "AccelStr", isFullName)
  --logShow(Item.AccelKey, Item.AccelStr, "xv8")
end ---- MakeAccelKey

-- Parse menu items keys.
-- Разбор клавиш пунктов меню.
--[[
  -- @params:
  Items     - список пунктов.
  Count     - число пунктов.
  StrKey    - поле полного имени клавиши.
--]]
function unit.ParseMenuItemsKeys (Items, Count, StrKey) --> (Keys)
  local Keys, StrKey = {}, StrKey or "AccelKey"

  for k = 1, Count or (Items and #Items or 0) do
    local Item = Items[k]
    if not isItemUnused(Item) then
      local Key = Item[StrKey]
      if Key then Keys[Key] = k end
    end
  end

  return Keys
end ---- ParseMenuItemsKeys

-- Parse menu handle keys.
-- Разбор клавиш обработки меню.
--[[
  -- @params:
  HandleKeys (table) - список клавиш вида: { BreakKey = "<key>", ... }
--]]
function unit.ParseMenuHandleKeys (HandleKeys) --> (BreakKeys)
  local BKeys = {}

  for i = 1, HandleKeys and #HandleKeys or 0 do
    local Key = HandleKeys[i]
    if Key.BreakKey then BKeys[Key.BreakKey] = i end
  end

  return BKeys
end ---- ParseMenuHandleKeys

---------------------------------------- Hot Chars
-- Get matching hot letter from text.
-- Получение подходящей горячей буквы текста.
function unit.TextAutoHotChar (text, hots) --> (pos, char | nil, nil)
  for k = 1, text:len() do
    local c = text:sub(k, k):upper() -- Текущий символ
    if c ~= ' ' and not hots:find(c, 1, true) then
      return k, c -- Любой подходящий символ кроме пробела
    end
  end
end ---- TextAutoHotChar

-- Get matching item hot letter.
-- Получение подходящей горячей буквы пункта.
function unit.GetAutoHotChar (item, pos, hots) --> (pos, char | nil, nil)
  if isItemSpeced(item) then return end -- Спец. пункт

  local c = hots:sub(pos, pos) or ' '
  if c ~= ' ' then return end -- Есть горячая буква

  return unit.TextAutoHotChar(item.text, hots) -- Подходящая буква
end ---- GetAutoHotChar

do
  local sat, ins = strings.sat, strings.ins

-- Set hot letter to item text.
-- Установка горячей буквы в текст пункта.
function unit.SetAutoHotChar (item, pos, hots) --> (string)
  local pos, c = unit.GetAutoHotChar(item, pos, hots)
  if not pos then return hots end -- Без горячей буквы

  -- Определение и назначение найденной подходящей буквы
  item.text = ins(item.text, pos, '&') -- Задание

  return sat(hots, pos, c) -- Обновление HotChars
end ---- SetAutoHotChar

end -- do

do
  local ParseHotText = farUt.ParseHotText

-- Get hot letters string from items text.
-- Получение строки горячих букв из текста пунктов.
function unit.GetMenuHotChars (Items, Count) --> (string | "")
  --local t = {} -- Список горячих букв-клавиш
  local t = t_create(Count) -- Список горячих букв

  for k = 1, Count do
    local Item, c, _ = Items[k] -- Текущий пункт
    if not isItemSpeced(Item) then
      _, c = ParseHotText(Item.text) -- Горячая буква
      --logShow({ k, c, c and c:upper(), Item }, "Hot char")
    end
    t[k] = c and c:upper() or ' ' -- Space
  end
  --logShow(t, "Hot chars")

  return t_concat(t)
end ---- GetMenuHotChars

end -- do

do
  local SetAutoHotChar = unit.SetAutoHotChar

-- Set hot letters to items text.
-- Установка горячих букв в тексты пунктов.
function unit.SetMenuHotChars (Items, Count, Flags) --| HotChar in text
  -- Информация о горячих буквах-клавишах пунктов.
  local HotChars = isFlag(Flags, ShowAmper) and "" or
                   unit.GetMenuHotChars(Items, Count)
  --logShow(HotChars, _G.tostring(isFlag(Flags, ShowAmper)))

  -- Назначение горячих букв-клавиш на пункты меню.
  if isFlag(Flags, DirAutoHL) then
    for k = 1, Count do
      HotChars = SetAutoHotChar(Items[k], k, HotChars)
      --logShow(HotChars, Item.text)
    end
  elseif isFlag(Flags, RevAutoHL) then
    for k = Count, 1, -1 do
      HotChars = SetAutoHotChar(Items[k], k, HotChars)
      --logShow(HotChars, Item.text)
    end
  end

  return HotChars
end ---- SetMenuHotChars

end -- do

---------------------------------------- Items table
-- TODO: Исключить DefItemSeler, DefItemField, FieldMax
--       после разделения RectMenu и RectGrid (Items-2D).

do

-- Выбор пункта меню по умолчанию.
--[[
  -- @params:
  Item  - пункт меню.
  Index - индекс текущего пункта по порядку.
  Selex - следующий индекс пункта по порядку выбора (Select Index).
--]]
local function DefItemSeler (Item, Index, Selex, Data) --> (bool)
  return not Item.hidden
end-- function DefItemSeler

-- Длина поля пункта меню по умолчанию.
local function DefItemField (Item, Index, Selex, Data) --> (number)
  return (Item.text or ""):len()
end-- function DefItemField

local max2 = numbers.max2

-- Расчёт макс. значения характеристики пунктов.
--[[
  -- @params:
  Items - список пунктов (меню).
  Count - число пунктов (по умолчанию = #Items).
  Seler - функция выбора пунктов (Selector).
  Field - функция расчёта характеристики пункта.
  Data  - дополнительная информация для функций.
--]]
function unit.FieldMax (Items, Count, Seler, Field, Data) --> (number)

  local function FieldLen (Item, Index, Selex, Data)
    return (Item[Field] or ""):len()
  end --

  local Count = Count or #Items
  local Seler = type(Seler) == 'function' and Seler or DefItemSeler
  local Field = type(Field) == 'string' and FieldLen or Field or DefItemField
  --rhlog.TblMenu({ Count, Seler, Field }, "FieldMax")

  -- Просмотр пунктов меню:
  local i, k, Max = 1, 1, 0
  while i <= Count do
    local Item = Items[i]
    if Seler(Item, i, k, Data) then -- Выбор
      Max = max2(Max, Field(Item, i, k, Data)) -- Расчёт
      k = k + 1
    end -- if
    i = i + 1
  end -- while
  return Max
end ---- FieldMax

end -- do

---------------------------------------- Menu View
do
  local IndexColor = farUt.IndexColor
  local basics = colors.BaseColors
  local make = colors.make
  local getFG, getBG = colors.getFG,  colors.getBG
  local setFG, setBG = colors.setFG, colors.setBG

-- Получение всех возможных цветов меню.
function unit.MenuColors () --> (table)
  local Colors = {}
  for k, v in pairs(farColors) do
    if k:match("^COL%_MENU") then
      Colors[k] = IndexColor(v)
    end
  end

  local MenuBG = getBG(Colors.COL_MENUTEXT) -- Цвет фона
  Colors.COL_MENUBGROUND    = make(basics.black, MenuBG)
  Colors.COL_MENUSTATUSBAR  = make(basics.silver, MenuBG)

  local MarkFG = basics.lime -- Цвет выделения части текста
  local Sel_BG = getBG(Colors.COL_MENUSELECTEDTEXT)
  Colors.COL_MARKFGROUND          = make(MarkFG, Sel_BG)
  Colors.COL_MENUMARKTEXT         = make(MarkFG, MenuBG)
  Colors.COL_MENUSELECTEDMARKTEXT = make(MarkFG, Sel_BG)

  return Colors
end ---- MenuColors

-- Изменение частей цветов меню.
function unit.ChangeColors (Colors, OldFG, OldBG, NewFG, NewBG) --> (table)
  local Colors = Colors or unit.MenuColors()

  for k, v in pairs(Colors) do
    if NewFG and (not OldFG or getFG(v) == OldFG) then
      Colors[k] = setFG(v, NewFG)
    end
    if NewBG and (not OldFG or getBG(v) == OldBG) then
      Colors[k] = setBG(v, NewBG)
    end
  end

  return Colors
end ---- ChangeColors

end -- do

-- Цвета пунктов с учётом их вида.
function unit.ItemColors (Colors) --> (table)
  return { -- Цвета текста пунктов меню:
    [false] = { -- Обычный пункт:
      normal  = {
        normal = Colors.COL_MENUTEXT,
        hlight = Colors.COL_MENUHIGHLIGHT,
        marked = Colors.COL_MENUMARKTEXT, },
      disable = {
        normal = Colors.COL_MENUDISABLEDTEXT,
        hlight = Colors.COL_MENUDISABLEDTEXT,
        marked = Colors.COL_MENUDISABLEDTEXT, },
      grayed  = {
        normal = Colors.COL_MENUGRAYTEXT,
        hlight = Colors.COL_MENUGRAYTEXT,
        marked = Colors.COL_MENUGRAYTEXT, },
    },
    [true] = { -- Выделенный пункт:
      normal  = {
        normal = Colors.COL_MENUSELECTEDTEXT,
        hlight = Colors.COL_MENUSELECTEDHIGHLIGHT,
        marked = Colors.COL_MENUSELECTEDMARKTEXT, },
      --disable = {
      --  normal = Colors.COL_MENUDISABLEDTEXT,
      --  hlight = Colors.COL_MENUDISABLEDTEXT,
      --  marked = Colors.COL_MENUSELECTEDMARKTEXT, },
      grayed  = {
        normal = Colors.COL_MENUSELECTEDGRAYTEXT,
        hlight = Colors.COL_MENUSELECTEDGRAYTEXT,
        marked = Colors.COL_MENUSELECTEDGRAYTEXT, },
    },
  } --- TextColors
end ---- ItemColors

do
  local DefColors = unit.MenuColors() -- Цвета меню
  local TextColors = unit.ItemColors(DefColors) -- Цвета пунктов

-- Цвет текста пункта меню.
function unit.ItemTextColor (Item, Selected, Colors) --> (color, color)
  --Selected = Selected == nil and Item.Selected or Selected
  local ItemKind = Item.disable and "disable" or
                   Item.grayed and "grayed" or "normal"
  local Colors = Colors and unit.ItemColors(Colors) or TextColors
  return (Colors)[Selected or false][ItemKind]
end ---- ItemTextColor

end -- do

-- Включение использования Hot chars.
function unit.HighlightOn (flags, reverse) --> (flags)
  flags = delFlag(flags, ShowAmper)
  if reverse then
    return addFlag(flags, RevAutoHL)
  else
    return addFlag(flags, DirAutoHL)
  end
end ----

-- Отключение использования Hot chars.
function unit.HighlightOff (flags) --> (flags)
  flags = addFlag(flags, ShowAmper)
  return delFlag(delFlag(flags, DirAutoHL), RevAutoHL)
end ----

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
