--[[ Characters-items ]]--

----------------------------------------
--[[ description:
  -- Menu of characters output items.
  -- Меню из пунктов вывода символов.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  LF context,
  Rh Utils.
  -- group: Common.
  -- areas: any (TODO).
--]]
--------------------------------------------------------------------------------

local type, assert = type, assert
local pairs, ipairs = pairs, ipairs
local setmetatable = setmetatable

----------------------------------------
--local win, far = win, far

----------------------------------------
--local context = context

--local utils = require 'context.utils.useUtils'
local strings = require 'context.utils.useStrings'
local tables = require 'context.utils.useTables'
--local datas = require 'context.utils.useDatas'

local u_byte = strings.u8byte
--local u_char, u_byte = strings.u8char, strings.u8byte

----------------------------------------
local luaUt = require "Rh_Scripts.Utils.luaUtils"

local length = luaUt.length

----------------------------------------
local keyUt = require "Rh_Scripts.Utils.keyUtils"

local uNames = require "Rh_Scripts.Utils.uniNames"
local CharNames = uNames.Names

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--logShow(uNames.Names, "CharNames", 2, "#fq")
--]]

--------------------------------------------------------------------------------
local sKeys = {}
local sItem = {}
local sList = {}
local unit = { Keys = sKeys, Item = sItem, List = sList }

---------------------------------------- Symbol keys
local SKEY_SymNames = keyUt.SKEY_SymNames

-- Клавиша-символ для VK_.
local function SVKeyValue (s) --> (string)
  if not s or s == "" then return s end
  --return s:upper()
  return SKEY_SymNames[s] or s:upper()
end --
sKeys.SVKeyValue = SVKeyValue

---------------------------------------- Combo-keys
-- Комбинации модификаторов:
--local SModKeyPat = "%s+%s"
local SModKeyPat = "%s%s"
local SKeyModifs = { 'S', 'C', 'CS', 'A', 'AS', 'CA', 'CAS' }
--local UsedModifs = SKeyModifs
local UsedModifs = { 'Shift', 'Ctrl', 'CtrlShift',
                     'Alt', 'AltShift', 'CtrlAlt', 'CtrlAltShift' }
local function SModifKey (s, m, f) --> (string)
  return SModKeyPat:format(m, f(s))
end --
--sKeys.SModifKey = SModifKey

-- Комбинации для VK_.
local SVKeyFuncs = { S = 0, C = 0, A = 0, CS = 0, AS = 0, CA = 0, CAS = 0 }
sKeys.SVKeyFuncs = SVKeyFuncs

for k, m in ipairs(SKeyModifs) do
  SVKeyFuncs[m] = function (s)
    return SModifKey(s, UsedModifs[k], SVKeyValue)
  end
end

---------------------------------------- Action keys
-- Вид клавиш обработки:
sKeys.DefActionKeys = {
  Kind = "AccelKey";
  SVKeyValue,    SVKeyFuncs.S,
  SVKeyFuncs.C,  SVKeyFuncs.CS,
  SVKeyFuncs.A,  SVKeyFuncs.AS,
  SVKeyFuncs.CA, SVKeyFuncs.CAS,
} --- DefActionKeys

local DefKeyOrder = { [0] = ""; "" }
sKeys.DefKeyOrder = DefKeyOrder
for _, m in ipairs(SKeyModifs) do
  DefKeyOrder[#DefKeyOrder+1] = m..'+'
end

-- Получение функции для комбинации.
local function GetKeyFunc (m) --> (func|nil)
  local m = m or ""
  if m == "" then return sKeys.SVKeyValue end
  if m:sub(-1, -1) == '+' then m = m:sub(1, -2) end
  return SVKeyFuncs[m]
end --
--sKeys.GetKeyFunc = GetKeyFunc

---------------------------------------- Character item

sItem.DefItemOrder = [[abcdefghijklmnopqrstuvwxyz`1234567890-=[]\;',./]]

-- Make menu head.
-- Формирование пункта-заголовка меню.
function sItem.MakeHead (s) --> (table)
  local t = { text = type(s) ~= 'table' and s or s[1], Label = true }
  return t
end --

--[[
-- Make menu item text and "Plain" action.
function sItem.MakeText (s) --> (text, Plain)
  if type(s) ~= 'table' then return s, s end
  return s[2], s[1]
end ----
--]]

-- Make handle key for item.
-- Формирование клавиши обработки для пункта.
function sItem.MakeKey (item, Keys, key, char)
  if Keys[key] then item.AccelKey = Keys[key](char) end
end ----

do
  local CharNameFmt = "U+%s — %s" -- utf-8 string

  -- Представление кодовой точки символа в виде строки.
  local uCP = strings.ucp2s

  -- Получение имени символа по её кодовой точке.
  local function uCPname (c) --> (string)
    return CharNames[c] and CharNames[c].name or ""
  end --

-- Make menu item.
-- Формирование пункта меню.
function sItem.MakeItem (text, Keys, key, char, hint) --> (table)
  local text = text
  local x = type(text) ~= 'table'
  text, x = x and text or text[2], x and text or text[1]

  local t = { text = text, Plain = x }
  --if text == "" or text == " " then t.grayed = true end
  if text == "" or text == " " then t.disable = true end
  if hint == true then
    if x:len() == 1 then
      local u = u_byte(x)
      hint = CharNameFmt:format(uCP(u, true), uCPname(u))
    end
  end
  if hint then t.Hint = hint end

  x = type(char) ~= 'table'
  sItem.MakeKey(t, Keys.Kind and Keys or Keys[1], key, x and char or char[2])
  char = x and char or char[3]
  if char and char ~= "" and not Keys.Kind then
    sItem.MakeKey(t, Keys[2], key, char)
  end

  return t
end ---- MakeItem

end -- do
---------------------------------------- Character items
-- Create characters items for menu.
-- Создание пунктов для меню. -- TODO: Convert to OOP-kind.
--[[
  -- @params:
  Properties (table) - информация о рядах и пунктах меню:
    Order   (string)   - порядок шаблонов для заголовков и клавиш.
             (table)   - массив таблиц-шаблонов. Поля:
      [1]     (string)   - название пункта-заголовка меню.
      [2]     (string)   - основной символ используемой клавиши.
      [3]     (string)   - добавочный символ используемой клавиши.
    Size    (number)   - размер ряда в Data.
    Count   (number)   - число рядов и число клавиш для них.
    Length  (number)   - длина пункта меню в Data.
    Serial    (bool)   - выборка пунктов из Data по рядам.
    KeyOrder (table)   - порядок строк клавиш для заголовков.
    Heading (string)   - вывод заголовков: "Order", "Keys", "Both".
  Data      (string) - "шаблоны" содержимого пунктов в порядке Order.
             (table) - массив таблиц-"шаблонов" содержимого. Поля:
    [1]       (string) - plain-текст содержимого.
    [2]       (string) - название пункта-"символа" меню.
  Keys      (string) - тип назначаемых клавиш (@default = "AccelKey").
             (table) - таблица функций формирования клавиш.
              (bool) - = "AccelKey" с использованием порядка KeyOrder.
                       (KeyOrder должен быть стандартного вида.)
--]]
function sList.CharsItems (Properties, Data, Keys) --> (table)
  -- Настройка параметров:
  local tp = type(Data)
  assert(tp == 'string' or tp == 'table')

  local Order = Properties.Order or sItem.DefItemOrder
  local iLen = Properties.Length or 1
  if tp == 'table' then iLen = 1 end

  local Size = Properties.Size or length(Order)
  assert(Size and Size >= 1)

  local dLen = length(Data)
  assert(dLen and dLen >= 1)
  local Count = Properties.Count or
                tp == 'string' and dLen / Size or dLen or 1
  if Count < 1 then Count = 1 end

  local Serial = Properties.Serial
  local KeyOrder = Properties.KeyOrder or DefKeyOrder
  local Hint = Properties.Hint
  if Hint == nil then Hint = true end
  local Heading = Properties.Heading or "Order"

  -- Клавиши быстрого выбора:
  KeyOrder[0] = KeyOrder[0] or ""
  local Keys = Keys or "AccelKey"
  local kk = type(Keys)
  if kk == 'boolean' then
    Keys, kk = { Kind = "AccelKey" }, Keys
    if kk == true then
      for _, m in ipairs(KeyOrder) do
        Keys[#Keys+1] = GetKeyFunc(m)
      end
    end
    --logShow({ tp, Keys }, "Used Keys", "#qd1")
  elseif kk == 'string' then
    Keys = sKeys.DefActionKeys
  end -- if

  -- Функция извлечения текста из Order
  local capt = type(Order) == 'table' and
               function (k) return Order[k] end or
               function (k) return Order:sub(k, k) end
  -- Функция извлечения текста из Data
  local text = tp == 'table' and
               function (k) return Data[k] end or
               function (k) return Data:sub(k, k + iLen - 1) end

  -- Формирование пунктов:
  local t, s, d = {} -- result, item text, caption text
  local i, j, k -- loop indexes: by item length, by 1, on key order

  if Heading == "Both" then
    t[#t+1] = sItem.MakeHead(KeyOrder[0]) -- Angle Head
  end

  if Serial then -- Последовательная выборка

    if Heading ~= "Keys" then
      i, j = 1, 1
      while j <= Size and i <= dLen do
        --logShow({ i, j }, "Head Loop", "#qd1")
        s = text(i)
        if s ~= "" then
          t[#t+1] = sItem.MakeHead(capt(j)) -- Head
        end
        --logShow({ Order:sub(j, j), MakeHead(Order:sub(j, j)) }, "Head Loop", "#qd1")
        i, j = i + iLen, j + 1
      end
    end

    i, k = 1, 1 -- Body
    while k <= Count and i <= dLen do
      --logShow(KeyOrder[k] or "", "MakeHead")
      if Heading ~= "Order" then
        t[#t+1] = sItem.MakeHead(KeyOrder[k] or "") -- SubHead
      end
      j = 1
      while j <= Size and i <= dLen do
        --logShow({ i, j, k }, "Char Loop", "#qd1")
        --logShow({ text(i), Order:sub(j, j) }, "Char Loop", "#qd1")
        s = text(i)
        if s ~= "" then
          t[#t+1] = sItem.MakeItem(s, Keys, k, capt(j), Hint)
        end
        i, j = i + iLen, j + 1
      end
      k = k + 1
    end

  else -- Across -- Пересекающая выборка

    if Heading ~= "Order" then
      i, k = 1, 1
      while k <= Count and i <= dLen do
        --logShow({ i, j, k }, "Head Loop", "#qd1")
        s = text(i)
        if s ~= "" then
          t[#t+1] = sItem.MakeHead(KeyOrder[k] or "") -- Head
        end
        --logShow({ capt(j) }, "Head Loop", "#qd1")
        i, k = i + iLen, k + 1
      end
    end

    i, j = 1, 1 -- Body
    while j <= Size and i <= dLen do
      d = capt(j)
      --logShow(KeyOrder[k] or "", "MakeHead")
      if Heading ~= "Keys" then
        t[#t+1] = sItem.MakeHead(d) -- SubHead
      end
      k = 1
      while k <= Count and i <= dLen do
        --logShow({ i, j, k }, "Char Loop", "#qd1")
        s = text(i)
        --logShow({ s, d }, "Char Loop", "#qd1")
        if s ~= "" then
          t[#t+1] = sItem.MakeItem(s, Keys, k, d, Hint)
        end
        i, k = i + iLen, k + 1
      end
      j = j + 1
    end

  end -- if Serial

  --logShow(t, "Items", "#qd1")
  return t
end ---- CharsItems

-- Change texts for items-labels with specified text.
-- Изменение текста пунктов-меток с заданным текстом.
--[[
  -- @params:
  Text  (string) - текст пункта-метки.
  Value (string) - новый текст пункта-метки.
--]]
function sList.SetLabelItemsText (Items, Text, Value) --|> Items
  assert(type(Items) == 'table')

  local Text  = Text or " "
  local Value = Value or '" "'

  for _, v in pairs(Items) do
    if v.Label and v.text == Text then
      v.text = Value
    end
  end

  return Items
end ----

-- Change fields for items with specified keys' pattern.
-- Изменение полей пунктов с заданным шаблоном для клавиши.
--[[
  -- @params:
  Pattern (string) - шаблон поиска клавиш.
  Field   (string) - изменяемое поле пункта.
  Value   (string) - новое значение поля пункта.
--]]
function sList.SetKeyItemsField (Items, Pattern, Field, Value) --|> Items
  assert(type(Items) == 'table')

  local Pattern = Pattern or "Space$"
  local Field   = Field or "disable"

  for _, v in pairs(Items) do
    if (v.AccelKey or ""):find(Pattern) then
      v[Field] = Value
    end
  end

  return Items
end ----

---------------------------------------- main
do
  local tcopy = tables.copy
  local DefMenuAlign = "CM"
  --local DefFixedRows = { HeadRows = 1 }
  --local DefFixedCols = { HeadCols = 1 }
  local DefFixedBoth = { HeadRows = 1, HeadCols = 1 }
  local DefUMenu = { TextNamedKeys = false }

  local function set__index (t, u)
    if u then
      t.__index = u
      return setmetatable(t, t)
    end
  end --

local Guid = win.Uuid("3b84d47b-930c-47ab-a211-913c76280491")

function unit.CharsMenu (MenuConfig, Props, Data, Keys) --> (table)
  local MenuConfig = MenuConfig or {}
  local Fixed = MenuConfig.Fixed or DefFixedBoth

  local Properties = {
    Bottom = MenuConfig.Bottom,

    RectMenu = {
      Guid = Guid,
      Cols = (Props.Size or length(Props.Order)) +
             (Fixed == DefFixedBoth and 1 or 0),
      MenuAlign = DefMenuAlign,
      MenuEdge = 2,
      Fixed = Fixed,
    }, --
  } ---

  --[[
  if Props.___ then
    logShow({ Props = Properties, Cfg = MenuConfig }, "ChUMenu", 3)
  --]]
  if set__index(Properties, MenuConfig.Props) then
    set__index(Properties.RectMenu, MenuConfig.Props.RectMenu)
  end

  local CfgData = { UMenu = tcopy(DefUMenu, false, pairs, false) }
  if set__index(CfgData, MenuConfig.CfgData) then
    set__index(CfgData.UMenu, MenuConfig.CfgData.UMenu)
  end
  --[[
  if Props.___ then
    logShow({ Menu = MenuConfig, Props = Properties, Cfg = CfgData }, "ChUMenu", 3)
  end
  --]]

  return {
    Name  = MenuConfig.Name,
    text  = MenuConfig.text,
    Title = MenuConfig.Title,
    MenuView = "RectMenu",

    Props = Properties,

    CfgData = CfgData,

    Items = sList.CharsItems(Props, Data, Keys),
  } ----
end ---- CharsMenu

end -- do

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
