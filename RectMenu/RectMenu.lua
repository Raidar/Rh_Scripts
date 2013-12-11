--[[ RectMenu ]]--

----------------------------------------
--[[ description:
  -- Rectangular menu.
  -- Прямоугольное меню.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  --far2,
  Rh Utils, [LUM].
  -- group: Menus, RectMenu.
--]]
--------------------------------------------------------------------------------

--local assert = assert
local type = type
local require = require
local getmetatable, setmetatable = getmetatable, setmetatable

----------------------------------------
local useprofiler = false
--local useprofiler = true

if useprofiler then
  require "profiler" -- Lua Profiler
  profiler.start("RectMenu.log")
end

----------------------------------------
local bit = bit64
--local band, bor = bit.band, bit.bor
--local bnot, bxor = bit.bnot, bit.bxor
local bshl, bshr = bit.lshift, bit.rshift

----------------------------------------
local win, far = win, far
local F = far.Flags

local farUt = require "Rh_Scripts.Utils.Utils"

local HText, VText, YText = farUt.HText, farUt.VText, farUt.YText

----------------------------------------
--local context = context
local logShow = context.ShowInfo

local utils = require 'context.utils.useUtils'
local tables = require 'context.utils.useTables'
local numbers = require 'context.utils.useNumbers'
local strings = require 'context.utils.useStrings'

local newFlag, isFlag = utils.newFlag, utils.isFlag

local Null = tables.Null

local abs, sign = math.abs, numbers.sign
local b2n = numbers.b2n
local max2, min2 = numbers.max2, numbers.min2
--local divf = numbers.divf
local divc, divr = numbers.divc, numbers.divr

----------------------------------------
local dlgUt = require "Rh_Scripts.Utils.Dialog"

----------------------------------------
local keyUt = require "Rh_Scripts.Utils.Keys"

----------------------------------------
local menUt = require "Rh_Scripts.Utils.Menu"

local MenuUsualColors = menUt.MenuColors()
local ItemTextColor = menUt.ItemTextColor

----------------------------------------
local uChars = require "Rh_Scripts.Utils.CharsSets"

----------------------------------------
local RDraw = require "Rh_Scripts.RectMenu.RectDraw"
local DrawLineText      = RDraw.DrawLineText
local DrawRectText      = RDraw.DrawRectText
local DrawItemText      = RDraw.DrawItemText
local DrawClearItemText = RDraw.DrawClearItemText
local DrawSeparItemText = RDraw.DrawSeparItemText

--------------------------------------------------------------------------------
--local unit = {}

---------------------------------------- Common

---------------------------------------- ---- Cell
-- Make cell from row and column.
-- Формирование ячейки из строки и столбца.
local function RC_cell (Row, Col)
  return { Row = Row, Col = Col, }
end
--unit.RC_cell = RC_cell

-- Check equality of two cells.
-- Проверка на равенство двух ячеек.
local function RC_iseq (c1, c2) --> (bool)
  return c1 and c2 and c1.Row == c2.Row and c1.Col == c2.Col
end
--unit.RC_iseq = RC_iseq

-- Make cell as copy of other cell.
-- Формирование ячейки как копии другой ячейки.
local function RC_copy (cell) --> (bool)
  return { Row = cell.Row, Col = cell.Col }
end ----
--unit.RC_copy = RC_copy

---------------------------------------- ---- Index

local inc2, divm, swap = numbers.inc2, numbers.divm, numbers.swap

-- Получение двойного индекса из одиночного.
local function i2c (Index, ByCat) --> (Major, Minor)
  return inc2(divm(Index - 1, ByCat))
end
-- Получение одиночного индекса из двойного.
local function c2i (Major, Minor, ByCat) --> (Index)
  return (Major - 1) * ByCat + Minor
end

-- Получение двойного индекса пункта из одиночного.
local function Idx2Cell (Index, Data) --> (Row, Col)
  if Data.Order == "H" then
    return      i2c(Index, Data.Cols)
  else
    return swap(i2c(Index, Data.Rows))
  end
end -- Idx2Cell

-- Получение одиночного индекса пункта из двойного.
local function Cell2Idx (Row, Col, Data) --> (Index)
  if Data.Order == "H" then
    return c2i(Row, Col, Data.Cols)
  else
    return c2i(Col, Row, Data.Rows)
  end
end -- Cell2Idx

---------------------------------------- ---- Span
--local inrange, outrange = numbers.inrange, numbers.outrange

-- Проверка на нахождение значения в пределах.
local function inspan (n, span) --> (bool)
  --return inrange(n, span.Min, span.Max)
  return n >= span.Min and n <= span.Max
end --

-- Проверка на НЕнахождение значения в пределах.
local function outspan (n, span) --> (bool)
  --return outrange(n, span.Min, span.Max)
  return n < span.Min or n > span.Max
end --

-- Получение значения в пределах.
local function tospan (n, span) --> (bool)
  --return torange(n, span.Min, span.Max)
  return n < span.Min and span.Min or
         n > span.Max and span.Max or n
end --

---------------------------------------- Catena
local sqrti = numbers.sqrti

-- Count existing catenas (of menu items).
-- Количество существующих рядов (пунктов меню).
local function MenuCatCount (Majors, Minors, Count) --> (number, number)
  if Count == 0 then return 0, 0 end
  local H, L, C = Majors, Minors, Count -- High, Low, Count

  if not H and not L then return 1, C end

  if (H and H == 0) or (L and L == 0) then
    H = sqrti(C)
    return H, divc(C, H)
  end

  if L and not H then
    if C > L then
      return divc(C, L), L
    else
      return 1, C
    end
  end

  -- if H and (not L or L) then -\/- end
  if C > H then
    return H, divc(C, H)
  else
    return C, 1
  end
end -- MenuCatCount

---------------------------------------- ---- Visibility
local VisibleCatCount = {
  Base = false,
  Pike = false,
} ---

-- Count visible catenas from start.
-- Количество видимых рядов с начала.
--[[
  -- @params:
  Len    (table) - таблица длин рядов.
  Sep   (number) - длина разделителя рядов.
  Total (number) - имеющаяся общая длина для рядов.
  Base  (number) - номер ряда-базы для отсчёта с начала.
  Fixes  (table) - данные о фиксированных рядах.
--]]
function VisibleCatCount.Base (Len, Sep, Total, Base, Fixes) --> (number, number)
  if not Len[Base] then return 0, 0 end

  local Base = tospan(Base, Fixes)
  local k, L = Base, 0
  local Count, Limit = Fixes.Max, Total + Sep - Fixes.Length
  repeat
    L = L + Len[k] + Sep
    k = k + 1
  until k > Count or L > Limit -- end

  k = k - 1
  --local sum = farUt.t_isum(Len, Fixes.Min, k) + Fixes.Length
  --logShow({ k, Total, Sep, L, Limit, Len, Base, sum, Fixes }, "Base", 2)

  local odd = (L <= Limit) -- Поправка:
  L = L - Sep - (odd and 0 or Len[k]) + Fixes.Length
  k = k - Base + 1 - (odd and 0 or 1) + Fixes.Count

  --local sum = farUt.t_isum(Len, Fixes.Min, k - Fixes.Count) + Fixes.Length
  --logShow({ k, Total, Sep, L, sum, Fixes }, "Base", 2)

  -- One cat must be show!
  if k < 1 then
    k = 1
    L = Total
  end

  return k, L
end ---- VisibleCatCount.Base

-- Count visible catenas from end.
-- Количество видимых рядов с конца.
--[[
  -- @params:
  Len    (table) - таблица длин рядов.
  Sep   (number) - длина разделителя рядов.
  Total (number) - имеющаяся общая длина для рядов.
  Pike  (number) - номер ряда-предела для отсчёта с конца.
  Fixes  (table) - данные о фиксированных рядах.
--]]
function VisibleCatCount.Pike (Len, Sep, Total, Pike, Fixes) --> (number, number)
  if not Len[Pike] then return 0, 0 end

  local Pike = tospan(Pike, Fixes)
  local k, L = Pike, 0
  local Count, Limit = Fixes.Min, Total + Sep - Fixes.Length
  --logShow({ k, Total, Sep, L, Limit, Len, Pike, Fixes }, "Pike", 2)
  repeat
    L = L + Len[k] + Sep
    k = k - 1
  until k < Count or L > Limit -- end

  k = k + 1
  --local sum = farUt.t_isum(Len, k, Fixes.Max) + Fixes.Length
  --logShow({ k, Total, Sep, L, Limit, Len, Pike, sum, Fixes }, "Pike", 2)

  local odd = (L <= Limit) -- Поправка:
  L = L - Sep - (odd and 0 or Len[k]) + Fixes.Length
  k = Pike - k + 1 - (odd and 0 or 1) + Fixes.Count

  --local sum = farUt.t_isum(Len, k - Fixes.Count, Fixes.Max) + Fixes.Length
  --logShow({ k, Total, Sep, L, sum, Fixes }, "Pike", 2)

  if k < 1 then k = 1; L = Total end -- One cat must be show!

  return k, L
end ---- VisibleCatCount.Pike

---------------------------------------- Menu class
local TMenu = {
  Guid = win.Uuid("2288381c-bcc7-4a75-8a09-b3fa9403795c"),
} -- Класс меню
local MMenu = { __index = TMenu }

-- Создание объекта класса меню.
local function CreateMenu (Properties, Items, BreakKeys, Additions) --> (object)
  local self = {
    Menu = {
      Props     = Properties,
      Items     = Items,
      BreakKeys = BreakKeys,
      Additions = Additions,
    }, ---
    Props = 0,
    RectMenu = 0,
    Flags = 0,
    Area = 0,
    Titles = { Top = "", Bottom = "", Left = "", Right = "", },

    List = tables.create(#Items),

    Data = {
      Count = 0, Shift = 0,
      checked = false,
      Shape = 0, Order = 0,
      Rows = 0, Cols = 0,
      Seps = 0, RowSep = 0, ColSep = 0,
    }, ---

    HKeys = 0, AKeys = 0, BKeys = 0, -- Быстрые клавиши (hot, accel, break)

    TextMax = 0, LineMax = 0,
    ColWidth = 0, RowHeight = 0,
    FixedRows = 0, FixedCols = 0,
    SelectIndex = 0, SelIndex = 0,

    Zone = {
      Base = 0, Pike = 0,
      BoxGage = 0,
      HomeX = 0, HomeY = 0,
      LastX = 0, LastY = 0,
      EdgeL = 0, EdgeR = 0,
      EdgeT = 0, EdgeB = 0,
      BeltWidth = 0, BeltHeight = 0,
      IndentH = 0, IndentV = 0,
      Width = 0, Height = 0,
      Rows = 0, Cols = 0,
      ScrolledH = 0,  ScrolledV = 0,
      BoxScrollH = 0, BoxScrollV = 0,
      EmbScrollH = 0, EmbScrollV = 0,
      BoxWidth = 0, BoxHeight = 0,
      DlgWidth = 0, DlgHeight = 0,
    }, -- Zone

    Form = 0, DlgFlags = 0, DlgPos = 0,
  } --- self

  return setmetatable(self, MMenu)
end -- CreateMenu

---------------------------------------- Class' methods
-- Проверка на меню.
function TMenu:isMenu (t) --> (bool | nil)
  if type(t) ~= 'table' then return end
  local mt = getmetatable(t._Menu or t)
  return mt and mt.__index == TMenu or false
end ----

-- Проверка на показ меню.
function TMenu:isShow (t) --> (bool | nil)
  if type(t) == 'table' then t = t._Show end
  return t ~= false
end ----

---------------------------------------- Menu dialog

-- Создание формы окна диалога с меню.
function TMenu:DialogForm () --> (dialog)
  local Zone = self.Zone
  return { { F.DI_USERCONTROL,
             Zone.HomeX,
             Zone.HomeY,
             Zone.LastX + Zone.EmbScrollV,
             Zone.LastY + Zone.EmbScrollH,
             0, 0, 0, 0, "" } }
end ---- DialogForm

-- Отображение окна диалога меню.
function TMenu:Dialog ()
  local self = self
  local Pos = self.DlgPos

  local hDlg = far.DialogInit(self.Props.Id or self.Guid,
                              Pos.x, Pos.y, Pos.xw, Pos.yh,
                              nil, self.Form, self.DlgFlags, self.DlgProc)
  local iDlg = far.DialogRun(hDlg)
  far.DialogFree(hDlg)
  --logShow(iDlg, "iDlg")

  return iDlg
end ---- Dialog

-- Выполнение показа меню.
function TMenu:Show (DlgProc)
  local self = self
  self.DlgProc = DlgProc
  local iDlg = self:Dialog()
  --logShow(Result, "Result")
  if iDlg < 0 then return nil, nil end -- Отмена

  local SelIndex = self:GetSelectIndex() -- Выбранный пункт меню
  if self.ChooseKind == "BKey" or self.ChooseKind == "FKey" then
    return self.Menu.BreakKeys[self.KeyIndex], SelIndex
  end
  --logShow({ self.List[self.SelIndex], self.Menu.Items[SelIndex] }, SelIndex, 1)
  return self.Menu.Items[SelIndex], SelIndex
end ---- Show

---------------------------------------- ---- Messages
local SetDlgItem = far.SetDlgItem
local SendDlgMessage = far.SendDlgMessage

-- Закрытие диалога.
local function Close (hDlg, id)
  return SendDlgMessage(hDlg, F.DM_CLOSE, id or -1, 0)
end --

local function CloseDialog (hDlg)
  Close(hDlg)
  return true
end --

local function GetRect (hDlg)
  return SendDlgMessage(hDlg, F.DM_GETDLGRECT, 0)
end --

--[[
-- Управление перерисовкой диалога.
local function Redraw (hDlg, kind)
  return SendDlgMessage(hDlg, F.DM_ENABLEREDRAW, kind)
end --
--]]
local RedrawAll = farUt.RedrawAll -- it's used instead of Redraw

-- Обновление позиции окна меню.
function TMenu:Move_Box (hDlg) --| Menu dialog position
  local Pos = self.DlgPos
  return SendDlgMessage(hDlg, F.DM_MOVEDIALOG, 1, { X = Pos.x, Y = Pos.y })
end --

-- Обновление размеров окна меню.
function TMenu:Resize_Box (hDlg) --| Menu dialog size
  local Pos = self.DlgPos
  return SendDlgMessage(hDlg, F.DM_RESIZEDIALOG, 0, { X = Pos.w, Y = Pos.h })
end --

-- Обновление элементов диалога-меню.
function TMenu:Update_Dlg (hDlg) --| Menu dialog items
  return SetDlgItem(hDlg, 1, self.Form[1])
end ----

---------------------------------------- Menu making
do
  local BoxKindNames = uChars.BoxKindNames

-- Информация о свойствах (и флагах) меню.
function TMenu:DefinePropInfo () --| Props
  local self = self
  -- Определение области/окна FAR.
  self.Area = farUt.GetAreaSize(self.Menu.Additions.FarArea)
  -- self.Area.Width = 80; self.Area.Height = 25 -- TEST only
  -- Корректировка размера.
  --self.Area.Width  = self.Area.Width -- - 2
  self.Area.Height = self.Area.Height + 1 -- - 3
  --logShow(self.Area, "self.Area")

  -- Заданные свойства меню:
  local Props = tables.copy(self.Menu.Props, true, pairs, false) -- MAYBE: clone + true?!
  self.Props = Props -- Свойства

  local RM = Props.RectMenu or {}
  self.RectMenu = RM

  --local MenuOnly = RM.MenuOnly -- Только меню

  -- Ширина края меню:
  local MenuEdge = RM.MenuOnly and 0 or RM.MenuEdge or 2
  if MenuEdge < 0 then MenuEdge = 0 end
  RM.MenuEdge = MenuEdge
  RM.Edges = RM.Edges or {}

  if RM.UncheckedChar then  -- Символ не-метки пункта меню: -- First call!
    RM.UncheckedChar = menUt.checkedChar(RM.UncheckedChar, " ", nil)
  end
  if RM.CheckedChar then    -- Символ метки пункта меню:    -- Second call!
    RM.CheckedChar = menUt.checkedChar(RM.CheckedChar, nil, RM.UncheckedChar)
  end

  -- Оформление меню:
  if RM.MenuOnly then -- Только меню:
    RM.BoxKind = "" -- Без рамки -- без надписей:
    --RM.BoxScroll = nil -- Без прокрутки на рамке.
  else -- Меню в окне:
    local Titles = self.Titles -- Надписи:
    Titles.Top, Titles.Bottom = Props.Title or "Menu", Props.Bottom or ""
    Titles.Left, Titles.Right = RM.LTitle or "", RM.RTitle or ""
    -- Вид рамки (двойная - по умолчанию):
    local BoxKind = RM.BoxKind == false and "" or RM.BoxKind or "D"
    RM.BoxKind = BoxKindNames[BoxKind] or BoxKind
  end

  -- Флаги свойств меню:
  local Flags = Props.Flags or newFlag()
  self.Flags = Flags
  Props.isHot = not isFlag(Flags, F.FMENU_SHOWAMPERSAND)
  --logShow(self.Props, "self.Props")

  -- Цвета меню:
  local Colors = RM.Colors
  if RM.ReuseProps then
    Colors = Colors or MenuUsualColors
  else
    Colors = Colors or {}
    Colors.__index = MenuUsualColors
    setmetatable(Colors, Colors)
  end
  self.Colors = Colors
  Colors.Debug = 0x74
  -- TODO: Завести поле-цвет clear!
  Colors.Form    = Colors.Standard.normal
  Colors.Fixed.Form = Colors.Form
  Colors.Borders = Colors.Borders or Null
  Colors.DlgBox  = Colors.DlgBox or
                   dlgUt.ItemColor(-- Text + Select + Box:
                                   Colors.Standard.normal,
                                   Colors.Standard.hlight,
                                   Colors.Border)

  --logShow(self.Colors, "self.Colors", "d2 x2")
end ---- DefinePropInfo

end -- do

local isItemPicked = menUt.isItem.Picked

-- Информация о списке пунктов меню.
function TMenu:DefineListInfo () --| List
  local self = self
  local Items = self.Menu.Items
  local List, RM = self.List, self.RectMenu
  --local Data, List, RM = self.Data, self.List, self.RectMenu
  local ReuseItems = RM.ReuseItems
  local checked = RM.ShowChecked

  local j, k = 0, 0 -- Счётчики скрытых и видимых пунктов
  for i = 1, #Items do -- Выборка только выводимых пунктов:
    local Item = Items[i]
    if ReuseItems then
      Item.Index = i
      Item.Shift = j
    else
      Item = {
        Index = i,
        Shift = j,
        __index = Item,
      } ---
      setmetatable(Item, Item) -- ^-- i = k + j + 1
    end

    if isItemPicked(Item) then
      j = j + 1 -- is Special!

    else -- no Special:
      k = k + 1
      --assert(k == i - j) -- Visible = Real - Hidden
      List[k] = Item

      -- Свойства пункта:
      local RI = Item.RectMenu or {}
      Item.RectMenu = RI
      RI.TextMark   = RI.TextMark or RM.TextMark -- Маркировка
      RI.TextAlign  = RI.TextAlign or "LT" -- Выравнивание

        -- Многострочность текста пункта:
      if RM.MultiLine == nil then
        RI.MultiLine = nil
      elseif RI.MultiLine == nil then
        RI.MultiLine = RM.MultiLine
      end

      if not checked and Item.checked then checked = true end
    end
  end -- for

  self.Data.Count, self.Data.Shift = k, j
  self.Data.checked = RM.ShowChecked ~= false and checked --or false
  --logShow(self.List, "self.List")
end ----- DefineListInfo

-- Информация о существующей части меню.
function TMenu:DefineDataInfo () --| Data
  local self = self
  local Data, Props, RM = self.Data, self.Props, self.RectMenu
  Data.Shape = RM.Shape or "V" -- Форма меню
  Data.Order = RM.Order or "H" -- Порядок вывода

  -- Число заданных пользователем рядов пунктов
  if Data.Shape == "V" then -- Число реальных рядов пунктов
    Data.Cols, Data.Rows = MenuCatCount(RM.Cols, RM.Rows, Data.Count)
  else -- Data.Shape == "H"
    Data.Rows, Data.Cols = MenuCatCount(RM.Rows, RM.Cols, Data.Count)
  end

  -- Определение наличия разделителей.
  Data.Seps = RM.Separators or ""
  Data.ColSep = Data.Seps:find("V", 1, true) and 1 or 0
  Data.RowSep = Data.Seps:find("H", 1, true) and 1 or 0

  -- Задание выделенного пункта меню.
  local SelIndex = Props.SelectIndex or 1
  SelIndex = SelIndex < 1 and 1 or SelIndex
  --logShow({ Data.Count, Idx2Cell(SelIndex, Data) }, SelIndex)
  if Data.Count > 0 then
    local List, k = self.List, 1 -- Учёт скрытых пунктов:
    while k < Data.Count and List[k].Index < SelIndex do
      k = k + 1
    end
    self.SelectIndex = k
  else
    self.SelectIndex = nil
  end
  --logShow(self.Data, "self.Data")
end ---- DefineDataInfo

do
  local SetMenuHotChars     = menUt.SetMenuHotChars
  local ParseMenuItemsKeys  = menUt.ParseMenuItemsKeys
  local ParseMenuHandleKeys = menUt.ParseMenuHandleKeys

-- Управление специальными комбинациями клавиш.
function TMenu:DefineKeysInfo () --| AKeys, BKeys
  local self = self
  local Data = self.Data
  -- Горячие буквы-клавиши пунктов меню.
  self.HKeys = SetMenuHotChars(self.List, Data.Count, self.Flags)
  -- Клавиши-акселераторы пунктов.
  self.AKeys = ParseMenuItemsKeys(self.List, Data.Count)
  -- Клавиши-прерыватели меню.
  self.BKeys = ParseMenuHandleKeys(self.Menu.BreakKeys)
end ---- DefineKeysInfo

end -- do
do
  -- Convert value to table with field [0].
  -- Преобразование значения в таблицу с полем [0].
  local function valtotab (v) --> (table)
    if type(v) == 'table' then return v end

    return { [0] = v or 0 }
  end ---- valtotab
  --local valtotab = farUt.valtotab

  local FieldMax = menUt.FieldMax
  local ClearHotText = farUt.ClearHotText

  -- Get displayed text of menu item.
  -- Получение отображаемого текста пункта меню.
  local function ViewItemText (Text, Hot) --> (string)
    if Hot then return ClearHotText(Text, Hot) else return Text end
  end --

  local slinemax   = strings.linemax   -- Длина ячейки с учётом многих линий
  local slinecount = strings.linecount -- Высота ячейки с учётом многих линий

-- Информация о пункте и разделителях пунктов меню.
function TMenu:DefineSpotInfo () --| Zone
  local self = self
  --local Data, List = self.Data, self.List
  --local Props, RM = self.Props, self.RectMenu
  local Data, List, RM = self.Data, self.List, self.RectMenu
  local MultiLine = RM.MultiLine -- Многострочность текста пункта

  -- Используемые размеры пункта меню.
  local TextMax = valtotab(RM.TextMax)
  local LineMax = valtotab(RM.LineMax)

  local Count, ColCount, RowCount = Data.Count, Data.Cols, Data.Rows
  local Hot = not isFlag(self.Flags, F.FMENU_SHOWAMPERSAND) and '&'

  -- Определение длины текста по столбцам.
  do
    -- Функция расчёта длины текста по столбцам:
    local function textLen (Item, Index, Selex, Col) --> (bool)
      local _, j = Idx2Cell(Selex, Data)
      if j ~= Col then return 0 end

      local s = Item.text -- Длина текста:
      if not Item.RectMenu.MultiLine then
        return ViewItemText(s, Hot):len()
      else
        return slinemax(ViewItemText(s, Hot))
      end
    end -- textLen

    local DefTextMax = TextMax[0]
    if DefTextMax == 0 then DefTextMax = false end
    for k = 1, ColCount do -- Макс. длина текста:
      if not TextMax[k] then
        TextMax[k] = DefTextMax or FieldMax(List, Count, nil, textLen, k)
      end
    end
  end
  --logShow(TextMax, "TextMax", "w d2")
  if not TextMax[0] or TextMax[0] == 0 then
    TextMax[0] = farUt.t_imax(TextMax) or 0
  end
  --logShow(TextMax, "TextMax")

  -- Определение высоты текста по строкам.
  if MultiLine == nil then
    LineMax[0] = 1
    tables.fillwith(LineMax, RowCount, LineMax[0])

  else
    -- Функция расчёта высоты текста по строкам:
    local function lineLat (Item, Index, Selex, Row) --> (bool)
      local i = Idx2Cell(Selex, Data)
      if i ~= Row then return 0 end

      local s = Item.text -- Высота текста:
      if not Item.RectMenu.MultiLine then
        return 1 -- Одна линия
      else
        return slinecount(ViewItemText(s, Hot))
      end
    end -- lineLat

    local DefLineMax = LineMax[0]
    if DefLineMax == 0 then DefLineMax = false end
    for k = 1, RowCount do -- Макс. высота текста:
      if not LineMax[k] then
        LineMax[k] = DefLineMax or FieldMax(List, Count, nil, lineLat, k)
      end
    end
  end
  --logShow(LineMax, "LineMax", "w d2")
  if not LineMax[0] or LineMax[0] == 0 then
    LineMax[0] = farUt.t_imax(LineMax) or 0
  end
  --logShow(LineMax, "LineMax")

  self.TextMax, self.LineMax = TextMax, LineMax
  -- Максимальные размеры пункта меню.
  self.ColWidth, self.RowHeight = {}, LineMax -- {}
  for k = 0, ColCount do
    self.ColWidth[k] = TextMax[k] + b2n(Data.checked) +
                       (RM.CompactText and 0 or 2) -- (L+R Space)
    --self.RowHeight[k] = LineMax[k] + 0 -- (U+D Space)
  end
  --logShow({ self.TextMax, self.LineMax, self.ColWidth, self.RowHeight }, "Spot", 2)
end ---- DefineSpotInfo

end -- do
do
  local torange = numbers.torange

  -- Задание параметров фиксированных рядов меню.
  local function MakeFixedCats (Cats, Len, Sep, Count) --| Cats
    local Cats = Cats
    if Cats.Head == 0 and Cats.Foot == 0 then return end
    if Count == 0 then
      Cats.Head, Cats.Foot = 0, 0
      return
    end

    local Limit = Count - 1 -- Число:
    Cats.Head = torange(Cats.Head, 0, Limit)
    Cats.Foot = torange(Cats.Foot, 0, Limit)
    if Cats.Head + Cats.Foot > Limit then
      Cats.Head, Cats.Foot = Limit - Cats.Foot, Limit - Cats.Head
    end
    Cats.Count = Cats.Head + Cats.Foot -- Общее число
    Cats.Alter = Count - Cats.Count -- Остаток от него
    if Cats.Count == 0 then return end

    Cats.Min, Cats.Max = Cats.Head + 1, Count - Cats.Foot
    Cats.All, Cats.Sole = Count, Cats.Max + 1
    --logShow(Cats, "Cats", 2)

    -- Суммарная длина (с разделителями):
    if Cats.Head > 0 then
      local Length = 0
      for k = 1, Cats.Head do Length = Length + Len[k] end
      Cats.HeadLen = Length + Cats.Head * Sep
    end
    if Cats.Foot > 0 then
      local Length = 0
      for k = Cats.Sole, Count do Length = Length + Len[k] end
      Cats.FootLen = Length + (Cats.Foot - 1) * Sep
    end
    Cats.Length = Cats.HeadLen + Cats.FootLen
  end -- MakeFixedCats

-- Информация об отображаемой части меню.
function TMenu:DefineZoneInfo () --| Zone
  local self = self
  local Data, Zone, RM = self.Data, self.Zone, self.RectMenu
  local RowCount, ColCount = Data.Rows, Data.Cols

  --do -- Фиксированные ряды меню.
    local Fixed = RM.Fixed or Null -- No change!

    local FixedRows = {
      -- Информация о фиксированных строках
      Head = Fixed.HeadRows or 0, HeadLen = 0,
      Foot = Fixed.FootRows or 0, FootLen = 0,
      Count = 0, Length = 0, Alter = RowCount,
      -- Информация о строках с учётом фиксированности
      All = RowCount, Sole = RowCount + 1,
      Min = min2(1, RowCount), Max = RowCount,
    } ---

    local FixedCols = {
      -- Информация о фиксированных столбцах
      Head = Fixed.HeadCols or 0, HeadLen = 0,
      Foot = Fixed.FootCols or 0, FootLen = 0,
      Count = 0, Length = 0, Alter = ColCount,
      -- Информация о столбцах с учётом фиксированности
      All = ColCount, Sole = ColCount + 1,
      Min = min2(1, ColCount), Max = ColCount,
    } ---

    MakeFixedCats(FixedRows, self.RowHeight, Data.RowSep, RowCount)
    MakeFixedCats(FixedCols, self.ColWidth,  Data.ColSep, ColCount)
    self.FixedRows, self.FixedCols = FixedRows, FixedCols
    --logShow({ self.FixedRows, self.FixedRows }, "Fixed")
  --end --

  local MenuOnly = RM.MenuOnly
  do -- Край, рамка и пояс.

    -- Размеры края окна диалога:
    local Edges = RM.Edges
    local MenuEdge = RM.MenuEdge -- по горизонтали
    Zone.EdgeL = (Edges.Left  or Edges.Width or MenuEdge)
    Zone.EdgeR = (Edges.Right or Edges.Width or MenuEdge)
    MenuEdge = bshr(MenuEdge, 1) -- по вертикали
    Zone.EdgeT = (Edges.Top    or Edges.Height or MenuEdge)
    Zone.EdgeB = (Edges.Bottom or Edges.Height or MenuEdge)

    -- Толщина рамки:
    local BoxGage = (MenuOnly or RM.BoxKind == "") and 0 or 1
    Zone.BoxGage = BoxGage

    -- Верхняя левая позиция зоны:
    Zone.HomeX = Zone.EdgeL + BoxGage
    Zone.HomeY = Zone.EdgeT + BoxGage

    -- Размер зоны, опоясывающей меню:
    Zone.BeltWidth  = Zone.EdgeL + BoxGage + BoxGage + Zone.EdgeR
    Zone.BeltHeight = Zone.EdgeT + BoxGage + BoxGage + Zone.EdgeB
  end --

  do -- Размеры меню окна диалога.
    local MaxWidth  = RM.MaxWidth  or self.Area.Width
    local MaxHeight = RM.MaxHeight or self.Area.Height
    local MinWidth  = min2(RM.MinWidth  or 1, self.Area.Width)
    local MinHeight = min2(RM.MinHeight or 1, self.Area.Height)
    Zone.Width  = max2(MaxWidth,  MinWidth  + Zone.BeltWidth ) - Zone.BeltWidth
    Zone.Height = max2(MaxHeight, MinHeight + Zone.BeltHeight) - Zone.BeltHeight

    -- Корректировка для учёта тени:
    --Zone.Width  = max2(MaxWidth,  MinWidth  + Zone.BeltWidth  + 1) - Zone.BeltWidth  - 1
    --Zone.Height = max2(MaxHeight, MinHeight + Zone.BeltHeight + 1) - Zone.BeltHeight - 1
    -- Отображаемые кол-во рядов и реальные размеры.
    Zone.Cols, Zone.Width  = self:VisibleColCount(1)
    Zone.Rows, Zone.Height = self:VisibleRowCount(1)
    Zone.MenuWidth  = max2(Zone.Width,  MinWidth)
    Zone.MenuHeight = max2(Zone.Height, MinHeight)
    --Zone.LastX and Zone.LastY is defined in DefineDBoxInfo
    --logShow(self.Zone, "self.Zone")
  end --

  do -- Показываемая часть пунктов меню.

    -- Базовый пункт - левый верхний видимый пункт меню. (by default.)
    Zone.Base = { Row = FixedRows.Min, Col = FixedCols.Min } -- Base
    Zone.Pike = { -- Предельная позиция базового пункта меню:
      Row = RowCount - self:VisibleRowCount(RowCount, "Pike") + Zone.Base.Row,
      Col = ColCount - self:VisibleColCount(ColCount, "Pike") + Zone.Base.Col,
    } --- Pike

    -- Уточнение выделенного пункта: -- Поиск подходящего для навигации:
    self.SelIndex = self.SelectIndex and self:FitSelected(self.SelectIndex)

    -- Задание базового пункта для показа выделенного пункта.
    if self.SelIndex then
      local Row, Col = Idx2Cell(self.SelIndex, Data)
      Zone.Base.Row = min2(Row, Zone.Pike.Row)
      Zone.Base.Col = min2(Col, Zone.Pike.Col)
    end
  end --

  do -- Полосы прокрутки.

    -- Необходимость и положение:
    local ScrolledH = ColCount > Zone.Cols
    local ScrolledV = RowCount > Zone.Rows
    local Titles, BoxScroll = self.Titles, RM.BoxScroll
    if BoxScroll then -- Прокрутка вместо надписей:
      if ScrolledH then Titles.Bottom = "" end
      if ScrolledV then Titles.Right  = "" end
    end
    Zone.ScrolledH = ScrolledH
    Zone.ScrolledV = ScrolledV
    Zone.BoxScrollH = not MenuOnly and ScrolledH and
                      BoxScroll ~= false and Titles.Bottom == ""
    Zone.BoxScrollV = not MenuOnly and ScrolledV and
                      BoxScroll ~= false and Titles.Right  == ""
    Zone.EmbScrollH = b2n(ScrolledH and not Zone.BoxScrollH)
    Zone.EmbScrollV = b2n(ScrolledV and not Zone.BoxScrollV)
    --logShow(self.Zone, "self.Zone")
  end --
end ---- DefineZoneInfo

end -- do
do
  local sfind = string.find

-- Информация об окне диалога.
function TMenu:DefineDBoxInfo () --| (Dlg...)
  local self = self
  local Zone, Titles = self.Zone, self.Titles
  --local Data, Zone, Titles = self.Data, self.Zone, self.Titles

  -- Выравнивание меню с учётом надписей.
  local MenuAlign = self.RectMenu.MenuAlign or "TL"
  --MenuAlign = MenuAlign or "R"
  --MenuAlign = MenuAlign or "C"
  Zone.IndentH, Zone.IndentV = 0, 0 -- Нет выравнивания

  do -- Поправка на длину горизонтальных надписей.
    local Length = max2(Titles.Top:len(), Titles.Bottom:len())
    if Length > 0 then Length = Length + 4 end
    Length = max2(Length, Zone.MenuWidth)
    local Delta = Length - Zone.Width -- Избыток пустоты
    --logShow({ Titles, Titles.Top:len(), Titles.Bottom:len(),
    --          Length, Zone.Width, Delta, bshr(Delta, 1) }, "self.Zone")
    if Delta > 0 then -- Выравнивание:
      Zone.Width  = Length
      if     sfind(MenuAlign, "L", 1, true) then
        Zone.IndentH = 0
      elseif sfind(MenuAlign, "R", 1, true) then
        Zone.IndentH = Delta
      else
        Zone.IndentH = bshr(Delta, 1)  end -- "C" --
    end
  end --

  do -- Поправка на длину вертикальных надписей.
    local Length = max2(Titles.Left:len(), Titles.Right:len())
    if Length > 0 then Length = Length + 2 end -- only 2, not 4
    Length = max2(Length, Zone.MenuHeight)
    local Delta = Length - Zone.Height -- Избыток пустоты
    if Delta > 0 then -- Выравнивание:
      Zone.Height = Length
      if     sfind(MenuAlign, "T", 1, true) then
        Zone.IndentV = 0
      elseif sfind(MenuAlign, "B", 1, true) then
        Zone.IndentV = Delta
      else
        Zone.IndentV = bshr(Delta, 1)  end -- "M" --
    end
  end --

  -- Нижняя правая позиция зоны:
  Zone.LastX = Zone.HomeX + Zone.Width  - 1
  Zone.LastY = Zone.HomeY + Zone.Height - 1

  -- Размеры с учётом прокрутки:
  Zone.BoxWidth  = Zone.Width  + Zone.EmbScrollV
  Zone.BoxHeight = Zone.Height + Zone.EmbScrollH
  -- Размеры окна диалога.
  Zone.DlgWidth  = Zone.BoxWidth  + Zone.BeltWidth
  Zone.DlgHeight = Zone.BoxHeight + Zone.BeltHeight
  --logShow(self.Zone, "self.Zone")

  do -- Форма окна:
    -- TODO: Параметр для выравнивания самого окна: Align.
    local RM = self.RectMenu
    self.DlgFlags = RM.MenuOnly and
                    { FDLG_SMALLDIALOG = 1, FDLG_NODRAWSHADOW = 1 } or
                    RM.Shadowed == false and { FDLG_NODRAWSHADOW = 1 } or {}
    local Pos = RM.Position or {} -- Позиция вывода окна:
    Pos = {
      x = Pos.x or -1,
      y = Pos.y or -1,
      w = Zone.DlgWidth,
      h = Zone.DlgHeight,
      xw = 0,
      yh = 0,
      -- Отступ = позиция зоны меню -- !?
      sx = Zone.HomeX,
      sy = Zone.HomeY,
    } ---
    self.DlgPos = Pos

    if Pos.x < 0 then
      local Delta = self.Area.Width - Pos.w
      Pos.x = Delta > 0 and bshr(Delta, 1) or 0
    end
    if Pos.y < 0 then
      local Delta = self.Area.Height - Pos.h
      Pos.y = Delta > 0 and bshr(self.Area.Height - Pos.h, 1) or 0
    end

    Pos.xw = Pos.x + Pos.w - 1
    Pos.yh = Pos.y + Pos.h - 1
    --logShow(self.DlgPos, "Dlg Pos")
  end --

  -- Задание формы окна диалога меню.
  self.Form = self:DialogForm()
  --logShow(self.Form, "Form table", "d2 ft_")
end ---- DefineDBoxInfo

end -- do
----------------------------------------

-- Определение вида меню.
function TMenu:DefineAll () --| (self)
  local self = self
  --logShow(self, "RectMenu", 1)
  -- DO NOT CHANGE ORDER!
  self:DefinePropInfo() --| Props -- Свойства
  self:DefineListInfo() --| List -- Список пунктов меню
  self:DefineDataInfo() --| Data -- Данные о меню
  self:DefineKeysInfo() --| Keys -- Клавиши
  self:DefineSpotInfo() --| Zone -- Место пункта и разделителей
  self:DefineZoneInfo() --| Zone -- Область отображения
  self:DefineDBoxInfo() --| Dlg... -- Сведения об окне диалога
  --logShow(self, "self", "d1 _")
end ---- DefineAll

-- Обновление вида меню.
function TMenu:UpdateAll (hDlg, Flags, Data) --| (self)
  local self = self
  local oldR = self.DlgPos
  local isRedraw = Flags.isRedraw

  --self = 0 -- TODO: Exclude all fields for right new info!?
  self.Menu = {
    Props     = Data[1],
    Items     = Data[2],
    BreakKeys = Data[3],
    Additions = self.Menu.Additions,
  } -- Menu
  self:DefineAll() -- Определение вида меню
  if Flags.isUpdate == false then return end

  local newR = self.DlgPos
  if isRedraw == nil then
    --logShow({ oldR, newR }, "UpdateAll", 2)
    isRedraw = not farUt.isEqual(oldR, newR) and (
               newR.w < oldR.w - oldR.sx or -- Уменьшение ширины окна
               newR.h < oldR.h - oldR.sy or -- Уменьшение высоты окна
               -- Сдвиг окна по горизонтали:
               newR.x > 0 and (newR.x  - oldR.sx > oldR.x or
                               newR.xw + oldR.sx < oldR.xw) or
               -- Сдвиг окна по вертикали:
               newR.y > 0 and (newR.y  - oldR.sy > oldR.y or
                               newR.yh + oldR.sy < oldR.yh)
               ) ---- isRedraw
  end
  --logShow({ Flags, Pos, { isUpdate, isRedraw, isRedrawAll } }, "UpdateAll")

  self:Move_Box(hDlg)
  self:Update_Dlg(hDlg)
  self:Resize_Box(hDlg)
  if isRedraw or Flags.isRedrawAll then RedrawAll() end
  self:Move_Box(hDlg) -- Fix FAR bug!
end ---- UpdateAll

---------------------------------------- Menu operation
local isItemDimmed = menUt.isItem.Dimmed

-- Check index to allowability.
-- Проверка индекса на допустимость.
function TMenu:isIndex (Index) --> (bool)
  local self = self
  return Index and Index > 0 and self.List[Index] and
         -- Недоступный (для управления) пункт:
         not isItemDimmed(self.List[Index])
end ----

-- Check index to scrollability.
-- Проверка индекса на прокрутку.
function TMenu:isScrolled (Index) --> (bool)
  local self = self
  local r, c = Idx2Cell(Index, self.Data)

  return inspan(r, self.FixedRows) and inspan(c, self.FixedCols)
end ----

-- Item index for specified cell.
-- Индекс пункта для заданной ячейки.
function TMenu:CellIndex (Row, Col) --> (Index)
  local Index = Cell2Idx(Row, Col, self.Data)

  return Index > self.Data.Count and 0 or Index
end ----

-- Check index of item for scrollable cell.
-- Проверка индекса пункта для прокручиваемой ячейки.
function TMenu:isScrollIndex (Row, Col) --> (Index)
  local self = self

  if outspan(Row, self.FixedRows) or
     outspan(Col, self.FixedCols) then
    return false
  end

  return self:isIndex(self:CellIndex(Row, Col))
end ----

---------------------------------------- ---- Visible area
-- Count visible rows of menu items.
-- Количество видимых строк пунктов меню.
function TMenu:VisibleRowCount (Row, Kind) --> (number, number)
  local self = self
  return VisibleCatCount[Kind or "Base"](self.RowHeight, self.Data.RowSep,
                                         self.Zone.Height, Row, self.FixedRows)
end ----

-- Count visible columns of menu items.
-- Количество видимых столбцов пунктов меню.
function TMenu:VisibleColCount (Col, Kind) --> (number, number)
  local self = self
  return VisibleCatCount[Kind or "Base"](self.ColWidth,  self.Data.ColSep,
                                         self.Zone.Width,  Col, self.FixedCols)
end ----

-- Count menu items visible in area.
-- Число видимых в области пунктов меню.
function TMenu:VisibleZoneCount () --> (number, number, number)
  local self = self
  local Base = self.Zone.Base

  local VisRows = self:VisibleRowCount(Base.Row)
  local VisCols = self:VisibleColCount(Base.Col)

  return VisRows * VisCols, VisRows, VisCols
end ---- VisibleZoneCount

---------------------------------------- ---- Selected
-- Index for selected menu item or 0.
-- Индекс выбранного пункта меню или 0.
function TMenu:GetSelectIndex () --> (number)
  local self = self
  -- Индекс выделенного пункта меню
  -- не обязательно совпадает с выделенным индексом!
  return self.SelIndex and self.List[self.SelIndex].Index or 0
end ---- GetSelectIndex

-- Define menu item as selected.
-- Выбор пункта меню в качестве выделенного.
function TMenu:SetSelected (SelIndex)
  if SelIndex and self.List[SelIndex] then
    self.SelIndex = SelIndex
  end
  --logShow(self.List, "SelIndex  = "..tostring(self.SelIndex), 1)
end ----

-- Find item suitable for navigation to select.
-- Поиск подходящего для навигации пункта для выделения.
function TMenu:FitSelected (SelIndex) --> (number)
  local self = self
  local List = self.List

  local k = SelIndex
  while k <= self.Data.Count and
        (isItemDimmed(List[k]) or not self:isScrolled(k)) do
    k = k + 1
  end

  if k <= self.Data.Count then return k end

  k = SelIndex - 1
  while k > 0 and
        (isItemDimmed(List[k]) or not self:isScrolled(k)) do
    k = k - 1
  end
  --logShow({ k, self.Data.Count, { Idx2Cell(k, self.Data) } }, "FitSelected")

  return k > 0 and k or nil
end ---- FitSelected

---------------------------------------- ---- Find / Goto
do
-- Get cell with allowable index value.
-- Получение ячейки с допустимым значением индекса.
function TMenu:FitCell (Row, Col) --> (Row, Col)
  local self = self

  -- Поиск по строке:
  local Row = Row
  do
    local Fixes = self.FixedRows
    if Row < Fixes.Min then
      Row = Fixes.Min
      while not self:isScrollIndex(Row, Col) do
        Row = Row + 1
      end

    elseif Row > Fixes.Max then
      Row = Fixes.Max
      while not self:isScrollIndex(Row, Col) do
        Row = Row - 1
      end
    end -- if
  end

  -- Поиск по столбцу:
  local Col = Col
  do
    local Fixes = self.FixedCols
    if Col < Fixes.Min then
      Col = Fixes.Min
      while not self:isScrollIndex(Row, Col) do
        Col = Col + 1
      end

    elseif Col > Fixes.Max then
      Col = Fixes.Max
      while not self:isScrollIndex(Row, Col) do
        Col = Col - 1
      end
    end -- if
  end

  return Row, Col
end ---- FitCell

-- Define cell considering scrollability.
-- Определение ячейки с учётом прокрутки.
function TMenu:WrapCell (Row, Col, dRow, dCol) --> (Cell)
  local self = self
  local Row, Col = Row, Col

  if dRow ~= 0 then -- Ячейка по строкам:
    local Cell, _
    local Fixes = self.FixedRows
    --logShow({ Cell, RC_cell(Row, Col) }, "dRow ~= 0")
    if outspan(Row, Fixes) then
      Cell = { Row = Row }
    else
      _, Cell = self:FindRowCell(Row, Col, dRow)
    end
    --logShow({ Cell, RC_cell(Row, Col), { Fixes.Min, Fixes.Max } }, "dRow ~= 0")

    if Cell then
      Row = Cell.Row -- Поиск:
      if Row > Fixes.Max or
         (Row == Fixes.Max and self:CellIndex(Row, Col) == 0) then
        Row = Fixes.Min - 1
      elseif Row < Fixes.Min then
        Row = Fixes.Max + 1
      end
    else
      if dRow > 0 then
        Row = Fixes.Min - 1
      elseif dRow < 0 then
        Row = Fixes.Max + 1
      end
    end
  end

  if dCol ~= 0 then -- Ячейка по столбцам:
    local Cell, _
    local Fixes = self.FixedCols
    if outspan(Col, Fixes) then
      Cell = { Col = Col }
    else
      _, Cell = self:FindColCell(Row, Col, dCol)
    end

    if Cell then
      Col = Cell.Col -- Поиск:
      if Col > Fixes.Max or
         (Col == Fixes.Max and self:CellIndex(Row, Col) == 0) then
        Col = Fixes.Min - 1
      elseif Col < Fixes.Min then
        Col = Fixes.Max + 1
      end
    else
      if dCol > 0 then
        Col = Fixes.Min - 1
      elseif dCol < 0 then
        Col = Fixes.Max + 1
      end
    end
  end
  --logShow(RC_cell(Row, Col), "WrapCell")

  return self:FitCell(Row, Col)
end ---- WrapCell

-- Получение подходящей ячейки по строке.
function TMenu:FindRowCell (Row, Col, dRow) --> (Index, Cell)
  --assert(dRow > 0)
  local self = self
  local Fixes = self.FixedRows
  while not self:isIndex(self:CellIndex(Row, Col)) do
    Row = Row + dRow
    if outspan(Row, Fixes) then return end
  end

  return self:CellIndex(Row, Col), RC_cell(Row, Col)
end ---- FindRowCell

-- Получение подходящей ячейки по столбцу.
function TMenu:FindColCell (Row, Col, dCol) --> (Index, Cell)
  --assert(dCol > 0)
  local self = self
  local Fixes = self.FixedCols
  while not self:isIndex(self:CellIndex(Row, Col)) do
    Col = Col + dCol
    if outspan(Col, Fixes) then return end
  end

  return self:CellIndex(Row, Col), RC_cell(Row, Col)
end ---- FindColCell

-- Получение подходящей ячейки.
function TMenu:FindCell (Row, Col, dRow, dCol) --> (Index, Cell)
  local Index, aCell

  if dRow ~= 0 then
    Index, aCell = self:FindRowCell(Row, Col, dRow)
  end

  -- TODO: Скорректировать при одновременном поиске по двум направлениям.
  --if Index then Row, Col = aCell.Row, aCell.Col end -- ???
  if dCol ~= 0 then
    Index, aCell = self:FindColCell(Row, Col, dCol)
  end

  return Index, aCell
end ---- FindCell

-- Define new selected menu item.
-- Определение нового выделенного пункта меню.
--[[
  -- @params:
  aCell  (cell) - абсолютное значение текущей / желаемой позиции.
  dCell  (cell) - относительное значение желаемого смещения.
  isNew  (bool) - вид позиции aCell: nil/false - текущая, true - желаемая.
  isWrap (bool) - цикличность прокрутки.
--]]
function TMenu:GotoCell (aCell, dCell, isNew, isWrap) --> (SelIndex, Cell)
  local self = self
  --logShow({ aCell, dCell, isNew, isWrap }, "GotoCell")
  --if not isWrap then logShow({ aCell, dCell, isNew, isWrap }, "GotoCell") end

  -- Выбор начального нового пункта меню.
  local R, C = aCell.Row, aCell.Col
  local dR, dC = dCell.Row, dCell.Col

  if isNew then
    dR, dC = -dR, -dC
  else
    R, C = R + dR, C + dC
    -- Корректировка ячейки в зависимости от шага.
    if abs(dR) > 1 or abs(dC) > 1 then
      R, C = self:FitCell(R, C) -- Допустимая ячейка
      --logShow(RC_cell(R, C), "Fitting")

    else -- Единичный шаг перемещения:
      --logShow(RC_cell(R, C), "Single step")
      if isWrap and dCell.canWrap and
         isFlag(self.Flags, F.FMENU_WRAPMODE) then
        R, C = self:WrapCell(R, C, dR, dC) -- Циклическая прокрутка
        --logShow(RC_cell(R, C), "Wrapping")

      elseif abs(dR) == 1 and abs(dC) == 1 then
        --logShow(RC_cell(R, C), "1 / 1")
        local outR = outspan(R, self.FixedRows)
        local outC = outspan(C, self.FixedCols)
        --logShow({ outR = outR, outC = outC, }, "outspan")
        if outR and outC then return end

        if outR then return self:FindCell(aCell.Row, C, 0, dC) end
        if outC then return self:FindCell(R, aCell.Col, dR, 0) end

      else
        -- Выход без изменения, если вне области.
        if outspan(R, self.FixedRows) then return end
        if outspan(C, self.FixedCols) then return end
      end
    end
  end -- if isNew

  -- Поиск подходящего нового пункта меню.
  dR, dC = sign(dR), sign(dC)
  --logShow({ RC_cell(R, C), RC_cell(dR, dC) }, "FindCell")
  local Index, Cell = self:FindCell(R, C, dR, dC) -- Прямо и обратно!
  --logShow(Cell, "FindCell: "..tostring(self:isIndex(Index)))
  if not self:isIndex(Index) then
    Index, Cell = self:FindCell(R, C, -dR, -dC)
  end
  --logShow(Cell, "FindCell: "..tostring(self:isIndex(Index)))

  return Index, Cell
end ---- GotoCell

-- Define base item to show selected menu item.
-- Определение базового пункта для показа выделенного пункта меню.
function TMenu:CellBase (aCell) --| Zone.Base
  local self = self
  -- Выбор начального базового пункта меню.
  local Cell = aCell
  local Base, Pike = self.Zone.Base, self.Zone.Pike

  -- Поиск подходящего базового пункта меню.
  if Cell.Row < Base.Row then
    Base.Row = Cell.Row -- Верхняя строка
  else                  -- Нижняя  строка:
    local Fixes = self.FixedRows
    local Cat = self:VisibleRowCount(Cell.Row, "Pike") - Fixes.Count
    Cat = Cell.Row - Cat + 1
    --logShow({ Base, Pike, Cell }, "Row: "..tostring(Row))
    if Cat > Base.Row then
      Base.Row = min2(Cat, Pike.Row)
    end
  end

  if Cell.Col < Base.Col then
    Base.Col = Cell.Col -- Левый  столбец
  else                  -- Правый столбец:
    local Fixes = self.FixedCols
    local Cat = self:VisibleColCount(Cell.Col, "Pike") - Fixes.Count
    Cat = Cell.Col - Cat + 1
    --logShow({ Base, Pike, Cell }, "Col: "..tostring(Col))
    if Cat > Base.Col then
      Base.Col = min2(Cat, Pike.Col)
    end
  end
  --logShow({ Base, Cell }, "Cells")
end ---- CellBase

-- Change base menu item (to show unallowable items).
-- Изменение базового пункта меню (для показа недоступных пунктов).
function TMenu:MoveBase (dCell, aBase) --| Zone.Base
  local self = self
  local Base, Pike = self.Zone.Base, self.Zone.Pike

  -- Выбор базового пункта меню.
  local Cell = RC_copy(aBase or Base) -- TEMP: aBase is not used now!
  if dCell then
    Cell = { -- Корректировка нового базового пункта:
      Row = tospan(Cell.Row + dCell.Row, self.FixedRows),
      Col = tospan(Cell.Col + dCell.Col, self.FixedCols),
    } -- Cell
  end
  --logShow({ Base, Cell }, "Cells")

  -- Установка базового пункта меню.
  Base.Row = min2(Cell.Row, Pike.Row)
  Base.Col = min2(Cell.Col, Pike.Col)
end ---- MoveBase

-- Move to other cell.
-- Переход на другую ячейку.
function TMenu:MoveToCell (hDlg, NewIndexCell, Kind) --> (bool)
  local self = self
  local OldIndex = self.SelIndex
  local oCell = RC_cell(Idx2Cell(OldIndex, self.Data))
  local dCell, NewIndex, nCell = NewIndexCell(oCell)

  if NewIndex == false then return false end
  if NewIndex == nil then
    NewIndex, nCell = OldIndex, oCell
  end
  --logShow({ OldIndex, Base, oCell, nCell, dCell }, NewIndex)

  if RC_iseq(oCell, nCell) then
    self:MoveBase(dCell)
  end
  self:CellBase(nCell)
  self:SetSelected(NewIndex)

  self:SelectItem(hDlg, Kind, self:GetSelectIndex())

  return self:DoMenuDraw() -- Перерисовка меню
end ---- MoveToCell

end -- do
---------------------------------------- Event

-- Обработка пользовательского события.
function TMenu:HandleEvent (Event, hDlg, ...) --> (nil|boolean)
  local self = self
  local RunEvent = self.RectMenu[Event]
  if not RunEvent then return end

  local Data, Flags = RunEvent(...)
  --logShow({ Data, Flags }, Event, 2)
  Flags = Flags or Null -- or {}
  if Flags.isCancel then
    self.SelIndex = nil
  end
  if Flags.isClose or Flags.isCancel then
    return CloseDialog(hDlg)
  end

  if type(Data) == 'table' then
    self:UpdateAll(hDlg, Flags, Data)
    return true
  end

  return Data
end ---- HandleEvent

---------------------------------------- Keyboard
local ParseKeyName = keyUt.ParseKeyName
local IsModCtrl, IsModAlt = keyUt.IsModCtrl, keyUt.IsModAlt
local IsModShift, IsModAltShift = keyUt.IsModShift, keyUt.IsModAltShift

local Shifts = {
  Z  = { Row =  0, Col =  0, },
  L  = { Row =  0, Col = -1, canWrap = true, },
  U  = { Row = -1, Col =  0, canWrap = true, },
  R  = { Row =  0, Col =  1, canWrap = true, },
  D  = { Row =  1, Col =  0, canWrap = true, },

  H  = { Row = -1, Col = -1, isNew = true, },
  E  = { Row =  1, Col =  1, isNew = true, },

  LU = { Row = -1, Col = -1, },
  LD = { Row =  1, Col = -1, },
  RU = { Row = -1, Col =  1, },
  RD = { Row =  1, Col =  1, },
} --- Shifts

-- Информация о перемещении курсора по ячейкам при нажатии клавиш.
--[[
  -- @return:
  1. Относительная величина для обычного перемещения.
  2. Абсолютная величина отсчёта обычного перемещения.
  3. Абсолютная величина отсчёта "прыжкового" перемещения.
--]]
function TMenu:ArrowKeyToCell (oCell, aKey) --> (cell, cell, cell)
  local self = self
  local Data, Zone = self.Data, self.Zone
  local Base = self.Zone.Base

  local rMin, rMax = self.FixedRows.Min, self.FixedRows.Max
  local cMin, cMax = self.FixedCols.Min, self.FixedCols.Max
  local rSum, cSum = self.FixedRows.Count, self.FixedCols.Count

  -- Выбор "листания" меню по горизонтали / вертикали.
  local ListByDef = Data.Rows > Zone.Rows or Data.Rows > 1 and
                   (Data.Rows <= Zone.Rows and Data.Cols <= Zone.Cols)
  --far.Message(ListByDef, "ListByDef")

  local Last = self.Last
  --[[
  local Last = { -- Последняя видимая ячейка:
    Row = Base.Row + self:VisibleRowCount(Base.Row) - rSum - 1,
    Col = Base.Col + self:VisibleColCount(Base.Col) - cSum - 1,
  } ---
  --]]
  --logShow({ oCell, VisRows, VisCols, Last }, "Arrow Cell Data")

  local KeydCell = {

    Left = function ()
      return Shifts.L, oCell, { Row = oCell.Row, Col = cMin, }
    end,

    Up = function ()
      return Shifts.U, oCell, { Row = rMin, Col = oCell.Col, }
    end,

    Right = function ()
      return Shifts.R, oCell, { Row = oCell.Row, Col = cMax, }
    end,

    Down = function ()
      return Shifts.D, oCell, { Row = rMax, Col = oCell.Col, }
    end,

    Clear = function () return Shifts.Z, oCell, oCell end, -- Clear

    Home = function ()
      local nCell = RC_iseq(oCell, Base) and
        { Row = Base.Row -
                self:VisibleRowCount(Base.Row, "Pike") + rSum + 1,
          Col = Base.Col -
                self:VisibleColCount(Base.Col, "Pike") + cSum + 1, } or
        { Row = Base.Row, Col = Base.Col, } -- nCell
      --logShow({ oCell, nCell }, "Cells")
      return Shifts.H, { Row = rMin, Col = cMin, }, nCell
    end, -- Home

    End = function ()
      local nCell = RC_iseq(oCell, Last) and
        { Row = Last.Row +
                self:VisibleRowCount(oCell.Row, "Base") - rSum - 1,
          Col = Last.Col +
                self:VisibleColCount(oCell.Col, "Base") - cSum - 1, } or
        Last -- nCell
      return Shifts.E, { Row = rMax, Col = cMax, }, nCell
      --return Shifts.E, RC_cell(Idx2Cell(Data.Count, Data)), nCell
    end, -- End

    PgUp = function ()
      local dCell = ListByDef and
        (oCell.Row == rMin and Shifts.Z or
         Base.Row == oCell.Row and
         { Row = -self:VisibleRowCount(Base.Row, "Pike") + rSum, Col = 0, } or
         { Row = Base.Row - oCell.Row,                           Col = 0, }) or
        (oCell.Col == cMin and Shifts.Z or
         Base.Col == oCell.Col and
         { Row = 0, Col = -self:VisibleColCount(Base.Col, "Pike") + cSum, } or
         { Row = 0, Col = Base.Col - oCell.Col,                           })
      return dCell, oCell, ListByDef and
             { Row = rMin, Col = oCell.Col, } or
             { Row = oCell.Row, Col = cMin, }
    end, -- Page Up

    PgDn  = function ()
      local dCell = ListByDef and
        (oCell.Row == rMax and Shifts.Z or
         Last.Row == oCell.Row and
         { Row = self:VisibleRowCount(Last.Row, "Base") - rSum, Col = 0, } or
         { Row = Last.Row - oCell.Row,                          Col = 0, }) or
        (oCell.Col == cMax and Shifts.Z or
         Last.Col == oCell.Col and
         { Row = 0, Col = self:VisibleColCount(Last.Col, "Base") - cSum, } or
         { Row = 0, Col = Last.Col - oCell.Col,                          })
      return dCell, oCell, ListByDef and
             { Row = rMax,      Col = oCell.Col, } or
             { Row = oCell.Row, Col = cMax,      }
    end, -- Page Down

    LeftUp      = function () return Shifts.LU, oCell, oCell end,
    LeftDown    = function () return Shifts.LD, oCell, oCell end,
    RightUp     = function () return Shifts.RU, oCell, oCell end,
    RightDown   = function () return Shifts.RD, oCell, oCell end,

  } --- KeydCell

  return KeydCell[aKey]()
end ---- ArrowKeyToCell

-- Проверка на используемость клавиш-стрелок.
function TMenu:CheckArrowUse (AKey) --> (bool)
  if     AKey == "Left" or AKey == "Right" then
    return self.Data.Cols > 1
  elseif AKey == "Up"   or AKey == "Down"  then
    return self.Data.Rows > 1
  end

  return true
end ---- CheckArrowUse

-- Обработка клавиш курсора в меню.
function TMenu:ArrowKeyPress (hDlg, AKey, VMod, isWrap) --> (bool)

  -- Переход на новую ячейку по нажатию клавиши.
  local function KeyPressCell (OldCell) --> (table, number, table)

    local self = self
    local dCell, bCell, jCell = self:ArrowKeyToCell(OldCell, AKey)

    if IsModCtrl(VMod) then -- CTRL:
      if not jCell then return false end
      --logShow({ jCell, dCell }, "Cells (CTRL)")
      return dCell, self:GotoCell(jCell, dCell, true, isWrap)
    end

    -- Без модификаторов:
    if not bCell then return false end
    --logShow({ bCell, dCell }, "Cells (No mods)")

    return dCell, self:GotoCell(bCell, dCell, dCell.isNew, isWrap)
  end --

  return self:MoveToCell(hDlg, KeyPressCell, AKey)
end ---- ArrowKeyPress

local UnhotSKeys = {
  [""]      = true,
  [" "]     = true,
  ["Space"] = true,
} ---

-- Обработка быстрых клавиш в меню.
function TMenu:RapidKeyPress (hDlg, VirKey) --> (bool)
  local self = self
  local RM = self.RectMenu
  --local Ctrl, RM = self.Ctrl, self.RectMenu
  if RM.NoRapidKey then return end -- TODO: --> Doc!

  local StrKey = VirKey.Name
  --logShow(VirKey, StrKey)

  -- 1. Обработка AccelKeys.
  local Index = self.AKeys[StrKey]
  --logShow({ Index, self.AKeys }, StrKey, "d1 xv8")
  if Index then
    self:SetSelected(Index)
    --logShow(StrKey, "Index: "..tostring(Index))
    return self:ChooseItem(hDlg, "AKey", Index)
  end

  -- 2. Обработка Hot Chars.
  local VMod = VirKey.ControlKeyState
  --logShow({ VirKey, StrKey, self.HKeys }, "Check HKeys", "d1 xv8")
  if ( RM.AltHotOnly and (IsModAlt(VMod) or IsModAltShift(VMod)) ) or
     ( not RM.AltHotOnly and (VMod == 0 or IsModShift(VMod)) ) then
    local SKey = VirKey.UnicodeChar:upper()
    --logShow({ VirKey, StrKey, self.HKeys }, "HKeys : "..tostring(SKey), "d1 xv8")
    if SKey and not UnhotSKeys[SKey] then
      local Index = self.HKeys:cfind(SKey, 1, true)
      local VName = VirKey.KeyName
      --logShow({ Index, VName, self.HKeys }, tostring(SKey), "d1 xv8")
      if not Index and VName:len() == 1 then
        -- Использование латинской буквы
        SKey = VName:upper()
        if SKey and SKey ~= "" then
          Index = self.HKeys:cfind(SKey, 1, true)
        end
      end
      --logShow(self.HKeys, "HKeys : "..tostring(SKey).." at "..tostring(Index), "d1 xv8")
      if Index then
        self:SetSelected(Index)
        return self:ChooseItem(hDlg, "HKey", Index)
      end
    end
  end

  -- 3. Обработка BreakKeys.
  Index = self.BKeys[StrKey]
  --logShow({ Index, self.BKeys }, StrKey, "d1 x8")
  if Index then
    self.KeyIndex = Index
    return self:ChooseItem(hDlg, "BKey", Index)
  end

  return false
end ---- RapidKeyPress

-- Пользовательская обработка клавиш навигации.
function TMenu:UserNavKeyPress (hDlg, AKey, VMod) --> (nil|true | Data)
  local self = self
  local OnNavKeyPress = self.RectMenu.OnNavKeyPress
  if not OnNavKeyPress then return end

  local Data, AKey, Mod, Flags =
    OnNavKeyPress(AKey, VMod, self:GetSelectIndex())
  --logShow({ AKey, Table, Flags }, "OnArrowKeyPress", "w d2")
  Flags = Flags or Null -- or {}

  if type(Data) == 'table' then
    self:UpdateAll(hDlg, Flags, Data)
    return true
  end

  return Data, AKey, Mod
end ---- UserNavKeyPress

-- Пользовательская обработка клавиш.
function TMenu:UserKeyPress (hDlg, VirKey, Index) --> (nil|true | Data)
  return self:HandleEvent("OnKeyPress", hDlg, VirKey, Index)
end ---- UserKeyPress

-- Обработчик нажатия клавиши.
function TMenu:DoKeyPress (hDlg, VirKey) --> (bool)
  local self = self
  --logShow(self, "self", 1)
  local SelIndex = self.SelIndex
  --logShow(VirKey, SelIndex, "d1 x8")

  self.DebugClickChar = "K"

  -- 1. Обработка выбора курсором.
  if SelIndex then -- (только при наличии выделения)

    -- Корректировка: Numpad / MSWheel --> Arrow keys
    local AKey = VirKey.KeyName
    AKey = keyUt.SKEY_NumpadNavs[AKey] or
           keyUt.SKEY_MSWheelNavs[AKey] or AKey
    --logShow(VirKey, AKey, "w d1 x8")
    local VMod = keyUt.GetModBase(VirKey.ControlKeyState)
    --logShow({ AKey, VMod, VirKey }, SelIndex, "h8d1")

    local isOk, NewKey, NewMod = self:UserNavKeyPress(hDlg, AKey, VMod)
    if isOk then return isOk end
    --if isOk ~= nil then return isOk end -- TODO: TEST
    --logShow({ AKey, VMod, isOk, NewKey, NewMod }, SelIndex, "w h8 d1")

    AKey, VMod = NewKey or AKey, NewMod or VMod

    if keyUt.SKEY_ArrowNavs[AKey] and -- Управление курсором:
       (VMod == 0 or IsModCtrl(VMod)) and self:CheckArrowUse(AKey) then
      --logShow({ AKey, VMod }, SelIndex, "w h8 d1")
      return self:ArrowKeyPress(hDlg, AKey, VMod, true)
    end

  end -- if SelIndex

  -- 2. Обработка быстрого выбора.
  local isOk = self:RapidKeyPress(hDlg, VirKey)
  if isOk then return isOk end

  -- 3. Пользовательская обработка
  isOk = self:UserKeyPress(hDlg, VirKey, self:GetSelectIndex())
  if isOk then return isOk end

  return false
end ---- DoKeyPress

---------------------------------------- ---- Mouse

-- Convert mouse cursor position to cat number.
-- Преобразование позиции курсора мыши в номер ряда.
--[[
  -- @params:
  Len    (table) - таблица длин рядов.
  Sep   (number) - длина разделителя рядов.
  Total (number) - имеющаяся общая длина для рядов.
  Pos   (number) - позиция курсора мыши для отсчёта с начала.
  Base  (number) - номер ряда-базы для отсчёта с начала.
  Fixes  (table) - данные о фиксированных рядах.
--]]
local function MousePosToCat (Len, Sep, Total, Pos, Base, Fixes) --> (number)
  if Pos >= Total then
    return #Len + 1
  end

  local k, L = Base, Fixes.HeadLen
  local Count = Fixes.Max
  repeat
    L = L + Len[k] + Sep
    k = k + 1
  until k > Count or L > Pos

  k = k - 1
  --logShow({ k, Total, Sep, L, Pos, Len, Base, Fixes }, "MousePosToCat", 2)

  return k
end -- MousePosToCat

--[[
-- Проверка позиции курсора мыши за областью прокрутки.
local function CheckMouseOut (Sep, Total, Pos, Fixes, Less, More) --> (string)
  if Fixes.Head > 0 and Pos <= Fixes.HeadLen then
    return Less
  end
  if Fixes.Foot > 0 and Pos >= Total + Sep - Fixes.FootLen then
    return More
  end

  return ""
end -- CheckMouseOut
--]]

-- Обработка обычного нажатия левой кнопки мыши в меню.
function TMenu:MouseBtnClick (hDlg, Input) --> (bool)
  local self = self
  self.DebugClickChar = "M"

  local x, y = Input.x, Input.y

  --[[
  local AKey = CheckMouseOut(self.Data.ColSep, self.Zone.Width,
                             x, self.FixedCols, "Left", "Right")..
               CheckMouseOut(self.Data.RowSep, self.Zone.Height,
                             y, self.FixedRows, "Up", "Down")
  --logShow({ x, y, }, AKey, 2)
  if AKey ~= "" then
    return self:ArrowKeyPress(hDlg, AKey, 0, false)
  end
  --]]

  --[[ -- DEBUG
  local r = MousePosToCat(self.RowHeight, self.Data.RowSep,
                          self.Zone.Height, y,
                          self.Zone.Base.Row, self.FixedRows)
  local c = MousePosToCat(self.ColWidth,  self.Data.ColSep,
                          self.Zone.Width,  x,
                          self.Zone.Base.Col, self.FixedCols)
  --]]

  -- Переход на новую ячейку по нажатию кнопки мыши.
  local function MouseClickCell (OldCell) --> (table, number, table)
    local self = self
    local bCell = {
      Row = MousePosToCat(self.RowHeight, self.Data.RowSep,
                          self.Zone.Height, y,
                          self.Zone.Base.Row, self.FixedRows),
      Col = MousePosToCat(self.ColWidth,  self.Data.ColSep,
                          self.Zone.Width,  x,
                          self.Zone.Base.Col, self.FixedCols),
    } ---
    local dCell = {
      Row = sign(bCell.Row - OldCell.Row),
      Col = sign(bCell.Col - OldCell.Col),
    } ---

    return dCell, self:GotoCell(bCell, dCell, true, false)
  end --

  return self:MoveToCell(hDlg, MouseClickCell, "Click")
end ---- MouseBtnClick

-- Обработка двойного нажатия левой кнопки мыши в меню.
function TMenu:MouseDblClick (hDlg, Input) --> (bool)
  local self = self
  self.DebugClickChar = "D"

  --local x, y = Input.x, Input.y

  return self:DefaultChooseItem(hDlg, "DblClick")
end ---- MouseDblClick

function TMenu:MouseBorderClick (hDlg, Input)
  local self = self
  self.DebugClickChar = "B"

  local Data = self:HandleEvent("OnBorderClick", hDlg, Input)
  if type(Data) ~= 'table' and
     self.RectMenu.IsDebugDraw then
    self:DoMenuDraw() -- Перерисовка меню
  end

  return Data
end ---- MouseBorderClick

function TMenu:MouseEdgeClick (hDlg, Input)
  local self = self
  self.DebugClickChar = "E"

  local Data = self:HandleEvent("OnEdgeClick", hDlg, Input)
  if type(Data) ~= 'table' and
     self.RectMenu.IsDebugDraw then
    self:DoMenuDraw() -- Перерисовка меню
  end

  return Data
end ---- MouseEdgeClick

---------------------------------------- ---- Scroll
do
-- Convert scroll position to cat number.
-- Преобразование позиции прокрутки в номер ряда.
local function ScrollPosToCat (ALen, Pos, Cats, Bar) --> (number)
  --logShow({ ALen, Cats }, Pos, 2)
  if ALen == 1 then return 1 end
  --Pos = max2(Pos - max2(bshr(Bar.Len, 1), 1), 0)
  --return min2(divr( Pos * (Cats.Alter - 1), (ALen - 1) ) +
  --            Cats.Min, Cats.Max)

  return min2(divr( (Pos - 1) * (Cats.Alter - 1), (ALen - 1) ) +
              Cats.Min, Cats.Max)
end -- ScrollPosToCat

-- Обработка горизонтальной прокрутки.
function TMenu:ScrollHClick (hDlg, Input)
  local self = self
  self.DebugClickChar = "H"

  local pos = Input.X
  local Bar = self.ScrollBars.ScrollH
  --logShow(Bar, pos, 2)
  if pos < Bar.X1 or pos > Bar.X2 then return false end

  if     pos == Bar.X1 then
    return self:ArrowKeyPress(hDlg, "Left", 0, true)
  elseif pos == Bar.X2 then
    return self:ArrowKeyPress(hDlg, "Right", 0, true)
  end
  pos = pos - Bar.X1

  local function ScrollHCell (OldCell) --> (table, number, table)
    local bCell = {
      Row = OldCell.Row,
      Col = ScrollPosToCat(Bar.Length, pos, self.FixedCols, Bar),
    } ---
    local dCell = pos < Bar.Pos + bshr(Bar.Len, 1) and Shifts.L or Shifts.R

    return dCell, self:GotoCell(bCell, dCell, true, true)
  end --

  return self:MoveToCell(hDlg, ScrollHCell, "ScrollH")
end ---- ScrollHClick

-- Обработка вертикальной прокрутки.
function TMenu:ScrollVClick (hDlg, Input)
  local self = self
  self.DebugClickChar = "V"

  local pos = Input.Y
  local Bar = self.ScrollBars.ScrollV
  --logShow(Bar, pos, 2)
  if pos < Bar.Y1 or pos > Bar.Y2 then return false end

  if     pos == Bar.Y1 then
    return self:ArrowKeyPress(hDlg, "Up", 0, true)
  elseif pos == Bar.Y2 then
    return self:ArrowKeyPress(hDlg, "Down", 0, true)
  end
  pos = pos - Bar.Y1

  local function ScrollVCell (OldCell) --> (table, number, table)
    local bCell = {
      Col = OldCell.Col,
      Row = ScrollPosToCat(Bar.Length, pos, self.FixedRows, Bar),
    } ---
    local dCell = pos < Bar.Pos + bshr(Bar.Len, 1) and Shifts.U or Shifts.D
    --logShow({ OldCell, bCell, dCell, Bar, FixRows }, pos)

    return dCell, self:GotoCell(bCell, dCell, true, true)
  end --

  return self:MoveToCell(hDlg, ScrollVCell, "ScrollV")
end ---- ScrollVClick

-- Обработка "пересечения" полос прокрутки.
function TMenu:ScrollXClick (hDlg, Input)
  local self = self
  self.DebugClickChar = "X"

  local Data = self:HandleEvent("OnScrollXClick", hDlg, Input)
  if type(Data) ~= 'table' and
     self.RectMenu.IsDebugDraw then
    self:DoMenuDraw() -- Перерисовка меню
  end

  return Data
end ---- ScrollXClick

end -- do
---------------------------------------- ---- Action

-- Пользовательская обработка выделения пункта.
function TMenu:SelectItem (hDlg, Kind, Index) --> (nil|boolean)
  self.SelectKind = Kind
  --[[local OnSelectItem = self.RectMenu.OnSelectItem

  if OnSelectItem then
    OnSelectItem(Kind, Index)
  end

  return true]]

  return self:HandleEvent("OnSelectItem", hDlg, Kind, Index)
end ---- SelectItem

-- Пользовательская обработка выбора пункта.
function TMenu:ChooseItem (hDlg, Kind, Index, ...) --> (nil|boolean)
  self.ChooseKind = Kind

  if not self.RectMenu.OnChooseItem then
    return CloseDialog(hDlg)
  end

  return self:HandleEvent("OnChooseItem", hDlg, Kind, Index, ...)
end ---- ChooseItem

-- Обработка выбора пункта по умолчанию.
function TMenu:DefaultChooseItem (hDlg, Kind, ...) --> (bool)
  local self = self
  local SelIndex = self.SelIndex
  --logShow(self.List[SelIndex], SelIndex)

  -- Исключение обработки "серых" пунктов меню:
  if SelIndex and self.List[SelIndex].grayed then return true end

  return self:ChooseItem(hDlg, Kind, self:GetSelectIndex(), ...)
end ---- DefaultChooseItem

---------------------------------------- Menu drawing
-- Draw menu item.
-- Рисование пункта меню.
function TMenu:DrawMenuItem (Rect, Row, Col)
  local self = self
  local Index = self:CellIndex(Row, Col)
  --if not Index or Index <= 0 then return end

  if Index and Index > 0 then -- Текст пункта меню:
    -- Определение цвета текста для пункта.
    local Item = self.List[Index]
    local Selected = self.SelIndex ~= nil and self.SelIndex == Index
    local Color = ItemTextColor(Item, Selected, Rect.Colors)

    if Item.separator then -- Вывод пункта-разделителя:
      return DrawSeparItemText(Rect, Color.normal, Item.text)
    end

    -- Вывод пункта (не разделителя):
    local Options = {
      Row = Row, Col = Col,         -- Координаты ячейки
      TextMax = self.TextMax[Col],  -- Макс. длина текста
      LineMax = self.LineMax[Row],  -- Макс. ширина текста
      isHot   = self.Props.isHot,   -- Признак использования горячих букв
      checked = self.Data.checked,  -- Признак отмеченных пунктов
      Props   = self.RectMenu,      -- Свойства RectMenu
    } --- Options

    return DrawItemText(Rect, Color, Item, Options)
  -- [[
  else -- Пустое место под пункт меню:
    return DrawClearItemText(Rect, Rect.Colors.Form)
  end -- if
  --]]
end ---- DrawMenuItem

-- Draw menu part with specified color.
-- Рисование части меню заданным цветом.
function TMenu:DrawMenuPart (A_Cell, A_Rect)
  local self = self
  local Data = self.Data

  local A_Cell, A_Rect = A_Cell, A_Rect
  local xLim, yLim = A_Rect.xMax, A_Rect.yMax
  local c, x = A_Cell.cMin, A_Rect.xMin -- column & x pos
  local r, y = A_Cell.rMin, A_Rect.yMin --  row   & y pos

  -- Область вывода текста пункта:
  local Rect = {
    fixed  = A_Rect.fixed,
    Colors = A_Rect.Colors,
    x = 0, y = 0,
    w = 0, h = 0,
  } ---
  local ClearColor = A_Rect.Colors.Form

  while y < yLim and r <= A_Cell.rMax do
    local h = self.RowHeight[r]
    c, x = A_Cell.cMin, A_Rect.xMin

    while x < xLim and c <= A_Cell.cMax do
      local w = self.ColWidth[c]

      Rect.x, Rect.y = x, y -- Координаты / Размеры области:
      Rect.w = Data.Cols > 1 and min2(w, xLim - x) or xLim - x -- - 1
      Rect.h = Data.Rows > 1 and min2(h, yLim - y) or yLim - y -- - 1

      --logShow({ Rect, r, c }, "Draw", 1)
      self:DrawMenuItem(Rect, r, c)
      c, x = c + 1, x + w + Data.ColSep
    end
    --logShow({ Rect, r, c, A_Rect, A_Cell }, "Draw end by x", 1)

    if x < xLim then
      Rect.x, Rect.w = x, xLim - x -- Заполнение пустоты:
      --Rect.y, Rect.h = Rect.y, Rect.h
      --logShow(Rect, "Draw Spaces by x", 1)
      DrawClearItemText(Rect, ClearColor)
    end

    r, y = r + 1, y + h + Data.RowSep
  end -- while

  if y < yLim then
    Rect.x, Rect.w = A_Rect.xMin, A_Rect.xMax - A_Rect.xMin
    Rect.y, Rect.h = y, yLim - y -- Заполнение пустоты:
    --logShow(Rect, "Draw Spaces by y", 1)
    DrawClearItemText(Rect, ClearColor)
  end -- if
  --logShow({ x, xLim }, "Values")

  return (y >= yLim or r > A_Cell.rMax) and r - 1 or r,
         (x >= xLim or c > A_Cell.cMax) and c - 1 or c
end ---- DrawMenuPart

-- Draw list of visible menu items.
-- Рисование списка видимых пунктов меню.
function TMenu:DrawMenu ()
  local self = self
  local Zone = self.Zone
  local FixRows, FixCols = self.FixedRows, self.FixedCols
  local Base, FixedColors = Zone.Base, self.Colors.Fixed
  if Base.Row == 0 or Base.Col == 0 then return end

  -- Расчёт начальной позиции вывода.
  local xMin = self.DlgRect.Left + Zone.HomeX + Zone.IndentH
  local yMin = self.DlgRect.Top  + Zone.HomeY + Zone.IndentV
  local xMax = xMin + Zone.Width  - Zone.IndentH
  local yMax = yMin + Zone.Height - Zone.IndentV
  --logShow({ xMin, xMax, yMin, yMax }, "DrawMenuList", 1)
  local xInc = FixCols.Head > 0 and FixCols.HeadLen or 0
  local yInc = FixRows.Head > 0 and FixRows.HeadLen or 0
  local xDec = FixCols.Foot > 0 and FixCols.FootLen or 0
  local yDec = FixRows.Foot > 0 and FixRows.FootLen or 0
  --logShow({ FixRows, FixCols }, "Fixed", 1)

  -- Вывод пунктов меню.

  -- Top-Left angle part:
  if FixRows.Head > 0 and FixCols.Head > 0 then
    local A_Rect = { fixed = true,        Colors = FixedColors,
                     xMin = xMin,         yMin = yMin,
                     xMax = xMin + xInc,  yMax = yMin + yInc, }
    local A_Cell = { rMin = 1,            rMax = FixRows.Head,
                     cMin = 1,            cMax = FixCols.Head, }
    self:DrawMenuPart(A_Cell, A_Rect)
  end
  -- Top catenas part:
  if FixRows.Head > 0 then
    local A_Rect = { fixed = true,        Colors = FixedColors,
                     xMin = xMin + xInc,  yMin = yMin,
                     xMax = xMax - xDec,  yMax = yMin + yInc, }
    local A_Cell = { rMin = 1,            rMax = FixRows.Head,
                     cMin = Base.Col,     cMax = FixCols.Max, }
    self:DrawMenuPart(A_Cell, A_Rect)
  end
  -- Top-Right angle part:
  if FixRows.Head > 0 and FixCols.Foot > 0 then
    local A_Rect = { fixed = true,        Colors = FixedColors,
                     xMin = xMax - xDec,  yMin = yMin,
                     xMax = xMax,         yMax = yMin + yInc, }
    local A_Cell = { rMin = 1,            rMax = FixRows.Head,
                     cMin = FixCols.Sole, cMax = FixCols.All, }
    self:DrawMenuPart(A_Cell, A_Rect)
  end
  -- Left catenas part:
  if FixCols.Head > 0 then
    local A_Rect = { fixed = true,        Colors = FixedColors,
                     xMin = xMin,         yMin = yMin + yInc,
                     xMax = xMin + xInc,  yMax = yMax - yDec, }
    local A_Cell = { rMin = Base.Row,     rMax = FixRows.Max,
                     cMin = 1,            cMax = FixCols.Head, }
    self:DrawMenuPart(A_Cell, A_Rect)
  end

  -- Scrollable items part:
  local A_Rect = { fixed = false,         Colors = self.Colors,
                   xMin = xMin + xInc,    yMin = yMin + yInc,
                   xMax = xMax - xDec,    yMax = yMax - yDec, }
  local A_Cell = { rMin = Base.Row,       rMax = FixRows.Max,
                   cMin = Base.Col,       cMax = FixCols.Max, }
  --logShow({ A_Cell, A_Rect }, "Usual cells")
  -- Последняя видимая из прокручиваемых ячеек:
  self.Last = RC_cell( self:DrawMenuPart(A_Cell, A_Rect) )
  --logShow(self.Last, "Last viewed cell")

  -- Right catenas part:
  if FixCols.Foot > 0 then
    local A_Rect = { fixed = true,        Colors = FixedColors,
                     xMin = xMax - xDec,  yMin = yMin + yInc,
                     xMax = xMax,         yMax = yMax - yDec, }
    local A_Cell = { rMin = Base.Row,     rMax = FixRows.Max,
                     cMin = FixCols.Sole, cMax = FixCols.All, }
    self:DrawMenuPart(A_Cell, A_Rect)
  end
  -- Bottom-Left angle part:
  if FixRows.Foot > 0 and FixCols.Head > 0 then
    local A_Rect = { fixed = true,        Colors = FixedColors,
                     xMin = xMin,         yMin = yMax - yDec,
                     xMax = xMin + xInc,  yMax = yMax, }
    local A_Cell = { rMin = FixRows.Sole, rMax = FixRows.All,
                     cMin = 1,            cMax = FixCols.Head, }
    self:DrawMenuPart(A_Cell, A_Rect)
  end
  -- Bottom catenas part:
  if FixRows.Foot > 0 then
    local A_Rect = { fixed = true,        Colors = FixedColors,
                     xMin = xMin + xInc,  yMin = yMax - yDec,
                     xMax = xMax - xDec,  yMax = yMax, }
    local A_Cell = { rMin = FixRows.Sole, rMax = FixRows.All,
                     cMin = Base.Col,     cMax = FixCols.Max, }
    self:DrawMenuPart(A_Cell, A_Rect)
  end
  -- Bottom-Right angle part:
  if FixRows.Foot > 0 and FixCols.Foot > 0 then
    local A_Rect = { fixed = true,        Colors = FixedColors,
                     xMin = xMax - xDec, yMin = yMax - yDec,
                     xMax = xMax,        yMax = yMax, }
    local A_Cell = { rMin = FixRows.Sole, rMax = FixRows.All,
                     cMin = FixCols.Sole, cMax = FixCols.All, }
    self:DrawMenuPart(A_Cell, A_Rect)
  end
end ---- DrawMenu

-- Рисование линии с текстом внутри.
local function DrawTitleLine (X, Y, TitleColor, Title, Color, Line, Show)
  if Title == "" then
    return Show(X, Y, Color, Line) -- Только линия
  end

  -- Линия с текстом:
  local Len, Space = Title:len(), 2
  local TextLen, Width = Len + Space, Line:len()
  local Delta = Width - TextLen

  if Delta < 0 then
    -- Поправка на слишком длинный текст:
    Delta = 0
    TextLen = Width - Delta

    Title = TextLen > Space and Title:sub(1, TextLen - Space) or ""
    if Title == "" then
      return Show(X, Y, Color, Line) -- Только линия
    end
  end
  Delta = bshr(Delta, 1)
  --logShow({ Title, X, Y, Len, TextLen, Width, Delta, Width - Delta - TextLen })

  Show(X, Y, Color, Line:sub(1, Delta))
  Show(X + Delta, Y, TitleColor, (" %s "):format(Title))
  Show(X + Delta + TextLen, Y,
       Color, Line:sub(1, Width - Delta - TextLen))
end -- DrawTitleLine

  local SymsBoxChars = uChars.BoxChars

-- Рисование рамки вокруг меню.
function TMenu:DrawBorderLine () -- --| Border
  local self = self

  local Color, Colors = self.Colors.Border, self.Colors.Borders
  local BoxChars = SymsBoxChars[self.RectMenu.BoxKind]

  local Zone, DlgRect = self.Zone, self.DlgRect
  --local BoxGage = Zone.BoxGage
  local X1 = DlgRect.Left + Zone.HomeX - Zone.BoxGage
  local Y1 = DlgRect.Top  + Zone.HomeY - Zone.BoxGage
  local X2 = DlgRect.Left + Zone.HomeX + Zone.BoxWidth
  local Y2 = DlgRect.Top  + Zone.HomeY + Zone.BoxHeight
  local W, H = X2 - X1 - 1, Y2 - Y1 - 1
  --logShow({ X1, Y1, X2, Y2, W, H }, "DrawBorderLine")

  local Titles = self.Titles
  local LineH = BoxChars.H:rep(W)
  local LineV = BoxChars.V:rep(H)
  HText(X1, Y1, Colors.TL or Color, BoxChars.TL)
  DrawTitleLine(X1 + 1, Y1, Colors.Top or Color, Titles.Top,
                            Colors.Top or Color, LineH, HText)
  HText(X2, Y1, Colors.TR or Color, BoxChars.TR)
  DrawTitleLine(Y1 + 1, X1, Colors.Left or Color, Titles.Left,
                            Colors.Left or Color, LineV, YText)
  if not Zone.BoxScrollV then
    DrawTitleLine(Y1 + 1, X2, Colors.Right or Color, Titles.Right,
                              Colors.Right or Color, LineV, YText)
  end
  HText(X1, Y2, Colors.BL or Color, BoxChars.BL)
  if not Zone.BoxScrollH then
    DrawTitleLine(X1 + 1, Y2, Colors.Bottom or Color, Titles.Bottom,
                              Colors.Bottom or Color, LineH, HText)
  end
  HText(X2, Y2, Colors.BR or Color, BoxChars.BR)
end ---- DrawBorderLine

-- Информация о полосах прокрутки меню.
function TMenu:CalcScrollBars () --| ScrollBars
  local self = self
  local Zone, DlgRect = self.Zone, self.DlgRect

  -- Расчёт параметров прокруток.
  local SH = { -- Горизонтальная прокрутка:
    X1 = DlgRect.Left + Zone.HomeX,
    Y1 = DlgRect.Top  + Zone.LastY + 1,
    X2 = 0, Y2 = 0,
    Length = Zone.Width  - 2, -- За вычетом стрелок
    --Length = Zone.MenuWidth  - 2, -- За вычетом стрелок
  } --- SH
  SH.X2, SH.Y2 = SH.X1 + SH.Length + 1, SH.Y1

  local SV = { -- Вертикальная прокрутка:
    X1 = DlgRect.Left + Zone.LastX + 1,
    Y1 = DlgRect.Top  + Zone.HomeY,
    X2 = 0, Y2 = 0,
    Length = Zone.Height - 2, -- За вычетом стрелок
    --Length = Zone.MenuHeight - 2, -- За вычетом стрелок
  } --- SV
  SV.X2, SV.Y2 = SV.X1, SV.Y1 + SV.Length + 1

  self.ScrollBars = { ScrollH = SH, ScrollV = SV, }
end ---- CalcScrollBars

-- Расчёт параметров каретки прокрутки.
local function ScrollCaret (ALen, Cat, Count) --> (Pos, Len, End)
  local Len = max2(1, divr(ALen, Count))
  local Pos = min2(divr(ALen * (Cat - 1), Count) + 1, ALen)
  --logShow({ ALen, Cat, Count, '-------', Len, Pos, Pos + Len - 1 }, "ScrollCaret")
  if Count > 1 then Len = min2(Len, ALen - Pos + 1) end

  return Pos, Len, Pos + Len - 1 -- Допустимые значения
end -- ScrollCaret

local BoxDrawings = uChars.BoxDrawings
local BlackShapes = uChars.GeometricShapes.Black

local Strap  = BoxDrawings.ShadeL:rep(255) -- Линия: полоса прокрутки
local Caret  = BoxDrawings.ShadeD:rep(255) -- Линия: каретка прокрутки
--local Strap  = BlackShapes.Square:rep(255) -- Линия: полоса прокрутки
--local Caret  = BlackShapes.SquareN:rep(255) -- Линия: каретка прокрутки
local ArrowL = BlackShapes.Tri_L -- Стрелки: влево
local ArrowR = BlackShapes.Tri_R -- Стрелки: вправо
local ArrowU = BlackShapes.Tri_U -- Стрелки: вверх
local ArrowD = BlackShapes.Tri_D -- Стрелки: вниз
local ArrowX = BlackShapes.Romb  -- Стрелки: пересечение полос
--local ArrowX = BlackShapes.Circle-- Стрелки: пересечение полос
--local ArrowX = BoxDrawings.ShadeL-- Стрелки: пересечение полос

-- Формирование рисунка полосы прокрутки.
local function ScrollBar (Bar) --> (string)
  local Head, Tail = Bar.Pos - 1, Bar.Length - Bar.End
  return ((Head > 0) and Strap:sub(1, Head) or "")..
         Caret:sub(1, Bar.Len)..
         ((Tail > 0) and Strap:sub(1, Tail) or "")
end -- ScrollBar

-- Рисование полос прокрутки меню.
function TMenu:DrawScrollBars ()
  local self = self
  local Zone = self.Zone

  -- Проверка необходимости полосы прокрутки.
  if not Zone.ScrolledH and not Zone.ScrolledV then return end
  local Cell = RC_cell(Idx2Cell(self.SelIndex, self.Data)) -- Текущая ячейка
  --logShow({ Zone, Cell }, "Zone and Cell", 1)

  -- Сведения о полосах прокрутки меню.
  self:CalcScrollBars()
  --logShow(self.ScrollBars, "self.ScrollBars")

  local Bars, Color = self.ScrollBars, self.Colors.ScrollBar

  -- Вывод горизонтальной прокрутки:
  if Zone.ScrolledH then
    local Bar, Fixes = Bars.ScrollH, self.FixedCols
    -- Позиция и длина каретки.
    Bar.Pos, Bar.Len, Bar.End = ScrollCaret(Bar.Length,
                                            Cell.Col - Fixes.Head,
                                            Fixes.Alter)
    -- Рисунок полосы прокрутки (+ стрелки).
    HText(Bar.X1, Bar.Y1, Color, ArrowL..ScrollBar(Bar)..ArrowR)
  end

  -- Вывод вертикальной прокрутки:
  if Zone.ScrolledV then
    local Bar, Fixes = Bars.ScrollV, self.FixedRows
    -- Позиция и длина каретки.
    Bar.Pos, Bar.Len, Bar.End = ScrollCaret(Bar.Length,
                                            Cell.Row - Fixes.Head,
                                            Fixes.Alter)
    --logShow(SV, "DrawScrollBarV")
    -- Рисунок полосы прокрутки (+ стрелки).
    VText(Bar.X1, Bar.Y1, Color, ArrowU..ScrollBar(Bar)..ArrowD)
  end

  if Zone.ScrolledH and Zone.ScrolledV then -- "Пересечение":
    HText(Bars.ScrollH.X2 + 1, Bars.ScrollV.Y2 + 1, Color, ArrowX)
  end
end ---- DrawScrollBars

function TMenu:DrawStatusBar ()
  local self = self
  local Zone = self.Zone
  if Zone.EdgeB < 1 then return end

  local DlgRect = self.DlgRect
  self.StatusBar = {
    x = DlgRect.Left + Zone.HomeX,
    y = DlgRect.Top  + Zone.HomeY + Zone.BoxHeight + Zone.BoxGage,
    h = 1,
    --h = Zone.EdgeB,
    w = Zone.Width,
  }
  --logShow({ self.StatusBar, DlgRect }, "DrawStatusBar")

  -- Подсказка пункта меню:
  local Index = self.SelIndex
  local Hint = Index and Index > 0 and self.List[Index].Hint or ""

  return DrawLineText(self.StatusBar, self.Colors.StatusBar, Hint)
end ---- DrawStatusBar

function TMenu:DrawZoneEdges ()
  local self = self
  local Zone, RM = self.Zone, self.RectMenu

  local Texts  = RM.Edges.Texts  or Null
  local Colors = RM.Edges.Colors or Null
  local Color = self.Colors.StatusBar
  local Item = self.SelIndex and self.List[self.SelIndex]

  local DlgRect = self.DlgRect

  if Texts.TL then
    local Rect = {
      x = DlgRect.Left,
      y = DlgRect.Top,
      h = Zone.EdgeT,
      w = Zone.EdgeL,
    }
    --logShow(Rect, "DrawZoneEdges: TL")
    DrawRectText(Rect, Colors.TL or Color, Texts.TL, Item, self)
  end

  if Texts.Top then
    local Rect = {
      x = DlgRect.Left + Zone.EdgeL,
      y = DlgRect.Top,
      h = Zone.EdgeT,
      w = Zone.BoxWidth,
    }
    --logShow(Rect, "DrawZoneEdges: Top")
    DrawRectText(Rect, Colors.Top or Color, Texts.Top, Item, self)
  end

  if Texts.TR then
    local Rect = {
      x = DlgRect.Left + Zone.HomeX + Zone.BoxWidth  + Zone.BoxGage,
      y = DlgRect.Top,
      h = Zone.EdgeT,
      w = Zone.EdgeR,
    }
    --logShow(Rect, "DrawZoneEdges: TR")
    DrawRectText(Rect, Colors.TR or Color, Texts.TR, Item, self)
  end

  if Texts.Left then
    local Rect = {
      x = DlgRect.Left,
      y = DlgRect.Top + Zone.EdgeT,
      h = Zone.BoxHeight,
      w = Zone.EdgeL,
    }
    --logShow(Rect, "DrawZoneEdges: Left")
    DrawRectText(Rect, Colors.Left or Color, Texts.Left, Item, self)
  end

  if Texts.Right then
    local Rect = {
      x = DlgRect.Left + Zone.HomeX + Zone.BoxWidth  + Zone.BoxGage,
      y = DlgRect.Top + Zone.EdgeT,
      h = Zone.BoxHeight,
      w = Zone.EdgeR,
    }
    --logShow(Rect, "DrawZoneEdges: Right")
    DrawRectText(Rect, Colors.Right or Color, Texts.Right, Item, self)
  end

  if Texts.BL then
    local Rect = {
      x = DlgRect.Left,
      y = DlgRect.Top  + Zone.HomeY + Zone.BoxHeight + Zone.BoxGage,
      h = Zone.EdgeB,
      w = Zone.EdgeL,
    }
    --logShow(Rect, "DrawZoneEdges: BL")
    DrawRectText(Rect, Colors.BL or Color, Texts.BL, Item, self)
  end

  if Texts.Bottom then
    local Rect = {
      x = DlgRect.Left + Zone.EdgeL,
      y = DlgRect.Top  + Zone.HomeY + Zone.BoxHeight + Zone.BoxGage,
      h = Zone.EdgeB,
      w = Zone.BoxWidth,
    }
    --logShow(Rect, "DrawZoneEdges: Bottom")
    DrawRectText(Rect, Colors.Bottom or Color, Texts.Bottom, Item, self)
  end

  if Texts.BR then
    local Rect = {
      x = DlgRect.Left + Zone.HomeX + Zone.BoxWidth  + Zone.BoxGage,
      y = DlgRect.Top  + Zone.HomeY + Zone.BoxHeight + Zone.BoxGage,
      h = Zone.EdgeB,
      w = Zone.EdgeR,
    }
    --logShow(Rect, "DrawZoneEdges: BR")
    DrawRectText(Rect, Colors.BR or Color, Texts.BR, Item, self)
  end
end ---- DrawZoneEdges

function TMenu:DoUserDraw ()
  local self = self
  local RunEvent = self.RectMenu.OnDrawMenu
  if not RunEvent then return end

  return RunEvent(self)
end ---- DoUserDraw

function TMenu:DrawDebugInfo ()
  local self = self
  local Color = self.Colors.Debug

  local function DbgText (x, y, text)
    HText(x, y, Color, text)
  end --

  local DlgRect = self.DlgRect
  local X, Y = DlgRect.Left, DlgRect.Top

  local function DbgDraw (x, y, text)
    HText(X + x, Y + y, Color, text)
  end --

  local Zone = self.Zone
  DbgDraw(0, 0, "○")
  DbgDraw(Zone.DlgWidth - 1, Zone.DlgHeight - 1, "●")

  DbgDraw(Zone.HomeX, Zone.HomeY, "H")
  DbgDraw(Zone.LastX, Zone.LastY, "L")

  local Bar = self.StatusBar
  if Bar then
    DbgText(Bar.x, Bar.y, "⟨")
    DbgText(Bar.x + Bar.w - 1, Bar.y + Bar.h - 1, "⟩")
  end

  if self.DebugClickChar then
    DbgDraw(Zone.HomeX - 1, Zone.HomeY - 1, self.DebugClickChar)
  end
end ---- DrawDebugInfo

-- Обработчик рисования меню.
function TMenu:DoMenuDraw (DlgRect)
  local self = self

  --logShow(DlgRect, "DoMenuDraw")
  if DlgRect then
    self.DlgRect = DlgRect
  end

  self:DrawMenu() -- Видимые пункты меню

  local Zone, RM = self.Zone, self.RectMenu

  --self:DrawSeparators() -- Разделители пунктов

  if Zone.BoxGage > 0 then
    self:DrawBorderLine() -- Рамка вокруг меню
  end

  if Zone.ScrolledH or Zone.ScrolledV then
    self:DrawScrollBars() -- Полосы прокрутки
  end

  if RM.IsStatusBar then
    self:DrawStatusBar() -- Статусная строка
  end

  if RM.IsDrawEdges then
    self:DrawZoneEdges() -- Рисование отступов
  end

  if RM.IsUserDraw then
    self:DoUserDraw() -- Пользовательское рисование
  end

  if RM.IsDebugDraw then
    self:DrawDebugInfo() -- Отладочные сведения
  end

  return true
end ---- DoMenuDraw

---------------------------------------- main
local function Menu (Properties, Items, BreakKeys, ShowMenu) --> (Item, Pos)
  if not Items then return end
  --logShow(BreakKeys, "BreakKeys", 2)

--[[ 1. Конфигурирование меню ]]

  local Additions = { FarArea = farUt.GetBasicAreaType() }
  local _Menu = TMenu:isMenu(ShowMenu) and ShowMenu or
                CreateMenu(Properties, Items, BreakKeys, Additions)
  --logShow(_Menu, "_Menu", 1)

  -- Определение вида меню:
  _Menu:DefineAll()
  --logShow(_Menu, "_Menu", "d1 t")

--[[ 2. Управление диалогом ]]
  --local PosX, PosY -- TODO: for mouse

  -- ОБРАБОТЧИКИ УСТАНОВКИ ЦВЕТОВ:
  -- Установка цветов как у меню.
  local function DlgGetCtlColor (hDlg) --> (Color)
    return _Menu.Colors.Form -- Цвет окна
  end
  local function DlgGetBoxColor (hDlg) --> (Color)
    return _Menu.Colors.DlgBox -- Цвет рамки и текста на рамке
  end

--[[ 2.1. Рисование меню в диалоге ]]

  -- Обработка рисования меню:
  local function DlgItemDraw (hDlg, ProcItem, DlgItem) --> (bool)
    local Form = _Menu.Form
    if not Form then return end

    return _Menu:DoMenuDraw(GetRect(hDlg))
  end -- DlgItemDraw

--[[ 2.2. Обработка реакции меню ]] --> AssignEvents

  --local NoDlgClose -- Нет выбора пункта меню для спец. действий.
  local InputRecordToName = (require "far2.keynames").InputRecordToName

  -- Обработка управления клавиатурой.
  local function DlgKeyInput (hDlg, ProcItem, Input) --> (bool)
    --logShow(_Menu, "_Menu", "d1 bns")

    --logShow(Input, ProcItem, "d1 x8")
    local StrKey = InputRecordToName(Input) or ""
    Input.Name = StrKey
    Input.StateName, Input.KeyName = ParseKeyName(StrKey)
    if Input.KeyName == "" and Input.StrName then
      Input.KeyName = Input.StrName
    end
    --logShow(Input, StrKey, "d1 x8")

    -- 1. Обработка специальных нажатий.
    if StrKey == "F1" then -- Получение помощи:
      return farUt.ShowHelpTopic(_Menu.Props.HelpTopic)
    end
    if StrKey == "Esc" then return end -- Отмена
    if StrKey == "Enter" or StrKey == "NumEnter" then -- Выбор пункта:
      return _Menu:DefaultChooseItem(hDlg, "Enter")
    end

    -- 2. Обработка обычных нажатий.
    return _Menu:DoKeyPress(hDlg, Input)
  end -- DlgKeyInput

  local MouseLeftBtn    = F.FROM_LEFT_1ST_BUTTON_PRESSED
  local MouseClickDbl   = F.DOUBLE_CLICK
  local MouseMoved      = F.MOUSE_MOVED
  local MouseWheeledV   = F.MOUSE_WHEELED
  local MouseWheeledH   = F.MOUSE_HWHEELED or 0x8 -- FIX

  -- Обработка прокрутки мышью.
  local function DlgMouseWheel (hDlg, ProcItem, Input) --> (bool)
    local Input = Input

    local Delta = bshr(Input.ButtonState, 16)
    if Delta >= 0x8000 then Delta = Delta - 0x10000 end

    if     Input.EventFlags == MouseWheeledV then
      --logShow({ Delta, Input }, ProcItem, "d3")
      Input.StrName = Delta >= 0 and "MSWheelUp" or "MSWheelDown"
    elseif Input.EventFlags == MouseWheeledH then
      --logShow(Input, ProcItem, "d3 x1")
      Input.StrName = Delta >= 0 and "MSWheelRight" or "MSWheelLeft"
    else
      return false
    end

    Input.EventType = F.KEY_EVENT
    Input.VirtualKeyCode = 0x00
    Input.UnicodeChar = ""

    return DlgKeyInput(hDlg, ProcItem, Input)
  end -- DlgMouseWheel

  -- Обработка управления мышью.
  local function DlgMouseInput (hDlg, ProcItem, Input) --> (bool)

    if ProcItem == -1 then return false end

    --logShow({ MouseClickDbl, MouseMoved, '-',
    --          MouseWheeledV, MouseWheeledH, '-', }, ProcItem, 3)

    local Input = Input
    --logShow(Input, ProcItem, 3)
    --if not Input.X then logShow(Input, ProcItem, 3) end

    if Input.ButtonState == MouseLeftBtn then
      local Zone = _Menu.Zone
      local x, y = Input.MousePositionX, Input.MousePositionY
      --logShow({ x, y, Zone = Zone, Input = Input, }, ProcItem, 3)
      Input.x = x
      Input.y = y
      Input.X = Input.X or _Menu.DlgRect.Left + Zone.HomeX + x
      Input.Y = Input.Y or _Menu.DlgRect.Top  + Zone.HomeY + y

      -- Обработка прокрутки мышью.
      if Zone.ScrolledH and y == Zone.Height and
         x >= 0         and x <  Zone.Width then
        --logShow({ x, y, Zone = Zone, }, "H", 3)
        return _Menu:ScrollHClick(hDlg, Input)
      end
      if Zone.ScrolledV and x == Zone.Width and
         y >= 0         and y <  Zone.Height then
        --logShow({ x, y, Zone = Zone }, "V", 3)
        return _Menu:ScrollVClick(hDlg, Input)
      end
      if Zone.ScrolledH and y == Zone.Height and
         Zone.ScrolledV and x == Zone.Width then
        --logShow({ x, y, Zone = Zone, }, "C", 3)
        return _Menu:ScrollXClick(hDlg, Input) -- "Пересечение"
      end

      -- Обработка областей вне меню.
      if x < 0 or
         y < 0 or
         x >= Zone.BoxWidth or
         y >= Zone.BoxHeight then

        if Zone.BoxGage > 0 then -- Рамка
          if (x == -1 or  x == Zone.BoxWidth ) and
             (y >= -1 and y <= Zone.BoxHeight) or
             (y == -1 or  y == Zone.BoxHeight) and
             (x >= -1 and x <= Zone.BoxWidth ) then
            return _Menu:MouseBorderClick(hDlg, Input)
          end
        end

        return _Menu:MouseEdgeClick(hDlg, Input) -- Край
      end

      -- Обработка выбором мышью.
      if Input.EventFlags == MouseClickDbl then
        return _Menu:MouseDblClick(hDlg, Input)
      else
        return _Menu:MouseBtnClick(hDlg, Input)
      end
    end -- if

    return false
  end -- DlgMouseInput

  -- Обработка управления клавиатурой и мышью.
  local function DlgCtrlInput (hDlg, ProcItem, Input) --> (bool)

    --logShow(Input, "Event", "d1 x8")
    local EventType = Input.EventType

    if EventType == F.KEY_EVENT or
       EventType == F.FARMACRO_KEY_EVENT then
      return DlgKeyInput(hDlg, ProcItem, Input)
    end

    if EventType == F.MOUSE_EVENT then
      if Input.EventFlags == MouseWheeledV or
         Input.EventFlags == MouseWheeledH then
        return DlgMouseWheel(hDlg, ProcItem, Input) -- FIX
      end

      if not _Menu.RectMenu.DoMouseEvent and
         Input.ButtonState == MouseLeftBtn then
        return DlgMouseInput(hDlg, ProcItem, Input)
      end
    end

    return false
  end -- DlgCtrlInput

  -- Предобработка управления мышью.
  local function DlgPredInput (hDlg, ProcItem, Input) --> (bool)
    local Input = Input
    --logShow(Input, ProcItem, 3)

    if Input.EventFlags == MouseMoved then return true end

    local Zone = _Menu.Zone
    local DlgRect = GetRect(hDlg)
    local x, y = Input.MousePositionX, Input.MousePositionY
    Input.X = x
    Input.Y = y
    Input.MousePositionX = x - DlgRect.Left - Zone.HomeX
    Input.MousePositionY = y - DlgRect.Top  - Zone.HomeY

    if Input.EventFlags == MouseWheeledV or
       Input.EventFlags == MouseWheeledH then
      --logShow(Input, ProcItem, 3)
      return not DlgMouseWheel(hDlg, ProcItem, Input)
    end

    if Input.ButtonState == MouseLeftBtn then
      --logShow({ Input, Zone }, ProcItem, 2)
      return not DlgMouseInput(hDlg, ProcItem, Input)
    end
    --logShow({ Input, Zone }, ProcItem, 2)

    return true
  end -- DlgPredInput

  -- Инициализация обработки.
  local function DlgInit (hDlg, ProcItem, NoUse) --> (bool)
    if _Menu.RectMenu.DoMouseEvent then -- TODO: --> doc!
      SendDlgMessage(hDlg, F.DM_SETMOUSEEVENTNOTIFY, 1, 0)
    end

    return true
  end -- DlgInit

  --[[
  local function DlgClose (hDlg, ProcItem, NoUse) --> (bool)
    -- Закрытие только при правильном выборе пункта меню:
    if NoDlgClose then NoDlgClose = false; return false else return true end
  end --
  --]]

  -- Ссылки на обработчики событий:
  local Procs = {
    [F.DN_INITDIALOG] = DlgInit,
    --[F.DN_CLOSE] = DlgClose,

    [F.DN_INPUT]        = DlgPredInput,
    [F.DN_CONTROLINPUT] = DlgCtrlInput,

    [F.DN_CTLCOLORDIALOG]  = DlgGetCtlColor,
    [F.DN_CTLCOLORDLGITEM] = DlgGetBoxColor,

    [F.DN_DRAWDLGITEM] = DlgItemDraw,
  } --- Procs

  -- Обработчик событий.
  local function DlgProc (hDlg, msg, param1, param2)
    return Procs[msg] and Procs[msg](hDlg, param1, param2) or nil
  end --

  if useprofiler then profiler.stop() end

  if TMenu:isShow(ShowMenu) then
    return _Menu:Show(DlgProc) -- Отображение окна диалога меню
  end

  return _Menu -- Возврат самого меню
end -- Menu

--------------------------------------------------------------------------------
return Menu
--------------------------------------------------------------------------------
