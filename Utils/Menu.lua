--[[ Menu utils ]]--

----------------------------------------
--[[ description:
  -- Working with menus and menu items.
  -- Работа с меню и пунктами меню.
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

----------------------------------------
--local context = context
local logShow = context.ShowInfo

local utils = require 'context.utils.useUtils'
local tables = require 'context.utils.useTables'
local numbers = require 'context.utils.useNumbers'
local strings = require 'context.utils.useStrings'
local colors = require 'context.utils.useColors'

local isFlag, addFlag, delFlag = utils.isFlag, utils.addFlag, utils.delFlag

local t_create, t_concat = tables.create, table.concat

----------------------------------------
local farUt = require "Rh_Scripts.Utils.Utils"
local keyUt = require "Rh_Scripts.Utils.Keys"

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

      if Key and type(Key) ~= 'table' then
        Keys[Key] = k
      elseif type(Key) == 'table' then
        for j = 1, #Key do
          Keys[ Key[j] ] = k
        end
      end
    end
  end -- for

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
  local ParseHotStr = farUt.ParseHotStr

-- Get hot letters string from items text.
-- Получение строки горячих букв из текста пунктов.
function unit.GetMenuHotChars (Items, Count) --> (string | "")
  --local t = {} -- Список горячих букв-клавиш
  local t = t_create(Count) -- Список горячих букв

  for k = 1, Count do
    local Item, c, _ = Items[k] -- Текущий пункт
    if not isItemSpeced(Item) then
      local s = Item.text
      -- TODO: Support 'table' type (ParseHotText):
      if s and type(s) == 'string' then
        _, c = ParseHotStr(Item.text) -- Горячая буква
        --logShow({ k, c, c and c:upper(), Item }, "Hot char")
      end
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

  local function FieldStrLen (Item, Index, Selex, Data)
    return (Item[Field] or ""):len()
  end --

  local function FieldTabLen (Item, Index, Selex, Data)
    return (Item[Field][1] or ""):len()
  end --

  local Count = Count or #Items
  local Seler = type(Seler) == 'function' and Seler or DefItemSeler
  local Field = type(Field) == 'string' and FieldStrLen or
                type(Field) == 'table'  and FieldTabLen or
                Field or DefItemField
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
  local C = far.Colors
  local IndexColor = farUt.IndexColor
  local basics = colors.BaseColors
  local make = colors.make
  local getFG, getBG = colors.getFG, colors.getBG
  local setFG, setBG = colors.setFG, colors.setBG
  
-- Формирование цветов для меню.
function unit.MenuColors (Basis) --> (table)
  local Basis = Basis or {}
  local Standard    = IndexColor(C.COL_MENUTEXT)
  local Selected    = IndexColor(C.COL_MENUSELECTEDTEXT)
  local StandardBG  = getBG(Standard)
  local SelectedBG  = getBG(Selected)
  local MarkedFG    = Basis.MarkedFG or basics.lime
  local FixedBG     = Basis.FixedBG or basics.gray
  
  local Colors = {
    Standard = { -- Нормальный:
      normal  = Standard,
      hlight  = IndexColor(C.COL_MENUHIGHLIGHT),
      marked  = make(MarkedFG, StandardBG),
      grayed  = IndexColor(C.COL_MENUGRAYTEXT),
      disable = IndexColor(C.COL_MENUDISABLEDTEXT),
    }, --
    Selected = { -- Выделенный:
      normal  = Selected,
      hlight  = IndexColor(C.COL_MENUSELECTEDHIGHLIGHT),
      marked  = make(MarkedFG, SelectedBG),
      grayed  = IndexColor(C.COL_MENUSELECTEDGRAYTEXT),
      disable = IndexColor(C.COL_MENUDISABLEDTEXT),
    }, --
    Fixed = { -- Фиксированный:
      normal  = make(getFG(Standard), FixedBG),
      hlight  = make(getFG(IndexColor(C.COL_MENUHIGHLIGHT)), FixedBG),
      marked  = make(MarkedFG, FixedBG),
      grayed  = make(getFG(IndexColor(C.COL_MENUGRAYTEXT)), FixedBG),
      disable = make(getFG(IndexColor(C.COL_MENUDISABLEDTEXT)), FixedBG),
    }, --

    Border    = IndexColor(C.COL_MENUBOX),
    Title     = IndexColor(C.COL_MENUTITLE),
    StatusBar = make(basics.silver, StandardBG),
    ScrollBar = IndexColor(C.COL_MENUSCROLLBAR),

    DlgBox    = false, -- Standard.normal + Standard.hlight + Border,
  } --- Colors

  Colors.Fixed.Standard = Colors.Fixed
  Colors.Fixed.Selected = Colors.Fixed

  return Colors
end ---- MenuColors

-- Формирование цветов для формы.
function unit.FormColors (Basis) --> (table)
  local Basis = Basis or {}
  local StandardFG  = Basis.StandardFG or basics.black
  local StandardBG  = Basis.StandardBG or basics.silver
  local SelectedFG  = Basis.SelectedFG or basics.blue
  local SelectedBG  = Basis.SelectedBG or basics.white
  local MarkedFG    = Basis.MarkedFG or basics.maroon
  local FixedFG     = Basis.FixedFG or basics.white
  local FixedBG     = Basis.FixedBG or basics.gray
  
  local Colors = {
    Standard = { -- Нормальный:
      normal  = make(StandardFG, StandardBG),
      hlight  = make(getFG(IndexColor(C.COL_MENUHIGHLIGHT)), StandardBG),
      marked  = make(MarkedFG, StandardBG),
      grayed  = make(getFG(IndexColor(C.COL_MENUGRAYTEXT)), StandardBG),
      disable = make(getFG(IndexColor(C.COL_MENUDISABLEDTEXT)), StandardBG),
    }, --
    Selected = { -- Выделенный:
      normal  = make(SelectedFG, SelectedBG),
      hlight  = make(getFG(IndexColor(C.COL_MENUSELECTEDHIGHLIGHT)), SelectedBG),
      marked  = make(MarkedFG, SelectedBG),
      grayed  = make(getFG(IndexColor(C.COL_MENUSELECTEDGRAYTEXT)), SelectedBG),
      disable = make(getFG(IndexColor(C.COL_MENUDISABLEDTEXT)), SelectedBG),
    }, --
    Fixed = { -- Фиксированный:
      normal  = make(FixedFG, FixedBG),
      hlight  = make(getFG(IndexColor(C.COL_MENUHIGHLIGHT)), FixedBG),
      marked  = make(MarkedFG, FixedBG),
      grayed  = make(getFG(IndexColor(C.COL_MENUGRAYTEXT)), FixedBG),
      disable = make(getFG(IndexColor(C.COL_MENUDISABLEDTEXT)), FixedBG),
    }, --

    Border    = make(Basis.BorderFG or StandardFG, StandardBG),
    Title     = make(Basis.TitleFG  or StandardFG, StandardBG),
    StatusBar = make(Basis.StatusBarFG or StandardFG, StandardBG),
    ScrollBar = make(Basis.ScrollBarFG or StandardFG, StandardBG),

    DlgBox    = false, -- Standard.normal + Standard.hlight + Border,
  } --- Colors

  Colors.Fixed.Standard = Colors.Fixed
  Colors.Fixed.Selected = Colors.Fixed

  return Colors
end ---- FormColors

--[[
  local tpairs = tables.allpairs

-- Изменение частей цветов меню.
function unit.ChangeColors (Colors, OldFG, OldBG, NewFG, NewBG) --> (table)
  local Colors = Colors or unit.MenuColors()

  for k, v in tpairs(Colors) do
    local w = v
    if NewFG and (not OldFG or getFG(w) == OldFG) then
      w = setFG(w, NewFG)
    end
    if NewBG and (not OldBG or getBG(w) == OldBG) then
      w = setBG(w, NewBG)
    end
    Colors[k] = w
  end

  return Colors
end ---- ChangeColors
--]]
end -- do

-- Цвета пунктов с учётом их вида.
function unit.ItemColors (Colors) --> (table)
  return { -- Цвета текста пунктов меню:
    [false] = { -- Обычный пункт:
      normal  = Colors.Standard,
      grayed  = {
        normal = Colors.Standard.grayed,
        hlight = Colors.Standard.grayed,
        marked = Colors.Standard.grayed,
      },
      disable = {
        normal = Colors.Standard.disable,
        hlight = Colors.Standard.disable,
        marked = Colors.Standard.disable,
      },
    },
    [true] = { -- Выделенный пункт:
      normal  = Colors.Selected,
      grayed  = {
        normal = Colors.Selected.grayed,
        hlight = Colors.Selected.grayed,
        marked = Colors.Selected.grayed,
      },
      --disable = {
      --  normal = Colors.Selected.disable,
      --  hlight = Colors.Selected.disable,
      --  marked = Colors.Selected.disable,
      --},
    },
  } --- TextColors
end ---- ItemColors

do
  local DefColors = unit.MenuColors() -- Цвета меню
  local TextColors = unit.ItemColors(DefColors) -- Цвета пунктов
  --logShow(DefColors, "MenuColors", "w d2 xv8")

-- Get color text of menu item.
-- Получение цвета текста пункта меню.
function unit.ItemTextColor (Item, Selected, Colors) --> (color, color)
  --Selected = Selected == nil and Item.Selected or Selected
  local ItemKind = Item.disable and "disable" or
                   Item.grayed and "grayed" or "normal"
  local Colors = Colors and unit.ItemColors(Colors) or TextColors

  return Colors[Selected or false][ItemKind]
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
