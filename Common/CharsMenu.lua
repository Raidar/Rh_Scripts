--[[ Characters menu ]]--

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
  -- areas: any.
--]]
--------------------------------------------------------------------------------

local type, assert = type, assert
local pairs, ipairs = pairs, ipairs
local setmetatable = setmetatable

----------------------------------------
local logShow = context.ShowInfo

--local strings = require 'context.utils.useStrings'
local tables = require 'context.utils.useTables'
local datas = require 'context.utils.useDatas'

local Null = tables.Null

----------------------------------------
local farUt = require "Rh_Scripts.Utils.Utils"

----------------------------------------
local keyUt = require "Rh_Scripts.Utils.Keys"

local CharsList = require "Rh_Scripts.Utils.CharsList"
local uCharCodeName = CharsList.uCharCodeName

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Keys

---------------------------------------- ---- Symbol keys
local SKEY_SymNames = keyUt.SKEY_SymNames

-- Клавиша-символ для VK_.
local function SVKeyValue (s) --> (string)
  if not s or s == "" then return s end

  --return s:upper()
  return SKEY_SymNames[s] or
         s:len() == 1 and s:upper() or s
end --
unit.SVKeyValue = SVKeyValue

---------------------------------------- ---- Combo-keys
-- Комбинации модификаторов:
--local SModKeyPat = "%s+%s"
local SModKeyPat = "%s%s"
local SKeyModifs = {
  'S', 'C', 'CS', 'A', 'AS', 'CA', 'CAS',

} --- SKeyModifs

local UsedModifs = {
  'Shift', 'Ctrl', 'CtrlShift',
  'Alt', 'AltShift', 'CtrlAlt', 'CtrlAltShift',

} --- UsedModifs

--[[
local function SModifKey (s, m, f) --> (string)
  return SModKeyPat:format(m, f(s))

end --
--unit.SModifKey = SModifKey
--]]

-- Комбинации для VK_.
local SVKeyFuncs = {
  S = 0, C = 0, A = 0, CS = 0, AS = 0, CA = 0, CAS = 0,

} --- SVKeyFuncs
unit.SVKeyFuncs = SVKeyFuncs

for k = 1, #SKeyModifs do
  local m = SKeyModifs[k]

  SVKeyFuncs[m] = function (s)

    --return SModifKey(s, UsedModifs[k], SVKeyValue)
    return SModKeyPat:format(UsedModifs[k], SVKeyValue(s))

  end
end

--logShow(SVKeyFuncs)

---------------------------------------- ---- Action keys
-- Вид клавиш обработки:
unit.DefActionKeys = {
  Kind = "AccelKey";
  SVKeyValue,    SVKeyFuncs.S,
  SVKeyFuncs.C,  SVKeyFuncs.CS,
  SVKeyFuncs.A,  SVKeyFuncs.AS,
  SVKeyFuncs.CA, SVKeyFuncs.CAS,

} --- DefActionKeys
unit.DefDoubleKeys = { unit.DefActionKeys, unit.DefActionKeys, }

local DefKeyOrder = { [0] = ""; "" }
unit.DefKeyOrder = DefKeyOrder
for _, m in ipairs(SKeyModifs) do
  DefKeyOrder[#DefKeyOrder + 1] = m..'+'

end

-- Получение функции для комбинации.
local function GetKeyFunc (m) --> (func|nil)

  m = m or ""
  if m == "" then return unit.SVKeyValue end
  if m:sub(-1, -1) == '+' then m = m:sub(1, -2) end

  return SVKeyFuncs[m]

end --
--unit.GetKeyFunc = GetKeyFunc

---------------------------------------- Characters

---------------------------------------- ---- Item
do

-- Make menu head.
-- Формирование пункта-заголовка меню.
function unit.MakeHeadItem (s) --> (table)

  local t = {
    Label = true,
    text = type(s) ~= 'table' and s or s[1],

  } ---

  return t

end ---- MakeHeadItem

--[[
-- Make menu item text and "Plain" action.
function unit.MakeItemText (s) --> (text, Plain)
  if type(s) ~= 'table' then return s, s end

  return s[2], s[1]

end ---- MakeItemText
--]]

-- Make handle key for item.
-- Формирование клавиши обработки для пункта.
local function MakeItemKey (item, Keys, key, char)

  local keys = Keys[key]
  if not keys then return end

  local akey = item.AccelKey
  if not akey then
    item.AccelKey = keys(char)

  elseif type(akey) == 'string' then
    item.AccelKey = { item.AccelKey, keys(char) }

  elseif type(akey) == 'table' then
    akey[#key + 1] = keys(char)

  end
end -- MakeItemKey
unit.MakeItemKey = MakeItemKey

-- Make menu item.
-- Формирование пункта меню.
--[[
  -- @params:
  text  - character itself.
  Keys  - key set for rapid keys.
  index - character position in Datas.
  order - character position in Order.
  key   - key name position in KeyOrder.
  capt  - caption character for rapid key.
  Props - properties for menu item.
--]]
function unit.MakeCharItem (text, Keys,
                            index, order, key,
                            capt, Props) --> (table)

  local x = type(text) ~= 'table'
  text, x = x and text or text[2], x and text or text[1]

  local t = {

    text = text,
    Plain = x,
    RectMenu = Props.RectItem,

  } ---

  --if text == "" or text == " " then t.grayed = true end
  if text == "" or text == " " then t.disable = true end

  local Hint = Props.Hint
  if Hint == true then
    if x:len() == 1 then
      t.Hint = uCharCodeName(x)

    end

  elseif Hint then
    t.Hint = Hint

  end

  x = type(capt) ~= 'table'
  MakeItemKey(t,
              Keys.Kind and Keys or Keys[1],
              key,
              x and capt or capt[2])

  capt = x and capt or capt[3]
  if capt and capt ~= "" and not Keys.Kind then
    MakeItemKey(t, Keys[2], key, capt)

  end

  local CI = Props.CharsItem or Null
  if CI.OnMakeCharItem then
    CI.OnMakeCharItem(t, index, order, key, capt, Props)

  end

  return t

end ---- MakeCharItem

end -- do
---------------------------------------- Items

unit.DefItemOrder = [[abcdefghijklmnopqrstuvwxyz`1234567890-=[]\;',./]]

local length = farUt.length

local MakeCharItem = unit.MakeCharItem
local MakeHeadItem = unit.MakeHeadItem

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
    Size    (number)   - размер ряда в Datas.
    Count   (number)   - число рядов и число клавиш для них.
    Length  (number)   - длина пункта меню в Datas.
    Serial    (bool)   - выборка пунктов из Datas по рядам.
    KeyOrder (table)   - порядок строк клавиш для заголовков.
    Heading (string)   - вывод заголовков: "Order", "Keys", "Both".
  Datas     (string) - "шаблоны" содержимого пунктов в порядке Order.
             (table) - массив таблиц-"шаблонов" содержимого. Поля:
    [1]       (string) - plain-текст содержимого.
    [2]       (string) - название пункта-"символа" меню.
  Keys      (string) - тип назначаемых клавиш (@default = "AccelKey"):
                       "None", "AccelKey".
             (table) - таблица функций формирования клавиш.
              (bool) - = "AccelKey" с использованием порядка KeyOrder.
                       KeyOrder должен быть стандартного вида.
--]]
function unit.MakeItems (Properties, Datas, Keys) --> (table)

  -- Настройка параметров:
  local tp = type(Datas)
  if tp ~= 'string' and tp ~= 'table' then
    return nil, "Datas type is not valid"

  end

  local Order = Properties.Order or unit.DefItemOrder
  local iLen = Properties.Length or 1
  if tp == 'table' then iLen = 1 end

  local Size = Properties.Size or length(Order)
  if not Size or Size < 1 then
    return nil, "Order size is not valid"

  end

  local dLen = length(Datas)
  if not dLen or dLen < 1 then
    return nil, "Datas length is not valid"

  end

  local Count = Properties.Count or
                tp == 'string' and dLen / Size or dLen or 1
  if Count < 1 then Count = 1 end

  local ItemProps = {
    Hint = Properties.Hint == nil and true or Properties.Hint,

    RectItem = Properties.RectItem or {},
    CharsItem = Properties.CharsItem or {},

  } --- ItemProps

  local Heading = Properties.Heading or "Order"

  -- Порядок клавиш
  local KeyOrder = Properties.KeyOrder or DefKeyOrder
  KeyOrder[0] = KeyOrder[0] or ""

  -- Клавиши быстрого выбора:
  Keys = Keys or "AccelKey"
  local kk = type(Keys)
  if kk == 'boolean' then
    Keys, kk = { Kind = "AccelKey" }, Keys
    if kk == true then
      for _, m in ipairs(KeyOrder) do
        Keys[#Keys + 1] = GetKeyFunc(m)

      end
    end

    --logShow({ tp, Keys }, "Used Keys", "#qd1")

  elseif kk == 'string' then
    if Keys == "None" then
      Keys = { Kind = "None", }

    else
      Keys = unit.DefActionKeys

    end

  end -- if

  -- Функция извлечения текста из Order
  local capt = type(Order) == 'table' and
               function (j) return Order[j] end or
               function (j) return Order:sub(j, j) end
  -- Функция извлечения текста из Datas
  local text = tp == 'table' and
               function (i) return Datas[i] end or
               function (i) return Datas:sub(i, i + iLen - 1) end

  -- Формирование пунктов:
  local t = {} -- result
  --local s, d -- result, item text, caption text
  --local i, j, k -- loop indexes: by item length, by 1, on key order

  if Heading == "Both" then
    t[#t + 1] = MakeHeadItem(KeyOrder[0]) -- Angle Head

  end

  local caps = {}
  for j = 1, Size do
    caps[j] = capt(j)

  end

  if Properties.Serial then -- Последовательная выборка

    if Heading ~= "Keys" then
      local i, j = 1, 1
      while j <= Size and i <= dLen do
        --logShow({ i, j }, "Head Loop", "#qd1")
        local s = text(i)
        if s ~= "" then
          t[#t + 1] = MakeHeadItem(caps[j]) -- Head

        end
        --logShow({ Order:sub(j, j), MakeHeadItem(Order:sub(j, j)) }, "Head Loop", "#qd1")

        i, j = i + iLen, j + 1

      end
    end

    local i, k = 1, 1 -- Body
    while k <= Count and i <= dLen do
      --logShow(KeyOrder[k] or "", "MakeHeadItem")
      if Heading ~= "Order" then
        t[#t + 1] = MakeHeadItem(KeyOrder[k] or "") -- SubHead

      end

      local j = 1
      while j <= Size and i <= dLen do
        --logShow({ i, j, k }, "Char Loop", "#qd1")
        --logShow({ text(i), Order:sub(j, j) }, "Char Loop", "#qd1")
        local s = text(i)
        if s ~= "" then
          t[#t + 1] = MakeCharItem(s, Keys, i, j, k, caps[j], ItemProps)

        end

        i, j = i + iLen, j + 1

      end

      k = k + 1

    end

  else -- Across -- Пересекающая выборка

    if Heading ~= "Order" then
      local i, k = 1, 1
      while k <= Count and i <= dLen do
        --logShow({ i, j, k }, "Head Loop", "#qd1")
        local s = text(i)
        if s ~= "" then
          t[#t + 1] = MakeHeadItem(KeyOrder[k] or "") -- Head

        end
        --logShow({ capt(j) }, "Head Loop", "#qd1")

        i, k = i + iLen, k + 1

      end
    end

    local i, j = 1, 1 -- Body
    while j <= Size and i <= dLen do
      --logShow(KeyOrder[k] or "", "MakeHeadItem")
      if Heading ~= "Keys" then
        t[#t + 1] = MakeHeadItem(caps[j]) -- SubHead

      end

      local k = 1
      while k <= Count and i <= dLen do
        --logShow({ i, j, k }, "Char Loop", "#qd1")
        local s = text(i)
        --logShow({ s, d }, "Char Loop", "#qd1")
        if s ~= "" then
          t[#t + 1] = MakeCharItem(s, Keys, i, j, k, caps[j], ItemProps)

        end

        i, k = i + iLen, k + 1

      end

      j = j + 1

    end

  end -- if Serial

  --logShow(t, "Items", "#qd1")
  return t

end ---- MakeItems

-- Change texts for items-labels with specified text.
-- Изменение текста пунктов-меток с заданным текстом.
--[[
  -- @params:
  Text  (string) - текст пункта-метки.
  Value (string) - новый текст пункта-метки.
--]]
function unit.SetLabelItemsText (Items, Text, Value) --|> Items

  assert(type(Items) == 'table')

  Text  = Text or " "
  Value = Value or '" "'

  for _, v in pairs(Items) do
    if v.Label and v.text == Text then
      v.text = Value

    end
  end

  return Items

end ---- SetLabelItemsText

-- Change fields for items with specified keys' pattern.
-- Изменение полей пунктов с заданным шаблоном для клавиши.
--[[
  -- @params:
  Pattern (string) - шаблон поиска клавиш.
  Field   (string) - изменяемое поле пункта.
  Value   (string) - новое значение поля пункта.
--]]
function unit.SetKeyItemsField (Items, Pattern, Field, Value) --|> Items

  assert(type(Items) == 'table')

  Pattern = Pattern or "Space$"
  Field   = Field or "disable"

  for _, v in pairs(Items) do
    if (v.AccelKey or ""):find(Pattern) then
      v[Field] = Value

    end
  end

  return Items

end ---- SetKeyItemsField

---------------------------------------- main
do
  local tcopy = tables.clone --copy
  local DefMenuAlign = "CM"

  --local DefFixedRows = { HeadRows = 1 }
  --local DefFixedCols = { HeadCols = 1 }
  local DefFixedBoth = {

    HeadRows = 1,
    HeadCols = 1,

  } --- DefFixedBoth

  local DefUMenu = {

    TextNamedKeys = false,
    UseMenuTexter = false,

  } --- DefUMenu

  local function set__index (t, u)
    if u then
      t.__index = u

      return setmetatable(t, t)

    end
  end -- set__index

  local CloseFlag  = { isClose = true }
  --local CancelFlag = { isCancel = true }
  --local CompleteFlags = { isRedraw = false, isRedrawAll = true }

local Guid = win.Uuid("3b84d47b-930c-47ab-a211-913c76280491")

local InsText = farUt.InsertText

function unit.MakeMenu (Config, Props, Datas, Keys) --> (table)

  Config = Config or {}

  local self = {
    Name  = Config.Name,
    text  = Config.text,
    Title = Config.Title,
    MenuView = "RectMenu",

    ArgData   = Config,
    --FarArea   = farUt.GetBasicAreaType(),
    InsArea   = farUt.GetAreaType(),

    Custom    = false,
    Options   = false,
    History   = false,
    HisData   = false,
    CfgData   = false,

    -- Текущее состояние:
    Items     = false,    -- Список пунктов меню
    Props     = false,    -- Свойства меню

  } --- self

  local mItems

  -- Lazy make items.
  -- Отложенное формирование пунктов.
  local function MakeItems ()
    mItems = unit.MakeItems(Props, Datas, Keys)
    --logShow(mItems, "mItems", "w d2")

    return mItems

  end --

  if not Config.LazyMake then
    mItems = unit.MakeItems(Props, Datas, Keys)

  end

  self.Items = Config.LazyMake and MakeItems or mItems

  local Properties = {

    Id = Guid,
    Bottom = Config.Bottom,

    RectMenu = false,

  } --- Properties
  self.Props = Properties

  local mChooseKinds = {

    AKey     = true,
    Enter    = true,
    DblClick = true,

  } --- mChooseKinds

  local function StopDrag (Flag)

    if Flag then
      self.History:save()

    end

    return -- unused result

  end -- StopDrag

  local function ChooseItem (Kind, Index)

    --logShow({ Index = Index, SelIndex = SelIndex }, Kind)
    --logShow({ Index = Index, Items = mItems }, Kind, "a60 h60 ak1 hk5")

    if not mChooseKinds[Kind or ""] then
      return nil, CloseFlag

    end

    local ActItem = mItems[Index]
    if not ActItem or not ActItem.Plain then
      return nil, CloseFlag

    end

    if not InsText(self.InsArea, ActItem.Plain, {}) then
      return nil, CloseFlag

    end

    --local F = far.Flags
    --local DlgRect = SendDlgMessage(hDlg, F.DM_GETDLGRECT, 0)
    --logShow(self.DlgPos, "DlgPos")

    farUt.RedrawAll()

    return true

  end -- ChooseItem

  local Fixed = Config.Fixed or DefFixedBoth

  local RM = Props.RectMenu or {}
  RM.Cols           = (Props.Size or length(Props.Order)) +
                      (Fixed == DefFixedBoth and 1 or 0)
  RM.MenuAlign      = DefMenuAlign
  RM.MenuEdge       = 2
  RM.IsStatusBar    = true
  RM.Fixed          = Fixed
  RM.StorePos       = true
  if RM.ReuseItems == nil then RM.ReuseItems = true end

  RM.OnStopDrag     = StopDrag
  RM.OnChooseItem   = ChooseItem
  ----- RM

  Properties.RectMenu = RM

  --[[
  if Props.___ then
    logShow({ Props = Properties, Cfg = Config }, "ChUMenu", 3)
  --]]
  if set__index(Properties, Config.Props) then
    set__index(Properties.RectMenu, Config.Props.RectMenu)

  end

  self.ArgData.Custom = {} -- self.ArgData.Custom or {}
  --logShow(self.ArgData, "ArgData", "wA d2")
  self.Custom = datas.customize(self.ArgData.Custom, self.ArgData.DefCustom)
  self.Options = {} -- addNewData(self.ArgData.Options, unit.DefOptions)

  self.History = datas.newHistory(self.Custom.history.full)
  --logShow(self.Custom.history, "Custom.history", "wA d2")
  self.HisData = self.History:field(self.Custom.history.field)
  --logShow(self.HisData, "HisData", "wA d2")

  local CfgData = { UMenu = false, }
  CfgData.UMenu = tcopy(DefUMenu, false, pairs, false)
  if set__index(CfgData, Config.CfgData) then
    set__index(CfgData.UMenu, Config.CfgData.UMenu)

  end
  self.CfgData = CfgData
  --logShow(self.CfgData, "CfgData", "wA d2")

  self.UpdateInsArea = function ()
    self.InsArea = farUt.GetAreaType()

    return self

  end -- UpdateInsArea

  --[[
  if Props.___ then
    logShow({ Menu = Config, Props = Properties, Cfg = CfgData }, "ChUMenu", 3)
  end
  --]]

  return self

end ---- MakeMenu

end -- do

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
